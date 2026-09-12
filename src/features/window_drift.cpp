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
    constexpr LONG MinCaptionY = 16;    // tolerates the Win10/11 top overhang

    SafetyHookInline shVerifyPosition{};
    SafetyHookInline shOnDestroy{};

    HWND Handle_(void* window)
    {
        return *reinterpret_cast<HWND*>(static_cast<uint8_t*>(window) + Handle);
    }

    // Only the caption strip counts, a window off the top edge has ample overlap but no
    // grabbable title bar. DEFAULTTONULL is load bearing, NEAREST never fails.
    bool UsablyVisible(const RECT& rect)
    {
        RECT caption{ rect.left, rect.top, rect.right, rect.top + CaptionBand };
        MONITORINFO info{ sizeof(info) };

        auto monitor = MonitorFromRect(&caption, MONITOR_DEFAULTTONULL);
        if (!monitor || !GetMonitorInfoW(monitor, &info))
            return false;

        RECT visible{};
        if (!IntersectRect(&visible, &caption, &info.rcWork))
            return false;

        return visible.right - visible.left >= MinVisibleX
            && visible.bottom - visible.top >= MinCaptionY;
    }

    // Prefer the owner's monitor so a rescued dialog lands on the same display as its frame.
    RECT FallbackWorkArea(HWND owner)
    {
        MONITORINFO info{ sizeof(info) };

        if (owner && IsWindow(owner))
            if (auto monitor = MonitorFromWindow(owner, MONITOR_DEFAULTTONULL); monitor && GetMonitorInfoW(monitor, &info))
                return info.rcWork;

        if (auto monitor = MonitorFromPoint(POINT{ 0, 0 }, MONITOR_DEFAULTTOPRIMARY); monitor && GetMonitorInfoW(monitor, &info))
            return info.rcWork;

        return { 0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN) };
    }

    // Far edges first, or a window that fits is left jammed against the edge. The origin
    // clamp still lets an oversized window run off the right and the bottom, as stock does.
    void ClampToWorkArea(const RECT& work, LONG& x, LONG& y, LONG width, LONG height)
    {
        if (width <= work.right - work.left && x + width > work.right)
            x = work.right - width;
        if (height <= work.bottom - work.top && y + height > work.bottom)
            y = work.bottom - height;

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

        // Rescue only. Stock snapped any window on a second monitor back to the primary.
        if (UsablyVisible(rect))
            return;

        auto x = rect.left;
        auto y = rect.top;
        ClampToWorkArea(FallbackWorkArea(GetWindow(window, GW_OWNER)), x, y,
                        rect.right - rect.left, rect.bottom - rect.top);

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
