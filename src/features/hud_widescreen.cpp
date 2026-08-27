#include "stdafx.h"
#include "common.hpp"
#include "config.hpp"
#include "feature.hpp"
#include "script.hpp"

static constexpr bool bWidescreenHUD = true;    // Prevents the HUD, reticules and scope overlay from stretching on widescreen
static constexpr float fHUDScale     = 1.0f;    // 0 is the stock native size, 1 matches the 640x480 proportions

static Config::Value bCenterOptics("HUD", "CenterOptics", true);
static Config::Value nHideCrosshairZoomed("HUD", "HideCrosshairWhenZoomed", 0);

namespace
{
    constexpr float DesignWidth  = 800.0f;
    constexpr float DesignHeight = 600.0f;

    // R6WithWeaponReticule divides explicitly against 640x480, not 800x600
    constexpr float ReticuleWidth  = 640.0f;
    constexpr float ReticuleHeight = 480.0f;

    constexpr ptrdiff_t OrgX        = 0x38;
    constexpr ptrdiff_t OrgY        = 0x3c;
    constexpr ptrdiff_t ClipX       = 0x40;
    constexpr ptrdiff_t ClipY       = 0x44;
    constexpr ptrdiff_t CurX        = 0x50;
    constexpr ptrdiff_t CurY        = 0x54;
    constexpr ptrdiff_t Viewport    = 0x7c;
    constexpr ptrdiff_t StretchX    = 0x94;
    constexpr ptrdiff_t StretchY    = 0x98;
    constexpr ptrdiff_t VirtualResY = 0xa0;

    constexpr ptrdiff_t ViewportSizeX = 0xa4;
    constexpr ptrdiff_t ViewportSizeY = 0xa8;

    constexpr ptrdiff_t ScaleX = 0x530;
    constexpr ptrdiff_t ScaleY = 0x534;

    // IDirect3DDevice8 vtable slots from D3DDrv's own calls, not d3d8.h
    constexpr ptrdiff_t Direct3DDevice = 0x468c;
    constexpr ptrdiff_t DeviceClear        = 0x90;
    constexpr ptrdiff_t DeviceSetTransform = 0x94;
    constexpr ptrdiff_t DeviceGetViewport  = 0xa4;
    constexpr uint32_t WorldTransform = 256;
    constexpr uint32_t ClearTarget    = 1;

    // Internal to execDrawNativeHUD - base + RVA, not exports
    constexpr uintptr_t WaypointStretchReset = 0xea3f;
    constexpr uintptr_t WaypointFOVCosCall   = 0xeb9e;
    constexpr uintptr_t WaypointLabelX       = 0xf284;

    // Engine.dll - optics and thermal vision passes
    constexpr uintptr_t ScopeMask   = 0xa6095;
    constexpr uintptr_t ScopeAdd    = 0xa611a;
    constexpr uintptr_t ThermalMask = 0xa6ec6;
    constexpr uintptr_t ThermalAdd  = 0xa6f53;

    // Device vignettes from UGameEngine::Draw
    constexpr uintptr_t DeviceMask[] = { 0xabf6c, 0xac089, 0xac1a6 };

    // Night vision is not a tile - drawn on clip-space quad shared with flash/fade passes
    constexpr uintptr_t FullScreenEffects = 0x9b00;
    constexpr uintptr_t VisionConeMask    = 0xa1bb;
    constexpr uintptr_t VisionConeScene   = 0xa264;
    constexpr uintptr_t VisionConeRemask  = 0xa4af;
    constexpr uintptr_t VisionConeJoin    = 0xa632;

    // One instruction before the wrap test
    constexpr uintptr_t ConsoleWrapTest = 0x12dbef;

    // The push of the clip width UGameEngine::Draw gives the two HUD message lists
    constexpr uintptr_t MessageClipWidth = 0xaccba;

    // Left margin pushed by the message loop at 0xacd68
    constexpr float MessageLeft = 4.0f;

    // Common worker for all text drawing paths
    constexpr uintptr_t DrawStringWorker = 0x8ac40;
    constexpr uintptr_t ClipTextNative   = 0x8c810;
    constexpr uintptr_t ClipTextDraw     = 0x8ca27;
    constexpr uintptr_t EngineDrawFrom   = 0xaa6e0;
    constexpr uintptr_t EngineDrawTo     = 0xae6ea;
    constexpr uintptr_t TextSizeResult = 0x8bba0;

    // R6MenuInGameInstructionWidget.uc's default m_fYInstructionTextPos, in 640x480 units.
    constexpr float InstructionTop = 35.0f;

    enum Anchor { Left, Center, Right, World };

    struct Region
    {
        uintptr_t from;
        uintptr_t to;
        Anchor    anchor;
    };

    // Keyed on the return address, so bounds are one instruction past the call. Unlisted is Left.
    constexpr Region regions[] =
    {
        { 0xbeb0, 0xc30a, Right  },  // DrawCharacterInfo
        { 0xc340, 0xcbcf, Right  },  // DisplayOtherTeamInfo
        { 0xd338, 0xdbcc, Right  },  // DisplayCurrentTeamInfo
        { 0xe592, 0xf1b0, Center },  // Order and action text
        { 0xf1b0, 0xf6a0, World  },  // DisplayWaypointInfo
        { 0xf6a0, 0xf752, Center },  // Go-code text
    };

    SafetyHookInline shDrawNativeHUD{};
    SafetyHookInline shSetStretch{};
    SafetyHookInline shWrappedPrint{};
    SafetyHookInline shUseVirtualSize{};
    SafetyHookInline shExecUseVirtualSize{};
    SafetyHookInline shExecDrawTile{};
    SafetyHookInline shExecDrawText{};
    SafetyHookInline shDrawStringWorker{};
    SafetyHookMid mhClipTextNative{};
    SafetyHookMid mhTextSize{};
    SafetyHookMid mhDrawTile{};
    SafetyHookMid mhDrawTileRotated{};
    SafetyHookMid mhDrawString{};
    SafetyHookMid mhWrappedPrintf{};
    SafetyHookMid mhWrappedStrLenf{};
    SafetyHookMid mhConsoleWrap{};
    SafetyHookMid mhMessageClip{};
    SafetyHookMid mhWaypointStretch{};
    SafetyHookMid mhWaypointFOV{};
    SafetyHookMid mhWaypointLabel{};
    SafetyHookMid mhVisionConeMask{};
    SafetyHookMid mhVisionConeScene{};
    SafetyHookMid mhVisionConeRemask{};
    SafetyHookMid mhVisionConeEnd{};

    uint8_t*  hud   = nullptr;
    void*     reticule = nullptr;
    void*     aiming   = nullptr;
    bool      optics   = false;
    bool      zoomed   = false;
    bool      dot      = false;
    void*     rose = nullptr;
    float     roseScale = 1.0f;
    float     roseOffset = 0.0f;
    bool      virtualSize = false;
    uintptr_t base  = 0;
    uintptr_t limit = 0;

    uintptr_t engineBase = 0;

    void (__fastcall* drawTilePrimitive)(void*, void*, float, float, float, float, float, float, float, float, float, void*, uint32_t) = nullptr;

    float shift    = 0.0f;
    bool  bShift   = false;
    bool  bMeasure = false;
    bool  bWindowText = false;
    float windowScale = 1.0f;

    float Scale(ptrdiff_t offset) { return *reinterpret_cast<float*>(hud + offset); }

    // m_fScaleX is SizeX / 800, so this is the width the HUD gains over the 4:3 layout
    float Delta() { return DesignWidth * (Scale(ScaleX) - Scale(ScaleY)); }

    float Weight(Anchor anchor) { return anchor == Right ? 1.0f : anchor == Center ? 0.5f : 0.0f; }

    // The primitives are shared with the reticles, the tooltip and the menus
    bool Gated(uintptr_t ret) { return hud && ret >= base && ret < limit; }

    Anchor AnchorFor(uintptr_t ret)
    {
        for (auto& region : regions)
            if (ret - base >= region.from && ret - base < region.to)
                return region.anchor;

        return Left;
    }

    // FCanvasUtil::DrawTile takes corners, not extents, so both X coordinates move
    void Correct(float* arg, Anchor anchor)
    {
        auto scale = Scale(ScaleY) / Scale(ScaleX);

        // A world tile is centered on a projected pixel, so it narrows about that point
        if (anchor == World)
        {
            auto center = (arg[0] + arg[2]) * 0.5f;

            arg[0] = center + (arg[0] - center) * scale;
            arg[2] = center + (arg[2] - center) * scale;
            return;
        }

        auto offset = Weight(anchor) * Delta();

        arg[0] = arg[0] * scale + offset;
        arg[2] = arg[2] * scale + offset;
    }

    // Compass rose scales per axis off C.SizeX/800 and C.SizeY/600 (off viewport, not in HUD)
    bool RoseTransform(uint8_t* canvas)
    {
        auto viewport = canvas ? *reinterpret_cast<uint8_t**>(canvas + Viewport) : nullptr;

        if (!viewport)
            return false;

        auto sizeX = static_cast<float>(*reinterpret_cast<int32_t*>(viewport + ViewportSizeX));
        auto sizeY = static_cast<float>(*reinterpret_cast<int32_t*>(viewport + ViewportSizeY));
        auto width = sizeY * 4.0f / 3.0f;

        // 4:3 and narrower is already round; the early out leaves those resolutions untouched
        if (sizeX <= 0.0f || sizeY <= 0.0f || sizeX <= width)
            return false;

        roseScale = width / sizeX;
        roseOffset = (sizeX - width) * 0.5f;
        return true;
    }

    void Rose(float* arg)
    {
        arg[0] = arg[0] * roseScale + roseOffset;
        arg[2] = arg[2] * roseScale + roseOffset;
    }

    // A square texture on a viewport-sized quad goes oval at any wider aspect. FOV is hor+, so
    // the vertical extent is already right - confining rather than growing keeps the two agreeing.
    void ConfineTo43(float* arg)
    {
        auto width = arg[2] - arg[0];
        auto height = arg[3] - arg[1];

        if (width * 3.0f > height * 4.0f)
        {
            auto inset = (width - height * 4.0f / 3.0f) * 0.5f;

            arg[0] += inset;
            arg[2] -= inset;
        }
        else
        {
            auto inset = (height - width * 3.0f / 4.0f) * 0.5f;

            arg[1] += inset;
            arg[3] -= inset;
        }
    }

    // Confining leaves the strips showing world, so they are filled with black tiles through the
    // same primitive. These re-enter the hook and pass through: the return address is in this dll.
    // The source rect is degenerate, so the strip uses the overlay's corner texel extended outward.
    // White leaves that texel unchanged, which excludes ADS overlays that are not fullscreen.
    void FillOutside(void* util, float* arg, float width, float height, uint32_t tint)
    {
        auto material = reinterpret_cast<void**>(arg)[9];

        if (arg[0] > 0.0f)
        {
            drawTilePrimitive(util, nullptr, 0.0f, 0.0f, arg[0], height, 0.0f, 0.0f, 0.0f, 0.0f, arg[8], material, tint);
            drawTilePrimitive(util, nullptr, arg[2], 0.0f, width, height, 0.0f, 0.0f, 0.0f, 0.0f, arg[8], material, tint);
        }
        else if (arg[1] > 0.0f)
        {
            drawTilePrimitive(util, nullptr, 0.0f, 0.0f, width, arg[1], 0.0f, 0.0f, 0.0f, 0.0f, arg[8], material, tint);
            drawTilePrimitive(util, nullptr, 0.0f, arg[3], width, height, 0.0f, 0.0f, 0.0f, 0.0f, arg[8], material, tint);
        }
    }

    struct D3DViewport { uint32_t x, y, width, height; float minZ, maxZ; };
    struct D3DRect      { int32_t x1, y1, x2, y2; };

    using ClearFn        = int32_t(__stdcall*)(void*, uint32_t, const D3DRect*, uint32_t, uint32_t, float, uint32_t);
    using SetTransformFn = int32_t(__stdcall*)(void*, uint32_t, const float*);
    using GetViewportFn  = int32_t(__stdcall*)(void*, D3DViewport*);

    template<typename Fn>
    Fn Method(void* object, ptrdiff_t slot)
    {
        return *reinterpret_cast<Fn*>(*reinterpret_cast<uint8_t**>(object) + slot);
    }

    constexpr float Identity[16] =
    {
        1.0f, 0.0f, 0.0f, 0.0f,
        0.0f, 1.0f, 0.0f, 0.0f,
        0.0f, 0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 1.0f,
    };

    float coneWorld[16] = {};
    bool  bVisionCone = false;

    bool ConeViewport(void* device, D3DViewport& viewport)
    {
        return device
            && Method<GetViewportFn>(device, DeviceGetViewport)(device, &viewport) >= 0
            && viewport.width > 0 && viewport.height > 0;
    }

    void ConeWorld(uintptr_t self, const float* world)
    {
        auto device = *reinterpret_cast<void**>(self + Direct3DDevice);

        if (device)
            Method<SetTransformFn>(device, DeviceSetTransform)(device, WorldTransform, world);
    }

    // esi is the UD3DRenderDevice. Past the block's SetStreamSource, before its first draw. The
    // vertices are XYZ through fixed-function transform, so world X narrows the quad about center.
    void VisionConeMaskBegin(SafetyHookContext& ctx)
    {
        auto device = *reinterpret_cast<void**>(ctx.esi + Direct3DDevice);

        D3DViewport viewport{};
        if (!ConeViewport(device, viewport))
            return;

        auto width = static_cast<float>(viewport.width);
        auto height = static_cast<float>(viewport.height);

        // 4:3 and narrower is already round; the early out leaves those resolutions untouched.
        if (width * 3.0f <= height * 4.0f)
            return;

        std::copy(std::begin(Identity), std::end(Identity), std::begin(coneWorld));
        coneWorld[0] = height * 4.0f / 3.0f / width;

        ConeWorld(ctx.esi, coneWorld);
        bVisionCone = true;
    }

    // The noise and the amplified scene copy are screen aligned - the copy is the picture itself,
    // and scaling it lays a squashed ghost of every bright edge over the real one.
    void VisionConeSceneBegin(SafetyHookContext& ctx)
    {
        if (bVisionCone)
            ConeWorld(ctx.esi, Identity);
    }

    // The second mask pass and the add pass are artwork again, so they take the scale back.
    void VisionConeMaskResume(SafetyHookContext& ctx)
    {
        if (bVisionCone)
            ConeWorld(ctx.esi, coneWorld);
    }

    // The join point both branches reach. Clear takes rectangles, so the strips are one call, and
    // the HUD's own panels draw later and land on top.
    void VisionConeEnd(SafetyHookContext& ctx)
    {
        if (!bVisionCone)
            return;

        bVisionCone = false;

        ConeWorld(ctx.esi, Identity);

        auto device = *reinterpret_cast<void**>(ctx.esi + Direct3DDevice);
        D3DViewport viewport{};
        if (!ConeViewport(device, viewport))
            return;

        auto width = static_cast<int32_t>(viewport.width);
        auto height = static_cast<int32_t>(viewport.height);

        // Rounded up, so the strips meet the quad from the outside.
        auto inset = static_cast<int32_t>(std::ceil(static_cast<float>(width) * (1.0f - coneWorld[0]) * 0.5f));
        if (inset <= 0)
            return;

        const D3DRect strips[] =
        {
            { 0, 0, inset, height },
            { width - inset, 0, width, height },
        };

        Method<ClearFn>(device, DeviceClear)(device, 2, strips, ClearTarget, 0xff000000, 1.0f, 0);
    }

    // 0 is the stock native size, 1 matches 640x480 proportions
    // Derived once because clip widths and wrap thresholds below must match the glyph scale
    float HUDScale(float sizeY)
    {
        return 1.0f + (sizeY / ReticuleHeight - 1.0f) * fHUDScale;
    }

    float ViewportScale(uint8_t* canvas)
    {
        auto viewport = canvas ? *reinterpret_cast<uint8_t**>(canvas + Viewport) : nullptr;

        if (!fHUDScale || !viewport)
            return 1.0f;

        return HUDScale(static_cast<float>(*reinterpret_cast<int32_t*>(viewport + ViewportSizeY)));
    }

    // Only scale untransformed full-viewport canvases
    float TextScale(uint8_t* canvas)
    {
        auto viewport = *reinterpret_cast<uint8_t**>(canvas + Viewport);

        if (!fHUDScale || !viewport)
            return 1.0f;

        auto sizeX = static_cast<float>(*reinterpret_cast<int32_t*>(viewport + ViewportSizeX));
        auto sizeY = static_cast<float>(*reinterpret_cast<int32_t*>(viewport + ViewportSizeY));

        if (*reinterpret_cast<float*>(canvas + StretchX) != 1.0f || *reinterpret_cast<float*>(canvas + StretchY) != 1.0f)
            return 1.0f;

        if (*reinterpret_cast<float*>(canvas + ClipX) != sizeX || *reinterpret_cast<float*>(canvas + ClipY) != sizeY)
            return 1.0f;

        return HUDScale(sizeY);
    }

    // The wrap threshold is Viewport->SizeX against widths measured at native size, so scaled text
    // never wraps. Scaling the scratch total is the same test as dividing SizeX down.
    void ConsoleWrap(SafetyHookContext& ctx)
    {
        auto viewport = *reinterpret_cast<uint8_t**>(ctx.ebp - 0x30);

        if (!fHUDScale || !viewport)
            return;

        auto scale = HUDScale(static_cast<float>(*reinterpret_cast<int32_t*>(viewport + ViewportSizeY)));

        if (scale > 1.0f)
            ctx.ecx = static_cast<uintptr_t>(static_cast<int32_t>(static_cast<float>(static_cast<int32_t>(ctx.ecx)) * scale));
    }

    // Messages clip against a fraction of SizeX, but glyphs scale from SizeY. Reconstruct the
    // 4:3 clip width so wider viewports don't show extra text.
    void MessageClip(SafetyHookContext& ctx)
    {
        if (!fHUDScale)
            return;

        // ebx is the viewport
        auto sizeX = static_cast<float>(*reinterpret_cast<int32_t*>(ctx.ebx + ViewportSizeX));
        auto sizeY = static_cast<float>(*reinterpret_cast<int32_t*>(ctx.ebx + ViewportSizeY));
        auto width = sizeY * ReticuleWidth / ReticuleHeight;
        auto scale = HUDScale(sizeY);
        auto clip = static_cast<float>(static_cast<int32_t>(ctx.eax));

        if (sizeX > width)
            clip = clip * width / sizeX;

        // MessageLeft stays in screen pixels instead of scaling with the HUD, so adjust the clip
        // to account for the resulting canvas space offset.
        ctx.eax = static_cast<uintptr_t>(static_cast<int32_t>(clip - (MessageLeft - std::floor(MessageLeft / scale)) * scale));
    }

    void DrawTile(SafetyHookContext& ctx)
    {
        auto ret = *reinterpret_cast<uintptr_t*>(ctx.esp);
        auto arg = reinterpret_cast<float*>(ctx.esp + 4);
        auto rva = ret - engineBase;

        auto device = false;

        for (auto mask : DeviceMask)
            device = device || rva == mask;

        if (rose)
            Rose(arg);
        else if (Gated(ret))
            Correct(arg, AnchorFor(ret));
        else if (device || rva == ScopeMask || rva == ScopeAdd || rva == ThermalMask || rva == ThermalAdd)
        {
            auto width = arg[2];
            auto height = arg[3];

            // Optics passes use a USize - 1 source rect, shifting the texture center by half a texel
            // Device vignettes use a separate call site and are left unchanged
            if (bCenterOptics && !device)
            {
                arg[6] += 1.0f;
                arg[7] += 1.0f;
                arg[0] -= 0.5f;
                arg[1] -= 0.5f;
                arg[2] -= 0.5f;
                arg[3] -= 0.5f;
            }

            // Any reticle drawn later this frame is inside the optic
            optics = optics || !device;

            ConfineTo43(arg);

            // Once per mode is enough, and the mask is the first of its pair.
            if (device || rva == ScopeMask || rva == ThermalMask)
                FillOutside(reinterpret_cast<void*>(ctx.ecx), arg, width, height, device ? 0xff000000 : 0xffffffff);
        }
    }

    void DrawTileRotated(SafetyHookContext& ctx)
    {
        auto ret = *reinterpret_cast<uintptr_t*>(ctx.esp);
        auto arg = reinterpret_cast<float*>(ctx.esp + 4);

        // Canvas.DrawRect and DrawIcon reach here through UCanvas::DrawTile, not FCanvasUtil::DrawTile
        if (aiming)
        {
            // R6WithWeaponReticule draws its center dot as the one square rect, the four accuracy
            // ticks are always long in one axis. A collapsed rect draws nothing
            if (zoomed && (nHideCrosshairZoomed == 2 ||
                (nHideCrosshairZoomed == 1 && dot && arg[2] - arg[0] == arg[3] - arg[1])))
            {
                arg[2] = arg[0];
                arg[3] = arg[1];
                return;
            }
        }

        if (rose)
            Rose(arg);
        else if (Gated(ret))
            Correct(arg, World);
    }

    // Waypoint coordinates are projected pixels; undo the canvas Y scale before drawing
    void DrawString(SafetyHookContext& ctx)
    {
        auto ret = *reinterpret_cast<uintptr_t*>(ctx.esp);
        if (!Gated(ret))
            return;

        auto arg = reinterpret_cast<int32_t*>(ctx.esp + 4);
        auto anchor = AnchorFor(ret);

        if (anchor == World)
        {
            arg[1] = static_cast<int32_t>(arg[1] / Scale(ScaleY));
            arg[2] = static_cast<int32_t>(arg[2] / Scale(ScaleY));
        }
        else
            arg[1] += static_cast<int32_t>(Weight(anchor) * Delta() / Scale(ScaleY));
    }

    // Waypoint code writes StretchX/Y directly, bypassing SetStretch
    void WaypointStretch(SafetyHookContext& ctx)
    {
        auto canvas = *reinterpret_cast<uint8_t**>(ctx.ebp - 0x14);

        *reinterpret_cast<float*>(canvas + StretchX) = Scale(ScaleY);
        *reinterpret_cast<float*>(canvas + StretchY) = Scale(ScaleY);
    }

    // Stock centers the label with a design-unit width against a pixel projection, so it only
    // agrees at 800x600. A stock bug, visible at 4:3.
    void WaypointLabel(SafetyHookContext& ctx)
    {
        auto projected = *reinterpret_cast<float*>(ctx.ebp - 0x64);
        auto width = static_cast<float>(*reinterpret_cast<int32_t*>(ctx.ebp - 0x50));

        ctx.eax = static_cast<uintptr_t>(static_cast<int32_t>(projected - width * Scale(ScaleY) * 0.5f));
    }

    float AdjustFOV(float fov, float aspect)
    {
        constexpr double pi = 3.14159265358979323846;
        constexpr double baseAspect = 4.0 / 3.0;

        return static_cast<float>(std::round(2.0 * std::atan((aspect / baseAspect) * std::tan(fov / 2.0 * (pi / 180.0))) * (180.0 / pi) * 100.0) / 100.0);
    }

    // The on/off-screen switch has its own FOV copy that never goes through FCameraSceneNode, so
    // the cone stays at the narrow 4:3 angle. Re-widened here from the half-angle on the stack.
    void WaypointFOV(SafetyHookContext& ctx)
    {
        constexpr double pi = 3.14159265358979323846;

        auto arg = reinterpret_cast<double*>(ctx.esp);
        auto aspect = (Scale(ScaleX) * DesignWidth) / (Scale(ScaleY) * DesignHeight);
        auto fov = AdjustFOV(static_cast<float>(*arg * 2.0 * (180.0 / pi)), aspect);

        *arg = fov * 0.5 * (pi / 180.0);
    }

    // Variadic, so __cdecl with no return to hook. WrappedPrint does the work.
    void WrappedPrintf(SafetyHookContext& ctx)
    {
        auto ret = *reinterpret_cast<uintptr_t*>(ctx.esp);
        if (!Gated(ret))
            return;

        shift = Weight(AnchorFor(ret)) * Delta() / Scale(ScaleY);
        bShift = true;
    }

    // NativeMenu lays these out at GUIScale, keep this list in the same order as WidgetRoot
    bool WidgetShowing(void* root)
    {
        static const wchar_t* widgets[] =
        {
            L"m_EscMenuWidget", L"m_DebriefingWidget", L"m_OptionsWidget", L"m_InGameOperativeSelectorWidget"
        };

        for (auto name : widgets)
            if (Script::GetBool(Script::Get<void*>(root, name), L"bWindowVisible"))
                return true;

        return false;
    }

    // Root.GUIScale threads through the whole box (stable: only re-runs when WinWidth changes)
    float WindowScale(void* object)
    {
        // WindowConsole declares a Root of its own, and this is reached from two general Canvas
        // natives, so the caller has to be a window before its root means anything
        auto root = Script::IsA(object, L"UWindowWindow") ? Script::Get<void*>(object, L"Root") : nullptr;

        // The main menu's scale is NativeMenu's, only the glyphs and measurements follow it here
        if (Script::IsA(root, L"R6MenuRootWindow"))
            return Script::Get<float>(root, L"GUIScale", 1.0f);

        if (!Script::IsA(root, L"R6MenuInGameRootWindow"))
            return 1.0f;

        // In-game widgets own the scale while visible, the instruction box claims it afterward
        if (WidgetShowing(root))
            return Script::Get<float>(root, L"GUIScale", 1.0f);

        auto width = Script::Get<float>(root, L"WinWidth");
        auto height = Script::Get<float>(root, L"WinHeight");
        auto scale = fHUDScale && height >= ReticuleHeight
                  && Script::GetBool(Script::Get<void*>(root, L"m_pInstructionWidget"), L"bWindowVisible")
                   ? HUDScale(height)
                   : 1.0f;

        Script::Set<float>(root, L"GUIScale", scale);

        // Both of these are already in raw pixels, so GUIScale would apply the resolution twice. They
        // are re-derived from the root's size rather than scaled in place, so repeats cannot compound.
        auto widget = Script::Get<void*>(root, L"m_pInstructionWidget");

        // A fixed 640x480 design centered in the root's pixel space.
        Script::Set<float>(widget, L"WinLeft", width * 0.5f / scale - ReticuleWidth * 0.5f);
        Script::Set<float>(widget, L"WinTop", height * 0.5f / scale - ReticuleHeight * 0.5f);

        // Recomputed on every layout as (C.SizeY / 480) * this, so divide the source constant back out.
        Script::Set<float>(widget, L"m_fYInstructionTextPos", InstructionTop / scale);

        return scale;
    }

    // One Canvas native draws every UWindow window, so the box is told from the menus by which
    // root the drawing window belongs to.
    void ClipText(SafetyHookContext& ctx)
    {
        // esp+4 is the FFrame& the exec was handed; Object is at +0x8 inside it.
        auto stack = *reinterpret_cast<uint8_t**>(ctx.esp + 4);
        auto object = *reinterpret_cast<void**>(stack + 0x8);

        windowScale = WindowScale(object);
        bWindowText = windowScale != 1.0f;
    }

    // TextSize divides its measurement by GUIScale on the assumption the glyphs stayed native
    // size. Ours are drawn at GUIScale, so that division is one factor too many.
    void TextSize(SafetyHookContext& ctx)
    {
        auto stack = *reinterpret_cast<uint8_t**>(ctx.ebp + 8);
        auto object = *reinterpret_cast<void**>(stack + 0x8);
        auto scale = WindowScale(object);

        if (scale == 1.0f)
            return;

        *(*reinterpret_cast<float**>(ctx.ebp - 0x2c)) *= scale;
        *(*reinterpret_cast<float**>(ctx.ebp - 0x34)) *= scale;
    }

    // Forwards to WrappedPrint, so the flag is read one call down rather than acted on here.
    void WrappedStrLenf(SafetyHookContext& ctx)
    {
        auto rva = *reinterpret_cast<uintptr_t*>(ctx.esp) - engineBase;

        bMeasure = rva >= EngineDrawFrom && rva < EngineDrawTo;
    }

    void __cdecl WrappedPrint(uint8_t* self, int style, int* xl, int* yl, void* font, int center, const wchar_t* text)
    {
        // Consumed here whichever branch runs, so a measurement cannot leak into the next call.
        auto measure = bMeasure;
        bMeasure = false;

        if (!bShift)
        {
            // A measurement made on UGameEngine::Draw's behalf has to scale with the glyphs it is for,
            // whatever the canvas looks like - the message loop narrows the clip before measuring.
            auto scale = measure ? ViewportScale(self) : TextScale(self);

            if (scale == 1.0f)
            {
                shWrappedPrint.call<void>(self, style, xl, yl, font, center, text);
                return;
            }

            // Divide the position down and let the stretch multiply it back. Everything handed back comes
            // out in canvas units, so it is multiplied into pixels for whoever asked.
            auto clipX = reinterpret_cast<float*>(self + ClipX);
            auto clipY = reinterpret_cast<float*>(self + ClipY);
            auto curX = reinterpret_cast<float*>(self + CurX);
            auto curY = reinterpret_cast<float*>(self + CurY);

            auto previousClipX = *clipX;
            auto previousClipY = *clipY;

            *reinterpret_cast<float*>(self + StretchX) = scale;
            *reinterpret_cast<float*>(self + StretchY) = scale;
            *clipX /= scale;
            *clipY /= scale;
            *curX /= scale;
            *curY /= scale;

            shWrappedPrint.call<void>(self, style, xl, yl, font, center, text);

            *curX *= scale;
            *curY *= scale;
            *clipX = previousClipX;
            *clipY = previousClipY;
            *reinterpret_cast<float*>(self + StretchX) = 1.0f;
            *reinterpret_cast<float*>(self + StretchY) = 1.0f;

            if (xl) *xl = static_cast<int>(*xl * scale);
            if (yl) *yl = static_cast<int>(*yl * scale);
            return;
        }

        bShift = false;

        auto clipX = reinterpret_cast<float*>(self + ClipX);
        auto previousClipX = *clipX;

        // Centered text is placed between CurX and ClipX, so the two move together.
        // CurX is not restored because WrappedPrint owns it once it returns.
        *reinterpret_cast<float*>(self + CurX) += shift;
        *clipX += shift;

        shWrappedPrint.call<void>(self, style, xl, yl, font, center, text);

        *clipX = previousClipX;
    }

    // Glyphs are drawn through the worker; the return address is the slot below the first argument
    // because this is __cdecl and SafetyHook enters on the original frame.
    int __cdecl DrawStringPrimitive(uint8_t* canvas, void* font, int x, int y, const wchar_t* text,
                                    float r, float g, float b, float a, int i1, int i2, int i3)
    {
        auto rva = *(reinterpret_cast<uintptr_t*>(&canvas) - 1) - engineBase;
        auto viewport = canvas ? *reinterpret_cast<uint8_t**>(canvas + Viewport) : nullptr;

        auto engineText = rva >= EngineDrawFrom && rva < EngineDrawTo;
        auto windowText = bWindowText && rva == ClipTextDraw;

        bWindowText = false;

        // UWindow glyphs follow their root's scale, HUDScale only applies to viewport text
        auto scale = windowText ? windowScale : ViewportScale(canvas);

        if (!viewport || scale == 1.0f || (!engineText && !windowText))
            return shDrawStringWorker.ccall<int>(canvas, font, x, y, text, r, g, b, a, i1, i2, i3);

        // The worker resolves a glyph as (X + OrgX) * StretchX, so the origin is inside the multiply
        // and comes down with the position. UWindow accumulates screen position into OrgX.
        auto stretchX = reinterpret_cast<float*>(canvas + StretchX);
        auto stretchY = reinterpret_cast<float*>(canvas + StretchY);
        auto clipX = reinterpret_cast<float*>(canvas + ClipX);
        auto clipY = reinterpret_cast<float*>(canvas + ClipY);
        auto orgX = reinterpret_cast<float*>(canvas + OrgX);
        auto orgY = reinterpret_cast<float*>(canvas + OrgY);

        auto previousStretchX = *stretchX;
        auto previousStretchY = *stretchY;
        auto previousClipX = *clipX;
        auto previousClipY = *clipY;
        auto previousOrgX = *orgX;
        auto previousOrgY = *orgY;

        *stretchX = scale;
        *stretchY = scale;
        *clipX /= scale;
        *clipY /= scale;
        *orgX /= scale;
        *orgY /= scale;

        auto result = shDrawStringWorker.ccall<int>(canvas, font,
                                                    static_cast<int>(x / scale), static_cast<int>(y / scale),
                                                    text, r, g, b, a, i1, i2, i3);

        *orgX = previousOrgX;
        *orgY = previousOrgY;
        *clipX = previousClipX;
        *clipY = previousClipY;
        *stretchX = previousStretchX;
        *stretchY = previousStretchY;
        return result;
    }

    void __fastcall SetStretch(void* self, void* edx, float x, float y)
    {
        shSetStretch.thiscall<void>(self, hud ? y : x, y);
    }

    // Widening the virtual space to the real aspect makes the stretch uniform and keeps HalfClipX
    // on the screen center, so no element needs a rule of its own.
    void __fastcall UseVirtualSize(uint8_t* self, void* edx, int bUse, float x, float y)
    {
        auto viewport = *reinterpret_cast<uint8_t**>(self + Viewport);

        if (bUse && viewport)
        {
            auto sizeX = *reinterpret_cast<int32_t*>(viewport + ViewportSizeX);
            auto sizeY = *reinterpret_cast<int32_t*>(viewport + ViewportSizeY);

            if (x == 0.0f || y == 0.0f)
                y = *reinterpret_cast<float*>(self + VirtualResY);

            if (sizeY > 0 && y > 0.0f)
                x = y * static_cast<float>(sizeX) / static_cast<float>(sizeY);
        }

        shUseVirtualSize.thiscall<void>(self, bUse, x, y);

        // Which correction applies to the next draw, clip layout or viewport pixels
        virtualSize = bUse != 0;

        // R6Weapons.PostRender draws the identification reticle with UseVirtualSize(true).
        // Only the reticle's UseVirtualSize(false) draw is transformed; its identification text is left alone.
        if (reticule && !bUse)
        {
            aiming = reticule;
            zoomed = optics;
            dot = Script::IsA(reticule, L"R6WithWeaponReticule");
            optics = false;
        }
        else if (!reticule)
        {
            aiming = nullptr;
        }

        if (reticule && fHUDScale && !bUse && viewport)
        {
            auto sizeX = static_cast<float>(*reinterpret_cast<int32_t*>(viewport + ViewportSizeX));
            auto sizeY = static_cast<float>(*reinterpret_cast<int32_t*>(viewport + ViewportSizeY));
            auto scale = HUDScale(sizeY);

            // R6WithWeaponReticule never backs its half line width off, so its cross sits down and right
            auto nudgeX = 0.0f;
            auto nudgeY = 0.0f;

            if (Script::IsA(reticule, L"R6WithWeaponReticule"))
            {
                nudgeX = sizeX / ReticuleWidth + 0.5f;
                nudgeY = sizeY / ReticuleHeight + 0.5f;
            }

            *reinterpret_cast<float*>(self + StretchX) = scale;
            *reinterpret_cast<float*>(self + StretchY) = scale;

            Script::Set<float>(reticule, L"m_fReticuleOffsetX", sizeX * 0.5f / scale - nudgeX);
            Script::Set<float>(reticule, L"m_fReticuleOffsetY", sizeY * 0.5f / scale - nudgeY);
        }
    }

    void __fastcall ExecUseVirtualSize(void* self, void* edx, uint8_t* stack, void* result)
    {
        auto object = *reinterpret_cast<void**>(stack + 0x8);

        reticule = Script::IsA(object, L"R6CrossReticule") || Script::IsA(object, L"R6WithWeaponReticule") ? object : nullptr;
        shExecUseVirtualSize.thiscall<void>(self, stack, result);
        reticule = nullptr;
    }

    void __fastcall ExecDrawTile(void* self, void* edx, uint8_t* stack, void* result)
    {
        auto object = *reinterpret_cast<void**>(stack + 0x8);

        // R6InteractionCircumstantialAction extends the rose and uses virtual size for the bottom-center icon
        // The wheel disables virtual size first, so canvas state distinguishes the two
        rose = !virtualSize && Script::IsA(object, L"R6InteractionRoseDesVents") && RoseTransform(static_cast<uint8_t*>(self))
             ? object
             : nullptr;

        shExecDrawTile.thiscall<void>(self, stack, result);
        rose = nullptr;
    }

    // Labels centered in box (OrgX + ClipX width, both stretched); must happen before worker sees coords
    void __fastcall ExecDrawText(void* self, void* edx, uint8_t* stack, void* result)
    {
        auto canvas = static_cast<uint8_t*>(self);
        auto object = *reinterpret_cast<void**>(stack + 0x8);

        if (virtualSize || !Script::IsA(object, L"R6InteractionRoseDesVents") || !RoseTransform(canvas))
        {
            shExecDrawText.thiscall<void>(self, stack, result);
            return;
        }

        auto orgX = reinterpret_cast<float*>(canvas + OrgX);
        auto clipX = reinterpret_cast<float*>(canvas + ClipX);

        auto previousOrgX = *orgX;
        auto previousClipX = *clipX;

        *orgX = previousOrgX * roseScale + roseOffset;
        *clipX = previousClipX * roseScale;

        shExecDrawText.thiscall<void>(self, stack, result);

        *clipX = previousClipX;
        *orgX = previousOrgX;
    }

    void __fastcall DrawNativeHUD(void* self, void* edx, void* frame, void* result)
    {
        hud = static_cast<uint8_t*>(self);
        shDrawNativeHUD.thiscall<void>(self, frame, result);
        hud = nullptr;
    }
}

FEATURE(R6Game, WidescreenHUD)
{
    if (!bWidescreenHUD)
        return;

    auto engine = GetModuleHandleW(L"Engine");
    auto r6game = GetModuleHandleW(L"R6Game");

    auto drawNativeHUD = GetProcAddress(r6game, "?execDrawNativeHUD@AR6HUD@@QAEXAAUFFrame@@QAX@Z");
    auto drawTile = GetProcAddress(engine, "?DrawTile@FCanvasUtil@@QAEXMMMMMMMMMPAVUMaterial@@VFColor@@@Z");
    auto drawTileRotated = GetProcAddress(engine, "?DrawTileRotated@FCanvasUtil@@QAEXMMMMMMMMMPAVUMaterial@@VFColor@@M@Z");
    auto drawString = GetProcAddress(engine, "?_DrawString@UCanvas@@UAEHPAVUFont@@HHPBGVFPlane@@HHH@Z");
    auto wrappedPrintf = GetProcAddress(engine, "?WrappedPrintf@UCanvas@@UAAXPAVUFont@@HPBGZZ");
    auto wrappedStrLenf = GetProcAddress(engine, "?WrappedStrLenf@UCanvas@@UAAXPAVUFont@@AAH1PBGZZ");
    auto wrappedPrint = GetProcAddress(engine, "?WrappedPrint@UCanvas@@AAAXW4ERenderStyle@@AAH1PAVUFont@@HPBG@Z");
    auto setStretch = GetProcAddress(engine, "?SetStretch@UCanvas@@QAEXMM@Z");
    auto useVirtualSize = GetProcAddress(engine, "?UseVirtualSize@UCanvas@@QAEXHMM@Z");
    auto execUseVirtualSize = GetProcAddress(engine, "?execUseVirtualSize@UCanvas@@QAEXAAUFFrame@@QAX@Z");
    auto execDrawTile = GetProcAddress(engine, "?execDrawTile@UCanvas@@QAEXAAUFFrame@@QAX@Z");
    auto execDrawText = GetProcAddress(engine, "?execDrawText@UCanvas@@QAEXAAUFFrame@@QAX@Z");

    if (!drawNativeHUD || !drawTile || !drawTileRotated || !drawString || !wrappedPrintf || !wrappedPrint || !setStretch || !useVirtualSize || !execUseVirtualSize || !wrappedStrLenf)
    {
        spdlog::error("WidescreenHUD: execDrawNativeHUD {}, DrawTile {}, DrawTileRotated {}, _DrawString {}, WrappedPrintf {}, WrappedPrint {}, SetStretch {}, UseVirtualSize {}, execUseVirtualSize {}, WrappedStrLenf {}",
                      (void*)drawNativeHUD, (void*)drawTile, (void*)drawTileRotated, (void*)drawString,
                      (void*)wrappedPrintf, (void*)wrappedPrint, (void*)setStretch, (void*)useVirtualSize, (void*)execUseVirtualSize, (void*)wrappedStrLenf);
        return;
    }

    auto dos = reinterpret_cast<IMAGE_DOS_HEADER*>(r6game);
    auto nt = reinterpret_cast<IMAGE_NT_HEADERS*>(reinterpret_cast<uint8_t*>(r6game) + dos->e_lfanew);

    base = reinterpret_cast<uintptr_t>(r6game);
    limit = base + nt->OptionalHeader.SizeOfImage;

    engineBase = reinterpret_cast<uintptr_t>(engine);
    drawTilePrimitive = reinterpret_cast<decltype(drawTilePrimitive)>(drawTile);

    shDrawNativeHUD = safetyhook::create_inline(drawNativeHUD, DrawNativeHUD);
    shSetStretch = safetyhook::create_inline(setStretch, SetStretch);
    shWrappedPrint = safetyhook::create_inline(wrappedPrint, WrappedPrint);
    mhDrawTile = safetyhook::create_mid(drawTile, DrawTile);
    mhDrawTileRotated = safetyhook::create_mid(drawTileRotated, DrawTileRotated);
    mhDrawString = safetyhook::create_mid(drawString, DrawString);
    mhWrappedPrintf = safetyhook::create_mid(wrappedPrintf, WrappedPrintf);
    mhWrappedStrLenf = safetyhook::create_mid(wrappedStrLenf, WrappedStrLenf);
    mhClipTextNative = safetyhook::create_mid(reinterpret_cast<void*>(engineBase + ClipTextNative), ClipText);
    mhTextSize = safetyhook::create_mid(reinterpret_cast<void*>(engineBase + TextSizeResult), TextSize);
    shUseVirtualSize = safetyhook::create_inline(useVirtualSize, UseVirtualSize);

    shExecUseVirtualSize = safetyhook::create_inline(execUseVirtualSize, ExecUseVirtualSize);

    if (execDrawTile && execDrawText)
    {
        shExecDrawTile = safetyhook::create_inline(execDrawTile, ExecDrawTile);
        shExecDrawText = safetyhook::create_inline(execDrawText, ExecDrawText);
    }
    else
        spdlog::error("WidescreenHUD: execDrawTile {}, execDrawText {} - the action wheel stays stretched",
                      (void*)execDrawTile, (void*)execDrawText);

    shDrawStringWorker = safetyhook::create_inline(reinterpret_cast<void*>(engineBase + DrawStringWorker), DrawStringPrimitive);

    mhConsoleWrap = safetyhook::create_mid(reinterpret_cast<void*>(engineBase + ConsoleWrapTest), ConsoleWrap);
    mhMessageClip = safetyhook::create_mid(reinterpret_cast<void*>(engineBase + MessageClipWidth), MessageClip);

    mhWaypointStretch = safetyhook::create_mid(reinterpret_cast<void*>(base + WaypointStretchReset), WaypointStretch);
    mhWaypointFOV = safetyhook::create_mid(reinterpret_cast<void*>(base + WaypointFOVCosCall), WaypointFOV);
    mhWaypointLabel = safetyhook::create_mid(reinterpret_cast<void*>(base + WaypointLabelX), WaypointLabel);
    spdlog::info("WidescreenHUD: HUD scaled uniformly and anchored to the screen edges");
}

// D3DDrv cone feature - function exported, four sites are base + RVA
FEATURE(D3DDrv, WidescreenVisionCone)
{
    if (!bWidescreenHUD)
        return;

    auto d3ddrv = GetModuleHandleW(L"D3DDrv");
    auto fullScreenEffects = GetProcAddress(d3ddrv, "?HandleFullScreenEffects@UD3DRenderDevice@@UAEXHH@Z");
    auto d3dBase = reinterpret_cast<uintptr_t>(d3ddrv);

    if (!fullScreenEffects || reinterpret_cast<uintptr_t>(fullScreenEffects) != d3dBase + FullScreenEffects)
    {
        spdlog::error("WidescreenVisionCone: HandleFullScreenEffects {}, expected base + {:#x}",
                      (void*)fullScreenEffects, FullScreenEffects);
        return;
    }

    mhVisionConeMask = safetyhook::create_mid(reinterpret_cast<void*>(d3dBase + VisionConeMask), VisionConeMaskBegin);
    mhVisionConeScene = safetyhook::create_mid(reinterpret_cast<void*>(d3dBase + VisionConeScene), VisionConeSceneBegin);
    mhVisionConeRemask = safetyhook::create_mid(reinterpret_cast<void*>(d3dBase + VisionConeRemask), VisionConeMaskResume);
    mhVisionConeEnd = safetyhook::create_mid(reinterpret_cast<void*>(d3dBase + VisionConeJoin), VisionConeEnd);
    spdlog::info("WidescreenVisionCone: night vision confined to 4:3 with black pillars");
}
