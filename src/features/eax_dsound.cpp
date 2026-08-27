#include "stdafx.h"
#include "common.hpp"
#include "config.hpp"
#include "feature.hpp"

#include <objbase.h>

#pragma comment(lib, "ole32.lib")

static Config::Value bLocalDirectSound("General", "LocalDirectSound", true);

namespace
{
    // CLSID_DirectSound and CLSID_DirectSound8, read out of eax.dll's own .rdata
    constexpr GUID clsidDirectSound  = { 0x47d4d946, 0x62e8, 0x11cf, { 0x93, 0xbc, 0x44, 0x45, 0x53, 0x54, 0x00, 0x00 } };
    constexpr GUID clsidDirectSound8 = { 0x3901cc3f, 0x84b5, 0x4fa4, { 0xba, 0x35, 0xaa, 0x81, 0x72, 0xb8, 0xa0, 0x9b } };

    HRESULT WINAPI CoCreateInstanceHook(REFCLSID rclsid, LPUNKNOWN pUnkOuter, DWORD dwClsContext, REFIID riid, LPVOID* ppv)
    {
        // COM resolves these through HKCR, which points at system32 and can never reach a
        // wrapper sitting next to the exe. Ask the locally loaded dsound.dll for the class
        // factory instead, so a replacement is picked up without editing the registry.
        if (rclsid == clsidDirectSound || rclsid == clsidDirectSound8)
        {
            auto dsound = LoadLibraryW(L"dsound.dll");
            auto getClassObject = dsound ? reinterpret_cast<LPFNGETCLASSOBJECT>(GetProcAddress(dsound, "DllGetClassObject")) : nullptr;

            // Ultimate ASI Loader also installs as dsound.dll and proxies nothing
            if (getClassObject && !GetProcAddress(dsound, "IsUltimateASILoader"))
            {
                IClassFactory* factory = nullptr;
                if (SUCCEEDED(getClassObject(rclsid, IID_IClassFactory, reinterpret_cast<LPVOID*>(&factory))))
                {
                    auto hr = factory->CreateInstance(pUnkOuter, riid, ppv);
                    factory->Release();
                    return hr;
                }
            }
        }

        return CoCreateInstance(rclsid, pUnkOuter, dwClsContext, riid, ppv);
    }
}

FEATURE(Eax, LocalDirectSound)
{
    if (!bLocalDirectSound)
        return;

    if (!Memory::WriteIAT(GetModuleHandleW(L"eax"), "OLE32.DLL", "CoCreateInstance", reinterpret_cast<void*>(CoCreateInstanceHook)))
    {
        spdlog::error("LocalDirectSound: CoCreateInstance import not found in eax.dll");
        return;
    }

    wchar_t path[MAX_PATH]{};
    if (auto dsound = GetModuleHandleW(L"dsound.dll"))
        GetModuleFileNameW(dsound, path, MAX_PATH);

    spdlog::info("LocalDirectSound: EAX DirectSound creation redirected, dsound.dll is {}", std::filesystem::path(path).string());
}
