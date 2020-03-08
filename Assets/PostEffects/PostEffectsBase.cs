using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UnityStandardAsserts.ImageEffects
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(Camera))]
    public class PostEffectsBase : MonoBehaviour
    {
        protected bool supportHDRTextures = true; //检测是否支持HDR贴图
        protected bool supportDX11 = false; //检测是否支持DX11
        protected bool isSupported = true; //标志用

        //检查shader并创建材质
        protected Material CheckShaderAndCreateMaterial(Shader shader, Material materialCreate)
        {
            //shader是不是存在 不存在关闭这个behavior 并返回空
            if (!shader)
            {
                Debug.Log("Missing Shader in " + ToString());
                enabled = false;
                return null;
            }

            //检测显卡是否支持 支持并且材质存在并且材质的shader和被检查的shader是同一个 返回当前材质
            if (shader.isSupported && materialCreate && materialCreate.shader == shader)
            {
                return materialCreate;
            }
            //如果到一步检测完之后没有返回 说明 shader存在 可能存在shader不支持|材质不存在|shader不匹配

            //检测shader平台支持
            if (!shader.isSupported)
            {
                NotSupported();
                Debug.Log("The Shader" + shader.ToString() + "on effect" + ToString() + "is not supported.");
                return null;
            }
            else
            {
                //进行到这一步 说明shader存在且被支持 那么就是材质不存在或者shader不匹配 就进行材质的创建
                materialCreate = new Material(shader); //用当前的shader创建一个新的材质
                materialCreate.hideFlags = HideFlags.DontSave; //设置对象为不会被保存到Scene 加载新场景不会被破坏
                if (materialCreate)
                {
                    return materialCreate; //创建成功 返回
                }
                else
                {
                    return null; //创建失败
                }
            }
        }

        protected Material CreateMaterial(Shader shader, Material materialCreate)
        {
            if (!shader)
            {
                Debug.Log("Missing shader in " + ToString());
                return null;
            }

            if (materialCreate && (materialCreate.shader == shader) && (shader.isSupported))
            {
                return materialCreate;
            }

            if (!shader.isSupported)
            {
                return null;
            }
            else
            {
                materialCreate = new Material(shader);
                materialCreate.hideFlags = HideFlags.DontSave;
                if (materialCreate)
                {
                    return materialCreate;
                }
                else
                {
                    return null;
                }
            }
        }

        void OnEnable()
        {
            isSupported = true;
        }

        protected bool CheckSupport()
        {
            return CheckSupport(false);
        }

        public virtual bool CheckResources()
        {
            Debug.LogWarning("CheckResources () for " + ToString() + " should be overwritten.");
            return isSupported;
        }

        protected void Start()
        {
            CheckResources();
        }

        protected bool CheckSupport(bool needDepth)
        {
            isSupported = true; //先把支持标志设置成true
            supportHDRTextures = SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.ARGBHalf); //检查当前的平台是否支持当前的Texture格式的ARGB通道
            supportDX11 = SystemInfo.graphicsShaderLevel >= 50 && SystemInfo.supportsComputeShaders; //检查当前的硬件的着色器功能支持级别是否>=50（这个值表示DX11） 并且 是否支持computer shader

            //需不需要深度值？ 需要的时候支持不支持高精度深度类型？
            if (needDepth && !SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.Depth))
            {
                NotSupported();
                return false;
            }

            if (needDepth)
            {
                GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth; //需要深度值的话 摄像机生成的深度纹理类型和DepthTextureMode的“Depth”类型 两者中有一个满足即可
            }

            return true;
        }

        //需要深度 又需要hdr
        protected bool CheckSupport(bool needDepth, bool needHdr)
        {
            if (!CheckSupport(needDepth)) //不支持深度纹理
            {
                return false;
            }
            if (needHdr && !supportHDRTextures) //不需要HDR 或者 不支持HDR
            {
                return false;
            }

            return true;
        }

        public bool Dx11Support()
        {
            return supportDX11;
        }

        protected void ReportAutoDisable()
        {
            Debug.LogWarning("The image effect " + ToString() + " has been disabled as it's not supported on the current platform.");
        }

        //支持检测失败
        protected void NotSupported()
        {
            enabled = false; //关闭启用
            isSupported = false; //将是否支持标志设为false
        }


    }
}