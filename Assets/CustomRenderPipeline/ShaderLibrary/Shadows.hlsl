//用来采样阴影贴图
#ifndef CUSTOM_SHADOWS_INCLUDED
#define CUSTOM_SHADOWS_INCLUDED

//宏定义最大支持阴影的方向光源数，需要与cpu端匹配
#define MAX_SHADOWED_DIRECTIONAL_LIGHT_COUNT 4
//宏定义最大支持阴影级联数，需要与cpu端匹配
#define MAX_CASCADE_COUNT 4

//接收CPU端传来的每个Shadow Tile的阴影变换矩阵
CBUFFER_START(_CustomShadows)
int _CascadeCount;
float4 _CascadeCullingSpheres[MAX_CASCADE_COUNT];
float4x4 _DirectionalShadowMatrices[MAX_SHADOWED_DIRECTIONAL_LIGHT_COUNT * MAX_CASCADE_COUNT];
float _ShadowDistance;
CBUFFER_END

//接收CPU端传来的ShadowAtlas
//使用TEXTURE2D_SHADOW来明确接收的是阴影贴图
TEXTURE2D_SHADOW(_DirectionalShadowAtlas);
//阴影贴图只有一种采样方式，因此显示定义一个阴影采样器状态,而不是依赖于Unity为渲染纹理推断的状态
//Unity会将sampler_linear_clamp_compare翻译成使用Linear过滤、Clamp包裹的用于深度比较的采样器
#define SHADOW_SAMPLER sampler_linear_clamp_compare
//SAMPLER_CMP是一个特殊的采样器，通过与其匹配的SampleCmp函数来采样深度图
//SampleCmp将采样一块纹素区域(不是一个纹素)，对于每个纹素，将其采样出来的深度值与给定比较值进行比较，返回0或1，最后将这些纹素的每个0或1结果通过纹理过滤模式混合在一起(不是平均值混合)，最后将[0..1]的float类型混合结果返回给着色器
SAMPLER_CMP(SHADOW_SAMPLER);

struct ShadowData
{
    int cascadeIndex;
    float strength;
};

float FadedShadowStrength(float distance, float scale, float fade)
{
    return saturate((1.0 - distance * scale) * fade);
}

ShadowData GetShadowData(Surface surfaceWS)
{
    ShadowData data;
    data.strength = surfaceWS.depth < _ShadowDistance ? 1.0 : 0.0;
    int i;
    for (i = 0; i < _CascadeCount; i++)
    {
        float4 sphere = _CascadeCullingSpheres[i];
        float distanceSqr = DistanceSquared(surfaceWS.position, sphere.xyz);
        if (distanceSqr < sphere.w)
        {
            break;
        }
    }
    //超出最大的级联Culling Sphere时，不对其渲染阴影，将其阴影强度设置为0
    if (i == _CascadeCount)
    {
        data.strength = 0.0;
    }
    data.cascadeIndex = i;
    return data;
}

//每个方向光源的阴影信息(包括不支持阴影的光源，不支持，其阴影强度就是0)
struct DirectionalShadowData
{
    float strength;
    int tileIndex;
};

//采样ShadowAtlas，传入positionSTS(STS是Shadow Tile Space，即阴影贴图对应Tile像素空间下的片元坐标)
float SampleDirectionalShadowAtlas(float3 positionSTS)
{
    //使用特定宏来采样阴影贴图
    return SAMPLE_TEXTURE2D_SHADOW(_DirectionalShadowAtlas, SHADOW_SAMPLER, positionSTS);
}

//计算阴影衰减值，返回值[0..1]，0代表阴影衰减最大(片元完全在阴影中)，1代表阴影衰减最少，片元完全被光照射，[0..1]的中间值代表片元有一部分在阴影中
float GetDirectionalShadowAttenuation(DirectionalShadowData data, Surface surfaceWS)
{
    //忽略不开启阴影和阴影强度为0的光源
    if (data.strength <= 0.0)
    {
        return 1.0;
    }
    //根据对应Tile阴影变换矩阵和片元的世界坐标计算Tile上的像素坐标STS
    float3 positionSTS = mul(_DirectionalShadowMatrices[data.tileIndex], float4(surfaceWS.position, 1.0)).xyz;
    //采样Tile得到阴影强度值
    float shadow = SampleDirectionalShadowAtlas(positionSTS);
    //考虑光源的阴影强度，strength为0时没有阴影
    return lerp(1.0, shadow, data.strength);
}

#endif
