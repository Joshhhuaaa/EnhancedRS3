#include "stdafx.h"
#include "common.hpp"
#include "config.hpp"
#include "feature.hpp"

#include <timeapi.h>
#pragma comment(lib, "winmm.lib")

static Config::Value nFPSLimit("General", "FPSLimit", 0);

namespace
{
    SafetyHookInline shGetMaxTickRate{};
    void (__stdcall* oBinkGetSummary)(void* bink, void* summary) = nullptr;

    HANDLE  hTimer = nullptr;
    int64_t qpcFrequency = 0;
    int64_t spinTicks = 0;

    // Leaves headroom for GPU present jitter without blocking Present or exceeding VRR range
    constexpr int32_t RefreshMargin = 3;

    int32_t RefreshRate()
    {
        static int32_t cached = 0;
        static int64_t next = 0;

        // Refreshes once per second to catch fullscreen and monitor changes
        LARGE_INTEGER now;
        QueryPerformanceCounter(&now);
        if (now.QuadPart < next)
            return cached;
        next = now.QuadPart + qpcFrequency;

        if (auto window = GetActiveWindow())
        {
            MONITORINFOEXW monitor{};
            DEVMODEW mode{};
            monitor.cbSize = sizeof(monitor);
            mode.dmSize = sizeof(mode);

            if (GetMonitorInfoW(MonitorFromWindow(window, MONITOR_DEFAULTTOPRIMARY), &monitor) &&
                EnumDisplaySettingsW(monitor.szDevice, ENUM_CURRENT_SETTINGS, &mode) &&
                mode.dmDisplayFrequency > 1 && static_cast<int32_t>(mode.dmDisplayFrequency) != cached)
            {
                cached = mode.dmDisplayFrequency;
                spdlog::info("FPSLimit: Monitor refresh rate is {} Hz, capping at {}", cached, cached - RefreshMargin);
            }
        }

        return cached;
    }

    int32_t Cap()
    {
        return nFPSLimit < 0 ? std::max(RefreshRate() - RefreshMargin, 0) : static_cast<int32_t>(nFPSLimit);
    }

    void SleepUntil(int64_t deadline)
    {
        LARGE_INTEGER now;

        for (;;)
        {
            QueryPerformanceCounter(&now);
            auto remaining = deadline - now.QuadPart;

            if (remaining <= 0)
                return;

            if (remaining <= spinTicks)
            {
                YieldProcessor();
                continue;
            }

            LARGE_INTEGER due;
            due.QuadPart = -((remaining - spinTicks) * 10000000 / qpcFrequency);
            if (SetWaitableTimer(hTimer, &due, 0, nullptr, nullptr, FALSE))
                WaitForSingleObject(hTimer, INFINITE);
        }
    }

    float __fastcall GetMaxTickRate(void* self, void* edx)
    {
        auto cap = static_cast<float>(Cap());
        auto stock = shGetMaxTickRate.thiscall<float>(self);

        // Preserve the network tick rate while enforcing the FPS limit
        if (stock > 0.0f)
            return cap > 0.0f ? std::min(stock, cap) : stock;

        return cap;
    }

    void __cdecl appSleep(float seconds)
    {
        LARGE_INTEGER now;
        QueryPerformanceCounter(&now);
        SleepUntil(now.QuadPart + static_cast<int64_t>(static_cast<double>(seconds) * qpcFrequency));
    }


    // DisplayGameVideo runs Bink videos in its own uncapped Lock/Present loop. It calls BinkGetSummary
    // once per iteration after Present, so pacing here puts the videos on the same cap as the game.
    void __stdcall BinkGetSummary(void* bink, void* summary)
    {
        oBinkGetSummary(bink, summary);

        auto cap = Cap();
        if (cap <= 0)
            return;

        static int64_t next = 0;
        LARGE_INTEGER now;
        QueryPerformanceCounter(&now);

        if (now.QuadPart < next)
            SleepUntil(next);
        else
            next = now.QuadPart;

        next += qpcFrequency / cap;
    }
}

FEATURE(Engine, FPSLimit)
{
    if (!nFPSLimit)
        return;

    LARGE_INTEGER frequency;
    QueryPerformanceFrequency(&frequency);
    qpcFrequency = frequency.QuadPart;

    // Before Windows 10, version 1803, fall back to a regular timer
    hTimer = CreateWaitableTimerExW(nullptr, nullptr, CREATE_WAITABLE_TIMER_HIGH_RESOLUTION, TIMER_ALL_ACCESS);
    spinTicks = qpcFrequency / 1000;

    if (!hTimer)
    {
        timeBeginPeriod(1);
        hTimer = CreateWaitableTimerExW(nullptr, nullptr, 0, TIMER_ALL_ACCESS);
        spinTicks *= 2;
        spdlog::warn("FPSLimit: High resolution timer unavailable, using a regular timer");
    }

    auto engine = GetModuleHandleW(L"Engine");
    auto getMaxTickRate = GetProcAddress(engine, "?GetMaxTickRate@UGameEngine@@UAEMXZ");
    oBinkGetSummary = reinterpret_cast<decltype(oBinkGetSummary)>(Memory::ReadIAT(engine, "binkw32.dll", "_BinkGetSummary@8"));

    // MainLoop already sleeps to the frame deadline, hook appSleep to enforce tick rate precisely
    if (!getMaxTickRate || !hTimer || !oBinkGetSummary ||
        !Memory::WriteIAT(GetModuleHandleW(nullptr), "Core.dll", "?appSleep@@YAXM@Z", reinterpret_cast<void*>(appSleep)) ||
        !Memory::WriteIAT(engine, "binkw32.dll", "_BinkGetSummary@8", reinterpret_cast<void*>(BinkGetSummary)))
    {
        spdlog::error("FPSLimit: GetMaxTickRate {}, BinkGetSummary {}, timer {}", (void*)getMaxTickRate, (void*)oBinkGetSummary, (void*)hTimer);
        return;
    }

    shGetMaxTickRate = safetyhook::create_inline(getMaxTickRate, GetMaxTickRate);

    if (nFPSLimit < 0)
        spdlog::info("FPSLimit: Frame rate capped to just under the monitor refresh rate");
    else
        spdlog::info("FPSLimit: Frame rate capped to {}", static_cast<int32_t>(nFPSLimit));
}
