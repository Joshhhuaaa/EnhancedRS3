#include "stdafx.h"
#include "common.hpp"
#include "config.hpp"
#include "feature.hpp"
#include "script.hpp"

#include <hidusage.h>

static constexpr bool bRawInput = true;

static Config::Float fLookSensitivity("General", "LookSensitivity", 1.0f);
static Config::Float fCursorSensitivity("General", "CursorSensitivity", 1.0f);

namespace
{
    constexpr ptrdiff_t Window = 0x204;  // UWindowsViewport::Window, WWindow::hWnd sits at +4

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
    SafetyHookInline shCauseInputEvent{};

    WNDPROC gameWndProc  = nullptr;
    HWND    hGameWindow  = nullptr;

    constexpr DWORD DISCL_NONEXCLUSIVE_FOREGROUND = 0x5;  // DISCL_NONEXCLUSIVE(1) | DISCL_FOREGROUND(4)

    void** ppMouse = nullptr;

    float deltaX    = 0.0f;
    float deltaY    = 0.0f;
    bool  bDropAxis = false;

    void* gSelf = nullptr;

    LRESULT CALLBACK RawInputWndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
    {
        if (msg == WM_INPUT && GetForegroundWindow() == hGameWindow)
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
                    if (flags & RI_MOUSE_LEFT_BUTTON_DOWN)   shCauseInputEvent.thiscall<int>(gSelf, IK_LeftMouse, IST_Press, 0.0f);
                    if (flags & RI_MOUSE_LEFT_BUTTON_UP)     shCauseInputEvent.thiscall<int>(gSelf, IK_LeftMouse, IST_Release, 0.0f);
                    if (flags & RI_MOUSE_RIGHT_BUTTON_DOWN)  shCauseInputEvent.thiscall<int>(gSelf, IK_RightMouse, IST_Press, 0.0f);
                    if (flags & RI_MOUSE_RIGHT_BUTTON_UP)    shCauseInputEvent.thiscall<int>(gSelf, IK_RightMouse, IST_Release, 0.0f);
                    if (flags & RI_MOUSE_MIDDLE_BUTTON_DOWN) shCauseInputEvent.thiscall<int>(gSelf, IK_MiddleMouse, IST_Press, 0.0f);
                    if (flags & RI_MOUSE_MIDDLE_BUTTON_UP)   shCauseInputEvent.thiscall<int>(gSelf, IK_MiddleMouse, IST_Release, 0.0f);
                    if (flags & RI_MOUSE_BUTTON_4_DOWN)      shCauseInputEvent.thiscall<int>(gSelf, IK_XButton1, IST_Press, 0.0f);
                    if (flags & RI_MOUSE_BUTTON_4_UP)        shCauseInputEvent.thiscall<int>(gSelf, IK_XButton1, IST_Release, 0.0f);
                    if (flags & RI_MOUSE_BUTTON_5_DOWN)      shCauseInputEvent.thiscall<int>(gSelf, IK_XButton2, IST_Press, 0.0f);
                    if (flags & RI_MOUSE_BUTTON_5_UP)        shCauseInputEvent.thiscall<int>(gSelf, IK_XButton2, IST_Release, 0.0f);

                    if (flags & RI_MOUSE_WHEEL)
                    {
                        SHORT wheelDelta = static_cast<SHORT>(raw.data.mouse.usButtonData);
                        shCauseInputEvent.thiscall<int>(gSelf, IK_MouseW, IST_Axis, static_cast<float>(wheelDelta));

                        int wheelKey = wheelDelta > 0 ? IK_MouseWheelUp : IK_MouseWheelDown;
                        shCauseInputEvent.thiscall<int>(gSelf, wheelKey, IST_Press, 0.0f);
                        shCauseInputEvent.thiscall<int>(gSelf, wheelKey, IST_Release, 0.0f);
                    }
                }
            }
        }

        return CallWindowProcW(gameWndProc, hWnd, msg, wParam, lParam);
    }

    // Re-registers raw mouse input after DirectInput reclaims the window
    void RegisterRawInput(HWND hWnd)
    {
        RAWINPUTDEVICE rid{};
        rid.usUsagePage = HID_USAGE_PAGE_GENERIC;
        rid.usUsage = HID_USAGE_GENERIC_MOUSE;
        rid.dwFlags = RIDEV_INPUTSINK;
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
            HRESULT hr = reinterpret_cast<HRESULT(__stdcall*)(void*, HWND, DWORD)>(vtable[13])
                (mouse, hWnd, DISCL_NONEXCLUSIVE_FOREGROUND);                // SetCooperativeLevel
            reinterpret_cast<HRESULT(__stdcall*)(void*)>(vtable[7])(mouse);  // Acquire

            spdlog::info("RawInput: mouse cooperative level set non-exclusive -> {:#x}", static_cast<unsigned>(hr));
        }
        else
        {
            spdlog::error("RawInput: Mouse not initialized yet, still exclusive - WM_INPUT will die out after the first second");
        }

        RegisterRawInput(hWnd);
        spdlog::info("RawInput: attached to hwnd {:#x}", reinterpret_cast<uintptr_t>(hWnd));
    }

    int __fastcall CauseInputEvent(void* self, void* edx, int key, int action, float delta)
    {
        if (bDropAxis && (key == IK_MouseX || key == IK_MouseY))
            return 0;

        return shCauseInputEvent.thiscall<int>(self, key, action, delta);
    }

    void __fastcall UpdateInput(uint8_t* self, void* edx, int reset, float deltaSeconds)
    {
        gSelf = self;

        auto hWnd = *reinterpret_cast<HWND*>(*reinterpret_cast<uint8_t**>(self + Window) + 4);

        if (hWnd && hWnd != hGameWindow)
            Attach(hWnd);

        CURSORINFO ci{};
        ci.cbSize = sizeof(ci);
        if (GetCursorInfo(&ci) && (ci.flags & CURSOR_SHOWING))
            ShowCursor(FALSE);

        bDropAxis = true;
        shUpdateInput.thiscall<void>(self, reset, deltaSeconds);
        bDropAxis = false;

        if (hWnd)
            RegisterRawInput(hWnd);

        if (!reset)
        {
            bool  bInMenu     = Script::GetBool(self, L"bShowWindowsMouse");
            float sensitivity = bInMenu ? fCursorSensitivity : fLookSensitivity;

            if (deltaX != 0.0f)
                shCauseInputEvent.thiscall<int>(self, IK_MouseX, IST_Axis, deltaX * sensitivity);

            if (deltaY != 0.0f)
                shCauseInputEvent.thiscall<int>(self, IK_MouseY, IST_Axis, -deltaY * sensitivity);
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
    auto causeInputEvent = GetProcAddress(windrv, "?CauseInputEvent@UWindowsViewport@@QAEHHW4EInputAction@@M@Z");

    if (!updateInput || !causeInputEvent)
    {
        spdlog::error("RawInput: UpdateInput {}, CauseInputEvent {}", (void*)updateInput, (void*)causeInputEvent);
        return;
    }

    ppMouse = reinterpret_cast<void**>(GetProcAddress(windrv, "?Mouse@UWindowsViewport@@2PAUIDirectInputDevice8W@@A"));
    if (!ppMouse)
        spdlog::error("RawInput: Mouse export not found, staying exclusive");

    shCauseInputEvent = safetyhook::create_inline(causeInputEvent, CauseInputEvent);
    shUpdateInput = safetyhook::create_inline(updateInput, UpdateInput);
    spdlog::info("RawInput: mouse axes taken from raw input, one delta per frame, look x{} / menu cursor x{}",
        static_cast<float>(fLookSensitivity), static_cast<float>(fCursorSensitivity));
}
