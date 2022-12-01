using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(menuName = "Rendering/Custom Render Pipeline")]
public class CustomRenderPipelineAsset : RenderPipelineAsset 
{

    public Material Material;

    private CustomRenderPipeline _pipeline;

    protected override RenderPipeline CreatePipeline()
    {
        this._pipeline = new CustomRenderPipeline(this.Material);
        return this._pipeline;
    }

    public RenderTexture GetLatestFrameTexture(Camera camera)
        => this._pipeline.GetLatestFrameTexture(camera);

}