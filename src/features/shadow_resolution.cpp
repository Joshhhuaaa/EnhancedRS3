#include "stdafx.h"
#include "common.hpp"
#include "config.hpp"
#include "feature.hpp"

#include <d3d9.h>

#include "shaders/shadow_blur_vs.h"
#include "shaders/shadow_blur_ps.h"

static Config::Value iShadowResolution("Graphics", "ShadowResolution", 128);
static Config::Value bShadowDetail("Graphics", "ShadowDetail", true);

namespace
{
    // UBitmapMaterial. Engine sizes both the render target and the projector's footprint from
    // these, so all six have to agree.
    constexpr int UBits = 0x5B, VBits = 0x5C, USize = 0x60, VSize = 0x64, UClamp = 0x68, VClamp = 0x6C;

    // FD3DRenderInterface, UD3DRenderDevice
    constexpr ptrdiff_t RenDev = 0x28, Direct3DDevice8 = 0x468c;

    // Variance of the stock blur in texels^2, the same at every resolution
    constexpr float StockVariance = 1.25f;

    int     iSize = 0;
    uint8_t iBits = 0;
    float   fFalloff = 0.0f;
    int     iPairs = 0;

    SafetyHookInline shShadowBitmapMaterial{};
    SafetyHookMid    mhShadowBlur{};
    SafetyHookInline shSetRes{};
    SafetyHookInline shExit{};

    IUnknown*                    source       = nullptr; // the D3D8 device the D3D9 one was queried from
    IDirect3DDevice9*            device       = nullptr;
    IDirect3DVertexShader9*      vertexShader = nullptr;
    IDirect3DPixelShader9*       pixelShader  = nullptr;
    IDirect3DVertexDeclaration9* declaration  = nullptr;

    void* __fastcall ShadowBitmapMaterial(void* self, void*)
    {
        // StaticAllocateObject copies the class defaults in before the constructor runs,
        // so this overwrites them rather than being overwritten by them.
        auto material = static_cast<uint8_t*>(shShadowBitmapMaterial.thiscall<void*>(self));

        *reinterpret_cast<uint8_t*>(material + UBits)  = iBits;
        *reinterpret_cast<uint8_t*>(material + VBits)  = iBits;
        *reinterpret_cast<int32_t*>(material + USize)  = iSize;
        *reinterpret_cast<int32_t*>(material + VSize)  = iSize;
        *reinterpret_cast<int32_t*>(material + UClamp) = iSize;
        *reinterpret_cast<int32_t*>(material + VClamp) = iSize;

        return material;
    }

    void ReleaseAll()
    {
        if (declaration)  declaration->Release();
        if (pixelShader)  pixelShader->Release();
        if (vertexShader) vertexShader->Release();
        if (device)       device->Release();
        declaration = nullptr;
        pixelShader = nullptr;
        vertexShader = nullptr;
        device = nullptr;
        source = nullptr;
    }

    bool Acquire(uint8_t* renderInterface)
    {
        auto d3d8 = *reinterpret_cast<IUnknown**>(*reinterpret_cast<uint8_t**>(renderInterface + RenDev) + Direct3DDevice8);
        if (d3d8 == source)
            return pixelShader != nullptr;

        ReleaseAll();
        source = d3d8;

        static const D3DVERTEXELEMENT9 Elements[] = { { 0, 0, D3DDECLTYPE_FLOAT4, D3DDECLMETHOD_DEFAULT, D3DDECLUSAGE_POSITION, 0 }, D3DDECL_END() };

        // The D3D8 device is d3d8to9's proxy, which answers a QueryInterface for the D3D9 device behind it
        if (!d3d8 || FAILED(d3d8->QueryInterface(__uuidof(IDirect3DDevice9), reinterpret_cast<void**>(&device))) ||
            FAILED(device->CreateVertexShader(reinterpret_cast<const DWORD*>(ShadowBlurVS), &vertexShader)) ||
            FAILED(device->CreatePixelShader(reinterpret_cast<const DWORD*>(ShadowBlurPS), &pixelShader)) ||
            FAILED(device->CreateVertexDeclaration(Elements, &declaration)))
        {
            static bool warned = false;
            if (!warned)
                spdlog::warn("ShadowResolution: no shader model 3 D3D9 device behind the D3D8 one, stock shadow blur");
            warned = true;
            ReleaseAll();
            source = d3d8;
            return false;
        }

        return true;
    }

    void Pass(IDirect3DTexture9* from, IDirect3DSurface9* to, float x, float y)
    {
        static constexpr float Quad[] = { -1, -1, 0, 1,  -1, 1, 0, 1,  1, -1, 0, 1,  1, 1, 0, 1 };
        float axis[] = { x, y, 1.0f / iSize, 1.0f / iSize };

        device->SetTexture(0, from);
        device->SetRenderTarget(0, to);
        device->SetPixelShaderConstantF(0, axis, 1);
        device->DrawPrimitiveUP(D3DPT_TRIANGLESTRIP, 2, Quad, 4 * sizeof(float));
    }

    // Runs after the stock blur, with its temp target still bound as the texture and the result as
    // the render target. The temp target is free to reuse until the next shadow render.
    void ShadowBlur(SafetyHookContext& ctx)
    {
        if (!Acquire(*reinterpret_cast<uint8_t**>(ctx.ebp - 0x34))) // Viewport->RI
            return;

        static constexpr std::pair<D3DRENDERSTATETYPE, DWORD> RenderStates[] =
        {
            { D3DRS_ZENABLE, FALSE }, { D3DRS_ZWRITEENABLE, FALSE }, { D3DRS_ALPHABLENDENABLE, FALSE },
            { D3DRS_ALPHATESTENABLE, FALSE }, { D3DRS_STENCILENABLE, FALSE }, { D3DRS_SCISSORTESTENABLE, FALSE },
            { D3DRS_CULLMODE, D3DCULL_NONE }, { D3DRS_COLORWRITEENABLE, 0xF }, { D3DRS_SRGBWRITEENABLE, FALSE },
            { D3DRS_CLIPPLANEENABLE, 0 }, { D3DRS_FOGENABLE, FALSE },
        };
        static constexpr std::pair<D3DSAMPLERSTATETYPE, DWORD> SamplerStates[] =
        {
            { D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP }, { D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP },
            { D3DSAMP_MINFILTER, D3DTEXF_LINEAR }, { D3DSAMP_MAGFILTER, D3DTEXF_LINEAR },
            { D3DSAMP_MIPFILTER, D3DTEXF_NONE }, { D3DSAMP_SRGBTEXTURE, FALSE },
        };

        IDirect3DSurface9*     result        = nullptr;
        IDirect3DBaseTexture9* bound         = nullptr;
        IDirect3DTexture9*     resultTexture = nullptr;
        IDirect3DSurface9*     tempSurface   = nullptr;
        IDirect3DStateBlock9*  saved         = nullptr;
        D3DSURFACE_DESC        resultDesc{}, tempDesc{};

        device->GetRenderTarget(0, &result);
        device->GetTexture(0, &bound);
        auto temp = (bound && bound->GetType() == D3DRTYPE_TEXTURE) ? static_cast<IDirect3DTexture9*>(bound) : nullptr;
        auto shadow = result && SUCCEEDED(result->GetDesc(&resultDesc)) && resultDesc.Width == static_cast<UINT>(iSize);

        if (iPairs && shadow && temp &&
            SUCCEEDED(temp->GetLevelDesc(0, &tempDesc)) &&
            tempDesc.Width == static_cast<UINT>(iSize) && (tempDesc.Usage & D3DUSAGE_RENDERTARGET) &&
            SUCCEEDED(result->GetContainer(__uuidof(IDirect3DTexture9), reinterpret_cast<void**>(&resultTexture))) &&
            SUCCEEDED(temp->GetSurfaceLevel(0, &tempSurface)) &&
            SUCCEEDED(device->CreateStateBlock(D3DSBT_ALL, &saved)))
        {
            float falloff[] = { fFalloff, 0, 0, 0 };
            int   pairs[]   = { iPairs, 0, 0, 0 };

            device->SetVertexDeclaration(declaration);
            device->SetVertexShader(vertexShader);
            device->SetPixelShader(pixelShader);
            device->SetPixelShaderConstantF(1, falloff, 1);
            device->SetPixelShaderConstantI(0, pairs, 1);
            for (auto [state, value] : RenderStates)
                device->SetRenderState(state, value);
            for (auto [state, value] : SamplerStates)
                device->SetSamplerState(0, state, value);

            Pass(resultTexture, tempSurface, 1.0f / iSize, 0.0f);
            Pass(temp, result, 0.0f, 1.0f / iSize);

            saved->Apply();

            static bool logged = false;
            if (!logged)
                spdlog::info("ShadowResolution: First shadow blurred, {} texel pairs per pass", iPairs);
            logged = true;
        }
        else if (iPairs)
        {
            static bool warned = false;
            if (!warned)
                spdlog::warn("ShadowResolution: Stock blur targets not bound as expected (result {} at {}, temp {} at {}), stock shadow blur",
                             (void*)result, resultDesc.Width, (void*)temp, tempDesc.Width);
            warned = true;
        }

        // The projector clamps its UVs onto receivers it doesn't clip, so the edge texels are
        // stretched across everything outside it. Keep them the untouched white.
        if (shadow)
        {
            RECT edges[] = { { 0, 0, iSize, 1 }, { 0, iSize - 1, iSize, iSize }, { 0, 0, 1, iSize }, { iSize - 1, 0, iSize, iSize } };
            for (auto& edge : edges)
                device->ColorFill(result, &edge, 0xFFFFFFFF);
        }

        if (saved)         saved->Release();
        if (tempSurface)   tempSurface->Release();
        if (resultTexture) resultTexture->Release();
        if (bound)         bound->Release();
        if (result)        result->Release();
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

FEATURE(Engine, ShadowResolution)
{
    iSize = iShadowResolution;

    if (iSize < 128 || iSize > 2048 || (iSize & (iSize - 1)))
    {
        spdlog::error("ShadowResolution: {} is not a power of two between 128 and 2048", iSize);
        return;
    }

    while ((1 << iBits) < iSize)
        ++iBits;

    auto engine = GetModuleHandleW(L"Engine");
    auto constructor = GetProcAddress(engine, "??0UShadowBitmapMaterial@@QAE@XZ");

    if (!constructor)
    {
        spdlog::error("ShadowResolution: UShadowBitmapMaterial constructor not found");
        return;
    }

    shShadowBitmapMaterial = safetyhook::create_inline(constructor, ShadowBitmapMaterial);
    spdlog::info("ShadowResolution: Pawn shadows render at {0}x{0}", iSize);

    // Just after the stock blur's Flush in UShadowBitmapMaterial::Get
    auto blur = FindModulePattern(engine, { "8D 8D 98 F0 FF FF E8 ? ? ? ? 8D 8D 98 F0 FF FF C6 45 FC 02 E8" });

    if (blur.empty())
    {
        spdlog::error("ShadowResolution: Stock blur not found in UShadowBitmapMaterial::Get, shadows keep the stock blur and edges");
        return;
    }

    // Softness on the ground relative to stock. Detail keeps it stock up to 256, then a quarter by 2048
    auto softness = bShadowDetail ? std::min(1.0f, std::pow(256.0f / iSize, 2.0f / 3.0f)) : 1.0f;
    auto scale = iSize / 128.0f * softness;
    auto variance = StockVariance * (scale * scale - 1.0f);

    if (variance > 0.0f)
    {
        auto sigma = std::sqrt(variance);
        fFalloff = -1.442695f / (2.0f * variance);
        iPairs = std::min(static_cast<int>(std::ceil(1.5f * sigma)), 255);
        spdlog::info("ShadowResolution: Blur widened by a sigma of {:.2f} texels, {:.2f}x stock softness on the ground", sigma, softness);
    }

    mhShadowBlur = safetyhook::create_mid(blur.get_first(11), ShadowBlur);
    spdlog::info("ShadowResolution: Shadow texture edges kept clear, so the clamped projection can't streak");
}

// The blur's shaders belong to the D3D9 device, so they go before SetRes or Exit can replace it
FEATURE(D3DDrv, ShadowBlurDevice)
{
    auto d3dDrv = GetModuleHandleW(L"D3DDrv");
    auto setRes = GetProcAddress(d3dDrv, "?SetRes@UD3DRenderDevice@@UAEHPAVUViewport@@HHH@Z");
    auto exit   = GetProcAddress(d3dDrv, "?Exit@UD3DRenderDevice@@UAEXPAVUViewport@@@Z");

    if (!setRes || !exit)
    {
        spdlog::error("ShadowResolution: SetRes {}, Exit {}", (void*)setRes, (void*)exit);
        return;
    }

    shSetRes = safetyhook::create_inline(setRes, SetRes);
    shExit   = safetyhook::create_inline(exit, Exit);
}
