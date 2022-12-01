// _lineLine and _lineRect adapted from jeffreythompson.org under the
// Creative Commons Attribution, Non-Commercial, Share-Alike license.

#ifndef PHYSICS_INCLUDED
#define PHYSICS_INCLUDED

// returns true if the two lines intersect, and populates the collision point.
// http://www.jeffreythompson.org/collision-detection/line-line.php
bool _lineLine(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4, out float2 collision)
{
    // calculate the distance to intersection point
    float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
    float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

    // if uA and uB are between 0-1, lines are colliding
    bool hit = uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1;
    if (hit)
        collision = float2(x1 + (uA * (x2-x1)), y1 + (uA * (y2-y1)));
    return hit;
}

// returns true if the line intersects the rect, and populates the collision point. 
// http://www.jeffreythompson.org/collision-detection/line-rect.php
bool _lineRect(float x1, float y1, float x2, float y2, float rx, float ry, float rw, float rh, out float2 collision) 
{
    bool left = _lineLine(x1, y1, x2, y2, rx - rw, ry - rh, rx - rw, ry + rh, collision);
    if (left) 
        return true;
    bool right = _lineLine(x1, y1, x2, y2, rx + rw, ry - rh, rx + rw, ry + rh, collision);
    if (right) 
        return true;
    bool top = _lineLine(x1, y1, x2, y2, rx - rw, ry + rh, rx + rw, ry + rh, collision);
    if (top) 
        return true;
    bool bottom = _lineLine(x1, y1, x2, y2, rx - rw, ry - rh, rx + rw, ry - rh, collision);
    if (bottom) 
        return true;

    return false;
}

bool LineCollides(GameObjects physicsObjects, float2 start, float2 end, out float2 collision)
{
    start = UVToPixels(start);
    end = UVToPixels(end);

    for (int i = 0; i < physicsObjects.NumObjects; i++)
    {
        float4 object = physicsObjects.Objects[i];
        if (_lineRect(start.x, start.y, end.x, end.y, object.x, object.y, object.z, object.w, collision))
        {
            collision = PixelsToUV(collision);
            return true;
        }
    }
    return false;
}  
#endif