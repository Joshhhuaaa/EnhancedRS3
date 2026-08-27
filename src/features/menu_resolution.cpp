#include "stdafx.h"
#include "common.hpp"
#include "feature.hpp"
#include "script.hpp"

#include <d3d9.h>

namespace
{
    // The menus, the planning natives and the videos are all based against this
    constexpr float DesignWidth  = 640.0f;
    constexpr float DesignHeight = 480.0f;

    // UViewport
    constexpr ptrdiff_t Console = 0x38;
    constexpr ptrdiff_t Canvas  = 0x7c;
    constexpr ptrdiff_t RenDev  = 0x8c;
    constexpr ptrdiff_t SizeX   = 0xa4;
    constexpr ptrdiff_t SizeY   = 0xa8;

    // UCanvas
    constexpr ptrdiff_t OrgX      = 0x38;
    constexpr ptrdiff_t OrgY      = 0x3c;
    constexpr ptrdiff_t ClipX     = 0x40;
    constexpr ptrdiff_t ClipY     = 0x44;
    constexpr ptrdiff_t CurX      = 0x50;
    constexpr ptrdiff_t CurY      = 0x54;
    constexpr ptrdiff_t Viewport  = 0x7c;
    constexpr ptrdiff_t Bink      = 0x80;
    constexpr ptrdiff_t Playing   = 0x84;
    constexpr ptrdiff_t PosX      = 0x88;
    constexpr ptrdiff_t PosY      = 0x8c;
    constexpr ptrdiff_t Requests  = 0xac;
    constexpr ptrdiff_t NewResX   = 0xb0;
    constexpr ptrdiff_t NewResY   = 0xb4;
    constexpr uint32_t  ChangeRes = 2;      // m_bChangeResRequested
    constexpr ptrdiff_t StretchX  = 0x94;
    constexpr ptrdiff_t StretchY  = 0x98;

    // UD3DRenderDevice - IDirect3DDevice8 vtable slot from D3DDrv's own calls
    constexpr ptrdiff_t Direct3DDevice8 = 0x468c;
    constexpr ptrdiff_t DeviceClear     = 0x90;
    constexpr uint32_t  ClearTarget     = 1;

    // Engine.dll - inside UGameEngine::Draw
    constexpr uintptr_t ResRequest  = 0xae390;   // reads Canvas->m_bChangeResRequested
    constexpr uintptr_t BeforeMenus = 0xaca1f;   // level rendered, UWindow not yet painted

    // Engine.dll - UGameEngine::PaintProgress lays the loading screen out in viewport pixels
    constexpr uintptr_t ProgressFrom     = 0xa1d60;
    constexpr uintptr_t ProgressTo       = 0xa292d;
    constexpr uintptr_t DrawStringWorker = 0x8ac40;

    // WinDrv.dll - past the two stores of the OS cursor into UViewport::WindowsMouseX/Y
    constexpr uintptr_t MouseStored = 0x6a4b;
    constexpr ptrdiff_t WindowsMouseX = 0x40;
    constexpr ptrdiff_t WindowsMouseY = 0x44;

    // UStruct::Script, the compiled bytecode - the offset UStruct::SerializeExpr works through
    constexpr ptrdiff_t Code = 0x4c;

    // UGameEngine / UClient
    constexpr ptrdiff_t Client    = 0x44;
    constexpr ptrdiff_t Viewports = 0x30;

    // Engine.dll - execRenderLevelFromMe parks its rect here for Draw
    constexpr uintptr_t LevelFromMeRect  = 0x36677c;
    constexpr uintptr_t LevelFromMeActor = 0x36678c;

    // R6Game.dll - AR6PlanningCtrl's click natives, one instruction past their P_GET_FLOATs
    constexpr uintptr_t GetClickResult     = 0x84f0;
    constexpr uintptr_t GetClickResultArgs = 0x8672;
    constexpr uintptr_t GetXYPoint         = 0x81c0;
    constexpr uintptr_t GetXYPointArgs     = 0x8277;

    // The displacement of FSUB/FADD [320.0] and [240.0] in execGetClickResult, the pivot of its zoom
    constexpr uintptr_t ClickPivotX[] = { 0x872d, 0x8739 };
    constexpr uintptr_t ClickPivotY[] = { 0x8742, 0x874b };
    constexpr uintptr_t Const320 = 0x18110;
    constexpr uintptr_t Const240 = 0x1810c;

    // Stock DisplayVideo's flags: BINKCOPYALL | BINKNOSKIP
    constexpr uint32_t BinkCopyFlags = 0x80080000;

    // BinkDX8SurfaceType's table for D3DFMT_R8G8B8 through A4R4G4B4 (it wants a D3D8 surface, not a format)
    constexpr int      BinkFirstFormat = D3DFMT_R8G8B8;
    constexpr uint32_t BinkSurfaceType[] = { 1, 5, 3, 10, 9, 8, 7 };

    // OpenFlags carries the BINKCOPY2X* mode when the copy flags leave it 0; Width/Height are then
    // already that scaled size, and the 1x size is what the layout was made for.
    struct BinkHandle { uint32_t Width, Height, Frames, FrameNum, LastFrameNum, FrameRate, FrameRateDiv, ReadError, OpenFlags; };
    constexpr uint32_t BinkScaleMask = 0x70000000;
    constexpr uint32_t BinkScale2XH  = 0x10000000;
    constexpr uint32_t BinkScale2XW  = 0x30000000;

    using GetIntFn = int(__thiscall*)(void*, const wchar_t*, const wchar_t*, int*, const wchar_t*);
    using ClearFn  = int32_t(__stdcall*)(void*, uint32_t, const RECT*, uint32_t, uint32_t, float, uint32_t);

    SafetyHookInline shDraw{};
    SafetyHookInline shTryRenderDevice{};
    SafetyHookInline shDisplayVideo{};
    SafetyHookInline shSetRes{};
    SafetyHookInline shExit{};
    SafetyHookInline shExecDrawText{};
    SafetyHookInline shExecDrawTextClipped{};
    SafetyHookInline shExecDrawTile{};
    SafetyHookInline shExecDrawTileClipped{};
    SafetyHookInline shPaintProgress{};
    SafetyHookMid    mhMouseStored{};
    SafetyHookMid    mhProgressText{};
    SafetyHookMid    mhProgressTile{};
    SafetyHookMid    mhResRequest{};
    SafetyHookMid    mhBeforeMenus{};
    SafetyHookMid    mhClickResult{};
    SafetyHookMid    mhXYPoint{};

    void**    gConfig    = nullptr;
    uintptr_t engineBase = 0;

    int      (__stdcall* BinkWait)(BinkHandle*)                = nullptr;
    int      (__stdcall* BinkDoFrame)(BinkHandle*)             = nullptr;
    void     (__stdcall* BinkNextFrame)(BinkHandle*)           = nullptr;
    int      (__stdcall* BinkCopyToBuffer)(BinkHandle*, void*, int, uint32_t, uint32_t, uint32_t, uint32_t) = nullptr;

    IUnknown*          source = nullptr;
    IDirect3DDevice9*  device = nullptr;
    IDirect3DSurface9* frame  = nullptr;
    D3DSURFACE_DESC    frameDesc{};

    // The frame's mapping from 640x480 to the screen, and which root is up. bWidget is the scale
    // gate; bDebrief is the one widget behind which the level is not being rendered.
    float scale   = 1.0f;
    float offsetX = 0.0f;
    float offsetY = 0.0f;
    bool  bMenu   = false;
    bool  bWidget = false;
    bool  bDebrief = false;
    bool  bProgress = false;
    bool  bFreed    = false;

    // execGetClickResult zooms about these instead of its 320,240 - see the R6Game feature
    float centerX = 320.0f;
    float centerY = 240.0f;

    int32_t lastRect[4] = {};

    template<typename Fn>
    Fn Method(void* object, ptrdiff_t slot)
    {
        return *reinterpret_cast<Fn*>(*reinterpret_cast<uint8_t**>(object) + slot);
    }

    int32_t Size(uint8_t* viewport, ptrdiff_t offset) { return *reinterpret_cast<int32_t*>(viewport + offset); }

    bool Configured(int& x, int& y)
    {
        auto config = gConfig ? *gConfig : nullptr;
        if (!config)
            return false;

        x = y = 0;
        Method<GetIntFn>(config, 4)(config, L"Engine.R6GameOptions", L"R6ScreenSizeX", &x, L"USER");
        Method<GetIntFn>(config, 4)(config, L"Engine.R6GameOptions", L"R6ScreenSizeY", &y, L"USER");
        return x > 0 && y > 0;
    }

    void Measure(uint8_t* viewport)
    {
        auto sizeX = static_cast<float>(Size(viewport, SizeX));
        auto sizeY = static_cast<float>(Size(viewport, SizeY));

        if (sizeX <= 0.0f || sizeY <= 0.0f)
            return;

        scale   = std::min(sizeX / DesignWidth, sizeY / DesignHeight);
        offsetX = (sizeX - DesignWidth * scale) * 0.5f;
        offsetY = (sizeY - DesignHeight * scale) * 0.5f;
        centerX = sizeX * 0.5f;
        centerY = sizeY * 0.5f;
    }

    void* ShellRoot(uint8_t* viewport)
    {
        auto root = Script::Get<void*>(*reinterpret_cast<void**>(viewport + Console), L"Root");
        return Script::IsA(root, L"R6MenuRootWindow") ? root : nullptr;
    }

    // Their 640x480 layout requests are dropped with the menu's, so they are scaled here instead of by the display mode
    // Same list, same order as WidgetShowing in hud_widescreen.cpp, which owns GUIScale for the training instruction box
    void* WidgetRoot(uint8_t* viewport)
    {
        static const wchar_t* widgets[] =
        {
            L"m_EscMenuWidget", L"m_DebriefingWidget", L"m_OptionsWidget", L"m_InGameOperativeSelectorWidget"
        };

        auto root = Script::Get<void*>(*reinterpret_cast<void**>(viewport + Console), L"Root");

        if (!Script::IsA(root, L"R6MenuInGameRootWindow"))
            return nullptr;

        for (auto name : widgets)
            if (Script::GetBool(Script::Get<void*>(root, name), L"bWindowVisible"))
                return root;

        return nullptr;
    }

    // The MP in-game root, which scales itself once it is told to, see FitMultiPlayer
    void* MultiPlayerRoot(uint8_t* viewport)
    {
        auto root = Script::Get<void*>(*reinterpret_cast<void**>(viewport + Console), L"Root");
        return Script::IsA(root, L"R6MenuInGameMultiPlayerRootWindow") ? root : nullptr;
    }

    // Created() pins the root at 640x480 with GUIScale 1. R6MenuLaptopWidget and R6MenuPlanningWidget
    // use those as root coordinates, so the script never sees the letterbox. Only GUIScale changes here.
    void Fit(void* root, uint8_t* viewport)
    {
        auto sizeX = static_cast<float>(Size(viewport, SizeX));
        auto sizeY = static_cast<float>(Size(viewport, SizeY));

        Script::Set<float>(root, L"GUIScale", scale);
        Script::Set<float>(root, L"RealWidth", DesignWidth * scale);
        Script::Set<float>(root, L"RealHeight", DesignHeight * scale);
        Script::Set<float>(root, L"WinWidth", DesignWidth);
        Script::Set<float>(root, L"WinHeight", DesignHeight);

        if (auto clip = static_cast<int32_t*>(Script::Field(root, L"ClippingRegion")))
        {
            clip[2] = static_cast<int32_t>(DesignWidth);
            clip[3] = static_cast<int32_t>(DesignHeight);
        }

        // RenderUWindow resizes the root to the canvas whenever the clip it last saw changes
        auto console = *reinterpret_cast<void**>(viewport + Console);
        Script::Set<float>(console, L"OldClipX", sizeX);
        Script::Set<float>(console, L"OldClipY", sizeY);
    }

    // R6MenuInGameRootWindow.WindowEvent repins the root to viewport pixels every frame, so GUIScale is the only thing here that is ours.
    // Children use 640x480 coordinates at 0,0, centered by ApplyResolutionOnWindowsPos.
    // Written absolutely so repeats do not compound.
    void FitInGame(void* root, uint8_t* viewport)
    {
        Script::Set<float>(root, L"GUIScale", scale);

        auto left = (Size(viewport, SizeX) / scale - DesignWidth) * 0.5f;
        auto top = (Size(viewport, SizeY) / scale - DesignHeight) * 0.5f;

        for (auto child = Script::Get<void*>(root, L"FirstChildWindow"); child; child = Script::Get<void*>(child, L"NextSiblingWindow"))
        {
            // Combo drop-downs are root children and position themselves in root coordinates
            if (Script::GetBool(child, L"bTransient"))
                continue;

            Script::Set<float>(child, L"WinLeft", left);
            Script::Set<float>(child, L"WinTop", top);
        }
    }

    // m_bScaleWindowToRoot makes this root handle its own 640x480 scaling and mouse conversion.
    // WidescreenHUD widens its UseVirtualSize space, so glyphs, hit-testing, and MouseX stay aligned.
    // R6MenuInGameRootWindow does not, so it is handled separately.
    void FitMultiPlayer(void* root, uint8_t* viewport)
    {
        // R6MenuInGameWritableMapWidget sets the flag itself, so it must be included here
        static const wchar_t* widgets[] =
        {
            L"m_pJoinTeamWidget", L"m_pIntermissionMenuWidget", L"m_pInGameEscMenu",
            L"m_pOptionsWidget", L"m_InGameOperativeSelectorWidget", L"m_InGameWritableMapWidget",
            L"m_pCountDownWidget"
        };

        auto showing = false;

        for (auto name : widgets)
            showing = showing || Script::GetBool(Script::Get<void*>(root, name), L"bWindowVisible");

        Script::SetBool(root, L"m_bScaleWindowToRoot", showing);

        if (!showing)
            return;

        auto left = (Size(viewport, SizeX) / scale - DesignWidth) * 0.5f;
        auto top = (Size(viewport, SizeY) / scale - DesignHeight) * 0.5f;

        for (auto child = Script::Get<void*>(root, L"FirstChildWindow"); child; child = Script::Get<void*>(child, L"NextSiblingWindow"))
        {
            if (Script::GetBool(child, L"bTransient"))
                continue;

            Script::Set<float>(child, L"WinLeft", left);
            Script::Set<float>(child, L"WinTop", top);

            // ApplyResolutionOnWindowsPos returns early while the flag is set, so OrgXOffset/YOffset can be updated here
            Script::Set<float>(child, L"OrgXOffset", left);
            Script::Set<float>(child, L"OrgYOffset", top);
        }
    }

    // The planning 3D view is rendered into a pixel rect the script hands over in 640x480 units.
    // Draw clears the actor once it has drawn it, so a rect is only ever seen once.
    void FitLevelFromMe()
    {
        auto actor = *reinterpret_cast<void**>(engineBase + LevelFromMeActor);
        auto rect = reinterpret_cast<int32_t*>(engineBase + LevelFromMeRect);

        if (!actor || std::equal(rect, rect + 4, lastRect))
            return;

        rect[0] = static_cast<int32_t>(offsetX + rect[0] * scale);
        rect[1] = static_cast<int32_t>(offsetY + rect[1] * scale);
        rect[2] = static_cast<int32_t>(rect[2] * scale);
        rect[3] = static_cast<int32_t>(rect[3] * scale);
        std::copy(rect, rect + 4, lastRect);
    }

    // WindowConsole.RenderUWindow clamps MouseX and MouseY to 0, which prevents the cursor from
    // reaching the letterbox. Remove the clamps while preserving the existing jump target.
    void FreeCursor(void* console)
    {
        if (bFreed)
            return;

        auto render = static_cast<uint8_t*>(Script::Declaration(console, L"RenderUWindow"));

        if (!render)
            return;

        auto code = *reinterpret_cast<uint8_t**>(render + Code);
        auto size = code ? *reinterpret_cast<int32_t*>(render + Code + 4) : 0;
        auto found = 0;

        for (auto i = 0; i + 24 <= size; ++i)
        {
            auto guard = code + i;

            if (guard[0] == 0x07 && guard[3] == 0xb0 && guard[4] == 0x01 && guard[9] == 0x39 &&
                guard[10] == 0x3f && guard[11] == 0x25 && guard[12] == 0x16 && guard[13] == 0x0f &&
                guard[14] == 0x01 && guard[19] == 0x1e && std::equal(guard + 5, guard + 9, guard + 15) &&
                !*reinterpret_cast<uint32_t*>(guard + 20))
            {
                guard[0] = 0x06;
                ++found;
            }
        }

        bFreed = true;

        if (found == 2)
            spdlog::info("NativeMenu: the menu cursor reaches the viewport edge");
        else
            spdlog::error("NativeMenu: {} of 2 MouseX/MouseY floors found in WindowConsole.RenderUWindow, the menu cursor stops at the 4:3 box", found);
    }

    void __fastcall Draw(void* self, void* edx, uint8_t* viewport, int blit, uint8_t* hitData, int* hitSize)
    {
        Measure(viewport);

        auto root = ShellRoot(viewport);
        auto inGame = root ? nullptr : WidgetRoot(viewport);
        auto multiPlayer = root || inGame ? nullptr : MultiPlayerRoot(viewport);

        bMenu = root != nullptr;
        bWidget = inGame != nullptr;

        // R6MenuDebriefingWidget suppresses the level render, other in-game widgets draw over the live game
        bDebrief = bWidget && Script::GetBool(Script::Get<void*>(inGame, L"m_DebriefingWidget"), L"bWindowVisible");

        if (root)
        {
            Fit(root, viewport);
            FitLevelFromMe();
        }
        else if (inGame)
        {
            FitInGame(inGame, viewport);
        }
        else if (multiPlayer)
        {
            FitMultiPlayer(multiPlayer, viewport);
        }

        // With RenderUWindow's own floor gone both limits are set here, one frame behind the
        // accumulator. The shell lays out in the 4:3 box, so the viewport starts behind its origin.
        auto console = *reinterpret_cast<void**>(viewport + Console);
        auto units = root || inGame ? scale : 1.0f;
        auto lowX = root ? -offsetX / scale : 0.0f;
        auto lowY = root ? -offsetY / scale : 0.0f;

        FreeCursor(console);
        Script::Set<float>(console, L"MouseX", std::clamp(Script::Get<float>(console, L"MouseX"), lowX, lowX + Size(viewport, SizeX) / units));
        Script::Set<float>(console, L"MouseY", std::clamp(Script::Get<float>(console, L"MouseY"), lowY, lowY + Size(viewport, SizeY) / units));

        // Draw leaves the letterboxed origin in place, so restore it after drawing.
        auto canvas = *reinterpret_cast<uint8_t**>(viewport + Canvas);
        auto orgX = *reinterpret_cast<float*>(canvas + OrgX);
        auto orgY = *reinterpret_cast<float*>(canvas + OrgY);

        shDraw.thiscall<void>(self, viewport, blit, hitData, hitSize);

        if (bMenu)
        {
            *reinterpret_cast<float*>(canvas + OrgX) = orgX;
            *reinterpret_cast<float*>(canvas + OrgY) = orgY;
        }
        else if (bWidget)
        {
            // RenderUWindow resets MouseScale each frame, so adjust it after rendering.
            Script::Set<float>(console, L"MouseScale", Script::Get<float>(console, L"MouseScale") / scale);
        }
    }

    // ebx is the viewport. Menus and debriefing are now laid out at the scaled viewport size.
    void ResRequestCheck(SafetyHookContext& ctx)
    {
        auto viewport = reinterpret_cast<uint8_t*>(ctx.ebx);
        auto canvas = *reinterpret_cast<uint8_t**>(viewport + Canvas);
        auto requests = reinterpret_cast<uint32_t*>(canvas + Requests);
        auto x = reinterpret_cast<int32_t*>(canvas + NewResX);
        auto y = reinterpret_cast<int32_t*>(canvas + NewResY);

        if (!(*requests & ChangeRes) || *x != 640 || *y != 480)
            return;

        // Use the configured resolution explicitly to avoid triggering the fade or mission videos.
        int width, height;
        if (Configured(width, height) && (Size(viewport, SizeX) != width || Size(viewport, SizeY) != height))
        {
            *x = width;
            *y = height;
            return;
        }

        *requests &= ~ChangeRes;
    }

    // ebx is the viewport. The level renders at the full aspect, strips outside the 4:3 box are cleared
    // before UWindow paints. Debriefing gets the strips too, but keeps the in-game root origin.
    void Letterbox(SafetyHookContext& ctx)
    {
        if (!bMenu && !bDebrief)
            return;

        auto viewport = reinterpret_cast<uint8_t*>(ctx.ebx);
        auto renDev = *reinterpret_cast<uint8_t**>(viewport + RenDev);
        auto d3d = renDev ? *reinterpret_cast<void**>(renDev + Direct3DDevice8) : nullptr;

        if (!d3d)
            return;

        auto width = Size(viewport, SizeX);
        auto height = Size(viewport, SizeY);
        auto insetX = static_cast<int32_t>(std::ceil(offsetX));
        auto insetY = static_cast<int32_t>(std::ceil(offsetY));

        RECT strips[4];
        uint32_t count = 0;

        if (insetX > 0)
        {
            strips[count++] = { 0, 0, insetX, height };
            strips[count++] = { width - insetX, 0, width, height };
        }

        if (insetY > 0)
        {
            strips[count++] = { 0, 0, width, insetY };
            strips[count++] = { 0, height - insetY, width, height };
        }

        if (count)
            Method<ClearFn>(d3d, DeviceClear)(d3d, count, strips, ClearTarget, 0xff000000, 1.0f, 0);

        if (!bMenu)
            return;

        // UWindow paints relative to whatever origin it is handed and restores it after each child
        auto canvas = *reinterpret_cast<uint8_t**>(viewport + Canvas);
        *reinterpret_cast<float*>(canvas + OrgX) = offsetX;
        *reinterpret_cast<float*>(canvas + OrgY) = offsetY;
    }

    // edx is the viewport. Offset the OS cursor onto the 4:3 box the script lays out in, which
    // leaves it negative over the left and top bars, the same range Draw bounds the accumulator to.
    void MouseStoredCheck(SafetyHookContext& ctx)
    {
        if (!bMenu)
            return;

        auto viewport = reinterpret_cast<uint8_t*>(ctx.edx);
        auto x = reinterpret_cast<float*>(viewport + WindowsMouseX);
        auto y = reinterpret_cast<float*>(viewport + WindowsMouseY);

        *x = std::clamp(*x, 0.0f, static_cast<float>(Size(viewport, SizeX))) - offsetX;
        *y = std::clamp(*y, 0.0f, static_cast<float>(Size(viewport, SizeY))) - offsetY;
    }

    // INDEX_NONE resolves to Client->FullscreenViewportX/Y, which stock leaves at the menu's 640x480.
    // Open at the configured resolution instead.
    void __fastcall TryRenderDevice(void* self, void* edx, const wchar_t* className, int newX, int newY, int fullscreen)
    {
        int width, height;
        if (newX == -1 && newY == -1 && fullscreen && Configured(width, height))
        {
            newX = width;
            newY = height;
        }

        shTryRenderDevice.thiscall<void>(self, className, newX, newY, fullscreen);
    }

    void ReleaseAll()
    {
        if (frame)  frame->Release();
        if (device) device->Release();
        frame = nullptr;
        device = nullptr;
        source = nullptr;
    }

    // The D3D8 device is d3d8to9's proxy, which answers a QueryInterface for the D3D9 device behind it
    bool Acquire(uint8_t* self)
    {
        auto d3d8 = *reinterpret_cast<IUnknown**>(self + Direct3DDevice8);
        if (d3d8 == source)
            return device != nullptr;

        ReleaseAll();
        source = d3d8;

        if (!d3d8 || FAILED(d3d8->QueryInterface(__uuidof(IDirect3DDevice9), reinterpret_cast<void**>(&device))))
        {
            static bool warned = false;
            if (!warned)
                spdlog::warn("NativeMenu: no D3D9 device behind the D3D8 one (wrapper d3d8.dll missing?), videos left at native size");
            warned = true;
            device = nullptr;
        }

        return device != nullptr;
    }

    // Stock decodes straight into the locked render target at the video's own size. Decoding into
    // a surface of that size and stretching it is the same copy plus one blit.
    void __fastcall DisplayVideo(uint8_t* self, void* edx, uint8_t* canvas, void* handle, int inScene)
    {
        auto bink = *reinterpret_cast<BinkHandle**>(canvas + Bink);

        if (!*reinterpret_cast<int32_t*>(canvas + Playing) || !bink)
            return;

        IDirect3DSurface9* target = nullptr;
        D3DSURFACE_DESC desc{};
        if (Acquire(self) && SUCCEEDED(device->GetRenderTarget(0, &target)))
            target->GetDesc(&desc);

        auto format = static_cast<int>(desc.Format) - BinkFirstFormat;
        if (!target || format < 0 || format >= static_cast<int>(std::size(BinkSurfaceType)))
        {
            if (target)
                target->Release();
            shDisplayVideo.thiscall<void>(self, canvas, handle, inScene);
            return;
        }

        if (!BinkWait(bink))
        {
            BinkDoFrame(bink);
            if (handle || bink->FrameNum != bink->Frames)
                BinkNextFrame(bink);
        }

        auto mode = bink->OpenFlags & BinkScaleMask;
        auto copyW = bink->Width;
        auto copyH = bink->Height;

        if (frame && (frameDesc.Width != copyW || frameDesc.Height != copyH || frameDesc.Format != desc.Format))
        {
            frame->Release();
            frame = nullptr;
        }

        if (!frame && SUCCEEDED(device->CreateOffscreenPlainSurface(copyW, copyH, desc.Format, D3DPOOL_DEFAULT, &frame, nullptr)))
            frame->GetDesc(&frameDesc);

        D3DLOCKED_RECT locked{};
        if (frame && SUCCEEDED(frame->LockRect(&locked, nullptr, 0)))
        {
            BinkCopyToBuffer(bink, locked.pBits, locked.Pitch, copyH, 0, 0, BinkSurfaceType[format] | BinkCopyFlags);
            frame->UnlockRect();

            auto viewport = *reinterpret_cast<uint8_t**>(canvas + Viewport);

            // The logos and intros run their own frame loop with nothing else drawn, so the scale is
            // taken here rather than from Draw, and the strips are cleared here too.
            if (!bProgress)
                Measure(viewport);

            auto width = copyW / (mode >= BinkScale2XW ? 2u : 1u) * scale;
            auto height = copyH / (mode >= BinkScale2XH && mode != BinkScale2XW ? 2u : 1u) * scale;
            float x, y;

            if (bProgress)
            {
                // The loading screen centers a fixed 200-pixel box on fractions of the viewport and
                // opens the video at 2x to fill it. At 640x480 that box is 100 and the video 1x.
                auto posX = static_cast<float>(*reinterpret_cast<int32_t*>(canvas + PosX));
                auto posY = static_cast<float>(*reinterpret_cast<int32_t*>(canvas + PosY));

                x = offsetX + (posX + copyW * 0.5f) * DesignWidth / Size(viewport, SizeX) * scale - width * 0.5f;
                y = offsetY + (posY + copyH * 0.5f) * DesignHeight / Size(viewport, SizeY) * scale - height * 0.5f;
            }
            else if (inScene)
            {
               // R6MenuVideo.Paint positions the briefing frame in 640x480 units, those units scale
                x = offsetX + *reinterpret_cast<int32_t*>(canvas + PosX) * scale;
                y = offsetY + *reinterpret_cast<int32_t*>(canvas + PosY) * scale;
            }
            else
            {
                // DisplayGameVideo already centers the frame in viewport pixels, so replace the offset rather than scale it
                x = offsetX + (DesignWidth * scale - width) * 0.5f;
                y = offsetY + (DesignHeight * scale - height) * 0.5f;
            }

            RECT dest
            {
                static_cast<LONG>(x), static_cast<LONG>(y),
                static_cast<LONG>(x + width), static_cast<LONG>(y + height),
            };

            if (!inScene)
                device->Clear(0, nullptr, D3DCLEAR_TARGET, 0xff000000, 1.0f, 0);

            if (FAILED(device->StretchRect(frame, nullptr, target, &dest, D3DTEXF_LINEAR)))
                device->StretchRect(frame, nullptr, target, &dest, D3DTEXF_NONE);
        }

        target->Release();
    }

    // Surfaces are kept across frames. SetRes and Exit drop them before Reset or Release can see them.
    int __fastcall SetRes(void* self, void* edx, void* viewport, int newX, int newY, int fullscreen)
    {
        ReleaseAll();
        return shSetRes.thiscall<int>(self, viewport, newX, newY, fullscreen);
    }

    void __fastcall Exit(void* self, void* edx, void* viewport)
    {
        ReleaseAll();
        shExit.thiscall<void>(self, viewport);
    }

    // The planning widget passes mouse coordinates relative to itself; add the letterbox offset.
    void ClickResultArgs(SafetyHookContext& ctx)
    {
        if (!bMenu)
            return;

        *reinterpret_cast<float*>(ctx.ebp - 0x24) += offsetX;
        *reinterpret_cast<float*>(ctx.ebp + 0x8) += offsetY;
    }

    void XYPointArgs(SafetyHookContext& ctx)
    {
        if (!bMenu)
            return;

        *reinterpret_cast<float*>(ctx.ebp - 0x18) += offsetX;
        *reinterpret_cast<float*>(ctx.ebp + 0x8) += offsetY;
    }

    // The loading screen lays out in viewport pixels, bring its background, text, and logo into the 4:3 box.
    void __fastcall PaintProgress(uint8_t* self, void* edx, void* url)
    {
        auto client = *reinterpret_cast<uint8_t**>(self + Client);
        auto viewport = client && *reinterpret_cast<int32_t*>(client + Viewports + 4) > 0
                      ? **reinterpret_cast<uint8_t***>(client + Viewports)
                      : nullptr;
        auto canvas = viewport ? *reinterpret_cast<uint8_t**>(viewport + Canvas) : nullptr;

        if (!canvas)
        {
            shPaintProgress.thiscall<void>(self, url);
            return;
        }

        Measure(viewport);

        auto at = [canvas](ptrdiff_t offset) -> float& { return *reinterpret_cast<float*>(canvas + offset); };
        float orgX = at(OrgX), orgY = at(OrgY), clipX = at(ClipX), clipY = at(ClipY), stretchX = at(StretchX), stretchY = at(StretchY);

        at(StretchX) = scale;
        at(StretchY) = scale;
        at(OrgX) = offsetX / scale;
        at(OrgY) = offsetY / scale;
        at(ClipX) = Size(viewport, SizeX) / scale;
        at(ClipY) = Size(viewport, SizeY) / scale;

        bProgress = true;
        shPaintProgress.thiscall<void>(self, url);
        bProgress = false;

        at(StretchX) = stretchX;
        at(StretchY) = stretchY;
        at(OrgX) = orgX;
        at(OrgY) = orgY;
        at(ClipX) = clipX;
        at(ClipY) = clipY;
    }

    // The loading text x is centered at native size, so translate it to the 640 center, y scales with height.
    // The measure call passes 0,0 and is left alone.
    void ProgressText(SafetyHookContext& ctx)
    {
        if (!bProgress)
            return;

        auto canvas = *reinterpret_cast<uint8_t**>(ctx.esp + 0x4);
        auto viewport = *reinterpret_cast<uint8_t**>(canvas + Viewport);
        auto x = reinterpret_cast<int32_t*>(ctx.esp + 0xc);
        auto y = reinterpret_cast<int32_t*>(ctx.esp + 0x10);

        if (!*x && !*y)
            return;

        // PaintProgress resets the canvas between the video and text, so restore the 4:3 origin here
        *reinterpret_cast<float*>(canvas + OrgX) = offsetX / scale;
        *reinterpret_cast<float*>(canvas + OrgY) = offsetY / scale;

        *x -= (Size(viewport, SizeX) - static_cast<int32_t>(DesignWidth)) / 2;
        *y = static_cast<int32_t>(*y * DesignHeight / Size(viewport, SizeY));
    }

    // The two backdrop tiles are identified by return address, the worker's glyph tiles pass through
    // FCanvasUtil parks the viewport at +0xca4
    void ProgressTile(SafetyHookContext& ctx)
    {
        auto rva = *reinterpret_cast<uintptr_t*>(ctx.esp) - engineBase;

        if (!bProgress || rva < ProgressFrom || rva >= ProgressTo)
            return;

        auto arg = reinterpret_cast<float*>(ctx.esp + 4);
        auto viewport = *reinterpret_cast<uint8_t**>(ctx.ecx + 0xca4);
        auto kx = DesignWidth * scale / Size(viewport, SizeX);
        auto ky = DesignHeight * scale / Size(viewport, SizeY);

        arg[0] = offsetX + arg[0] * kx;
        arg[1] = offsetY + arg[1] * ky;
        arg[2] = offsetX + arg[2] * kx;
        arg[3] = offsetY + arg[3] * ky;
    }

    // UCanvas::DrawTile and the text worker both resolve a point as (Org + Cur) * Stretch, so a
    // native the script hands 640x480 units is scaled by stretching it, after bringing back down
    // whatever the script already put in pixels. The cursor trims against Cur rather than the point
    // it resolves to, so it carries the letterbox itself and keeps the clip the script asked for.
    enum class Placed { Units, Pixels, Cursor }; // Pixels: the script already multiplied by GUIScale before calling the native

    template<typename Fn>
    void Stretched(uint8_t* canvas, float s, Placed placed, Fn call)
    {
        auto at = [canvas](ptrdiff_t offset) -> float& { return *reinterpret_cast<float*>(canvas + offset); };
        auto viewport = *reinterpret_cast<uint8_t**>(canvas + Viewport);

        float orgX = at(OrgX), orgY = at(OrgY), clipX = at(ClipX), clipY = at(ClipY);
        float curX = at(CurX), curY = at(CurY), stretchX = at(StretchX), stretchY = at(StretchY);

        // DrawTileClipped clips against CurX, so include the letterbox offset for the cursor.
        auto foldX = placed == Placed::Cursor ? orgX : 0.0f;
        auto foldY = placed == Placed::Cursor ? orgY : 0.0f;

        // R6MenuRootWindow.DrawMouse clips the cursor at its GUIScale-adjusted edge.
        // The stock 640x480 edge widens to the viewport while widget-specific clipping stays unchanged.
        auto edgeX = clipX > (DesignWidth - 1.0f) * s ? static_cast<float>(Size(viewport, SizeX)) : foldX + clipX;
        auto edgeY = clipY > (DesignHeight - 1.0f) * s ? static_cast<float>(Size(viewport, SizeY)) : foldY + clipY;

        at(StretchX) = s;
        at(StretchY) = s;
        at(OrgX) = (orgX - foldX) / s;
        at(OrgY) = (orgY - foldY) / s;
        // ClipTextWidth forgets GUIScale on its width, so pixel clips are still in window units.
        at(ClipX) = placed == Placed::Cursor ? edgeX / s : placed == Placed::Pixels ? clipX : clipX / s;
        at(ClipY) = placed == Placed::Cursor ? edgeY / s : clipY / s;

        if (placed != Placed::Units)
        {
            at(CurX) = (curX + foldX) / s;
            at(CurY) = (curY + foldY) / s;
        }

        call();

        if (placed != Placed::Units)
        {
            at(CurX) = at(CurX) * s - foldX;
            at(CurY) = at(CurY) * s - foldY;
        }

        at(StretchX) = stretchX;
        at(StretchY) = stretchY;
        at(OrgX) = orgX;
        at(OrgY) = orgY;
        at(ClipX) = clipX;
        at(ClipY) = clipY;
    }

    // Get the scale from the window's root; debriefing and options lists also draw through DrawText.
    // WindowConsole has a Root too, but its typed line is pixel-based and must not use it.
    float MenuScale(uint8_t* stack)
    {
        auto object = *reinterpret_cast<void**>(stack + 0x8);
        auto root = Script::IsA(object, L"UWindowWindow") ? Script::Get<void*>(object, L"Root") : nullptr;
        return bWidget || Script::IsA(root, L"R6MenuRootWindow") ? Script::Get<float>(root, L"GUIScale", 1.0f) : 1.0f;
    }

    // Roots draw the cursor at texture size. In-game roots use GUIScale while a widget is open,
    // otherwise the cursor follows the viewport height like HUDScale.
    float CursorScale(uint8_t* canvas, uint8_t* stack)
    {
        auto root = *reinterpret_cast<void**>(stack + 0x8);
        auto viewport = *reinterpret_cast<uint8_t**>(canvas + Viewport);

        if (!viewport || !Script::IsA(root, L"UWindowRootWindow"))
            return 1.0f;

        return bWidget || Script::IsA(root, L"R6MenuRootWindow")
             ? Script::Get<float>(root, L"GUIScale", 1.0f)
             : static_cast<float>(Size(viewport, SizeY)) / DesignHeight;
    }

    // R6WindowTextListBoxExt and R6WindowListMODS use window units without GUIScale, stretch the whole layout.
    void __fastcall ExecDrawText(uint8_t* self, void* edx, uint8_t* stack, void* result)
    {
        auto s = MenuScale(stack);

        if (s == 1.0f)
            shExecDrawText.thiscall<void>(self, stack, result);
        else
            Stretched(self, s, Placed::Units, [&] { shExecDrawText.thiscall<void>(self, stack, result); });
    }

    // ClipTextWidth has already multiplied its position by GUIScale, so only the glyphs are short
    void __fastcall ExecDrawTextClipped(uint8_t* self, void* edx, uint8_t* stack, void* result)
    {
        auto s = MenuScale(stack);

        if (s == 1.0f)
            shExecDrawTextClipped.thiscall<void>(self, stack, result);
        else
            Stretched(self, s, Placed::Pixels, [&] { shExecDrawTextClipped.thiscall<void>(self, stack, result); });
    }

    // R6MenuRootWindow.DrawMouse multiplies the cursor position by GUIScale, R6MenuInGameRootWindow does not.
    // Only the menu cursor needs to be converted back before the stretch.
    void __fastcall ExecDrawTile(uint8_t* self, void* edx, uint8_t* stack, void* result)
    {
        auto s = CursorScale(self, stack);

        if (s == 1.0f)
            shExecDrawTile.thiscall<void>(self, stack, result);
        else
            Stretched(self, s, bWidget ? Placed::Units : Placed::Cursor, [&] { shExecDrawTile.thiscall<void>(self, stack, result); });
    }

    void __fastcall ExecDrawTileClipped(uint8_t* self, void* edx, uint8_t* stack, void* result)
    {
        auto s = CursorScale(self, stack);

        if (s == 1.0f)
            shExecDrawTileClipped.thiscall<void>(self, stack, result);
        else
            Stretched(self, s, bWidget ? Placed::Units : Placed::Cursor, [&] { shExecDrawTileClipped.thiscall<void>(self, stack, result); });
    }
}

FEATURE(Engine, NativeMenu)
{
    auto engine = GetModuleHandleW(L"Engine");
    auto draw = GetProcAddress(engine, "?Draw@UGameEngine@@UAEXPAVUViewport@@HPAEPAH@Z");
    auto drawText = GetProcAddress(engine, "?execDrawText@UCanvas@@QAEXAAUFFrame@@QAX@Z");
    auto drawTextClipped = GetProcAddress(engine, "?execDrawTextClipped@UCanvas@@QAEXAAUFFrame@@QAX@Z");
    auto drawTile = GetProcAddress(engine, "?execDrawTile@UCanvas@@QAEXAAUFFrame@@QAX@Z");
    auto drawTileClipped = GetProcAddress(engine, "?execDrawTileClipped@UCanvas@@QAEXAAUFFrame@@QAX@Z");
    auto paintProgress = GetProcAddress(engine, "?PaintProgress@UGameEngine@@UAEXABVFURL@@@Z");
    auto tile = GetProcAddress(engine, "?DrawTile@FCanvasUtil@@QAEXMMMMMMMMMPAVUMaterial@@VFColor@@@Z");
    gConfig = reinterpret_cast<void**>(GetProcAddress(GetModuleHandleW(L"Core"), "?GConfig@@3PAVFConfigCache@@A"));

    if (!draw || !drawText || !drawTextClipped || !drawTile || !drawTileClipped || !paintProgress || !tile || !gConfig)
    {
        spdlog::error("NativeMenu: UGameEngine::Draw {}, execDrawText {}, execDrawTextClipped {}, execDrawTile {}, execDrawTileClipped {}, PaintProgress {}, FCanvasUtil::DrawTile {}, GConfig {}",
                      (void*)draw, (void*)drawText, (void*)drawTextClipped, (void*)drawTile, (void*)drawTileClipped, (void*)paintProgress, (void*)tile, (void*)gConfig);
        return;
    }

    engineBase = reinterpret_cast<uintptr_t>(engine);

    shDraw = safetyhook::create_inline(draw, Draw);
    shExecDrawText = safetyhook::create_inline(drawText, ExecDrawText);
    shExecDrawTextClipped = safetyhook::create_inline(drawTextClipped, ExecDrawTextClipped);
    shExecDrawTile = safetyhook::create_inline(drawTile, ExecDrawTile);
    shExecDrawTileClipped = safetyhook::create_inline(drawTileClipped, ExecDrawTileClipped);
    shPaintProgress = safetyhook::create_inline(paintProgress, PaintProgress);
    mhProgressText = safetyhook::create_mid(reinterpret_cast<void*>(engineBase + DrawStringWorker), ProgressText);
    mhProgressTile = safetyhook::create_mid(tile, ProgressTile);
    mhResRequest = safetyhook::create_mid(reinterpret_cast<void*>(engineBase + ResRequest), ResRequestCheck);
    mhBeforeMenus = safetyhook::create_mid(reinterpret_cast<void*>(engineBase + BeforeMenus), Letterbox);
    spdlog::info("NativeMenu: menus run at the game resolution, scaled to fit");
}

FEATURE(WinDrv, NativeMenuBoot)
{
    auto winDrv = GetModuleHandleW(L"WinDrv");
    auto tryRenderDevice = GetProcAddress(winDrv, "?TryRenderDevice@UWindowsViewport@@UAEXPBGHHH@Z");
    auto wndProc = GetProcAddress(winDrv, "?ViewportWndProc@UWindowsViewport@@QAEJIIJ@Z");
    auto base = reinterpret_cast<uintptr_t>(winDrv);

    // The cursor store is inside ViewportWndProc and is base + RVA, so the export doubles as the guard
    if (!tryRenderDevice || !wndProc || reinterpret_cast<uintptr_t>(wndProc) >= base + MouseStored)
    {
        spdlog::error("NativeMenu: TryRenderDevice {}, ViewportWndProc {} - boot resolution and menu mouse left alone",
                      (void*)tryRenderDevice, (void*)wndProc);
        return;
    }

    shTryRenderDevice = safetyhook::create_inline(tryRenderDevice, TryRenderDevice);
    mhMouseStored = safetyhook::create_mid(reinterpret_cast<void*>(base + MouseStored), MouseStoredCheck);
}

FEATURE(D3DDrv, NativeMenuVideo)
{
    auto d3dDrv = GetModuleHandleW(L"D3DDrv");
    auto bink = GetModuleHandleW(L"binkw32");
    auto displayVideo = GetProcAddress(d3dDrv, "?DisplayVideo@UD3DRenderDevice@@UAEXPAVUCanvas@@PAXH@Z");
    auto setRes = GetProcAddress(d3dDrv, "?SetRes@UD3DRenderDevice@@UAEHPAVUViewport@@HHH@Z");
    auto exit = GetProcAddress(d3dDrv, "?Exit@UD3DRenderDevice@@UAEXPAVUViewport@@@Z");

    BinkWait           = reinterpret_cast<decltype(BinkWait)>(GetProcAddress(bink, "_BinkWait@4"));
    BinkDoFrame        = reinterpret_cast<decltype(BinkDoFrame)>(GetProcAddress(bink, "_BinkDoFrame@4"));
    BinkNextFrame      = reinterpret_cast<decltype(BinkNextFrame)>(GetProcAddress(bink, "_BinkNextFrame@4"));
    BinkCopyToBuffer   = reinterpret_cast<decltype(BinkCopyToBuffer)>(GetProcAddress(bink, "_BinkCopyToBuffer@28"));

    if (!displayVideo || !setRes || !exit || !BinkWait || !BinkDoFrame || !BinkNextFrame || !BinkCopyToBuffer)
    {
        spdlog::error("NativeMenu: DisplayVideo {}, SetRes {}, Exit {}, BinkWait {}, BinkDoFrame {}, BinkNextFrame {}, BinkCopyToBuffer {}",
                      (void*)displayVideo, (void*)setRes, (void*)exit, (void*)BinkWait, (void*)BinkDoFrame, (void*)BinkNextFrame, (void*)BinkCopyToBuffer);
        return;
    }

    shDisplayVideo = safetyhook::create_inline(displayVideo, DisplayVideo);
    shSetRes = safetyhook::create_inline(setRes, SetRes);
    shExit = safetyhook::create_inline(exit, Exit);
    spdlog::info("NativeMenu: videos scaled to the 4:3 box");
}

// Both natives are exports, and the sites inside them are base + RVA, so the exports double as the guard
FEATURE(R6Game, NativeMenuPlanning)
{
    auto r6game = GetModuleHandleW(L"R6Game");
    auto base = reinterpret_cast<uintptr_t>(r6game);
    auto clickResult = GetProcAddress(r6game, "?execGetClickResult@AR6PlanningCtrl@@QAEXAAUFFrame@@QAX@Z");
    auto xyPoint = GetProcAddress(r6game, "?execGetXYPoint@AR6PlanningCtrl@@QAEXAAUFFrame@@QAX@Z");

    if (reinterpret_cast<uintptr_t>(clickResult) != base + GetClickResult || reinterpret_cast<uintptr_t>(xyPoint) != base + GetXYPoint)
    {
        spdlog::error("NativeMenu: execGetClickResult {}, execGetXYPoint {}, expected base + {:#x} and {:#x} - planning clicks left alone",
                      (void*)clickResult, (void*)xyPoint, GetClickResult, GetXYPoint);
        return;
    }

    // The zoom about the 640x480 center is redirected to the viewport's. The constants stay, only
    // these four operands move, and the pivot is refreshed from the viewport every Draw.
    for (auto rva : ClickPivotX)
        if (injector::ReadMemory<uintptr_t>(base + rva, true) == base + Const320)
            injector::WriteMemory(base + rva, &centerX, true);

    for (auto rva : ClickPivotY)
        if (injector::ReadMemory<uintptr_t>(base + rva, true) == base + Const240)
            injector::WriteMemory(base + rva, &centerY, true);

    mhClickResult = safetyhook::create_mid(reinterpret_cast<void*>(base + GetClickResultArgs), ClickResultArgs);
    mhXYPoint = safetyhook::create_mid(reinterpret_cast<void*>(base + GetXYPointArgs), XYPointArgs);
    spdlog::info("NativeMenu: planning map clicks follow the letterbox");
}
