using UnityEngine;
using UnityEngine.Rendering;

[System.Serializable]
public class CustomRenderPipeline : RenderPipeline 
{
    
    private static readonly int SHADER_PARAM_SCREEN_PARAMS = Shader.PropertyToID("_ScreenParams");
    private static readonly int SHADER_PARAM_TIME = Shader.PropertyToID("_Time");
    private static readonly int SHADER_PARAM_SIN_TIME = Shader.PropertyToID("_SinTime");
    private static readonly int DOUBLE_BUFFER_ID = Shader.PropertyToID("_DoubleBuffer");

    private readonly CommandBuffer _commandBuffer;
    private readonly Material _material;

    private RenderTexture _frameTex;

    public CustomRenderPipeline(Material material)
    {
        this._commandBuffer = new CommandBuffer();
        this._material = material;
    }

    // Render all active cameras
    protected override void Render(ScriptableRenderContext ctx, Camera[] cameras) 
    {
        this.SetTime(Time.time);

        for (int i = 0; i < cameras.Length; i++)
        {
            Camera camera = cameras[i];
            if (!camera.CompareTag("MainCamera"))
                continue;

            this.SetCamera(camera);
            this.Render(ctx, camera);
        }
    }
    
    // Render a specific camera
    private void Render(ScriptableRenderContext ctx, Camera camera)
    {
        RenderTexture lastFrame = this.GetLatestFrameTexture(camera);
        this._commandBuffer.Clear();

        // windows requires double-buffering, can't blit the frame over itself!
        #if UNITY_STANDALONE_WIN || UNITY_EDITOR_WIN
            this._commandBuffer.GetTemporaryRT(DOUBLE_BUFFER_ID, lastFrame.descriptor);
            this._commandBuffer.Blit(lastFrame, DOUBLE_BUFFER_ID, this._material);
            this._commandBuffer.Blit(DOUBLE_BUFFER_ID, lastFrame);
            this._commandBuffer.ReleaseTemporaryRT(DOUBLE_BUFFER_ID);
        #else
            this._commandBuffer.Blit(lastFrame, lastFrame, this._material);
        #endif
        
        this._commandBuffer.Blit(lastFrame, BuiltinRenderTextureType.CameraTarget);
        
        ctx.ExecuteCommandBuffer(this._commandBuffer);
        ctx.Submit();
    }

    public RenderTexture GetLatestFrameTexture(Camera camera)
    {
        int width = camera.pixelWidth;
        int height = camera.pixelHeight;
        
        if (this._frameTex != null && (this._frameTex.width != width || this._frameTex.height != height))
        {
            this._frameTex.Release();
            Object.Destroy(this._frameTex);
            this._frameTex = null;
        }

        if (this._frameTex == null)
            this._frameTex = new RenderTexture(camera.pixelWidth, camera.pixelHeight, 0, RenderTextureFormat.ARGBFloat);

        return this._frameTex;
    }

    // Standard Unity time shader parameters
    // https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
    private void SetTime(float t)
    {
        Shader.SetGlobalVector(SHADER_PARAM_TIME, new Vector4(
            t / 20, t, t * 2, t * 3
        ));
        Shader.SetGlobalVector(SHADER_PARAM_SIN_TIME, new Vector4(
            Mathf.Sin(t / 8), 
            Mathf.Sin(t / 4), 
            Mathf.Sin(t / 2),
            Mathf.Sin(t)
        ));
    }

    // Standard Unity camera shader parameters
    // https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
    private void SetCamera(Camera camera)
    {
        Shader.SetGlobalVector(SHADER_PARAM_SCREEN_PARAMS, new Vector2(
            camera.pixelWidth, camera.pixelHeight
        ));
    }

}