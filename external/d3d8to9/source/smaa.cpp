#include "d3dx9.hpp"
#include "smaa.hpp"
#include "ini.hpp"

#include <fstream>

#ifndef D3D8TO9NOLOG
extern std::ofstream LOG;
#define SMAA_LOG(Message) do { LOG << "> SMAA: " << Message << std::endl; } while (false)
#else
#define SMAA_LOG(Message) do { } while (false)
#endif

namespace
{
	bool Enabled = false;
	bool Configured = false;
	bool InitFailed = false;
	bool FrameDirty = true;

	IDirect3DTexture9 *SceneCopy = nullptr;   // DEFAULT, backbuffer format
	IDirect3DTexture9 *EdgesTex = nullptr;    // DEFAULT, A8R8G8B8
	IDirect3DTexture9 *BlendTex = nullptr;    // DEFAULT, A8R8G8B8
	IDirect3DTexture9 *AreaTex = nullptr;     // MANAGED, survives a Reset
	IDirect3DTexture9 *SearchTex = nullptr;   // MANAGED, survives a Reset
	IDirect3DPixelShader9  *PS[3] = {};
	IDirect3DVertexShader9 *VS[3] = {};
	IDirect3DVertexDeclaration9 *VertexDecl = nullptr;
	IDirect3DStateBlock9 *StateBlock = nullptr;

	UINT PostWidth = 0, PostHeight = 0;

	void ReleaseDefaultPoolResources()
	{
		if (SceneCopy != nullptr)
		{
			SceneCopy->Release();
			SceneCopy = nullptr;
		}
		if (EdgesTex != nullptr)
		{
			EdgesTex->Release();
			EdgesTex = nullptr;
		}
		if (BlendTex != nullptr)
		{
			BlendTex->Release();
			BlendTex = nullptr;
		}
		if (StateBlock != nullptr)
		{
			StateBlock->Release();
			StateBlock = nullptr;
		}

		PostWidth = PostHeight = 0;
	}

	void ReleaseResources()
	{
		ReleaseDefaultPoolResources();

		if (AreaTex != nullptr)
		{
			AreaTex->Release();
			AreaTex = nullptr;
		}
		if (SearchTex != nullptr)
		{
			SearchTex->Release();
			SearchTex = nullptr;
		}
		for (IDirect3DPixelShader9 *&Shader : PS)
		{
			if (Shader != nullptr)
			{
				Shader->Release();
				Shader = nullptr;
			}
		}
		for (IDirect3DVertexShader9 *&Shader : VS)
		{
			if (Shader != nullptr)
			{
				Shader->Release();
				Shader = nullptr;
			}
		}
		if (VertexDecl != nullptr)
		{
			VertexDecl->Release();
			VertexDecl = nullptr;
		}
	}

	bool EnsureResources(IDirect3DDevice9 *Device, UINT Width, UINT Height, D3DFORMAT BackBufferFormat)
	{
		// A windowed resize without a Reset: rebuild the size-dependent set, keep the shaders
		// and the lookup textures
		if (PostWidth != 0 && (PostWidth != Width || PostHeight != Height))
			ReleaseDefaultPoolResources();

		// Missing D3DX entry points and a device below shader model 3.0 are both permanent.
		// 'ConvertCaps' pins the game-visible versions at ps_1_4 / vs_1_1, so this has to ask
		// the proxy for the real ones
		if (PS[0] == nullptr)
		{
			D3DCAPS9 Caps = {};
			if (D3DXCompileShader == nullptr || D3DXCreateTextureFromFileInMemoryEx == nullptr ||
				FAILED(Device->GetDeviceCaps(&Caps)) ||
				Caps.PixelShaderVersion < D3DPS_VERSION(3, 0) || Caps.VertexShaderVersion < D3DVS_VERSION(3, 0))
			{
				SMAA_LOG("unsupported: needs D3DX and shader model 3.0");
				InitFailed = true;
				return false;
			}
		}

		// One-time: the three pass shader pairs, compiled from the embedded SMAA source. All
		// configuration is baked into that text, so no macros and no flags
		if (PS[0] == nullptr || VS[0] == nullptr)
		{
			static const char *const PSEntries[3] = { "DX9_SMAALumaEdgeDetectionPS", "DX9_SMAABlendingWeightCalculationPS", "DX9_SMAANeighborhoodBlendingPS" };
			static const char *const VSEntries[3] = { "DX9_SMAAEdgeDetectionVS", "DX9_SMAABlendingWeightCalculationVS", "DX9_SMAANeighborhoodBlendingVS" };

			for (int i = 0; i < 3; ++i)
			{
				for (int IsVS = 0; IsVS < 2; ++IsVS)
				{
					LPD3DXBUFFER Bytecode = nullptr, Errors = nullptr;
					HRESULT hr = D3DXCompileShader(reinterpret_cast<const char *>(SMAA_HLSL), SMAA_HLSL_len,
						nullptr, nullptr, IsVS ? VSEntries[i] : PSEntries[i], IsVS ? "vs_3_0" : "ps_3_0",
						0, &Bytecode, &Errors, nullptr);

					if (SUCCEEDED(hr) && Bytecode != nullptr)
					{
						hr = IsVS
							? Device->CreateVertexShader(static_cast<const DWORD *>(Bytecode->GetBufferPointer()), &VS[i])
							: Device->CreatePixelShader(static_cast<const DWORD *>(Bytecode->GetBufferPointer()), &PS[i]);
					}

					if (FAILED(hr) || (IsVS ? static_cast<void *>(VS[i]) : static_cast<void *>(PS[i])) == nullptr)
					{
						SMAA_LOG("shader " << (IsVS ? VSEntries[i] : PSEntries[i]) << " failed, hr " << hr);
						InitFailed = true;
					}

					if (Bytecode != nullptr)
						Bytecode->Release();
					if (Errors != nullptr)
						Errors->Release();

					if (InitFailed)
					{
						ReleaseResources(); // drop the half-built set
						return false;
					}
				}
			}
		}

		// One-time: the fullscreen-quad declaration. The DX9_*VS entries pass POSITION straight
		// through, so what goes in here is already clip space
		if (VertexDecl == nullptr)
		{
			static const D3DVERTEXELEMENT9 DeclElements[] =
			{
				{ 0, 0,  D3DDECLTYPE_FLOAT3, D3DDECLMETHOD_DEFAULT, D3DDECLUSAGE_POSITION, 0 },
				{ 0, 12, D3DDECLTYPE_FLOAT2, D3DDECLMETHOD_DEFAULT, D3DDECLUSAGE_TEXCOORD, 0 },
				D3DDECL_END()
			};

			if (FAILED(Device->CreateVertexDeclaration(DeclElements, &VertexDecl)))
				return false;
		}

		// One-time: the two precomputed lookup textures. MANAGED, so they survive a Reset; the
		// format comes from the DDS header and a failed decode is not going to start working
		if (AreaTex == nullptr &&
			FAILED(D3DXCreateTextureFromFileInMemoryEx(Device, SMAA_AREATEX_DDS, SMAA_AREATEX_DDS_len,
				160, 560, 1, 0, D3DFMT_UNKNOWN, D3DPOOL_MANAGED, D3DX_FILTER_NONE, D3DX_FILTER_NONE, 0, nullptr, nullptr, &AreaTex)))
		{
			SMAA_LOG("AreaTex decode failed");
			InitFailed = true;
			return false;
		}
		if (SearchTex == nullptr &&
			FAILED(D3DXCreateTextureFromFileInMemoryEx(Device, SMAA_SEARCHTEX_DDS, SMAA_SEARCHTEX_DDS_len,
				64, 16, 1, 0, D3DFMT_UNKNOWN, D3DPOOL_MANAGED, D3DX_FILTER_NONE, D3DX_FILTER_NONE, 0, nullptr, nullptr, &SearchTex)))
		{
			SMAA_LOG("SearchTex decode failed");
			InitFailed = true;
			return false;
		}

		// Per-size: the scene copy matches the backbuffer format so the StretchRect into it is a
		// plain copy; SMAA wants RGBA for the two intermediates. All DEFAULT pool, so a failure
		// here is transient and worth retrying on the next Present
		if (SceneCopy == nullptr &&
			FAILED(Device->CreateTexture(Width, Height, 1, D3DUSAGE_RENDERTARGET, BackBufferFormat, D3DPOOL_DEFAULT, &SceneCopy, nullptr)))
			return false;
		if (EdgesTex == nullptr &&
			FAILED(Device->CreateTexture(Width, Height, 1, D3DUSAGE_RENDERTARGET, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, &EdgesTex, nullptr)))
			return false;
		if (BlendTex == nullptr &&
			FAILED(Device->CreateTexture(Width, Height, 1, D3DUSAGE_RENDERTARGET, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, &BlendTex, nullptr)))
			return false;

		// Per-device-generation: the save and restore block, released before a Reset like the
		// DEFAULT-pool textures
		if (StateBlock == nullptr &&
			FAILED(Device->CreateStateBlock(D3DSBT_ALL, &StateBlock)))
			return false;

		if (PostWidth != Width || PostHeight != Height)
			SMAA_LOG("running at " << Width << "x" << Height);

		PostWidth = Width;
		PostHeight = Height;

		return true;
	}

	void ApplyInvariantState(IDirect3DDevice9 *Device, UINT Width, UINT Height)
	{
		Device->SetRenderState(D3DRS_ALPHABLENDENABLE, FALSE);
		Device->SetRenderState(D3DRS_ALPHATESTENABLE, FALSE);
		Device->SetRenderState(D3DRS_ZENABLE, D3DZB_FALSE);
		Device->SetRenderState(D3DRS_ZWRITEENABLE, FALSE);
		Device->SetRenderState(D3DRS_STENCILENABLE, FALSE);
		Device->SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
		Device->SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID);
		Device->SetRenderState(D3DRS_COLORWRITEENABLE, 0x0000000F);
		Device->SetRenderState(D3DRS_FOGENABLE, FALSE);
		Device->SetRenderState(D3DRS_SCISSORTESTENABLE, FALSE);
		Device->SetRenderState(D3DRS_CLIPPLANEENABLE, 0);
		Device->SetRenderState(D3DRS_SRGBWRITEENABLE, 0); // the pipeline is not sRGB-managed

		// A cylindrical wrap flag would corrupt the interpolated offsets, and TEXCOORD0..4 are
		// all in use across the three passes
		for (DWORD i = 0; i < 5; ++i)
			Device->SetRenderState(static_cast<D3DRENDERSTATETYPE>(D3DRS_WRAP0 + i), 0);

		Device->SetVertexDeclaration(VertexDecl);

		// SMAA_RT_METRICS sits at c44 in both stages: the shader declares globalScreenSize as
		// (w, h, 1/w, 1/h) and reads it back as .zwxy
		const float Metrics[4] =
		{
			static_cast<float>(Width),
			static_cast<float>(Height),
			1.0f / static_cast<float>(Width),
			1.0f / static_cast<float>(Height)
		};
		Device->SetVertexShaderConstantF(44, Metrics, 1);
		Device->SetPixelShaderConstantF(44, Metrics, 1);

		// s0 scene, s1 edges, s2 area, s3 search, s4 blend. Search is the one point-sampled
		// stage; nothing here has mips
		for (DWORD s = 0; s <= 4; ++s)
		{
			const DWORD Filter = (s == 3) ? D3DTEXF_POINT : D3DTEXF_LINEAR;
			Device->SetSamplerState(s, D3DSAMP_MINFILTER, Filter);
			Device->SetSamplerState(s, D3DSAMP_MAGFILTER, Filter);
			Device->SetSamplerState(s, D3DSAMP_MIPFILTER, D3DTEXF_NONE);
			Device->SetSamplerState(s, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
			Device->SetSamplerState(s, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);
			Device->SetSamplerState(s, D3DSAMP_SRGBTEXTURE, 0);
		}
	}

	void Apply(IDirect3DDevice9 *Device)
	{
		// Never create resources or draw on an unhealthy device: every CreateTexture would fail
		// and a transient failure would start looking permanent
		if (Device->TestCooperativeLevel() != D3D_OK)
			return;

		IDirect3DSurface9 *BackBuffer = nullptr;
		if (FAILED(Device->GetBackBuffer(0, 0, D3DBACKBUFFER_TYPE_MONO, &BackBuffer)) || BackBuffer == nullptr)
			return;

		D3DSURFACE_DESC BBDesc;
		BackBuffer->GetDesc(&BBDesc);

		IDirect3DSurface9 *SceneSurf = nullptr, *EdgesSurf = nullptr, *BlendSurf = nullptr;
		if (EnsureResources(Device, BBDesc.Width, BBDesc.Height, BBDesc.Format))
		{
			SceneCopy->GetSurfaceLevel(0, &SceneSurf);
			EdgesTex->GetSurfaceLevel(0, &EdgesSurf);
			BlendTex->GetSurfaceLevel(0, &BlendSurf);
		}

		if (SceneSurf != nullptr && EdgesSurf != nullptr && BlendSurf != nullptr)
		{
			// A state block does not cover the render target or the depth-stencil, so those are
			// saved by hand
			IDirect3DSurface9 *SavedRT = nullptr, *SavedDS = nullptr;
			Device->GetRenderTarget(0, &SavedRT);
			Device->GetDepthStencilSurface(&SavedDS); // may legitimately be null
			StateBlock->Capture();

			// The work targets must never pair with the game's depth-stencil
			Device->SetDepthStencilSurface(nullptr);

			ApplyInvariantState(Device, BBDesc.Width, BBDesc.Height);

			// Clip-space quad with the D3D9 half-pixel offset baked in, since the DX9_*VS entries
			// pass POSITION through untouched. Texcoord v = 0 is the top of the frame
			struct SMAAVertex { float x, y, z, u, v; };
			const float ox = -1.0f / static_cast<float>(BBDesc.Width);
			const float oy = 1.0f / static_cast<float>(BBDesc.Height);
			const SMAAVertex Quad[4] =
			{
				{ -1.0f + ox,  1.0f + oy, 0.0f, 0.0f, 0.0f },
				{  1.0f + ox,  1.0f + oy, 0.0f, 1.0f, 0.0f },
				{ -1.0f + ox, -1.0f + oy, 0.0f, 0.0f, 1.0f },
				{  1.0f + ox, -1.0f + oy, 0.0f, 1.0f, 1.0f },
			};

			// Present runs outside the game's Begin/EndScene pair, and D3D9 allows more than one
			// pair per frame, so the passes get their own
			Device->BeginScene();

			if (SUCCEEDED(Device->StretchRect(BackBuffer, nullptr, SceneSurf, nullptr, D3DTEXF_NONE)))
			{
				// Edge detection, scene -> edges. Both intermediates have to be cleared every
				// frame, alpha included, which SMAA requires. SetRenderTarget resets the
				// viewport to the whole target, which is exactly what these passes want
				Device->SetRenderTarget(0, EdgesSurf);
				Device->Clear(0, nullptr, D3DCLEAR_TARGET, 0, 1.0f, 0);
				Device->SetVertexShader(VS[0]);
				Device->SetPixelShader(PS[0]);
				Device->SetTexture(0, SceneCopy);
				Device->DrawPrimitiveUP(D3DPT_TRIANGLESTRIP, 2, Quad, sizeof(SMAAVertex));

				// Blending-weight calculation, edges + area + search -> blend
				Device->SetRenderTarget(0, BlendSurf);
				Device->Clear(0, nullptr, D3DCLEAR_TARGET, 0, 1.0f, 0);
				Device->SetVertexShader(VS[1]);
				Device->SetPixelShader(PS[1]);
				Device->SetTexture(1, EdgesTex);
				Device->SetTexture(2, AreaTex);
				Device->SetTexture(3, SearchTex);
				Device->DrawPrimitiveUP(D3DPT_TRIANGLESTRIP, 2, Quad, sizeof(SMAAVertex));

				// Neighborhood blending, scene + blend -> backbuffer. Every pixel is written, so
				// there is nothing to clear
				Device->SetRenderTarget(0, BackBuffer);
				Device->SetVertexShader(VS[2]);
				Device->SetPixelShader(PS[2]);
				Device->SetTexture(0, SceneCopy);
				Device->SetTexture(4, BlendTex);
				Device->DrawPrimitiveUP(D3DPT_TRIANGLESTRIP, 2, Quad, sizeof(SMAAVertex));
			}

			Device->EndScene();

			// Render target first, then the block: 'SetRenderTarget' resets the viewport and the
			// block is what carries the game's
			Device->SetRenderTarget(0, SavedRT != nullptr ? SavedRT : BackBuffer);
			Device->SetDepthStencilSurface(SavedDS);
			StateBlock->Apply();

			if (SavedRT != nullptr)
				SavedRT->Release();
			if (SavedDS != nullptr)
				SavedDS->Release();
		}

		if (BlendSurf != nullptr)
			BlendSurf->Release();
		if (EdgesSurf != nullptr)
			EdgesSurf->Release();
		if (SceneSurf != nullptr)
			SceneSurf->Release();
		BackBuffer->Release();
	}
}

void Smaa::OnDraw()
{
	FrameDirty = true;
}

void Smaa::OnPresent(IDirect3DDevice9 *Device)
{
	if (!Configured)
	{
		Configured = true;
		Enabled = Ini::ReadInt(L"SMAA", 1) != 0;
		SMAA_LOG((Enabled ? "enabled" : "disabled"));
	}

	// Nothing drawn since the last Present means a loading screen or an idle menu presenting
	// the same finished frame in a loop, and the pass writes back into the backbuffer, so
	// re-running it would filter an already-filtered image
	if (Enabled && !InitFailed && FrameDirty)
		Apply(Device);

	FrameDirty = false;
}

void Smaa::OnDeviceLost()
{
	ReleaseDefaultPoolResources();
}

void Smaa::Shutdown()
{
	ReleaseResources();
}

DWORD Smaa::InternalDeviceRefs()
{
	DWORD Refs = 0;

	for (IDirect3DPixelShader9 *const Shader : PS)
	{
		if (Shader != nullptr)
			++Refs;
	}
	for (IDirect3DVertexShader9 *const Shader : VS)
	{
		if (Shader != nullptr)
			++Refs;
	}
	if (SceneCopy != nullptr)
		++Refs;
	if (EdgesTex != nullptr)
		++Refs;
	if (BlendTex != nullptr)
		++Refs;
	if (AreaTex != nullptr)
		++Refs;
	if (SearchTex != nullptr)
		++Refs;
	if (VertexDecl != nullptr)
		++Refs;
	if (StateBlock != nullptr)
		++Refs;

	return Refs;
}
