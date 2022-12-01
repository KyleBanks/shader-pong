#ifndef COORDINATES_INCLUDED
#define COORDINATES_INCLUDED

// Convert a point from UV to Pixel space.
float2 UVToPixels(float2 uv)
{
    return float2(_ScreenParams.x * uv.x, _ScreenParams.y * uv.y);
}

// Convert a point from Pixel to UV space.
float2 PixelsToUV(float2 pixels)
{
    return float2(pixels.x / _ScreenParams.x, pixels.y / _ScreenParams.y);
}

// Create a UV point that represents a square in its equivalent Pixel space, regardless of resolution.
float2 SquareUV(float len)
{
    float2 size = UVToPixels(len.xx);
    size.x = size.y = min(size.x, size.y);
    return PixelsToUV(size);
}

// Returns true if the UV point is contained within a rect defined in Pixel space.
bool InPixelRect(float2 center, float2 extents, float2 uv)
{
    uv = UVToPixels(uv);
    return (abs(center.x - uv.x) < extents.x) * (abs(center.y - uv.y) < extents.y);
}

// Returns true if the UV point is contained within a rect defined in UV space. 
bool InUVRect(float2 center, float2 extents, float2 uv)
{
    center = UVToPixels(center);
    extents = UVToPixels(extents);
    return InPixelRect(center, extents, uv);
}
#endif