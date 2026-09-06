#include "stdafx.h"
#include "common.hpp"
#include "feature.hpp"

namespace
{
    // WWindow
    constexpr ptrdiff_t Handle      = 0x04;
    constexpr ptrdiff_t OwnerWindow = 0x14;

    constexpr LONG MinVisibleX = 120;
    constexpr LONG CaptionBand = 32;

    SafetyHookInline shVerifyPosition{};
    SafetyHookInline shOnDestroy{};

    HWND Handle_(void* window)
    {
        return *reinterpret_cast<HWND*>(static_cast<uint8_t*>(window) + Handle);
    }

    // Clamps the origin only, so an oversized window can still run off the right and the
    // bottom - the stock code does the same.
    void ClampToWorkArea(LONG& x, LONG& y)
    {
        RECT work{ 0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN) };
        MONITORINFO info{ sizeof(info) };
        POINT point{ x, y };

        if (auto monitor = MonitorFromPoint(point, MONITOR_DEFAULTTONEAREST); monitor && GetMonitorInfoW(monitor, &info))
            work = info.rcWork;

        auto maxX = work.right - MinVisibleX;
        auto maxY = work.bottom - CaptionBand;

        x = std::clamp(x, work.left, maxX > work.left ? maxX : work.left);
        y = std::clamp(y, work.top, maxY > work.top ? maxY : work.top);
    }

    // Replaces the stock XP-era off-screen check, which snaps windows with left/top below -4 to 0.
    // Modern maximized windows legitimately extend further past the screen, so stock shifts them
    // down and right, often under the taskbar.
    void __fastcall VerifyPosition(void* self)
    {
        auto window = Handle_(self);
        if (!window || !IsWindow(window) || IsZoomed(window) || IsIconic(window))
            return;

        // A fullscreen viewport is a popup at the screen origin, outside the work area when the
        // taskbar is on the top or left.
        auto style = GetWindowLongW(window, GWL_STYLE);
        if ((style & WS_CHILD) || !(style & WS_CAPTION))
            return;

        RECT rect{};
        ::GetWindowRect(window, &rect);

        auto x = rect.left;
        auto y = rect.top;
        ClampToWorkArea(x, y);

        if (x != rect.left || y != rect.top)
            SetWindowPos(window, nullptr, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE | SWP_NOSENDCHANGING);
    }

    // GetWindowRect converts owned windows to owner client space, but CreateWindowEx restores the
    // saved position as screen coordinates for non child windows. Clear the owner while saving so
    // the position stays in the space it is restored in.
    void __fastcall OnDestroy(void* self)
    {
        auto owner = reinterpret_cast<void**>(static_cast<uint8_t*>(self) + OwnerWindow);
        auto saved = *owner;
        auto window = Handle_(self);

        if (saved && window && !(GetWindowLongW(window, GWL_STYLE) & WS_CHILD))
            *owner = nullptr;

        shOnDestroy.thiscall<void>(self);
        *owner = saved;
    }
}

EDITOR_FEATURE(Window, WindowDrift)
{
    if (!bEditor)
        return;

    auto module = GetModuleHandleW(L"Window");
    auto verifyPosition = GetProcAddress(module, "?VerifyPosition@WWindow@@QAEXXZ");
    auto onDestroy = GetProcAddress(module, "?OnDestroy@WWindow@@UAEXXZ");

    if (!verifyPosition || !onDestroy)
    {
        spdlog::error("WindowDrift: WWindow::{} not found", verifyPosition ? "OnDestroy" : "VerifyPosition");
        return;
    }

    shVerifyPosition = safetyhook::create_inline(verifyPosition, VerifyPosition);
    shOnDestroy = safetyhook::create_inline(onDestroy, OnDestroy);
    spdlog::info("WindowDrift: Window positions clamped to the work area and saved in screen space");
}
