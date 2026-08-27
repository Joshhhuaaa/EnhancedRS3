#pragma once

#include <d3d9.h>
#include <windows.h>

namespace Msaa
{
	void OnPresentParameters(IDirect3D9 *D3D, UINT Adapter, D3DDEVTYPE DeviceType, D3DPRESENT_PARAMETERS &PresentParams);
	void OnPresentParameters(IDirect3DDevice9 *Device, D3DPRESENT_PARAMETERS &PresentParams);

	bool Active();
	void OnParamsApplied(const D3DPRESENT_PARAMETERS &PresentParams);
	bool SkipRedundantReset(IDirect3DDevice9 *Device, const D3DPRESENT_PARAMETERS &PresentParams);
	IDirect3DSurface9 *OnSetDepthStencil(IDirect3DDevice9 *Device, IDirect3DSurface9 *RenderTarget, IDirect3DSurface9 *DepthStencil);
	void OnDeviceLost();
	DWORD InternalDeviceRefs();

	HRESULT OnLockRect(IDirect3DDevice9 *Device, IDirect3DSurface9 *Surface, D3DLOCKED_RECT *pLockedRect, const RECT *pRect, DWORD Flags);
	bool OnUnlockRect(IDirect3DSurface9 *Surface);
}
