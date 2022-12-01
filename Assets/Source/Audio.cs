using System;
using UnityEngine;
using Unity.Collections;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;

[RequireComponent(typeof(AudioSource))]
public class Audio : MonoBehaviour
{

    const float MEMORY_BLOCK_SIZE = .015f;
    const float MEMORY_BLOCK_SPACING = .05f;

    public CustomRenderPipelineAsset RenderPipeline;
    public Vector2 MemoryBlock = new(3, 0);

    private AudioSource _audio;
    private NativeArray<float> _bufferArr;
    private Texture2D _bufferTex;

    private void Awake()
    {
        this._audio = this.GetComponent<AudioSource>();
        this._bufferArr = new NativeArray<float>(4, Allocator.Persistent, NativeArrayOptions.UninitializedMemory);
    }

    private void OnEnable()
    {
        this.SetVolume(0);
        this.SampleVolume();
    }

    private void OnDestroy()
    {
        AsyncGPUReadback.WaitAllRequests();
        this._bufferArr.Dispose();

        if (this._bufferTex != null)
            Destroy(this._bufferTex);
    }

    private void SetVolume(float volume)
        => this._audio.volume = volume;

    private void SampleVolume()
    {
        Camera camera = Camera.main;
        RenderTexture frameTex = this.RenderPipeline.GetLatestFrameTexture(camera);

        if (this._bufferTex == null)
        {
            TextureFormat tf = GraphicsFormatUtility.GetTextureFormat(frameTex.graphicsFormat);
            this._bufferTex = new Texture2D(1, 1, tf, false, true);
            this._bufferTex.hideFlags = HideFlags.HideAndDontSave;
        }

        // reconstruct the block position
        Vector2 blockPos = this.MemoryBlock * MEMORY_BLOCK_SIZE
            + ((this.MemoryBlock + Vector2.one) * MEMORY_BLOCK_SPACING);

        int x = Mathf.RoundToInt(blockPos.x * camera.pixelWidth);
        int y = Mathf.RoundToInt(blockPos.y * camera.pixelHeight);

        // copy one pixel from the render texture on the GPU
        Graphics.CopyTexture(
            frameTex, 
            0, 0, x, y, 1, 1, 
            this._bufferTex, 
            0, 0, 0, 0
        );

        // load the pixel back onto the CPU async
        AsyncGPUReadback.RequestIntoNativeArray(ref this._bufferArr, this._bufferTex, 0, this.OnSampleComplete);
    }

    private void OnSampleComplete(AsyncGPUReadbackRequest req)
    {
        if (this == null || !this.isActiveAndEnabled)
            return;

        if (req.hasError)
        {
            Debug.LogError("Failed to sample volume");
            return;
        }
        
        // set volume equal to the alpha channel of the pixel
        this.SetVolume(this._bufferArr[3]);

        // recursively sample volume
        this.SampleVolume();
    }

}
