#include "stdafx.h"
#include "common.hpp"
#include "feature.hpp"
#include "script.hpp"

// The Multiplayer options page offers five Connection Speed presets:
// T1    20000
// T3    20000
// ADSL  5000
// Cable 4000 (default)
// Modem 1500
static constexpr bool    bForceNetSpeed = true;
static constexpr int32_t iNetSpeed      = 480000;

namespace
{
    SafetyHookInline shUNetConnection{};

    void** ppPlayerDefaults = nullptr;

    void* __fastcall UNetConnection(void* self, void* edx, void* driver, void* url)
    {
        // The constructor seeds CurrentNetSpeed from ConfiguredInternetSpeed, so overwrite it
        // before construction to ensure the selected speed is used
        if (auto playerDefaults = *ppPlayerDefaults)
            if (!Script::Set<int32_t>(playerDefaults, L"ConfiguredInternetSpeed", iNetSpeed))
                spdlog::error("ForceNetSpeed: Engine.Player.ConfiguredInternetSpeed not found");

        return shUNetConnection.thiscall<void*>(self, driver, url);
    }
}

FEATURE(Engine, ForceNetSpeed)
{
    if (!bForceNetSpeed)
        return;

    auto engine = GetModuleHandleW(L"Engine");
    auto netConnection = GetProcAddress(engine, "??0UNetConnection@@QAE@PAVUNetDriver@@ABVFURL@@@Z");

    // Engine reaches the object holding ConfiguredInternetSpeed through a private global,
    // so the constructor's own read of it is the only handle on where that object lives
    auto playerDefaults = FindModulePattern(engine, { "A1 ? ? ? ? 8B 48 4C 83 C4 0C 89 4E 48" });

    if (!netConnection || playerDefaults.empty())
    {
        spdlog::error("ForceNetSpeed: UNetConnection {}, player defaults {}", (void*)netConnection, !playerDefaults.empty());
        return;
    }

    ppPlayerDefaults = *static_cast<void***>(playerDefaults.get_first(1));

    shUNetConnection = safetyhook::create_inline(netConnection, UNetConnection);
    spdlog::info("ForceNetSpeed: Connection rate forced to {}", iNetSpeed);
}
