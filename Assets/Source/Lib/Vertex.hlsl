#ifndef VERTEX_INCLUDED
#define VERTEX_INCLUDED

Varyings vert(Attributes i)
{
    Varyings o;
    o.vertex = mul(unity_MatrixVP, mul(unity_ObjectToWorld, i.vertex));
    o.uv = i.uv.xy;
    return o;
}

#endif