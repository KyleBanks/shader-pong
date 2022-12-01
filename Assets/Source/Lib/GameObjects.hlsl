#ifndef GAMEOBJECTS_INCLUDED
#define GAMEOBJECTS_INCLUDED

#define MAX_GAME_OBJECTS 3

struct GameObjects
{
    int NumObjects;
    float4 Objects[MAX_GAME_OBJECTS];
};

void RegisterGameObject(inout GameObjects gameObjects, float2 center, float2 extents)
{
    gameObjects.Objects[gameObjects.NumObjects] = float4(
        UVToPixels(center), 
        UVToPixels(extents)
    );
    gameObjects.NumObjects ++;
}

#endif