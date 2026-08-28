#include "stdafx.h"
#include "common.hpp"
#include "config.hpp"
#include "feature.hpp"

static constexpr int iShadowResolution = 128; // Resolution of the dynamic pawn shadow, which needs shadow detail on High. Powers of two up to 2048.
//static Config::Value iShadowResolution("Graphics", "ShadowResolution", 128);

namespace
{
    // UBitmapMaterial property storage. ShadowBitmapMaterial's defaultproperties put 128
    // in all six, and Engine reads USize/VSize back out for both the render target size
    // and the projector's world footprint, so they have to stay in agreement.
    constexpr int UBits = 0x5B, VBits = 0x5C, USize = 0x60, VSize = 0x64, UClamp = 0x68, VClamp = 0x6C;

    int     iSize = 0;
    uint8_t iBits = 0;

    SafetyHookInline shShadowBitmapMaterial{};

    void* __fastcall ShadowBitmapMaterial(void* self, void*)
    {
        // StaticAllocateObject copies the class defaults in before the constructor runs,
        // so this overwrites them rather than being overwritten by them.
        auto material = static_cast<uint8_t*>(shShadowBitmapMaterial.thiscall<void*>(self));

        *reinterpret_cast<uint8_t*>(material + UBits)  = iBits;
        *reinterpret_cast<uint8_t*>(material + VBits)  = iBits;
        *reinterpret_cast<int32_t*>(material + USize)  = iSize;
        *reinterpret_cast<int32_t*>(material + VSize)  = iSize;
        *reinterpret_cast<int32_t*>(material + UClamp) = iSize;
        *reinterpret_cast<int32_t*>(material + VClamp) = iSize;

        return material;
    }
}

FEATURE(Engine, ShadowResolution)
{
    iSize = iShadowResolution;

    if (iSize == 128)
        return;

    if (iSize < 128 || iSize > 2048 || (iSize & (iSize - 1)))
    {
        spdlog::error("ShadowResolution: {} is not a power of two between 128 and 2048", iSize);
        return;
    }

    while ((1 << iBits) < iSize)
        ++iBits;

    auto engine = GetModuleHandleW(L"Engine");
    auto constructor = GetProcAddress(engine, "??0UShadowBitmapMaterial@@QAE@XZ");

    if (!constructor)
    {
        spdlog::error("ShadowResolution: UShadowBitmapMaterial constructor not found");
        return;
    }

    shShadowBitmapMaterial = safetyhook::create_inline(constructor, ShadowBitmapMaterial);
    spdlog::info("ShadowResolution: Pawn shadows render at {0}x{0}", iSize);
}
