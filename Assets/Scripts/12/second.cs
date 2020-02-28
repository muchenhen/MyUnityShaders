using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class second : PostEffectBase
{
    public Shader briSatConShader;
    private Material briSatConMaterial;
    public Material material
    {
        get
        {
            briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader,briSatConMaterial);
            return briSatConMaterial;
        }
    }

    //参数
    [Range(0.0f,3.0f)]
    public float brightness = 1.0f;
    [Range(0.0f,3.0f)]
    public float saturation = 1.0f;
    [Range(0.0f,3.0f)]
    public float contrast = 1.0f;

    void OnRenderImage(RenderTexture src, RenderTexture dest) {
        //先检查是否可用 然后传递参数
        if(material != null)
        {
            material.SetFloat("_Brightness",brightness);
            material.SetFloat("_Saturation",saturation);
            material.SetFloat("_Contrast",contrast);

            Graphics.Blit(src,dest,material);
        }
        else//否则直接显示到屏幕上
        {
            Graphics.Blit(src,dest);
        }
    }

}
