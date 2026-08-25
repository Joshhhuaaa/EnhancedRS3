#include "stdafx.h"
#include "common.hpp"
#include "feature.hpp"

static constexpr bool bZoomRamp = true;

namespace
{
    // UStruct::Script, TArray<BYTE>
    constexpr ptrdiff_t ScriptData = 0x4c;
    constexpr ptrdiff_t ScriptNum  = 0x50;

    constexpr uint8_t FMin = 0xf4;
    constexpr uint8_t FMax = 0xf5;

    // PlayerController.AdjustView uses FMax(7.0, 0.9 * DeltaTime * delta), making the FOV ramp 7 degrees per frame.
    // Retargeting to FMin caps the step at 7 degrees, instruction size is unchanged.
    constexpr uint8_t ZoomIn[]  = { FMax, 0x1e, 0x00, 0x00, 0xe0, 0x40, 0xab, 0xab, 0x1e, 0x66, 0x66, 0x66, 0x3f };
    constexpr uint8_t ZoomOut[] = { FMin, 0x1e, 0x00, 0x00, 0xe0, 0xc0, 0xab, 0xab, 0x1e, 0x66, 0x66, 0x66, 0x3f };

    using StaticFindObjectFn = void*(__cdecl*)(void* cls, void* outer, const wchar_t* name, int exactClass);

    SafetyHookInline shTick{};

    uint8_t* Find(uint8_t* code, int32_t size, const uint8_t (&site)[13])
    {
        auto found = std::search(code, code + size, std::begin(site), std::end(site));
        return found == code + size ? nullptr : found;
    }

    void Retarget(uint8_t* site, uint8_t op, float rate)
    {
        site[0] = op;
        site[6] = op;
        *reinterpret_cast<float*>(site + 9) = rate;
    }

    // False means the class is not loaded yet, so try again on the next tick
    bool PatchAdjustView()
    {
        auto staticFindObject = reinterpret_cast<StaticFindObjectFn>(
            GetProcAddress(GetModuleHandleW(L"Core"), "?StaticFindObject@UObject@@SAPAV1@PAVUClass@@PAV1@PBGH@Z"));

        if (!staticFindObject)
        {
            spdlog::error("ZoomRamp: UObject::StaticFindObject not found");
            return true;
        }

        auto playerController = staticFindObject(nullptr, nullptr, L"Engine.PlayerController", 0);
        if (!playerController)
            return false;

        auto adjustView = static_cast<uint8_t*>(staticFindObject(nullptr, playerController, L"AdjustView", 0));
        if (!adjustView)
        {
            spdlog::error("ZoomRamp: Engine.PlayerController.AdjustView not found");
            return true;
        }

        auto code = *reinterpret_cast<uint8_t**>(adjustView + ScriptData);
        auto size = *reinterpret_cast<int32_t*>(adjustView + ScriptNum);

        auto in  = Find(code, size, ZoomIn);
        auto out = Find(code, size, ZoomOut);

        if (!in || !out)
        {
            spdlog::error("ZoomRamp: AdjustView bytecode is not what v1.60 ships, zoom in {} zoom out {}", (void*)in, (void*)out);
            return true;
        }

        Retarget(in,  FMin,  210.0f);
        Retarget(out, FMax, -210.0f);

        spdlog::info("ZoomRamp: zoom FOV ramp held to 210 degrees a second above 30 fps");
        return true;
    }

    void __fastcall Tick(void* self, void* edx, float deltaSeconds)
    {
        shTick.thiscall<void>(self, deltaSeconds);

        static bool done = false;
        if (!done)
            done = PatchAdjustView();
    }
}

FEATURE(Engine, ZoomRamp)
{
    if (!bZoomRamp)
        return;

    // The script objects only exist once the engine is up, long after Engine.dll lands
    auto tick = GetProcAddress(GetModuleHandleW(L"Engine"), "?Tick@UGameEngine@@UAEXM@Z");

    if (!tick)
    {
        spdlog::error("ZoomRamp: UGameEngine::Tick not found");
        return;
    }

    shTick = safetyhook::create_inline(tick, Tick);
    spdlog::info("ZoomRamp: armed on UGameEngine::Tick, hook {}", shTick ? "installed" : "FAILED");
}
