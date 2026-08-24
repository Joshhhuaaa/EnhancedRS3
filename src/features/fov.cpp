#include "stdafx.h"
#include "common.hpp"
#include "feature.hpp"

namespace
{
    constexpr ptrdiff_t SizeX = 0xa4;
    constexpr ptrdiff_t SizeY = 0xa8;

    SafetyHookInline shFCameraSceneNode{};

    float AdjustFOV(float fov, float aspect)
    {
        constexpr double pi = 3.14159265358979323846;
        constexpr double baseAspect = 4.0 / 3.0;

        return static_cast<float>(std::round(2.0 * std::atan((aspect / baseAspect) * std::tan(fov / 2.0 * (pi / 180.0))) * (180.0 / pi) * 100.0) / 100.0);
    }

    void* __fastcall FCameraSceneNode(void* self, void* edx, uint8_t* viewport, void* actor,
                                      float locX, float locY, float locZ,
                                      int pitch, int yaw, int roll, float fov)
    {
        auto sizeX = *reinterpret_cast<int32_t*>(viewport + SizeX);
        auto sizeY = *reinterpret_cast<int32_t*>(viewport + SizeY);

        if (sizeY > 0)
            fov = AdjustFOV(fov, static_cast<float>(sizeX) / static_cast<float>(sizeY));

        return shFCameraSceneNode.thiscall<void*>(self, viewport, actor, locX, locY, locZ, pitch, yaw, roll, fov);
    }
}

FEATURE(Engine, FOV)
{
    auto cameraSceneNode = GetProcAddress(GetModuleHandleW(L"Engine"), "??0FCameraSceneNode@@QAE@PAVUViewport@@PAVAActor@@VFVector@@VFRotator@@M@Z");

    if (!cameraSceneNode)
    {
        spdlog::error("FOV: FCameraSceneNode constructor not found");
        return;
    }

    shFCameraSceneNode = safetyhook::create_inline(cameraSceneNode, FCameraSceneNode);
    spdlog::info("FOV: Horizontal FOV corrected to hor+ against a 4:3 reference");
}
