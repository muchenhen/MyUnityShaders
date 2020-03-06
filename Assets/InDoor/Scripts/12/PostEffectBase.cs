using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectBase : MonoBehaviour
{
    //检测是否支持
    protected void CheckResources() {
		bool isSupported = CheckSupport();
		
		if (isSupported == false) {
			NotSupported();
		}
	}

    protected bool CheckSupport()
    {
        if(SystemInfo.supportsImageEffects == false)
        {
            Debug.LogWarning("This platform does not support image effects");
            return false;
        }
        return true;
    }

    protected void NotSupported() {
		enabled = false;
	}

    protected void Start() {
		CheckResources();
	}

    //第一个参数指定了需要使用的shader 第二个是用于后期处理的材质
    protected Material CheckShaderAndCreateMaterial(Shader shader,Material material)
    {
        //先检查shader的可用性
        if(shader == null)
        {
            return null;
        }
        if(shader.isSupported && material && material.shader == shader)
            return material;
        if(!shader.isSupported)
        {
            return null;
        }
        else
        {
            material = new Material(shader);
            material.hideFlags=HideFlags.DontSave;
            if(material)
                return material;
            else
                return null;
        }
    }
    
}
