#include "stdafx.h"
#include "common.hpp"
#include "feature.hpp"

namespace
{
    constexpr ptrdiff_t RenDev = 0x8c;

    SafetyHookInline shViewportWndProc{};
    SafetyHookInline shTryRenderDevice{};
    SafetyHookInline shSetRes{};
    SafetyHookInline shDraw{};

    UINT wndProcMsg   = 0;
    int  wndProcDepth = 0;
    bool bInDevice    = false;
    bool bSkipping    = false;

    LONG __fastcall ViewportWndProc(void* self, void* edx, UINT msg, UINT wParam, LONG lParam)
    {
        auto previousMsg = wndProcMsg;
        wndProcMsg = msg;
        wndProcDepth++;

        auto result = shViewportWndProc.thiscall<LONG>(self, msg, wParam, lParam);

        wndProcDepth--;
        wndProcMsg = previousMsg;

        return result;
    }

    int __fastcall SetRes(void* self, void* edx, uint8_t* viewport, int newX, int newY, int fullscreen)
    {
        // Avoid re-entering D3D8's window procedure during device reset; lock retries SetRes on the next frame
        if (bInDevice || wndProcDepth > 1)
        {
            spdlog::warn("AltTabCrashFix: SetRes re-entered from message {:#x} (inDevice {}, depth {}), leaving it to Lock", wndProcMsg, bInDevice, wndProcDepth);
            return 1;
        }

        bInDevice = true;
        auto result = shSetRes.thiscall<int>(self, viewport, newX, newY, fullscreen);
        bInDevice = false;

        return result;
    }

    void __fastcall TryRenderDevice(uint8_t* self, void* edx, const wchar_t* className, int newX, int newY, int fullscreen)
    {
        // Let Lock handle device recovery instead of rebuilding on WM_ACTIVATEAPP
        if (wndProcMsg == WM_ACTIVATEAPP && *reinterpret_cast<void**>(self + RenDev))
            return;

        shTryRenderDevice.thiscall<void>(self, className, newX, newY, fullscreen);
    }

    void __fastcall Draw(void* self, void* edx, uint8_t* viewport, int blit, uint8_t* hitData, int* hitSize)
    {
        if (!*reinterpret_cast<void**>(viewport + RenDev))
        {
            if (!bSkipping)
            {
                bSkipping = true;
                spdlog::warn("AltTabCrashFix: viewport has no render device, skipping draw");
            }

            return;
        }

        bSkipping = false;
        shDraw.thiscall<void>(self, viewport, blit, hitData, hitSize);
    }
}

FEATURE(D3DDrv, AltTabCrashFix)
{
    auto draw = GetProcAddress(GetModuleHandleW(L"Engine"), "?Draw@UGameEngine@@UAEXPAVUViewport@@HPAEPAH@Z");
    auto wndProc = GetProcAddress(GetModuleHandleW(L"WinDrv"), "?ViewportWndProc@UWindowsViewport@@QAEJIIJ@Z");
    auto tryRenderDevice = GetProcAddress(GetModuleHandleW(L"WinDrv"), "?TryRenderDevice@UWindowsViewport@@UAEXPBGHHH@Z");
    auto setRes = GetProcAddress(GetModuleHandleW(L"D3DDrv"), "?SetRes@UD3DRenderDevice@@UAEHPAVUViewport@@HHH@Z");

    if (!draw || !wndProc || !tryRenderDevice || !setRes)
    {
        spdlog::error("AltTabCrashFix: Draw {}, ViewportWndProc {}, TryRenderDevice {}, SetRes {}",
                      (void*)draw, (void*)wndProc, (void*)tryRenderDevice, (void*)setRes);
        return;
    }

    // Unlike UnrealEd, SetRes releases and recreates the device. Overlays such as RTSS
    // retain a reference to the old device, causing CreateDevice to fail in exclusive fullscreen.
    auto resetGate = FindModulePattern(GetModuleHandleW(L"D3DDrv"), { "39 18 74 13 8B 07 8B 08 8D 96 90 46 00 00" });

    if (resetGate.empty())
        spdlog::error("AltTabCrashFix: SetRes editor-only Reset gate not found");
    else
        injector::MakeNOP(resetGate.get_first(2), 2, true);

    shDraw = safetyhook::create_inline(draw, Draw);
    shViewportWndProc = safetyhook::create_inline(wndProc, ViewportWndProc);
    shTryRenderDevice = safetyhook::create_inline(tryRenderDevice, TryRenderDevice);
    shSetRes = safetyhook::create_inline(setRes, SetRes);
    spdlog::info("AltTabCrashFix: WM_ACTIVATEAPP rebuild dropped, device reset in place instead of recreated");
}
