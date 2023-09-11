#ifndef CUSTOM_UNITY_INPUT_INCLUDED
#define CUSTOM_UNITY_INPUT_INCLUDED

CBUFFER_START(UnityPerDraw)
float4x4 unity_ObjectToWorld;
float4x4 unity_WorldToObject;
//在定义(UnityPerDraw)CBuffer时，因为Unity对一组相关数据都归到一个Feature中，即使我们没用到unity_LODFade,我们也需要放到这个CBuffer中来构造一个完整的Feature
//如果不加这个unity_LODFade，不能支持SRP Batcher
float4 unity_LODFade;
real4 unity_WorldTransformParams;
CBUFFER_END

float4x4 unity_MatrixVP;
float4x4 unity_MatrixV;
float4x4 unity_MatrixInvV;
float4x4 unity_MatrixInvP;
float4x4 unity_MatrixInvVP;
float4x4 unity_MatrixPreviousM;
float4x4 unity_MatrixPreviousMI;
float4x4 glstate_matrix_projection;

//获取内置参数:摄像机世界空间坐标
float3 _WorldSpaceCameraPos;

#endif
