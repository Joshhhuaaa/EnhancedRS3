#include "stdafx.h"
#include "common.hpp"
#include "feature.hpp"

namespace
{
    SafetyHookMid mhMaterialScale{};

    void MaterialScale(SafetyHookContext& ctx)
    {
        // Cubemaps have no 2D size, so DrawMaterial produces NaN for the scale
        auto scale = reinterpret_cast<float*>(ctx.ebp - 0x14);

        if (std::isnan(*scale))
            *scale = 0.0f;
    }
}

EDITOR_FEATURE(Startup, MaterialTreeIcon)
{
    // Tail of DrawMaterial's scale calculation, where the wide and tall branches join
    auto scale = FindModulePattern(GetModuleHandleW(nullptr), { "DB 45 08 89 45 DC DA 75 DC 8B 87 70 01 00 00 D9 5D EC" });

    if (scale.empty())
    {
        spdlog::error("MaterialTreeIcon: Icon scale not found in DrawMaterial");
        return;
    }

    mhMaterialScale = safetyhook::create_mid(scale.get_first(18), MaterialScale);
    spdlog::info("MaterialTreeIcon: Zero sized materials no longer smear across the material tree");
}
