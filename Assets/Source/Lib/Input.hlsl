#ifndef INPUT_INCLUDED
#define INPUT_INCLUDED

// Recreate Standard Unity Input
//
float2 _ScreenParams;
float4 _Time;
float4 _SinTime;

float4 unity_DeltaTime;
float4x4 unity_ObjectToWorld;
float4x4 unity_MatrixVP;

// Vertex Input
//
struct Attributes
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};

// Frag Input
//
struct Varyings
{
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
};







// Material Input
//
Texture2D _MainTex;
SamplerState sampler_MainTex;

cbuffer UnityPerMaterial
{
    float _GameSpeed;

    float2 _BallStartPos;
    float3 _BackgroundColor;
    float3 _ObjectColor;

    float4 _Vignette;
    float2 _Light;
    float4 _ShadowColor;

    float _BallSize;
    float _BallSpeed;

    float _AISpeed;

    float _PaddleOffsetX;
    float2 _PaddleSize;
    float _Player1PaddlePos;
    float _Player2PaddlePos;

    float _ScoreOffsetX;
    float _ScoreOffsetY;
    float2 _ScoreSize;
    float _ScoreSpacing;
    float4 _ScoreColor;

    float _MaxVolume;
    float _VolumeDecaySpeed;
};

#endif