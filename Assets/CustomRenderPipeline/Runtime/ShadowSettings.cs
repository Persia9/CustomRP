using System;
using UnityEngine;

//用来存放阴影配置选项的容器
[Serializable]
public class ShadowSettings
{
    //maxDistance决定视野内多大范围会被渲染到阴影贴图上，距离主摄像机超过maxDistance的物体不会被渲染在阴影贴图上
    [Min(0f)] public float maxDistance = 100f;

    //阴影贴图的所有尺寸，使用枚举防止出现其他数值，范围为256-8192
    public enum MapSize
    {
        _256 = 256,
        _512 = 512,
        _1024 = 1024,
        _2048 = 2048,
        _4096 = 4096,
        _8192 = 8192,
    }

    //定义方向光源的阴影贴图配置
    [Serializable]
    public struct Directional
    {
        public MapSize atlasSize;

        [Range(1, 4)] public int cascadeCount;

        [Range(0f, 1f)] public float cascadeRatio1, cascadeRatio2, cascadeRatio3;

        public Vector3 CascadeRatios => new Vector3(cascadeRatio1, cascadeRatio2, cascadeRatio3);
    }

    //创建一个1024大小的Directional Shadow Map
    public Directional directional = new Directional
    {
        atlasSize = MapSize._1024,
        cascadeCount = 4,
        cascadeRatio1 = 0.1f,
        cascadeRatio2 = 0.25f,
        cascadeRatio3 = 0.5f
    };
}