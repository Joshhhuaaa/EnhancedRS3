#include "stdafx.h"
#include "common.hpp"
#include "feature.hpp"

namespace
{
    SafetyHookInline shLocalize{};

    const wchar_t* (__cdecl* GetLanguage)() = nullptr;

    struct KeyNames
    {
        const wchar_t* language;
        const wchar_t* mouse4;
        const wchar_t* mouse5;
    };

    constexpr KeyNames keyNames[] =
    {
        { L"int", L"Mouse Button 4", L"Mouse Button 5" },
    };

    const KeyNames* KeyNamesFor(int forceInt)
    {
        if (forceInt)
            return &keyNames[0];

        for (auto& entry : keyNames)
            if (_wcsicmp(GetLanguage(), entry.language) == 0)
                return &entry;

        static bool logged = false;
        if (!logged)
        {
            logged = true;
            spdlog::info("Localization: no key names for language {}, leaving them to the game",
                std::filesystem::path(GetLanguage()).string());
        }

        return nullptr;
    }

    const wchar_t* __cdecl Localize(const wchar_t* section, const wchar_t* key, const wchar_t* package,
                                    const wchar_t* language, int optional, int forceInt)
    {
        auto result = shLocalize.ccall<wchar_t*>(section, key, package, language, optional, forceInt);

        if (_wcsicmp(section, L"Interactions") == 0)
        {
            if (auto names = KeyNamesFor(forceInt))
            {
                if (_wcsicmp(key, L"IK_Unknown05") == 0)
                    return wcscpy(result, names->mouse4);

                if (_wcsicmp(key, L"IK_Unknown06") == 0)
                    return wcscpy(result, names->mouse5);
            }
        }

        return result;
    }
}

FEATURE(Core, Localization)
{
    auto core = GetModuleHandleW(L"Core");
    auto localize = GetProcAddress(core, "?Localize@@YAPBGPBG000HH@Z");
    GetLanguage = reinterpret_cast<decltype(GetLanguage)>(GetProcAddress(core, "?GetLanguage@UObject@@SAPBGXZ"));

    if (!localize || !GetLanguage)
    {
        spdlog::error("Localization: Localize {}, GetLanguage {}", (void*)localize, (void*)GetLanguage);
        return;
    }

    shLocalize = safetyhook::create_inline(localize, Localize);
    spdlog::info("Localization: hooked, {} key name rows", std::size(keyNames));
}
