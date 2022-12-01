#ifndef RENDERING_INCLUDED
#define RENDERING_INCLUDED

void DrawBackground(inout float3 output, float2 uv)
{
    // vignette based on distance to center of the screen
    float t = distance(uv, float2(0.5, 0.5)) / _Vignette.a;
    output = lerp(
        _BackgroundColor,
        _Vignette.rgb,
        t 
    );
}

void DrawShadows(inout float3 output, float2 uv, GameObjects shadowCasters)
{
    // check for collision between the current pixel and the light source
    // if a collision is found, then we're in a shadow
    float2 _;
    bool shadow = LineCollides(shadowCasters, uv, _Light, _);
    output = lerp(
        output, 
        _ShadowColor.rgb, 
        shadow * _ShadowColor.a
    );
}

void DrawObjects(inout float3 output, float2 uv, GameObjects gameObjects)
{
    for (int i = 0; i < gameObjects.NumObjects; i++)
    {
        float4 object = gameObjects.Objects[i];
        if (InPixelRect(object.xy, object.zw, uv))
            output = _ObjectColor;
    }
}

void DrawUI(inout float3 output, float2 uv, int2 fullScore)
{
    int score;
    float spacingX;
    float2 startPos; 
    if (uv.x < 0.5) 
    {
        score = fullScore.x;
        spacingX = _ScoreSpacing;
        startPos = float2(_ScoreOffsetX, _ScoreOffsetY);
    }
    else
    {
        score = fullScore.y;
        spacingX = - _ScoreSpacing;
        startPos = float2(1 - _ScoreOffsetX, _ScoreOffsetY);
    }

    int rowLen = (int) floor((0.5 - _ScoreOffsetX) / (_ScoreSize + _ScoreSpacing));
    float2 currentPos = startPos;
    for (int i = 1; i <= score; i++)
    {
        if (InUVRect(currentPos, _ScoreSize, uv))
        {
            output = _ScoreColor.rgb;
            return;
        }

        if (i % rowLen == 0)
        {
            currentPos.x = startPos.x;
            currentPos.y += _ScoreSpacing;
        }
        else
        {
            currentPos.x += spacingX;
        }
    }
}
#endif