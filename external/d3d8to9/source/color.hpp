#pragma once

#include <d3d9.h>
#include <windows.h>

namespace Color
{
	void OnDraw();
	void OnPresent(IDirect3DDevice9 *Device);
	void OnDeviceLost();
	void Shutdown();

	DWORD InternalDeviceRefs();
}
