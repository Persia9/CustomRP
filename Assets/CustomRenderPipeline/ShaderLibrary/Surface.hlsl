//定义与光照相关的物体表面属性
//HLSL编译保护机制
#ifndef CUSTOM_SURFACE_INCLUDED
#define CUSTOM_SURFACE_INCLUDED

//物体表面属性，该结构体在片元着色器中被构建
struct Surface
{
    //世界坐标
    float3 position;
    //顶点法线，在这里不明确其坐标空间，因为光照可以在任何空间下计算，在该项目中使用世界空间
    float3 normal;
    //观察方向
    float3 viewDirection;
    //深度
    float depth;
    //表面颜色
    float3 color;
    //透明度
    float alpha;
    //金属度
    float metallic;
    //光滑度
    float smoothness;
};

#endif
