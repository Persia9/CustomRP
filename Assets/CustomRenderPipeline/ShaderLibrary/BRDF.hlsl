//定义BRDF函数需要传入的参数
#ifndef CUSTOM_BRDF_INCLUDED
#define CUSTOM_BRDF_INCLUDED

//最小高光反射率
#define MIN_REFLECTIVITY 0.04

//物体表面属性，该结构体在片元着色器中被构建
struct BRDF
{
    //物体表面漫反射颜色
    float3 diffuse;
    //物体表面高光颜色
    float3 specular;
    //物体表面粗糙度
    float3 roughness;
};

float OneMinusReflectivity(float metallic)
{
    //将漫反射反射率控制在[0,0.96]内
    float range = 1.0 - MIN_REFLECTIVITY;
    return range - metallic * range;
}

BRDF GetBRDF(Surface surface,bool applyAlphaToDiffuse = false)
{
    BRDF brdf;
    //Reflectivity表示Specular反射率
    float oneMinusReflectivity = OneMinusReflectivity(surface.metallic);
    //diffuse等于物体表面不吸收的光能量color*(1-高光反射率)
    brdf.diffuse = surface.color * oneMinusReflectivity;
    if(applyAlphaToDiffuse)
    {
        //diffuse随alpha渐变
        brdf.diffuse *= surface.alpha;
    }
    //高光占比(specular)应该等于surface.color(物体不吸收的光能量，即用于反射的所有光能量)-brdf.diffuse(漫反射占比)
    //但是直接减违背了事实,即金属
    brdf.specular = lerp(MIN_REFLECTIVITY, surface.color, surface.metallic);
    //先根据surface.smoothness计算出感知粗糙度，再将感知粗糙度转为实际粗糙度
    //PerceptualSmoothnessToPerceptualRoughness返回值就是(1-surface.smoothness)
    float perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(surface.smoothness);
    //PerceptualRoughnessToRoughness返回的值就是perceptualRoughness的平方
    brdf.roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
    return brdf;
}

//高光强度
float SpecularStrength(Surface surface, BRDF brdf, Light light)
{
    //SafeNormalize防止观察方向与物体表面法线完全反向时，其相加结果为0向量导致归一化时除以0
    float3 h = SafeNormalize(light.direction + surface.viewDirection);
    float nh2 = Square(saturate(dot(surface.normal, h)));
    float lh2 = Square(saturate(dot(light.direction, h)));
    float r2 = Square(brdf.roughness);
    float d2 = Square(nh2 * (r2 - 1.0) + 1.0001);
    float normalization = brdf.roughness * 4.0 + 2.0;
    return r2 / (d2 * max(0.1, lh2) * normalization);
}

//计算反射出的总光能量比例(漫反射+高光)
float3 DirectBRDF(Surface surface, BRDF brdf, Light light)
{
    return SpecularStrength(surface, brdf, light) * brdf.specular + brdf.diffuse;
}

#endif
