using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class fourth : PostEffectBase
{
    public Shader gaussianBlurShader;
    private Material gaussianBlurMaterial = null;
    public Material material
    {
        get
        {
            gaussianBlurMaterial = CheckShaderAndCreateMaterial(gaussianBlurShader,gaussianBlurMaterial);
            return gaussianBlurMaterial;
        }
    }

    [Range(0,4)]
    public int iterations = 3;//模糊程度

    [Range(0.2f,3.0f)]
    public float blurSpread = 0.6f;//出于性能考虑

    [Range(1,8)]
    public int downSample = 2;//该值越大 处理的像素数量越少 同时进一步提高模糊程度 但是过大会导致像素化

    void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (material != null) {
            int rtW = src.width/downSample;
            int rtH = src.height/downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW,rtH,0);
            buffer0.filterMode  = FilterMode.Bilinear;

            Graphics.Blit(src,buffer0);

            for (int i = 0; i < iterations; i++)
            {
                material.SetFloat("_BlurSize",1.0f + i*blurSpread);
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW,rtH,0);
                Graphics.Blit(buffer0,buffer1,material,0);

                //竖直方向
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW,rtH,0);

                //水平方向
                Graphics.Blit(buffer0,buffer1,material,1);
                
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 =buffer1;
            }
            Graphics.Blit(buffer0,dest);
            RenderTexture.ReleaseTemporary(buffer0);         
		} 
        else 
        {
			Graphics.Blit(src, dest);
		}
	}
}
