#include "stdafx.h"
#include "common.hpp"
#include "config.hpp"
#include "feature.hpp"

static constexpr bool bDisableMasterServer = true;

namespace
{
    SafetyHookInline shProcessInternetSrv{};

    // Hosting a multiplayer session can freeze the game while attempting to connect
    // to Ubi.com's unavailable master server every 15 seconds
    void __fastcall ProcessInternetSrv(void*, void*, void*, void*)
    {
    }
}

FEATURE(R6GameService, DisableMasterServer)
{
    if (!bDisableMasterServer)
        return;

    auto processInternetSrv = GetProcAddress(GetModuleHandleW(L"R6GameService"), "?ProcessInternetSrv@UR6GSServers@@QAEXPAVAR6AbstractGameInfo@@PAVALevelInfo@@@Z");

    if (!processInternetSrv)
    {
        spdlog::error("DisableMasterServer: UR6GSServers::ProcessInternetSrv not found");
        return;
    }

    shProcessInternetSrv = safetyhook::create_inline(processInternetSrv, ProcessInternetSrv);
    spdlog::info("DisableMasterServer: Ubi.com server registration disabled");
}
