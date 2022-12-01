#ifndef PERSISTENCE_INCLUDED
#define PERSISTENCE_INCLUDED

struct GameState
{
    bool Started;

    float2 BallPos;
    float2 BallVelocity;
    float2 Player1Pos;
    float2 Player2Pos;
    int2 Score;

    float Volume;
};

#define MEMORY_BLOCK_SIZE .015
#define MEMORY_BLOCK_SPACING .05
#define MEMORY_BLOCK_POS(slot) \
    slot * MEMORY_BLOCK_SIZE + ((slot + 1) * MEMORY_BLOCK_SPACING)

#define GAME_STARTED_BLOCK    MEMORY_BLOCK_POS(int2(0, 0))
#define BALL_POS_X_BLOCK      MEMORY_BLOCK_POS(int2(0, 1))
#define BALL_POS_Y_BLOCK      MEMORY_BLOCK_POS(int2(0, 2))
#define BALL_VEL_X_BLOCK      MEMORY_BLOCK_POS(int2(0, 3))
#define BALL_VEL_Y_BLOCK      MEMORY_BLOCK_POS(int2(0, 4))
#define P1_PADDLE_POS_BLOCK   MEMORY_BLOCK_POS(int2(1, 0))
#define P2_PADDLE_POS_BLOCK   MEMORY_BLOCK_POS(int2(1, 1))
#define SCORE_P1_BLOCK        MEMORY_BLOCK_POS(int2(2, 0))
#define SCORE_P2_BLOCK        MEMORY_BLOCK_POS(int2(2, 1))
#define VOLUME_BLOCK          MEMORY_BLOCK_POS(int2(3, 0))

float SampleGameState(float2 block)
{
    #ifdef NEW_GAME
        return 0;
    #else
        return _MainTex.Sample(sampler_MainTex, block).a; 
    #endif
}     

GameState LoadGameState()
{
    GameState gameState = (GameState) 0;
    gameState.Started = SampleGameState(GAME_STARTED_BLOCK) > 0.5; 
    gameState.BallPos = float2(
        SampleGameState(BALL_POS_X_BLOCK), 
        SampleGameState(BALL_POS_Y_BLOCK)
    );
    gameState.BallVelocity = float2(
        SampleGameState(BALL_VEL_X_BLOCK), 
        SampleGameState(BALL_VEL_Y_BLOCK)
    );

    gameState.Player1Pos.x = _PaddleOffsetX; 
    #ifdef PLAYER_1
        gameState.Player1Pos.y = _Player1PaddlePos;
    #else
        gameState.Player1Pos.y = SampleGameState(P1_PADDLE_POS_BLOCK);
    #endif

    gameState.Player2Pos.x = 1 - _PaddleOffsetX;
    #ifdef PLAYER_2
        gameState.Player2Pos.y = _Player2PaddlePos;
    #else
        gameState.Player2Pos.y = SampleGameState(P2_PADDLE_POS_BLOCK);
    #endif
    
    gameState.Score = int2(
        round(SampleGameState(SCORE_P1_BLOCK)),
        round(SampleGameState(SCORE_P2_BLOCK))
    );

    gameState.Volume = SampleGameState(VOLUME_BLOCK);

    return gameState;
}

float SaveGameState(GameState gameState, float2 uv)
{
    float2 blockSize = SquareUV(MEMORY_BLOCK_SIZE); 
    if (InUVRect(GAME_STARTED_BLOCK, blockSize, uv))
        return gameState.Started; 
    if (InUVRect(BALL_POS_X_BLOCK, blockSize, uv))
        return gameState.BallPos.x;
    if (InUVRect(BALL_POS_Y_BLOCK, blockSize, uv))
        return gameState.BallPos.y;
    if (InUVRect(BALL_VEL_X_BLOCK, blockSize, uv))
        return gameState.BallVelocity.x;
    if (InUVRect(BALL_VEL_Y_BLOCK, blockSize, uv))
        return gameState.BallVelocity.y;
    if (InUVRect(P1_PADDLE_POS_BLOCK, blockSize, uv))
        return gameState.Player1Pos.y;
    if (InUVRect(P2_PADDLE_POS_BLOCK, blockSize, uv))
        return gameState.Player2Pos.y;
    if (InUVRect(SCORE_P1_BLOCK, blockSize, uv))
        return gameState.Score.x;
    if (InUVRect(SCORE_P2_BLOCK, blockSize, uv))
        return gameState.Score.y;
    if (InUVRect(VOLUME_BLOCK, blockSize, uv))
        return gameState.Volume;
    return 0;
}   
#endif