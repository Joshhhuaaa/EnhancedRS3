// One axis of a Gaussian blur over a shadow render target. Rebuild the headers after editing:
//   fxc /nologo /O3 /T vs_3_0 /E VS /Vn ShadowBlurVS /Fh shadow_blur_vs.h shadow_blur.hlsl
//   fxc /nologo /O3 /T ps_3_0 /E PS /Vn ShadowBlurPS /Fh shadow_blur_ps.h shadow_blur.hlsl

float4    Axis    : register(c0); // xy = one texel along the blur axis, zw = one texel in UV
float4    Falloff : register(c1); // x = -log2(e) / (2 sigma^2), so exp2(k * k * x) is the Gaussian at k texels
int       Pairs   : register(i0); // texel pairs per side, each read with one bilinear fetch
sampler2D Source  : register(s0);

float4 VS(float4 position : POSITION) : POSITION
{
    return position;
}

float4 PS(float2 position : VPOS) : COLOR
{
    float2 uv = (position + 0.5) * Axis.zw;
    float4 color = tex2Dlod(Source, float4(uv, 0, 0));
    float total = 1;
    float k = 1;

    [loop] for (int i = 0; i < Pairs; i++)
    {
        float a = exp2(k * k * Falloff.x);
        float b = exp2((k + 1) * (k + 1) * Falloff.x);
        float w = a + b;
        float2 offset = Axis.xy * (k + b / w);

        color += (tex2Dlod(Source, float4(uv + offset, 0, 0)) + tex2Dlod(Source, float4(uv - offset, 0, 0))) * w;
        total += 2 * w;
        k += 2;
    }

    return color / total;
}
