#pragma once

#include <d3d9.h>
#include <windows.h>

namespace Aniso
{
	void OnDeviceReady(IDirect3DDevice9 *Device);

	DWORD OnSetMinFilter(DWORD Stage, DWORD Value);
	DWORD OnSetMaxAnisotropy(DWORD Stage, DWORD Value);
	bool  OnGetMinFilter(DWORD Stage, DWORD *Value);
	bool  OnGetMaxAnisotropy(DWORD Stage, DWORD *Value);
}
