#include "msaa.hpp"
#include "ini.hpp"

#include <cstring>
#include <fstream>

#ifndef D3D8TO9NOLOG
extern std::ofstream LOG;
#define MSAA_LOG(Message) do { LOG << "> MSAA: " << Message << std::endl; } while (false)
#else
#define MSAA_LOG(Message) do { } while (false)
#endif

namespace
{
	int Requested = -1;
	bool Forced = false;
	IDirect3DSurface9 *SubstituteDepth = nullptr;
	IDirect3DSurface9 *LockOwner = nullptr;
	IDirect3DSurface9 *LockSysMem = nullptr;
	D3DPRESENT_PARAMETERS Applied = {};
	bool HaveApplied = false;

	// UnrealEd is nothing but hit frames, and SetRes skips the render-to-texture setup under
	// GIsEditor anyway, so MSAA stays off outright outside the game
	bool HostIsGame()
	{
		wchar_t Path[MAX_PATH] = {};
		if (GetModuleFileNameW(nullptr, Path, MAX_PATH) == 0)
			return false;

		const wchar_t *const Slash = wcsrchr(Path, L'\\');
		return _wcsicmp(Slash != nullptr ? Slash + 1 : Path, L"RavenShield.exe") == 0;
	}
}

void Msaa::OnPresentParameters(IDirect3D9 *D3D, UINT Adapter, D3DDEVTYPE DeviceType, D3DPRESENT_PARAMETERS &PresentParams)
{
	if (Requested < 0)
	{
		Requested = HostIsGame() ? Ini::ReadInt(L"Graphics", L"MSAA", 0) : 0;

		if (Requested < 2)
			MSAA_LOG("off");
	}

	if (Requested < 2)
		return;

	// The auto depth-stencil is created at the back buffer's sample count, so both formats
	// have to support the count
	static const D3DMULTISAMPLE_TYPE Levels[] = { D3DMULTISAMPLE_8_SAMPLES, D3DMULTISAMPLE_4_SAMPLES, D3DMULTISAMPLE_2_SAMPLES };

	D3DMULTISAMPLE_TYPE Taken = D3DMULTISAMPLE_NONE;
	for (const D3DMULTISAMPLE_TYPE Level : Levels)
	{
		if (static_cast<int>(Level) > Requested)
			continue;
		if (FAILED(D3D->CheckDeviceMultiSampleType(Adapter, DeviceType, PresentParams.BackBufferFormat, PresentParams.Windowed, Level, nullptr)))
			continue;
		if (PresentParams.EnableAutoDepthStencil &&
			FAILED(D3D->CheckDeviceMultiSampleType(Adapter, DeviceType, PresentParams.AutoDepthStencilFormat, PresentParams.Windowed, Level, nullptr)))
			continue;

		Taken = Level;
		break;
	}

	if (Taken == D3DMULTISAMPLE_NONE)
	{
		MSAA_LOG(Requested << "x asked for, the device supports none of it");
		return;
	}

	// The game asks for a lockable COPY chain, which ConvertPresentParameters rightly refuses
	// to multisample. Rewriting only the D3D9 struct leaves the game's own D3D8 parameters
	// believing it still has one
	PresentParams.MultiSampleType = Taken;
	PresentParams.MultiSampleQuality = 0;
	PresentParams.SwapEffect = D3DSWAPEFFECT_DISCARD;
	PresentParams.Flags &= ~D3DPRESENTFLAG_LOCKABLE_BACKBUFFER;
	Forced = true;

	if (static_cast<int>(Taken) < Requested)
		MSAA_LOG(Requested << "x asked for, " << static_cast<int>(Taken) << "x is the highest the device supports");
	else
		MSAA_LOG(static_cast<int>(Taken) << "x");
}

bool Msaa::Active()
{
	return Forced;
}

void Msaa::OnParamsApplied(const D3DPRESENT_PARAMETERS &PresentParams)
{
	Applied = PresentParams;
	HaveApplied = true;
}

bool Msaa::SkipRedundantReset(IDirect3DDevice9 *Device, const D3DPRESENT_PARAMETERS &PresentParams)
{
	if (!Forced || !HaveApplied)
		return false;
	if (memcmp(&Applied, &PresentParams, sizeof(Applied)) != 0)
		return false;
	if (Device->TestCooperativeLevel() != D3D_OK)
		return false;

	MSAA_LOG("Reset with unchanged parameters on a healthy device skipped");
	return true;
}

IDirect3DSurface9 *Msaa::OnSetDepthStencil(IDirect3DDevice9 *Device, IDirect3DSurface9 *RenderTarget, IDirect3DSurface9 *DepthStencil)
{
	if (!Forced || RenderTarget == nullptr || DepthStencil == nullptr)
		return DepthStencil;

	D3DSURFACE_DESC TargetDesc = {}, DepthDesc = {};
	if (FAILED(RenderTarget->GetDesc(&TargetDesc)) || FAILED(DepthStencil->GetDesc(&DepthDesc)))
		return DepthStencil;

	// The R6 effect path pairs its render-target textures with the saved auto depth-stencil,
	// which is now multisampled. D3D9 accepts each bind on its own and instead drops every
	// draw on the mismatch, which is night vision losing most of the scene
	if (TargetDesc.MultiSampleType != D3DMULTISAMPLE_NONE || DepthDesc.MultiSampleType == D3DMULTISAMPLE_NONE)
		return DepthStencil;

	// Grow-only: the effect path binds a pow2 screen-size texture and a 256x256 one, and a
	// depth-stencil larger than the render target is legal
	if (SubstituteDepth != nullptr)
	{
		D3DSURFACE_DESC HaveDesc = {};
		SubstituteDepth->GetDesc(&HaveDesc);

		if (HaveDesc.Width < TargetDesc.Width || HaveDesc.Height < TargetDesc.Height || HaveDesc.Format != DepthDesc.Format)
		{
			SubstituteDepth->Release();
			SubstituteDepth = nullptr;
		}
	}

	if (SubstituteDepth == nullptr)
	{
		if (FAILED(Device->CreateDepthStencilSurface(TargetDesc.Width, TargetDesc.Height, DepthDesc.Format, D3DMULTISAMPLE_NONE, 0, FALSE, &SubstituteDepth, nullptr)))
			return DepthStencil;

		MSAA_LOG("depth substitute " << TargetDesc.Width << "x" << TargetDesc.Height << " for a non-multisampled render target");
	}

	return SubstituteDepth;
}

void Msaa::OnDeviceLost()
{
	if (SubstituteDepth != nullptr)
	{
		SubstituteDepth->Release();
		SubstituteDepth = nullptr;
	}
}

DWORD Msaa::InternalDeviceRefs()
{
	return SubstituteDepth != nullptr ? 1 : 0;
}

HRESULT Msaa::OnLockRect(IDirect3DDevice9 *Device, IDirect3DSurface9 *Surface, D3DLOCKED_RECT *pLockedRect, const RECT *pRect, DWORD Flags)
{
	if (!Forced || LockOwner != nullptr)
		return D3DERR_INVALIDCALL;

	D3DSURFACE_DESC Desc = {};
	if (FAILED(Surface->GetDesc(&Desc)) || Desc.MultiSampleType == D3DMULTISAMPLE_NONE)
		return D3DERR_INVALIDCALL;

	// The game expects the back buffer to be lockable and reports a lock failure through GError.
	// Resolve the multisampled surface, copy it to system memory, and return those pixels instead.
	// ReadPixels is read-only, so nothing written here could reach the multisampled surface anyway.
	IDirect3DSurface9 *Resolved = nullptr, *SysMem = nullptr;
	if (FAILED(Device->CreateRenderTarget(Desc.Width, Desc.Height, Desc.Format, D3DMULTISAMPLE_NONE, 0, FALSE, &Resolved, nullptr)))
		return D3DERR_INVALIDCALL;

	if (FAILED(Device->StretchRect(Surface, nullptr, Resolved, nullptr, D3DTEXF_NONE)) ||
		FAILED(Device->CreateOffscreenPlainSurface(Desc.Width, Desc.Height, Desc.Format, D3DPOOL_SYSTEMMEM, &SysMem, nullptr)) ||
		FAILED(Device->GetRenderTargetData(Resolved, SysMem)) ||
		FAILED(SysMem->LockRect(pLockedRect, pRect, Flags)))
	{
		if (SysMem != nullptr)
			SysMem->Release();
		Resolved->Release();
		return D3DERR_INVALIDCALL;
	}

	Resolved->Release();
	LockOwner = Surface;
	LockSysMem = SysMem;

	MSAA_LOG("lock on a multisampled surface served from a resolved copy");
	return D3D_OK;
}

bool Msaa::OnUnlockRect(IDirect3DSurface9 *Surface)
{
	if (Surface != LockOwner)
		return false;

	LockSysMem->UnlockRect();
	LockSysMem->Release();
	LockSysMem = nullptr;
	LockOwner = nullptr;
	return true;
}

void Msaa::OnPresentParameters(IDirect3DDevice9 *Device, D3DPRESENT_PARAMETERS &PresentParams)
{
	IDirect3D9 *D3D = nullptr;
	if (FAILED(Device->GetDirect3D(&D3D)))
		return;

	D3DDEVICE_CREATION_PARAMETERS Creation = {};
	if (SUCCEEDED(Device->GetCreationParameters(&Creation)))
		OnPresentParameters(D3D, Creation.AdapterOrdinal, Creation.DeviceType, PresentParams);

	D3D->Release();
}
