#pragma once

#include <d3d9.h>
#include <windows.h>

extern const unsigned char SMAA_HLSL[];
extern const unsigned int  SMAA_HLSL_len;
extern const unsigned char SMAA_AREATEX_DDS[];
extern const unsigned int  SMAA_AREATEX_DDS_len;
extern const unsigned char SMAA_SEARCHTEX_DDS[];
extern const unsigned int  SMAA_SEARCHTEX_DDS_len;

namespace Smaa
{
	void OnDraw();
	void OnPresent(IDirect3DDevice9 *Device);
	void OnDeviceLost();
	void Shutdown();

	DWORD InternalDeviceRefs();
}
