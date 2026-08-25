#include "stdafx.h"
#include "common.hpp"
#include "feature.hpp"

#include <d3d9.h>

// Stock PushHit/PopHit locks the backbuffer to read an 8x8 marker for every hit, causing
// a GPU/CPU sync each time. Batch the rects into an atlas and read them back once at Unlock
// to significantly improve selection speed.
namespace
{
    // FD3DRenderInterface
    constexpr ptrdiff_t RenDev   = 0x28;
    constexpr ptrdiff_t HitStack = 0x2c038;
    constexpr ptrdiff_t HitData  = 0x2c044;
    constexpr ptrdiff_t HitSize  = 0x2c048;
    constexpr ptrdiff_t HitCount = 0x2c04c;

    // UD3DRenderDevice
    constexpr ptrdiff_t LockedViewport  = 0x4670;
    constexpr ptrdiff_t Direct3DDevice8 = 0x468c;

    // UViewport
    constexpr ptrdiff_t HitX  = 0x174;
    constexpr ptrdiff_t HitY  = 0x178;
    constexpr ptrdiff_t HitXL = 0x17c;
    constexpr ptrdiff_t HitYL = 0x180;

    constexpr int   HitMax    = 8;      // HIT_SIZE, the stock code asserts against it
    constexpr DWORD IgnorePix = 0xfe0d; // IGNOREPIX, as the 32-bit path stores it

    // 8x8 tiles, one per popped proxy; a fuller frame is evaluated in batches
    constexpr int AtlasW = 1024;
    constexpr int AtlasH = 512;
    constexpr int Tiles  = (AtlasW / HitMax) * (AtlasH / HitMax);

    struct TArray { uint8_t* Data; int Num; int Max; };

    struct Save
    {
        IDirect3DSurface9* surface = nullptr;
        RECT rect{};
        bool ok = false;
    };

    // A popped proxy waiting for the atlas read back: where its tile is and what the hit
    // stack looked like when it was popped, so Unlock can replay the stock PopHit rules
    struct Pending
    {
        RECT   rect;
        int    tile;
        size_t offset;
        int    num;
        int    count;
        int    force;
    };

    SafetyHookInline shPushHit{};
    SafetyHookInline shPopHit{};
    SafetyHookInline shSetRes{};
    SafetyHookInline shExit{};
    SafetyHookInline shUnlock{};

    int  (__fastcall* TArrayAdd)(TArray*, void*, int)         = nullptr;
    void (__fastcall* TArrayRemove)(TArray*, void*, int, int) = nullptr;

    IUnknown*          source    = nullptr; // the D3D8 device the D3D9 one was queried from
    IDirect3DDevice9*  device    = nullptr;
    IDirect3DSurface9* atlas     = nullptr;
    IDirect3DSurface9* atlasCopy = nullptr;
    D3DFORMAT          targetFormat = D3DFMT_UNKNOWN;
    std::vector<Save>  saves;
    int                depth     = 0;

    std::vector<Pending> pending;
    std::vector<uint8_t> snapshots;

    void ReleaseAll()
    {
        for (auto& save : saves)
            if (save.surface)
                save.surface->Release();
        saves.clear();
        depth = 0;
        pending.clear();
        snapshots.clear();

        if (atlasCopy) atlasCopy->Release();
        if (atlas)     atlas->Release();
        if (device)    device->Release();
        atlasCopy = atlas = nullptr;
        device = nullptr;
        source = nullptr;
    }

    // Surfaces are kept across frames: creating and releasing DEFAULT-pool targets every click
    // is a delay of its own. SetRes and Exit drop them before Reset or Release can see them.
    bool Acquire(uint8_t* self)
    {
        auto d3d8 = *reinterpret_cast<IUnknown**>(*reinterpret_cast<uint8_t**>(self + RenDev) + Direct3DDevice8);
        if (d3d8 == source)
            return device != nullptr;

        ReleaseAll();
        source = d3d8;

        // The D3D8 device is d3d8to9's proxy, which answers a QueryInterface for the D3D9 device behind it
        if (!d3d8 || FAILED(d3d8->QueryInterface(__uuidof(IDirect3DDevice9), reinterpret_cast<void**>(&device))))
        {
            static bool warned = false;
            if (!warned)
                spdlog::warn("HitTest: no D3D9 device behind the D3D8 one (wrapper d3d8.dll missing?), stock hit testing");
            warned = true;
            device = nullptr;
            return false;
        }

        IDirect3DSurface9* target = nullptr;
        D3DSURFACE_DESC desc{};
        if (SUCCEEDED(device->GetRenderTarget(0, &target)))
        {
            target->GetDesc(&desc);
            target->Release();
        }

        // The marker compare below is written for 32-bit pixels, anything else keeps the stock path
        if ((desc.Format != D3DFMT_X8R8G8B8 && desc.Format != D3DFMT_A8R8G8B8) ||
            FAILED(device->CreateRenderTarget(AtlasW, AtlasH, desc.Format, D3DMULTISAMPLE_NONE, 0, FALSE, &atlas, nullptr)) ||
            FAILED(device->CreateOffscreenPlainSurface(AtlasW, AtlasH, desc.Format, D3DPOOL_SYSTEMMEM, &atlasCopy, nullptr)))
        {
            static bool warned = false;
            if (!warned)
                spdlog::warn("HitTest: render target format {} not handled, stock hit testing", static_cast<int>(desc.Format));
            warned = true;
            ReleaseAll();
            source = d3d8;
            return false;
        }

        targetFormat = desc.Format;
        return true;
    }

    RECT HitRect(uint8_t* self, IDirect3DSurface9* target)
    {
        auto viewport = *reinterpret_cast<uint8_t**>(*reinterpret_cast<uint8_t**>(self + RenDev) + LockedViewport);
        auto x = *reinterpret_cast<int*>(viewport + HitX);
        auto y = *reinterpret_cast<int*>(viewport + HitY);

        D3DSURFACE_DESC desc{};
        target->GetDesc(&desc);

        // Stock writes past the row when the cursor sits on the viewport edge, D3D refuses the rect instead
        RECT rect{ x, y, x + std::min(*reinterpret_cast<int*>(viewport + HitXL), HitMax), y + std::min(*reinterpret_cast<int*>(viewport + HitYL), HitMax) };
        RECT bounds{ 0, 0, static_cast<LONG>(desc.Width), static_cast<LONG>(desc.Height) };
        IntersectRect(&rect, &rect, &bounds);
        return rect;
    }

    RECT TileRect(int tile, const RECT& rect)
    {
        LONG x = (tile % (AtlasW / HitMax)) * HitMax;
        LONG y = (tile / (AtlasW / HitMax)) * HitMax;
        return { x, y, x + rect.right - rect.left, y + rect.bottom - rect.top };
    }

    // The one read back. Replays what stock PopHit did per proxy, in the same order, so the
    // last proxy that hit (or was forced) is the one left in HitData
    void Flush(uint8_t* self)
    {
        if (pending.empty())
            return;

        D3DLOCKED_RECT locked{};
        bool readable = SUCCEEDED(device->GetRenderTargetData(atlas, atlasCopy)) &&
                        SUCCEEDED(atlasCopy->LockRect(&locked, nullptr, D3DLOCK_READONLY));

        auto hitSize = *reinterpret_cast<int**>(self + HitSize);

        for (auto& p : pending)
        {
            bool  hit   = false;
            DWORD color = 0xFF000000;

            if (readable && p.tile >= 0)
            {
                RECT tile = TileRect(p.tile, p.rect);
                for (LONG y = tile.top; y < tile.bottom && !hit; y++)
                {
                    auto row = reinterpret_cast<DWORD*>(static_cast<uint8_t*>(locked.pBits) + y * locked.Pitch);
                    for (LONG x = tile.left; x < tile.right; x++)
                    {
                        // X8R8G8B8 leaves the top byte undefined
                        if (((row[x] ^ IgnorePix) & 0x00FFFFFF) == 0)
                            continue;

                        hit = true;
                        color = 0xFF000000 | (row[x] & 0x00FFFFFF);
                        break;
                    }
                }
            }

            if (!hit && !p.force)
                continue;

            auto stack = snapshots.data() + p.offset;
            *reinterpret_cast<DWORD*>(stack + p.num - p.count + 8) = color;

            if (hitSize && p.num <= *hitSize)
            {
                *reinterpret_cast<int*>(self + HitCount) = p.num;
                memcpy(*reinterpret_cast<uint8_t**>(self + HitData), stack, p.num);
            }
            else
                *reinterpret_cast<int*>(self + HitCount) = 0;
        }

        if (readable)
            atlasCopy->UnlockRect();

        pending.clear();
        snapshots.clear();
    }

    void __fastcall PushHit(uint8_t* self, void* edx, const uint8_t* data, int count)
    {
        if (!Acquire(self))
            return shPushHit.thiscall<void>(self, data, count);

        auto stack = reinterpret_cast<TArray*>(self + HitStack);
        auto index = TArrayAdd(stack, nullptr, count);
        memcpy(stack->Data + index, data, count);

        if (depth >= static_cast<int>(saves.size()))
            saves.emplace_back();
        auto& save = saves[depth++];
        save.ok = false;
        save.rect = {};

        IDirect3DSurface9* target = nullptr;
        if (FAILED(device->GetRenderTarget(0, &target)))
            return;

        save.rect = HitRect(self, target);
        RECT local{ 0, 0, save.rect.right - save.rect.left, save.rect.bottom - save.rect.top };

        if (!IsRectEmpty(&save.rect))
        {
            // Only an enclosing proxy ever looks at these pixels again, so the save and restore
            // stock does for every level is only paid for nested ones
            if (depth > 1)
            {
                if (!save.surface)
                    device->CreateRenderTarget(HitMax, HitMax, targetFormat, D3DMULTISAMPLE_NONE, 0, FALSE, &save.surface, nullptr);
                if (save.surface)
                    save.ok = SUCCEEDED(device->StretchRect(target, &save.rect, save.surface, &local, D3DTEXF_NONE));
            }

            device->ColorFill(target, &save.rect, IgnorePix);

            // Nothing outside the rect is ever read in a hit frame, so a proxy's full-screen
            // shading is wasted. D3D8 has no scissor, so the engine never sees this state.
            // The rect is set on every push because SetRenderTarget resets it
            if (depth == 1)
                device->SetRenderState(D3DRS_SCISSORTESTENABLE, TRUE);
            device->SetScissorRect(&save.rect);
        }

        target->Release();
    }

    void __fastcall PopHit(uint8_t* self, void* edx, int count, int force)
    {
        if (!Acquire(self))
            return shPopHit.thiscall<void>(self, count, force);

        auto stack = reinterpret_cast<TArray*>(self + HitStack);
        Pending p{ {}, -1, 0, stack->Num, count, force };

        IDirect3DSurface9* target = nullptr;
        if (depth > 0 && SUCCEEDED(device->GetRenderTarget(0, &target)))
        {
            auto& save = saves[depth - 1];
            RECT local{ 0, 0, save.rect.right - save.rect.left, save.rect.bottom - save.rect.top };

            if (!IsRectEmpty(&save.rect))
            {
                if (static_cast<int>(pending.size()) == Tiles)
                    Flush(self);

                p.rect = save.rect;
                p.tile = static_cast<int>(pending.size());
                RECT tile = TileRect(p.tile, save.rect);
                if (FAILED(device->StretchRect(target, &save.rect, atlas, &tile, D3DTEXF_NONE)))
                    p.tile = -1;
            }

            if (save.ok)
                device->StretchRect(save.surface, &local, target, &save.rect, D3DTEXF_NONE);

            target->Release();
        }
        if (depth > 0 && --depth == 0)
            device->SetRenderState(D3DRS_SCISSORTESTENABLE, FALSE);

        // After the possible mid-frame Flush above, which empties both
        p.offset = snapshots.size();
        snapshots.insert(snapshots.end(), stack->Data, stack->Data + stack->Num);
        pending.push_back(p);

        TArrayRemove(stack, nullptr, stack->Num - count, count);
    }

    void __fastcall Unlock(void* self, void* edx, uint8_t* renderInterface)
    {
        // Stock wrote HitData during the frame and Unlock only publishes HitCount, so the
        // read back has to land before it runs
        if (device)
            Flush(renderInterface);

        shUnlock.thiscall<void>(self, renderInterface);
    }

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
}

EDITOR_FEATURE(D3DDrv, HitTest)
{
    auto d3dDrv = GetModuleHandleW(L"D3DDrv");
    auto engine = GetModuleHandleW(L"Engine");

    // FD3DRenderInterface::PushHit and PopHit are virtual and not exported. Both patterns run
    // through the LockedViewport, HitYL and HIT_SIZE operands the code above depends on.
    auto pushHit = FindModulePattern(d3dDrv, { "55 8B EC 6A FF 68 ? ? ? ? 64 A1 00 00 00 00 50 64 89 25 00 00 00 00 83 EC 28 53 56 57 8B F9 8B 47 28 8B 98 70 46 00 00 8B 83 80 01 00 00 BE 08 00 00 00" });
    auto popHit  = FindModulePattern(d3dDrv, { "55 8B EC 6A FF 68 ? ? ? ? 64 A1 00 00 00 00 50 64 89 25 00 00 00 00 83 EC 44 53 56 57 8B F9 8B 47 28 8B B0 70 46 00 00 33 DB 8D 8F 38 C0 02 00" });
    auto setRes  = GetProcAddress(d3dDrv, "?SetRes@UD3DRenderDevice@@UAEHPAVUViewport@@HHH@Z");
    auto exit    = GetProcAddress(d3dDrv, "?Exit@UD3DRenderDevice@@UAEXPAVUViewport@@@Z");
    auto unlock  = GetProcAddress(d3dDrv, "?Unlock@UD3DRenderDevice@@UAEXPAVFRenderInterface@@@Z");

    TArrayAdd    = reinterpret_cast<decltype(TArrayAdd)>(GetProcAddress(engine, "?Add@?$TArray@E@@QAEHH@Z"));
    TArrayRemove = reinterpret_cast<decltype(TArrayRemove)>(GetProcAddress(engine, "?Remove@?$TArray@E@@QAEXHH@Z"));

    if (pushHit.empty() || popHit.empty() || !setRes || !exit || !unlock || !TArrayAdd || !TArrayRemove)
    {
        spdlog::error("HitTest: PushHit {}, PopHit {}, SetRes {}, Exit {}, Unlock {}, TArray::Add {}, TArray::Remove {}",
                      !pushHit.empty(), !popHit.empty(), (void*)setRes, (void*)exit, (void*)unlock, (void*)TArrayAdd, (void*)TArrayRemove);
        return;
    }

    shPushHit = safetyhook::create_inline(pushHit.get_first(), PushHit);
    shPopHit  = safetyhook::create_inline(popHit.get_first(), PopHit);
    shSetRes  = safetyhook::create_inline(setRes, SetRes);
    shExit    = safetyhook::create_inline(exit, Exit);
    shUnlock  = safetyhook::create_inline(unlock, Unlock);
    spdlog::info("HitTest: Hit testing batched through an atlas, one read back per frame");
}
