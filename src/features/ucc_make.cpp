#include "stdafx.h"
#include "common.hpp"
#include "feature.hpp"

UCC_FEATURE(Editor, MakeAllPackages)
{
    // UMakeCommandlet::Main starts its build loop at the EditPackages count it read from the ini, so
    // retail make only builds packages appended by MOD= / Operative=
    auto editor    = GetModuleHandleW(L"Editor");
    auto loopStart = FindModulePattern(editor, { "8B 7D B4 C6 45 FC 03 89 7D DC 8B 0D ? ? ? ? 81 C1 48 05 00 00 FF 15 ? ? ? ? 3B F8 0F 8D" });
    auto baseGate  = FindModulePattern(editor, { "3B 75 B4 7D 1D 8D 4D C4 FF 15 ? ? ? ? 8B 0D ? ? ? ? 8B 11 50 68 ? ? ? ? 52 FF D7" });

    if (loopStart.empty())
        spdlog::error("MakeAllPackages: Build loop start not found in UMakeCommandlet::Main");
    if (baseGate.empty())
        spdlog::error("MakeAllPackages: Base package gate not found in UMakeCommandlet::Main");
    if (loopStart.empty() || baseGate.empty())
        return;

    injector::WriteMemory<uint16_t>(loopStart.get_first(), 0xFF31, true);
    injector::MakeNOP(loopStart.get_first(2), 1, true);

    injector::WriteMemory<uint8_t>(baseGate.get_first(3), 0xEB, true);
    spdlog::info("MakeAllPackages: ucc make builds every EditPackages entry, Core through UnrealEd");
}
