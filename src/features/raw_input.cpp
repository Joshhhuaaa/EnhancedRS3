#include "stdafx.h"
#include "common.hpp"
#include "config.hpp"
#include "feature.hpp"
#include "script.hpp"

#include <hidusage.h>

static constexpr bool bRawInput = true;

static Config::Float fLookSensitivity("Input", "LookSensitivity", 1.0f);
static Config::Float fCursorSensitivity("Input", "CursorSensitivity", 1.0f);

namespace
{
    constexpr ptrdiff_t Window   = 0x204;  // UWindowsViewport::Window, WWindow::hWnd sits at +4
    constexpr ptrdiff_t Captured = 0x220;  // the last SetMouseCapture Capture argument

    constexpr int IK_LeftMouse      = 1;
    constexpr int IK_RightMouse     = 2;
    constexpr int IK_MiddleMouse    = 4;
    constexpr int IK_XButton1       = 5; // IK_Unknown05 = VK_XBUTTON1
    constexpr int IK_XButton2       = 6; // IK_Unknown06 = VK_XBUTTON2
    constexpr int IK_MouseX         = 0xe4;
    constexpr int IK_MouseY         = 0xe5;
    constexpr int IK_MouseW         = 0xe7;
    constexpr int IK_MouseWheelUp   = 0xec;
    constexpr int IK_MouseWheelDown = 0xed;

    constexpr int IST_Press   = 1;
    constexpr int IST_Release = 3;
    constexpr int IST_Axis    = 4;

    SafetyHookInline shUpdateInput{};
    SafetyHookInline shKeyPressed{};

    int (__fastcall* CauseInputEvent)(void*, void*, int, int, float) = nullptr;

    WNDPROC gameWndProc  = nullptr;
    HWND    hGameWindow  = nullptr;

    bool bFrameClick = false;

    void** ppMouse = nullptr;

    float deltaX = 0.0f;
    float deltaY = 0.0f;

    void* gSelf      = nullptr;
    bool  bLegacyOff = false;

    // With legacy messages disabled, the thread key state is not updated for side mouse buttons.
    // UpdateInput's release sweep reads GetKeyState, so held Mouse 4/5 buttons would otherwise
    // be treated as released on the next frame.
    void SetXButtonState(int vk, bool bDown)
    {
        BYTE keys[256];
        if (GetKeyboardState(keys))
        {
            keys[vk] = bDown ? 0x80 : 0;
            SetKeyboardState(keys);
        }
    }

    // The Bink playback loop in UGameEngine::DisplayGameVideo polls the DirectInput mouse for its
    // skip click, and Attach unacquires that device
    int __fastcall KeyPressed(void* self, void* edx, int bCheckMouse)
    {
        if (bCheckMouse)
        {
            for (int vk : { VK_LBUTTON, VK_RBUTTON, VK_MBUTTON, VK_XBUTTON1, VK_XBUTTON2 })
                if (GetAsyncKeyState(vk) & 0x8000)
                    return 1;
        }

        return shKeyPressed.thiscall<int>(self, bCheckMouse);
    }

    LRESULT CALLBACK RawInputWndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
    {
        switch (msg)
        {
        case WM_MOUSEACTIVATE: bFrameClick = LOWORD(lParam) != HTCLIENT; break;
        case WM_SETFOCUS:      bInputFocus = !bFrameClick; bFrameClick = false; break;
        case WM_KILLFOCUS:     bInputFocus = false; break;
        case WM_LBUTTONDOWN:
        case WM_RBUTTONDOWN:
        case WM_MBUTTONDOWN:   bInputFocus = true; break;
        }

        // Ignore game keyboard input until the window has focus
        if (!bInputFocus && (msg == WM_KEYDOWN || msg == WM_KEYUP || msg == WM_CHAR))
            return 0;

        // ViewportWndProc returns 0 for every WM_SYSKEYDOWN, so DefWindowProc never sees Alt+F4, and handing it
        // either the keystroke or the SC_CLOSE it stands for produces nothing, so post what both would have led to
        if (msg == WM_SYSKEYDOWN && wParam == VK_F4)
        {
            PostMessageW(hWnd, WM_CLOSE, 0, 0);
            return 0;
        }

        if (msg == WM_INPUT && bInputFocus)
        {
            RAWINPUT raw{};
            UINT size = sizeof(raw);

            if (GetRawInputData(reinterpret_cast<HRAWINPUT>(lParam), RID_INPUT, &raw, &size, sizeof(RAWINPUTHEADER)) != UINT(-1) &&
                raw.header.dwType == RIM_TYPEMOUSE)
            {
                if (!(raw.data.mouse.usFlags & MOUSE_MOVE_ABSOLUTE))
                {
                    deltaX += static_cast<float>(raw.data.mouse.lLastX);
                    deltaY += static_cast<float>(raw.data.mouse.lLastY);
                }

                USHORT flags = raw.data.mouse.usButtonFlags;
                if (gSelf)
                {
                    if (flags & RI_MOUSE_LEFT_BUTTON_DOWN)   CauseInputEvent(gSelf, nullptr, IK_LeftMouse, IST_Press, 0.0f);
                    if (flags & RI_MOUSE_LEFT_BUTTON_UP)     CauseInputEvent(gSelf, nullptr, IK_LeftMouse, IST_Release, 0.0f);
                    if (flags & RI_MOUSE_RIGHT_BUTTON_DOWN)  CauseInputEvent(gSelf, nullptr, IK_RightMouse, IST_Press, 0.0f);
                    if (flags & RI_MOUSE_RIGHT_BUTTON_UP)    CauseInputEvent(gSelf, nullptr, IK_RightMouse, IST_Release, 0.0f);
                    if (flags & RI_MOUSE_MIDDLE_BUTTON_DOWN) CauseInputEvent(gSelf, nullptr, IK_MiddleMouse, IST_Press, 0.0f);
                    if (flags & RI_MOUSE_MIDDLE_BUTTON_UP)   CauseInputEvent(gSelf, nullptr, IK_MiddleMouse, IST_Release, 0.0f);
                    if (flags & RI_MOUSE_BUTTON_4_DOWN)      CauseInputEvent(gSelf, nullptr, IK_XButton1, IST_Press, 0.0f);
                    if (flags & RI_MOUSE_BUTTON_4_UP)        CauseInputEvent(gSelf, nullptr, IK_XButton1, IST_Release, 0.0f);
                    if (flags & RI_MOUSE_BUTTON_5_DOWN)      CauseInputEvent(gSelf, nullptr, IK_XButton2, IST_Press, 0.0f);
                    if (flags & RI_MOUSE_BUTTON_5_UP)        CauseInputEvent(gSelf, nullptr, IK_XButton2, IST_Release, 0.0f);

                    if (flags & (RI_MOUSE_BUTTON_4_DOWN | RI_MOUSE_BUTTON_4_UP)) SetXButtonState(VK_XBUTTON1, (flags & RI_MOUSE_BUTTON_4_DOWN) != 0);
                    if (flags & (RI_MOUSE_BUTTON_5_DOWN | RI_MOUSE_BUTTON_5_UP)) SetXButtonState(VK_XBUTTON2, (flags & RI_MOUSE_BUTTON_5_DOWN) != 0);

                    if (flags & RI_MOUSE_WHEEL)
                    {
                        SHORT wheelDelta = static_cast<SHORT>(raw.data.mouse.usButtonData);
                        CauseInputEvent(gSelf, nullptr, IK_MouseW, IST_Axis, static_cast<float>(wheelDelta));

                        int wheelKey = wheelDelta > 0 ? IK_MouseWheelUp : IK_MouseWheelDown;
                        CauseInputEvent(gSelf, nullptr, wheelKey, IST_Press, 0.0f);
                        CauseInputEvent(gSelf, nullptr, wheelKey, IST_Release, 0.0f);
                    }
                }
            }
        }

        return CallWindowProcW(gameWndProc, hWnd, msg, wParam, lParam);
    }

    void RegisterRawInput(HWND hWnd, bool bNoLegacy)
    {
        RAWINPUTDEVICE rid{};
        rid.usUsagePage = HID_USAGE_PAGE_GENERIC;
        rid.usUsage = HID_USAGE_GENERIC_MOUSE;
        rid.dwFlags = RIDEV_INPUTSINK | (bNoLegacy ? RIDEV_NOLEGACY : 0);
        rid.hwndTarget = hWnd;
        if (!RegisterRawInputDevices(&rid, 1, sizeof(rid)))
            spdlog::error("RawInput: RegisterRawInputDevices failed, GetLastError {}", GetLastError());
    }

    void Attach(HWND hWnd)
    {
        hGameWindow = hWnd;
        gameWndProc = reinterpret_cast<WNDPROC>(SetWindowLongPtrW(hWnd, GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(RawInputWndProc)));

        if (ppMouse && *ppMouse)
        {
            void* mouse = *ppMouse;
            void** vtable = *reinterpret_cast<void***>(mouse);

            reinterpret_cast<HRESULT(__stdcall*)(void*)>(vtable[8])(mouse);  // Unacquire
            *ppMouse = nullptr;

            spdlog::info("RawInput: DirectInput mouse unacquired and detached");
        }

        bLegacyOff = false;
        bInputFocus = GetForegroundWindow() == hWnd;
        RegisterRawInput(hWnd, false);
        spdlog::info("RawInput: attached to hwnd {:#x}", reinterpret_cast<uintptr_t>(hWnd));
    }

    void __fastcall UpdateInput(uint8_t* self, void* edx, int reset, float deltaSeconds)
    {
        gSelf = self;

        auto hWnd = *reinterpret_cast<HWND*>(*reinterpret_cast<uint8_t**>(self + Window) + 4);

        if (hWnd && hWnd != hGameWindow)
            Attach(hWnd);

        // Keep the cursor visible until the game has focus and the cursor is inside the client area
        POINT cursor{};
        RECT client{};
        GetCursorPos(&cursor);
        ScreenToClient(hGameWindow, &cursor);
        GetClientRect(hGameWindow, &client);

        auto bShow = !bInputFocus || !PtInRect(&client, cursor);

        CURSORINFO ci{};
        ci.cbSize = sizeof(ci);
        if (GetCursorInfo(&ci) && bShow != ((ci.flags & CURSOR_SHOWING) != 0))
            ShowCursor(bShow);

        shUpdateInput.thiscall<void>(self, reset, deltaSeconds);

        bool bInMenu = Script::GetBool(self, L"bShowWindowsMouse");

        // Disable legacy mouse messages while the game has capture and the cursor is hidden
        bool bNoLegacy = *reinterpret_cast<int32_t*>(self + Captured) != 0 && !bShow;
        if (hWnd && bNoLegacy != bLegacyOff)
        {
            bLegacyOff = bNoLegacy;
            RegisterRawInput(hWnd, bNoLegacy);
        }

        if (!reset)
        {
            float sensitivity = bInMenu ? fCursorSensitivity : fLookSensitivity;

            if (deltaX != 0.0f)
                CauseInputEvent(self, nullptr, IK_MouseX, IST_Axis, deltaX * sensitivity);

            if (deltaY != 0.0f)
                CauseInputEvent(self, nullptr, IK_MouseY, IST_Axis, -deltaY * sensitivity);
        }

        deltaX = 0.0f;
        deltaY = 0.0f;
    }
}

FEATURE(WinDrv, RawInput)
{
    if (!bRawInput)
        return;

    auto windrv = GetModuleHandleW(L"WinDrv");
    auto updateInput = GetProcAddress(windrv, "?UpdateInput@UWindowsViewport@@UAEXHM@Z");
    CauseInputEvent = reinterpret_cast<decltype(CauseInputEvent)>(GetProcAddress(windrv, "?CauseInputEvent@UWindowsViewport@@QAEHHW4EInputAction@@M@Z"));

    if (!updateInput || !CauseInputEvent)
    {
        spdlog::error("RawInput: UpdateInput {}, CauseInputEvent {}", (void*)updateInput, (void*)CauseInputEvent);
        return;
    }

    ppMouse = reinterpret_cast<void**>(GetProcAddress(windrv, "?Mouse@UWindowsViewport@@2PAUIDirectInputDevice8W@@A"));
    if (!ppMouse)
        spdlog::error("RawInput: Mouse export not found, DirectInput mouse left running");

    auto keyPressed = GetProcAddress(windrv, "?KeyPressed@UWindowsViewport@@UAEHH@Z");
    if (keyPressed)
        shKeyPressed = safetyhook::create_inline(keyPressed, KeyPressed);
    else
        spdlog::error("RawInput: KeyPressed export not found, videos will not skip on click");

    shUpdateInput = safetyhook::create_inline(updateInput, UpdateInput);
    spdlog::info("RawInput: mouse axes taken from raw input, one delta per frame, look x{} / menu cursor x{}",
        static_cast<float>(fLookSensitivity), static_cast<float>(fCursorSensitivity));
}
