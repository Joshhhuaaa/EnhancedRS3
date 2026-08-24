#include "stdafx.h"
#include "common.hpp"
#include "config.hpp"
#include "feature.hpp"

static Config::Value bSkipIntro("General", "SkipIntro", false);

namespace
{
    enum eGameVideoType { GAMEVIDEO_Logos = 0, GAMEVIDEO_Intro = 1 };

    SafetyHookInline shDisplayGameVideo{};

    void __fastcall DisplayGameVideo(void* self, void* edx, int type)
    {
        // The remaining types are the quit video and the per-mission intro and outro
        if (type == GAMEVIDEO_Logos || type == GAMEVIDEO_Intro)
            return;

        shDisplayGameVideo.thiscall<void>(self, type);
    }
}

FEATURE(Engine, SkipIntro)
{
    if (!bSkipIntro)
        return;

    auto engine = GetModuleHandleW(L"Engine");
    auto displayGameVideo = GetProcAddress(engine, "?DisplayGameVideo@UGameEngine@@UAEXW4eGameVideoType@@@Z");

    if (!displayGameVideo)
    {
        spdlog::error("SkipIntro: UGameEngine::DisplayGameVideo not found");
        return;
    }

    shDisplayGameVideo = safetyhook::create_inline(displayGameVideo, DisplayGameVideo);
    spdlog::info("SkipIntro: Intro videos skipped");
}
