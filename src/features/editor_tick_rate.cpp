#include "stdafx.h"
#include "common.hpp"
#include "feature.hpp"

namespace
{
    // Frames per second the editor's main loop is allowed
    constexpr float MaxTickRate = 240.0f;

    SafetyHookInline shGetMaxTickRate{};
    SafetyHookInline shAppSleep{};

    float __fastcall GetMaxTickRate(void*, void*)
    {
        return MaxTickRate;
    }

    void __cdecl AppSleep(float seconds)
    {
        LARGE_INTEGER frequency, now;
        QueryPerformanceFrequency(&frequency);
        QueryPerformanceCounter(&now);
        auto target = now.QuadPart + static_cast<LONGLONG>(seconds * frequency.QuadPart);

        auto ms = static_cast<int>(seconds * 1000.0f);
        if (ms > 1)
            Sleep(ms - 1);

        while (QueryPerformanceCounter(&now), now.QuadPart < target)
            YieldProcessor();
    }
}

EDITOR_FEATURE(Engine, EditorTickRate)
{
    if (!bEditor)
        return;

    auto getMaxTickRate = GetProcAddress(GetModuleHandleW(L"Engine"), "?GetMaxTickRate@UEngine@@UAEMXZ");
    auto appSleep       = GetProcAddress(GetModuleHandleW(L"Core"), "?appSleep@@YAXM@Z");

    if (!getMaxTickRate || !appSleep)
    {
        spdlog::error("EditorTickRate: {} not found", getMaxTickRate ? "appSleep" : "UEngine::GetMaxTickRate");
        return;
    }

    shGetMaxTickRate = safetyhook::create_inline(getMaxTickRate, GetMaxTickRate);
    shAppSleep       = safetyhook::create_inline(appSleep, AppSleep);
    spdlog::info("EditorTickRate: Editor tick rate raised to {}", MaxTickRate);
}
