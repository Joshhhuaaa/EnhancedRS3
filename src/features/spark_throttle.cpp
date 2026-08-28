#include "stdafx.h"
#include "common.hpp"
#include "feature.hpp"

namespace
{
    SafetyHookInline shLoadMap{};

    float*    pSparkTime   = nullptr;
    uint32_t* pSparkSeeded = nullptr;

    void* __fastcall LoadMap(void* self, void*, const void* url, void* pending, const void* options, void* error)
    {
        // Seed below the clock so the first WallHit can trigger a spark
        *pSparkTime = -1.0f;
        *pSparkSeeded |= 1u;

        return shLoadMap.thiscall<void*>(self, url, pending, options, error);
    }
}

FEATURE(Engine, SparkThrottle)
{
    auto engine = GetModuleHandleW(L"Engine");
    auto spawnEffects = GetProcAddress(engine, "?SpawnEffects@AR6WallHit@@UAEXXZ");
    auto loadMap = GetProcAddress(engine, "?LoadMap@UGameEngine@@UAEPAVULevel@@ABVFURL@@PAVUPendingLevel@@PBV?$TMap@VFString@@V1@@@AAVFString@@@Z");

    if (!spawnEffects || !loadMap)
    {
        spdlog::error("SparkThrottle: SpawnEffects {}, LoadMap {}", (void*)spawnEffects, (void*)loadMap);
        return;
    }

    // Ubisoft forgot to reset the spark timer when loading a new level,
    // so the timer carries over from the previous level
    auto seeding = hook::range_pattern(reinterpret_cast<uintptr_t>(spawnEffects),
        reinterpret_cast<uintptr_t>(spawnEffects) + 0x400, "D9 1D ? ? ? ? A3 ? ? ? ?");

    if (seeding.empty())
    {
        spdlog::error("SparkThrottle: Spark timer not found in AR6WallHit::SpawnEffects");
        return;
    }

    pSparkTime   = *static_cast<float**>(seeding.get_first(2));
    pSparkSeeded = *static_cast<uint32_t**>(seeding.get_first(7));

    shLoadMap = safetyhook::create_inline(loadMap, LoadMap);
    spdlog::info("SparkThrottle: Spark timer at {} reset on map load", (void*)pSparkTime);
}
