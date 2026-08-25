#include "aniso.hpp"

#include <cstdlib>
#include <fstream>

#ifndef D3D8TO9NOLOG
extern std::ofstream LOG;
#define ANISO_LOG(Message) do { LOG << "> ANISO: " << Message << std::endl; } while (false)
#else
#define ANISO_LOG(Message) do { } while (false)
#endif

namespace
{
	constexpr DWORD Stages = 8;

	DWORD Level = 0;
	DWORD CapsMax = 1;
	DWORD GameMinFilter[Stages] = {};
	DWORD GameMaxAnisotropy[Stages] = {};
	bool  Configured = false;

	DWORD ReadIniLevel()
	{
		wchar_t Path[MAX_PATH] = {};

		if (GetModuleFileNameW(nullptr, Path, MAX_PATH) == 0)
			return 0;

		wchar_t *const Slash = wcsrchr(Path, L'\\');
		if (Slash == nullptr)
			return 0;

		Slash[1] = L'\0';
		wcsncat_s(Path, L"plugins\\EnhancedRS3.ini", _TRUNCATE);

		wchar_t Text[64] = {};
		GetPrivateProfileStringW(L"General", L"AnisotropicFiltering", L"16", Text, _countof(Text), Path);

		// Parse the number before any trailing // comment
		return static_cast<DWORD>(wcstoul(Text, nullptr, 10));
	}
}

void Aniso::OnDeviceReady(IDirect3DDevice9 *Device)
{
	if (!Configured)
	{
		Configured = true;

		// A Reset cannot change the cap, so query it once
		D3DCAPS9 Caps = {};
		if (SUCCEEDED(Device->GetDeviceCaps(&Caps)) &&
			(Caps.TextureFilterCaps & D3DPTFILTERCAPS_MINFANISOTROPIC) != 0 && Caps.MaxAnisotropy > 1)
		{
			CapsMax = Caps.MaxAnisotropy;
		}

		Level = ReadIniLevel();
		if (Level > CapsMax)
			Level = CapsMax;
		if (Level <= 1)
			Level = 0; // A device that cannot filter anisotropically clamps down to off

		ANISO_LOG("level " << Level << "x, device cap " << CapsMax << "x");
	}

	// Both a device create and a successful Reset wipe every sampler on the proxy, so restart
	// from the D3D8 defaults. The game never asks for MAXANISOTROPY itself, so nothing would
	// push it back
	for (DWORD Stage = 0; Stage < Stages; ++Stage)
	{
		GameMinFilter[Stage] = D3DTEXF_POINT;
		GameMaxAnisotropy[Stage] = 1;

		if (Level > 1)
			Device->SetSamplerState(Stage, D3DSAMP_MAXANISOTROPY, Level);
	}
}

DWORD Aniso::OnSetMinFilter(DWORD Stage, DWORD Value)
{
	if (Stage >= Stages)
		return Value;

	GameMinFilter[Stage] = Value;

	// Only ever upgrade LINEAR: POINT is an intentional look, and MAGFILTER is never touched
	// because anisotropy only applies to minification
	if (Level > 1 && Value == D3DTEXF_LINEAR)
		return D3DTEXF_ANISOTROPIC;

	return Value;
}

DWORD Aniso::OnSetMaxAnisotropy(DWORD Stage, DWORD Value)
{
	if (Stage >= Stages)
		return Value;

	GameMaxAnisotropy[Stage] = Value;

	// Never let the game lower the forced level
	return (Value < Level) ? Level : Value;
}

bool Aniso::OnGetMinFilter(DWORD Stage, DWORD *Value)
{
	// Hide the forced filter and report what the game last asked for, so its own
	// redundant-set filtering still works
	if (Level <= 1 || Stage >= Stages || Value == nullptr)
		return false;

	*Value = GameMinFilter[Stage];
	return true;
}

bool Aniso::OnGetMaxAnisotropy(DWORD Stage, DWORD *Value)
{
	if (Level <= 1 || Stage >= Stages || Value == nullptr)
		return false;

	*Value = GameMaxAnisotropy[Stage];
	return true;
}
