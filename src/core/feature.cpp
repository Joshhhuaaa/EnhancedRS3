#include "stdafx.h"
#include "feature.hpp"

namespace
{
    struct Entry
    {
        GameModule module;
        FeatureFn  fn;
    };

    std::vector<Entry>& List()
    {
        static std::vector<Entry> list;
        return list;
    }

    const wchar_t* ModuleName(GameModule module)
    {
        switch (module)
        {
        case GameModule::Core:          return L"Core.dll";
        case GameModule::Engine:        return L"Engine.dll";
        case GameModule::Fire:          return L"Fire.dll";
        case GameModule::IpDrv:         return L"IpDrv.dll";
        case GameModule::R6Abstract:    return L"R6Abstract.dll";
        case GameModule::R6Engine:      return L"R6Engine.dll";
        case GameModule::R6Game:        return L"R6Game.dll";
        case GameModule::R6GameService: return L"R6GameService.dll";
        case GameModule::R6Weapons:     return L"R6Weapons.dll";
        case GameModule::D3DDrv:        return L"D3DDrv.dll";
        case GameModule::WinDrv:        return L"WinDrv.dll";
        case GameModule::Window:        return L"Window.dll";
        case GameModule::DareAudio:     return L"DareAudio.dll";
        default:                        return L"";
        }
    }
}

Feature::Feature(GameModule module, FeatureFn fn)
{
    List().push_back({ module, fn });
}

void RegisterFeatures()
{
    // CallbackHandler keys module callbacks in a std::map, so registering one per feature
    // silently drops every fix past the first for a given package. Group by module and
    // register a single callback that runs them all.
    std::map<std::wstring, std::vector<FeatureFn>> byModule;

    for (auto& entry : List())
        byModule[ModuleName(entry.module)].push_back(entry.fn);

    for (auto& [name, fns] : byModule)
    {
        CallbackHandler::RegisterCallback(name, [fns]()
        {
            for (auto fn : fns)
                fn();
        });
    }
}
