#include "stdafx.h"
#include "common.hpp"
#include "config.hpp"
#include "feature.hpp"

static Config::Float fFieldOfView("Graphics", "FieldOfView", 1.0f);

namespace
{
    constexpr ptrdiff_t SizeX = 0xa4;
    constexpr ptrdiff_t SizeY = 0xa8;

    constexpr float MinFOV = 65.0f;
    constexpr float MaxFOV = 140.0f;

    SafetyHookInline shFCameraSceneNode{};

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

float AdjustFOV(float fov, float aspect)
{
    constexpr double pi = 3.14159265358979323846;
    constexpr double baseAspect = 4.0 / 3.0;

    double scale = 1.0;

    if (fFieldOfView == 1.0f)
        scale = aspect / baseAspect;
    else if (fFieldOfView != 0.0f)
        scale = std::tan(std::clamp(static_cast<float>(fFieldOfView), MinFOV, MaxFOV) / 2.0 * (pi / 180.0));

    return static_cast<float>(std::round(2.0 * std::atan(scale * std::tan(fov / 2.0 * (pi / 180.0))) * (180.0 / pi) * 100.0) / 100.0);
}

FEATURE(Engine, FOV)
{
    if (fFieldOfView == 0.0f)
        return;

    auto cameraSceneNode = GetProcAddress(GetModuleHandleW(L"Engine"), "??0FCameraSceneNode@@QAE@PAVUViewport@@PAVAActor@@VFVector@@VFRotator@@M@Z");

    if (!cameraSceneNode)
    {
        spdlog::error("FOV: FCameraSceneNode constructor not found");
        return;
    }

    shFCameraSceneNode = safetyhook::create_inline(cameraSceneNode, FCameraSceneNode);

    if (fFieldOfView == 1.0f)
        spdlog::info("FOV: Horizontal FOV corrected to hor+ against a 4:3 reference");
    else
        spdlog::info("FOV: Horizontal FOV forced to {}", std::clamp(static_cast<float>(fFieldOfView), MinFOV, MaxFOV));
}
