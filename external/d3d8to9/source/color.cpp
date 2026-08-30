#include "d3dx9.hpp"
#include "color.hpp"
#include "ini.hpp"

#include <fstream>

#ifndef D3D8TO9NOLOG
extern std::ofstream LOG;
#define COLOR_LOG(Message) do { LOG << "> COLOR: " << Message << std::endl; } while (false)
#else
#define COLOR_LOG(Message) do { } while (false)
#endif

namespace
{
	bool Enabled = false;
	bool Configured = false;
	bool InitFailed = false;
	bool FrameDirty = true;

	// Brightness, contrast and saturation, straight into c0
	float Grade[4] = { 1.0f, 1.0f, 1.0f, 0.0f };

	IDirect3DTexture9 *SceneCopy = nullptr;   // DEFAULT, backbuffer format
	IDirect3DPixelShader9  *PS = nullptr;
	IDirect3DVertexShader9 *VS = nullptr;
	IDirect3DVertexDeclaration9 *VertexDecl = nullptr;
	IDirect3DStateBlock9 *StateBlock = nullptr;

	UINT PostWidth = 0, PostHeight = 0;

	// The grade runs on the presented frame, so it is gamma space, which is what a driver
	// control panel and dgVoodoo's own sliders operate in too
	static const char Source[] =
		"struct VSOut { float4 pos : POSITION; float2 uv : TEXCOORD0; };\n"
		"VSOut ColorVS(float3 pos : POSITION, float2 uv : TEXCOORD0)\n"
		"{\n"
		"	VSOut Out;\n"
		"	Out.pos = float4(pos, 1.0);\n"
		"	Out.uv = uv;\n"
		"	return Out;\n"
		"}\n"
		"sampler2D SceneMap : register(s0);\n"
		"float3 Grade : register(c0);\n"
		"float4 ColorPS(float2 uv : TEXCOORD0) : COLOR\n"
		"{\n"
		"	float3 c = tex2D(SceneMap, uv).rgb * Grade.x;\n"
		"	c = (c - 0.5) * Grade.y + 0.5;\n"
		"	c = lerp(dot(c, float3(0.2126, 0.7152, 0.0722)), c, Grade.z);\n"
		"	return float4(saturate(c), 1.0);\n"
		"}\n";

	void ReleaseDefaultPoolResources()
	{
		if (SceneCopy != nullptr)
		{
			SceneCopy->Release();
			SceneCopy = nullptr;
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

		if (PS != nullptr)
		{
			PS->Release();
			PS = nullptr;
		}
		if (VS != nullptr)
		{
			VS->Release();
			VS = nullptr;
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
		if (PostWidth != 0 && (PostWidth != Width || PostHeight != Height))
			ReleaseDefaultPoolResources();

		// Missing D3DX entry points and a device below shader model 2.0 are both permanent.
		// 'ConvertCaps' pins the game-visible versions at ps_1_4 / vs_1_1, so this has to ask
		// the proxy for the real ones
		if (PS == nullptr)
		{
			D3DCAPS9 Caps = {};
			if (D3DXCompileShader == nullptr ||
				FAILED(Device->GetDeviceCaps(&Caps)) ||
				Caps.PixelShaderVersion < D3DPS_VERSION(2, 0) || Caps.VertexShaderVersion < D3DVS_VERSION(2, 0))
			{
				COLOR_LOG("unsupported: needs D3DX and shader model 2.0");
				InitFailed = true;
				return false;
			}
		}

		// One-time: the pass shader pair, compiled from the source above
		if (PS == nullptr || VS == nullptr)
		{
			for (int IsVS = 0; IsVS < 2; ++IsVS)
			{
				LPD3DXBUFFER Bytecode = nullptr, Errors = nullptr;
				HRESULT hr = D3DXCompileShader(Source, sizeof(Source) - 1,
					nullptr, nullptr, IsVS ? "ColorVS" : "ColorPS", IsVS ? "vs_2_0" : "ps_2_0",
					0, &Bytecode, &Errors, nullptr);

				if (SUCCEEDED(hr) && Bytecode != nullptr)
				{
					hr = IsVS
						? Device->CreateVertexShader(static_cast<const DWORD *>(Bytecode->GetBufferPointer()), &VS)
						: Device->CreatePixelShader(static_cast<const DWORD *>(Bytecode->GetBufferPointer()), &PS);
				}

				if (FAILED(hr) || (IsVS ? static_cast<void *>(VS) : static_cast<void *>(PS)) == nullptr)
				{
					COLOR_LOG((IsVS ? "vertex" : "pixel") << " shader failed, hr " << hr);
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

		// One-time: the fullscreen-quad declaration. 'ColorVS' passes POSITION straight through,
		// so what goes in here is already clip space
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

		// Per-size: the scene copy matches the backbuffer format so the StretchRect into it is a
		// plain copy. DEFAULT pool, so a failure here is transient and worth retrying on the next
		// Present
		if (SceneCopy == nullptr &&
			FAILED(Device->CreateTexture(Width, Height, 1, D3DUSAGE_RENDERTARGET, BackBufferFormat, D3DPOOL_DEFAULT, &SceneCopy, nullptr)))
			return false;

		// Per-device-generation: the save and restore block, released before a Reset like the
		// DEFAULT-pool texture
		if (StateBlock == nullptr &&
			FAILED(Device->CreateStateBlock(D3DSBT_ALL, &StateBlock)))
			return false;

		PostWidth = Width;
		PostHeight = Height;

		return true;
	}

	void ApplyInvariantState(IDirect3DDevice9 *Device)
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
		Device->SetRenderState(D3DRS_WRAP0, 0);

		Device->SetVertexDeclaration(VertexDecl);

		// The copy is 1:1, so point sampling is exact and nothing here has mips
		Device->SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_POINT);
		Device->SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_POINT);
		Device->SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_NONE);
		Device->SetSamplerState(0, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
		Device->SetSamplerState(0, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);
		Device->SetSamplerState(0, D3DSAMP_SRGBTEXTURE, 0);
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

		IDirect3DSurface9 *SceneSurf = nullptr;
		if (EnsureResources(Device, BBDesc.Width, BBDesc.Height, BBDesc.Format))
			SceneCopy->GetSurfaceLevel(0, &SceneSurf);

		if (SceneSurf != nullptr)
		{
			// A state block does not cover the render target or the depth-stencil, so those are
			// saved by hand
			IDirect3DSurface9 *SavedRT = nullptr, *SavedDS = nullptr;
			Device->GetRenderTarget(0, &SavedRT);
			Device->GetDepthStencilSurface(&SavedDS); // may legitimately be null
			StateBlock->Capture();

			Device->SetDepthStencilSurface(nullptr);

			ApplyInvariantState(Device);

			// Clip-space quad with the D3D9 half-pixel offset baked in, since 'ColorVS' passes
			// POSITION through untouched. Texcoord v = 0 is the top of the frame
			struct ColorVertex { float x, y, z, u, v; };
			const float ox = -1.0f / static_cast<float>(BBDesc.Width);
			const float oy = 1.0f / static_cast<float>(BBDesc.Height);
			const ColorVertex Quad[4] =
			{
				{ -1.0f + ox,  1.0f + oy, 0.0f, 0.0f, 0.0f },
				{  1.0f + ox,  1.0f + oy, 0.0f, 1.0f, 0.0f },
				{ -1.0f + ox, -1.0f + oy, 0.0f, 0.0f, 1.0f },
				{  1.0f + ox, -1.0f + oy, 0.0f, 1.0f, 1.0f },
			};

			// Present runs outside the game's Begin/EndScene pair, and D3D9 allows more than one
			// pair per frame, so the pass gets its own
			Device->BeginScene();

			if (SUCCEEDED(Device->StretchRect(BackBuffer, nullptr, SceneSurf, nullptr, D3DTEXF_NONE)))
			{
				// Every pixel is written, so there is nothing to clear. SetRenderTarget resets the
				// viewport to the whole target, which is exactly what this pass wants
				Device->SetRenderTarget(0, BackBuffer);
				Device->SetVertexShader(VS);
				Device->SetPixelShader(PS);
				Device->SetPixelShaderConstantF(0, Grade, 1);
				Device->SetTexture(0, SceneCopy);
				Device->DrawPrimitiveUP(D3DPT_TRIANGLESTRIP, 2, Quad, sizeof(ColorVertex));
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

			SceneSurf->Release();
		}

		BackBuffer->Release();
	}
}

void Color::OnDraw()
{
	FrameDirty = true;
}

void Color::OnPresent(IDirect3DDevice9 *Device)
{
	if (!Configured)
	{
		Configured = true;

		Grade[0] = Ini::ReadInt(L"Color", L"Brightness", 100) / 100.0f;
		Grade[1] = Ini::ReadInt(L"Color", L"Contrast", 100) / 100.0f;
		Grade[2] = Ini::ReadInt(L"Color", L"Saturation", 100) / 100.0f;

		Enabled = Grade[0] != 1.0f || Grade[1] != 1.0f || Grade[2] != 1.0f;

		if (Enabled)
			COLOR_LOG("brightness " << Grade[0] << ", contrast " << Grade[1] << ", saturation " << Grade[2]);
		else
			COLOR_LOG("off");
	}

	// Nothing drawn since the last Present means a loading screen or an idle menu presenting
	// the same finished frame in a loop, and the pass writes back into the backbuffer, so
	// re-running it would grade an already-graded image
	if (Enabled && !InitFailed && FrameDirty)
		Apply(Device);

	FrameDirty = false;
}

void Color::OnDeviceLost()
{
	ReleaseDefaultPoolResources();
}

void Color::Shutdown()
{
	ReleaseResources();
}

DWORD Color::InternalDeviceRefs()
{
	DWORD Refs = 0;

	if (PS != nullptr)
		++Refs;
	if (VS != nullptr)
		++Refs;
	if (SceneCopy != nullptr)
		++Refs;
	if (VertexDecl != nullptr)
		++Refs;
	if (StateBlock != nullptr)
		++Refs;

	return Refs;
}
