#include "ini.hpp"

#include <cstdlib>
#include <windows.h>

int Ini::ReadInt(const wchar_t *Key, int Default)
{
	// The ASI's own ini, next to it in 'system\plugins'. 'd3d8.dll' and 'RavenShield.exe'
	// both live in 'system', so the exe path is the same directory and one call shorter
	wchar_t Path[MAX_PATH] = {};

	if (GetModuleFileNameW(nullptr, Path, MAX_PATH) == 0)
		return Default;

	wchar_t *const Slash = wcsrchr(Path, L'\\');
	if (Slash == nullptr)
		return Default;

	Slash[1] = L'\0';
	wcsncat_s(Path, L"plugins\\EnhancedRS3.ini", _TRUNCATE);

	wchar_t Text[64] = {};
	if (GetPrivateProfileStringW(L"Graphics", Key, L"", Text, _countof(Text), Path) == 0)
		return Default;

	// Parse the number before any trailing // comment
	return static_cast<int>(wcstol(Text, nullptr, 10));
}
