Shader "Pong/Final"
{
    Properties
    {
        [HideInInspector] _MainTex("Texture", 2D) = "black" {}
        [Toggle(DEBUG_MEMORY)] _DebugMemory("Debug Memory", Float) = 0
        [Toggle(NEW_GAME)] _NewGame("New Game", Float) = 0
        [Toggle(PAUSE_GAME)] _PauseGame("Pause Game", Float) = 0
        _GameSpeed("Game Speed", Range(0, 10)) = 1

        [Header(AI)]
        _AISpeed("AI Speed", Range(0, 1)) = 0.1

        [Header(Player 1)]
        [Toggle(PLAYER_1)] _Player1("Player 1", Float) = 1.0
        _Player1PaddlePos("Paddle Pos", Range(0, 1)) = 0.5

        [Header(Player 2)]
        [Toggle(PLAYER_2)] _Player2("Player 2", Float) = 0.0
        _Player2PaddlePos("Paddle Pos", Range(0, 1)) = 0.5        

        [Header(Color)]
        _BackgroundColor("Background Color", Color) = (0, 0, 0, 0)
        _ObjectColor("Object Color", Color) = (1, 1, 1, 1)

        [Header(Lighting)]
        _Vignette("Vignette (rgb=color, a=radius)", Color) = (0, 0, 0, 0.5)
        _Light("Light (xy=position)", Vector) = (0.5, 1, 0, 0)
        _ShadowColor("Shadow Color (a=intensity)", Color) = (0, 0, 0, 0)

        [Header(Ball)]
        _BallStartPos("Ball Start Pos", Vector) = (0.5, 0.7, 0, 0)
        _BallSize("Ball Size", Range(0, 1)) = 0.05
        _BallSpeed("Ball Speed", Range(0, 5)) = 0.05

        [Header(Paddles)]
        _PaddleOffsetX("Paddle Offset X", Range(0, 1)) = 0.05
        _PaddleSize("Paddle Size", Vector) = (0.05, 0.2, 0, 0)

        [Header(Score)]
        _ScoreOffsetX("Score Offset X", Range(0, 1)) = 0.1
        _ScoreOffsetY("Score Offset Y", Range(0, 1)) = 0.1
        _ScoreSize("Score Size", Vector) = (0.01, 0.01, 0, 0)
        _ScoreSpacing("Score Spacing", Range(0, 1)) = 0.02
        _ScoreColor("Score Color", Color) = (1, 1, 1, 1)

        [Header(Volume)]
        _MaxVolume("Max Volume", Range(0.0, 1.0)) = 1.0
        _VolumeDecaySpeed("Volume Decay Speed", Range(0.0, 2.0)) = 0.2
    }
    SubShader
    {
        Pass
        {
            Name "Pong"

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature_local_fragment DEBUG_MEMORY
            #pragma shader_feature_local_fragment NEW_GAME
            #pragma shader_feature_local_fragment PAUSE_GAME
            #pragma shader_feature_local_fragment PLAYER_1
            #pragma shader_feature_local_fragment PLAYER_2

            #include "Assets/Source/Lib/Input.hlsl"
            #include "Assets/Source/Lib/Coordinates.hlsl"
            #include "Assets/Source/Lib/GameObjects.hlsl"
            #include "Assets/Source/Lib/Persistence.hlsl"
            #include "Assets/Source/Lib/Physics.hlsl"
            #include "Assets/Source/Lib/Pong.hlsl"
            #include "Assets/Source/Lib/Rendering.hlsl"
            #include "Assets/Source/Lib/Vertex.hlsl"
            
            float4 frag(Varyings i) : SV_Target
            {
                // Game Loop
                GameState gameState = LoadGameState();
                StartGame(gameState);
                UpdateGame(gameState, unity_DeltaTime.x * _GameSpeed);

                // Persistence
                float memory = SaveGameState(gameState, i.uv);
                #ifdef DEBUG_MEMORY
                    return memory;
                #endif
                
                // Setup "Scene"
                GameObjects gameObjects = (GameObjects) 0;
                RegisterGameObject(gameObjects, gameState.BallPos, SquareUV(_BallSize)); 
                RegisterGameObject(gameObjects, gameState.Player1Pos, _PaddleSize);
                RegisterGameObject(gameObjects, gameState.Player2Pos, _PaddleSize);
                
                // Rendering
                float3 output;
                DrawBackground(output, i.uv);
                DrawShadows(output, i.uv, gameObjects);
                DrawObjects(output, i.uv, gameObjects);
                DrawUI(output, i.uv, gameState.Score);
                
                return float4(output, memory);
            }
            ENDHLSL
        }
        
    }
}
