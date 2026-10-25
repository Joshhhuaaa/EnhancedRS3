#include "stdafx.h"
#include "common.hpp"
#include "feature.hpp"
#include "script.hpp"

static constexpr bool bOwnShadow = true;

// The level renderer only lights and updates the shadows of pawns the main view draws, which never
// includes the player's own pawn in first person (bOwnerNoSee)
namespace
{
    // FLevelSceneNode
    constexpr ptrdiff_t Viewport = 0x4, Level = 0x1b8, Model = 0x1bc;

    // UViewport
    constexpr ptrdiff_t ViewportActor = 0x34;

    // ULevel
    constexpr ptrdiff_t Sun = 0x10198, ShadowPawns = 0x101c0;

    // UModel: 256 FZoneProperties of 0x48, ZoneActor first
    constexpr ptrdiff_t Zones = 0x120, ZoneStride = 0x48;

    // AActor
    constexpr ptrdiff_t Shadow = 0x194, Zone = 0x228, Location = 0x234, Rotation = 0x240;

    // AProjector bLightInfluenced, and the AZoneInfo flag that lights shadows from zone actors
    constexpr ptrdiff_t ProjectorFlags = 0x3a0, ZoneFlags = 0x398;
    constexpr uint32_t  LightInfluenced = 0x40000, ZoneLights = 0x10;

    struct FVector { float X, Y, Z; };
    struct TArray  { void** Data; int Num; int Max; };

    SafetyHookMid mhShadowPawns{};

    int      (__fastcall* FArrayAdd)(TArray*, void*, int, int)                       = nullptr;
    int      (__fastcall* Normalize)(FVector*, void*)                                = nullptr;
    FVector* (__fastcall* RotatorVector)(void*, void*, FVector*)                     = nullptr;
    void     (__fastcall* LightUpdateDirect)(void*, void*, FVector, float, uint8_t) = nullptr;

    // The same light FDynamicActor::Render gives the pawns it draws
    void UpdateShadowLight(uint8_t* node, uint8_t* pawn, void* shadow)
    {
        auto location = reinterpret_cast<FVector*>(pawn + Location);
        auto zone     = *reinterpret_cast<uint8_t**>(pawn + Zone);

        FVector sum{};
        float strongest = 0.0f;
        bool lit = false;

        auto add = [&](FVector dir, float weight)
        {
            Normalize(&dir, nullptr);
            dir.Z += 0.8f;
            Normalize(&dir, nullptr);
            sum.X += dir.X * weight;
            sum.Y += dir.Y * weight;
            sum.Z += dir.Z * weight;
            strongest = std::max(strongest, weight);
            lit = true;
        };

        if (zone && (*reinterpret_cast<uint32_t*>(zone + ZoneFlags) & ZoneLights))
        {
            auto model = *reinterpret_cast<uint8_t**>(node + Model);
            for (int i = 0; i < 256; i++)
            {
                auto zoneActor = *reinterpret_cast<uint8_t**>(model + Zones + i * ZoneStride);
                if (!zoneActor)
                    continue;

                auto light = reinterpret_cast<FVector*>(zoneActor + Location);
                FVector dir{ light->X - location->X, light->Y - location->Y, 256.0f };
                auto distance = std::sqrt(dir.X * dir.X + dir.Y * dir.Y + dir.Z * dir.Z);
                if (distance < 1000.0f)
                    add(dir, 1.0f - distance * 0.001f);
            }
        }
        else if (auto sun = *reinterpret_cast<uint8_t**>(*reinterpret_cast<uint8_t**>(node + Level) + Sun))
        {
            FVector dir;
            RotatorVector(sun + Rotation, nullptr, &dir);
            add({ -dir.X, -dir.Y, -dir.Z }, 0.5f);
        }

        if (!lit)
            return;

        Normalize(&sum, nullptr);
        LightUpdateDirect(shadow, nullptr, sum, 256.0f, static_cast<uint8_t>(std::clamp(static_cast<int>(strongest * 255.0f), 0, 255)));
    }

    void QueuePlayerShadow(SafetyHookContext& ctx)
    {
        auto node       = reinterpret_cast<uint8_t*>(ctx.ebx);
        auto viewport   = *reinterpret_cast<uint8_t**>(node + Viewport);
        auto controller = viewport ? *reinterpret_cast<void**>(viewport + ViewportActor) : nullptr;
        auto pawn       = controller ? static_cast<uint8_t*>(Script::Get<void*>(controller, L"Pawn")) : nullptr;
        auto shadow     = pawn ? *reinterpret_cast<uint8_t**>(pawn + Shadow) : nullptr;

        if (!shadow)
            return;

        if (*reinterpret_cast<uint32_t*>(shadow + ProjectorFlags) & LightInfluenced)
            UpdateShadowLight(node, pawn, shadow);

        auto& pawns = *reinterpret_cast<TArray*>(ctx.esi + ShadowPawns);
        for (int i = 0; i < pawns.Num; i++)
            if (pawns.Data[i] == pawn)
                return;

        auto index = FArrayAdd(&pawns, nullptr, 1, sizeof(void*));
        pawns.Data[index] = pawn;
    }
}

FEATURE(Engine, OwnShadow)
{
    if (!bOwnShadow)
        return;

    auto core   = GetModuleHandleW(L"Core");
    auto engine = GetModuleHandleW(L"Engine");

    // The level render, past its IsPaused check and before the shadow update loop. EBX is the scene
    // node and ESI the level
    auto queue = FindModulePattern(engine, { "8B 16 8B CE FF 92 EC 00 00 00 85 C0 75 ? 89 45 E8 8B FF 8D BE C0 01 01 00" });

    FArrayAdd         = reinterpret_cast<decltype(FArrayAdd)>(GetProcAddress(core, "?Add@FArray@@QAEHHH@Z"));
    Normalize         = reinterpret_cast<decltype(Normalize)>(GetProcAddress(core, "?Normalize@FVector@@QAEHXZ"));
    RotatorVector     = reinterpret_cast<decltype(RotatorVector)>(GetProcAddress(core, "?Vector@FRotator@@QAE?AVFVector@@XZ"));
    LightUpdateDirect = reinterpret_cast<decltype(LightUpdateDirect)>(GetProcAddress(engine, "?eventLightUpdateDirect@AProjector@@QAEXVFVector@@ME@Z"));

    if (queue.empty() || !FArrayAdd || !Normalize || !RotatorVector || !LightUpdateDirect)
    {
        spdlog::error("OwnShadow: Shadow update loop {}, FArray::Add {}, FVector::Normalize {}, FRotator::Vector {}, LightUpdateDirect {}",
                      !queue.empty(), (void*)FArrayAdd, (void*)Normalize, (void*)RotatorVector, (void*)LightUpdateDirect);
        return;
    }

    mhShadowPawns = safetyhook::create_mid(queue.get_first(14), QueuePlayerShadow);
    spdlog::info("OwnShadow: The player's own shadow is lit and updated every frame");
}
