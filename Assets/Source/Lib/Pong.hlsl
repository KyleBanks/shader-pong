#ifndef PONG_INCLUDED
#define PONG_INCLUDED

void ResetBall(inout GameState gameState)
{
    gameState.BallPos = _BallStartPos;
    gameState.BallVelocity = float2(
        floor(_Time.y) % 2 == 0 ? 1 : -1,
        _SinTime.y
    );
}

void StartGame(inout GameState gameState)
{
    if (gameState.Started)
        return;

    gameState.Started = true;
    gameState.Player1Pos.y = 0.5;
    gameState.Player2Pos.y = 0.5;
    gameState.Score = int2(0, 0);
    ResetBall(gameState);
}

void UpdateAI(inout float2 pos, GameState gameState, float deltaTime)
{
    float2 ballEndPos = gameState.BallPos + (gameState.BallVelocity * 10);
    float2 targetPos = 0;
    if (!_lineLine(pos.x, -100, pos.x, 100, gameState.BallPos.x, gameState.BallPos.y, ballEndPos.x, ballEndPos.y, targetPos))
        return;

    float targetDir = sign(targetPos.y - pos.y);
    float targetDist = abs(targetPos.y - pos.y);
    float movement = targetDir * min(targetDist, _AISpeed * deltaTime);
    pos.y = saturate(pos.y + movement);
}

void UpdateGame(inout GameState gameState, float deltaTime)
{
    #if defined(NEW_GAME) || defined(PAUSE_GAME)
        return;
    #endif

    // apply velocity
    float2 previousBallPos = gameState.BallPos;
    gameState.BallPos += gameState.BallVelocity * deltaTime * _BallSpeed;

    // update AI paddles
    #ifndef PLAYER_1
        UpdateAI(gameState.Player1Pos, gameState, deltaTime);
    #endif
    #ifndef PLAYER_2
        UpdateAI(gameState.Player2Pos, gameState, deltaTime);
    #endif                  

    // check for paddle collisions
    GameObjects paddles = (GameObjects) 0;
    RegisterGameObject(paddles, gameState.Player1Pos, _PaddleSize);
    RegisterGameObject(paddles, gameState.Player2Pos, _PaddleSize);

    // check the line from previous to current position so you can't jump through the paddles
    float2 paddleCollisionPoint = 0;
    bool collision = LineCollides(paddles, previousBallPos, gameState.BallPos, paddleCollisionPoint);
    // flip the ball direction on paddle hit
    if (collision)
    {
        float2 ballSize = SquareUV(_BallSize);
        gameState.BallPos = paddleCollisionPoint - float2(
            // add a slight buffer to avoid getting stuck inside paddle
            sign(gameState.BallVelocity.x) * ballSize.x * 1.01, 
            0
        );
        gameState.BallVelocity.x *= -1;
    }

    // update volume, decaying if no collision
    gameState.Volume = max(
        collision ? _MaxVolume : 0, 
        gameState.Volume - deltaTime * _VolumeDecaySpeed
    ); 

    // scoring
    if (gameState.BallPos.x < 0)
    {
        gameState.Score.y ++;
        ResetBall(gameState);
    }
    else if (gameState.BallPos.x > 1)
    {
        gameState.Score.x ++;
        ResetBall(gameState);
    }
    // handle vertical boundaries
    else if (gameState.BallPos.y < 0 || gameState.BallPos.y > 1)
    {
        gameState.BallPos.y = saturate(gameState.BallPos.y);
        gameState.BallVelocity.y *= -1;
    }              
}   
#endif