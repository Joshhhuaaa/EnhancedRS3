#include "stdafx.h"
#include "common.hpp"
#include "config.hpp"
#include "feature.hpp"

static Config::Value nDisplayMode("Graphics", "DisplayMode", 0);

namespace
{
    enum { Fullscreen, Borderless, Windowed };

    constexpr ptrdiff_t Window          = 0x204;  // UWindowsViewport::Window, WWindow::hWnd sits at +4
    constexpr ptrdiff_t BlitFlags       = 0x218;  // BLIT_Fullscreen is bit 0
    constexpr ptrdiff_t CaptionStripped = 0x21c;  // UWindowsViewport::Borderless, set when fullscreen dropped WS_CAPTION | WS_THICKFRAME
    constexpr ptrdiff_t Captured        = 0x220;  // the last SetMouseCapture Capture argument

    SafetyHookInline shSetRes{};
    SafetyHookInline shViewportWndProc{};
    SafetyHookInline shSetMouseCapture{};

    POINT savedCursor{};
    bool  bCursorSaved = false;
    bool  bRetakeCapture = false;

    HWND WindowOf(uint8_t* viewport)
    {
        auto window = *reinterpret_cast<uint8_t**>(viewport + Window);
        return window ? *reinterpret_cast<HWND*>(window + 4) : nullptr;
    }

    bool IsWindowed(uint8_t* viewport)
    {
        return (*reinterpret_cast<uint32_t*>(viewport + BlitFlags) & 1) == 0;
    }

    void ClipToClient(HWND hWnd)
    {
        RECT client{};

        if (GetClientRect(hWnd, &client))
        {
            MapWindowPoints(hWnd, nullptr, reinterpret_cast<POINT*>(&client), 2);
            ClipCursor(&client);
        }
    }

    bool CursorOverClient(HWND hWnd)
    {
        POINT cursor{};
        RECT client{};

        if (!GetCursorPos(&cursor) || !GetClientRect(hWnd, &client))
            return true;

        ScreenToClient(hWnd, &cursor);
        return PtInRect(&client, cursor) != 0;
    }

    // Capturing warps the cursor to the client center and releasing restores the saved position.
    // Focus triggered capture can happen after WM_SETFOCUS returns so neither warp should occur unfocused.
    void __fastcall SetMouseCapture(uint8_t* self, void* edx, int capture, int clip, int onlyFocus)
    {
        auto hWnd = WindowOf(self);

        // Capture clips the cursor to the client and makes the window receive non client messages
        // so capturing over the title bar makes it undraggable. Fullscreen has no frame to protect
        if (capture && IsWindowed(self) && (!bInputFocus || !CursorOverClient(hWnd)))
        {
            // Retry once the cursor is back inside if the game still has focus
            bRetakeCapture = bInputFocus;
            return;
        }

        if (capture)
            bRetakeCapture = false;

        POINT cursor{};
        auto bHeld = GetCursorPos(&cursor) != 0;

        shSetMouseCapture.thiscall<void>(self, capture, clip, onlyFocus);

        if (bHeld)
            SetCursorPos(cursor.x, cursor.y);

        // Keep the cursor clipped while focused and over the client area so releasing capture does not let it leave the game
        if (!capture && IsWindowed(self) && bInputFocus && GetForegroundWindow() == hWnd && CursorOverClient(hWnd))
            ClipToClient(hWnd);
    }

    // WM_MOUSEMOVE updates WindowsMouseX/Y which the menu cursor reads so ignore it until the game has focus
    LONG __fastcall ViewportWndProc(uint8_t* self, void* edx, UINT msg, UINT wParam, LONG lParam)
    {
        auto hWnd = WindowOf(self);

        if (msg == WM_MOUSEMOVE && !bInputFocus)
            return 0;

        // Re-capture on a click or after a deferred capture once the cursor is back inside the client
        auto bClick = msg == WM_LBUTTONDOWN || msg == WM_RBUTTONDOWN || msg == WM_MBUTTONDOWN;

        if ((bClick || (msg == WM_MOUSEMOVE && bRetakeCapture)) &&
            !*reinterpret_cast<int32_t*>(self + Captured) && CursorOverClient(hWnd))
            SetMouseCapture(self, nullptr, 1, 1, 0);

        // Reset the saved cursor on mouse activation so the first focus loss saves the current position
        if (msg == WM_MOUSEACTIVATE)
            bCursorSaved = false;

        if (msg == WM_KILLFOCUS && !bCursorSaved)
            bCursorSaved = GetCursorPos(&savedCursor) != 0;

        auto result = shViewportWndProc.thiscall<LONG>(self, msg, wParam, lParam);

        // The cursor is free to wander the desktop while another application has focus
        if (msg == WM_SETFOCUS && bCursorSaved)
        {
            SetCursorPos(savedCursor.x, savedCursor.y);
            bCursorSaved = false;
        }

        return result;
    }

    // Fullscreen is handled here and drives the present parameters and window styling through ResizeViewport
    int __fastcall SetRes(void* self, void* edx, uint8_t* viewport, int newX, int newY, int fullscreen)
    {
        auto hWnd = WindowOf(viewport);

        MONITORINFO monitor{};
        monitor.cbSize = sizeof(monitor);

        // Alt+Enter already asks for windowed, so only the forced modes override the argument
        if (nDisplayMode != Fullscreen)
            fullscreen = 0;

        auto bBorderless = nDisplayMode == Borderless && hWnd &&
                           GetMonitorInfoW(MonitorFromWindow(hWnd, MONITOR_DEFAULTTOPRIMARY), &monitor);

        if (bBorderless)
        {
            newX = monitor.rcMonitor.right - monitor.rcMonitor.left;
            newY = monitor.rcMonitor.bottom - monitor.rcMonitor.top;
        }

        // Prevent window resizing since the renderer does not follow the window size. ResizeViewport puts
        // WS_CAPTION and WS_THICKFRAME back together once the window has been fullscreen, so the caption is
        // restored here and its flag cleared to leave its AdjustWindowRect on the final style
        if (!fullscreen && !bBorderless && hWnd)
        {
            auto style = GetWindowLongW(hWnd, GWL_STYLE) & ~(WS_THICKFRAME | WS_MAXIMIZEBOX);

            if (*reinterpret_cast<int32_t*>(viewport + CaptionStripped))
            {
                *reinterpret_cast<int32_t*>(viewport + CaptionStripped) = 0;
                style |= WS_CAPTION;
            }

            SetWindowLongW(hWnd, GWL_STYLE, style);
        }

        auto result = shSetRes.thiscall<int>(self, viewport, newX, newY, fullscreen);

        // ResizeViewport changes the window style and position so apply the borderless style afterward
        if (result && bBorderless)
        {
            SetWindowLongW(hWnd, GWL_STYLE, WS_POPUP | WS_VISIBLE);
            SetWindowPos(hWnd, nullptr, monitor.rcMonitor.left, monitor.rcMonitor.top, newX, newY, SWP_NOZORDER | SWP_FRAMECHANGED);

            // SetRes clips the cursor to the old client rect so restore it to the new monitor bounds
            ClipCursor(&monitor.rcMonitor);
        }
        // A resolution change resizes the window under the cursor, so the capture SetRes ends with is
        // declined and the cursor stays clipped to the client rect the window had before
        else if (result && !fullscreen && bInputFocus)
            ClipToClient(hWnd);

        return result;
    }
}

FEATURE(D3DDrv, DisplayMode)
{
    auto setRes = GetProcAddress(GetModuleHandleW(L"D3DDrv"), "?SetRes@UD3DRenderDevice@@UAEHPAVUViewport@@HHH@Z");
    auto wndProc = GetProcAddress(GetModuleHandleW(L"WinDrv"), "?ViewportWndProc@UWindowsViewport@@QAEJIIJ@Z");
    auto setMouseCapture = GetProcAddress(GetModuleHandleW(L"WinDrv"), "?SetMouseCapture@UWindowsViewport@@UAEXHHH@Z");

    if (!setRes || !wndProc || !setMouseCapture)
    {
        spdlog::error("DisplayMode: SetRes {}, ViewportWndProc {}, SetMouseCapture {}", (void*)setRes, (void*)wndProc, (void*)setMouseCapture);
        return;
    }

    shSetRes = safetyhook::create_inline(setRes, SetRes);
    shViewportWndProc = safetyhook::create_inline(wndProc, ViewportWndProc);
    shSetMouseCapture = safetyhook::create_inline(setMouseCapture, SetMouseCapture);
    spdlog::info("DisplayMode: {}", nDisplayMode == Fullscreen ? "fullscreen, windowed on alt+enter" :
        nDisplayMode == Borderless ? "borderless at the monitor resolution" : "windowed at the game resolution");
}
