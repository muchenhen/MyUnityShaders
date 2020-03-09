using UnityEngine;
using System;

namespace UnityStandardAssets.ImageEffects
{
    [ExecuteInEditMode]
    [AddComponentMenu ("Image Effects/Color Adjustments/Color Correction (Curves, Saturation)")]

    public class ColorCorrectionCurves : PostEffectsBase
    {
        //设置矫正的模式 简单和高级两种
        public enum ColorCorrectionMode
        {
            Simple = 0,
            Advanced = 1
        }

        //将RGB分量的通道设置为曲线动画
        public AnimationCurve redChannel = new AnimationCurve(new Keyframe(0f,0f),new Keyframe(1f,1f));
        public AnimationCurve greenChannel = new AnimationCurve(new Keyframe(0f,0f),new Keyframe(1f,1f));
        public AnimationCurve blueChannel = new AnimationCurve(new Keyframe(0f,0f),new Keyframe(1f,1f));

        //深度值矫正的开关
        public bool useDepthCorrection = false;

        //将深度值相关通道设置为曲线动画
        public AnimationCurve zCurve = new AnimationCurve(new Keyframe(0f,0f), new Keyframe(1f,1f));
        public AnimationCurve depthRedChannel = new AnimationCurve(new Keyframe(0f,0f), new Keyframe(1f,1f));
        public AnimationCurve depthGreenChannel = new AnimationCurve(new Keyframe(0f,0f), new Keyframe(1f,1f));
        public AnimationCurve depthBlueChannel = new AnimationCurve(new Keyframe(0f,0f), new Keyframe(1f,1f));

        private Material colorCorrectMaterial;
        private Material colorCorrectDepthMaterial;
        private Material selectiveColorCorrectMaterial;

        private Texture2D rgbChannelTex;
        private Texture2D rgbDepthChannelTex;
        private Texture2D zCurveTex;

        
        //public float brightness = 1.0f;//亮度参数
        [Range(0.0f,3.0f)]
        public float saturation = 1.0f;//饱和度参数
       
        //public float contrast = 1.0f;//对比度参数

        public bool selectiveColorCorrect = false;
        public Color selectiveFromColor = Color.white;
        public Color selectiveToColor = Color.white;

        public ColorCorrectionMode mode;//矫正模式

        public bool updateTextures = true;
        public bool updateTexturesOnStartup = true;

        //指定着色器
        public Shader colorCorrectionCurvesShader = null;
        public Shader simpleColorCorrectionCurvesShader = null;
        public Shader colorCorrectionSelectiveShader = null;

        new void Start ()
		{
            base.Start ();
            updateTexturesOnStartup = true;
        }

        void Awake () 
        {

        }
        public override bool CheckResources()
        {
            CheckSupport (mode == ColorCorrectionMode.Advanced);

            colorCorrectMaterial = CheckShaderAndCreateMaterial(simpleColorCorrectionCurvesShader,colorCorrectMaterial);
            colorCorrectDepthMaterial = CheckShaderAndCreateMaterial(colorCorrectionCurvesShader,colorCorrectDepthMaterial);
            selectiveColorCorrectMaterial = CheckShaderAndCreateMaterial(colorCorrectionSelectiveShader,selectiveColorCorrectMaterial);

            //检查一下需要的纹理存不存在 不存在就创建个新的
            if(!rgbChannelTex)
            {
                rgbChannelTex = new Texture2D(256,4,TextureFormat.ARGB32,false,true);
            }
            if(!rgbDepthChannelTex)
            {
                rgbDepthChannelTex = new Texture2D(256,4,TextureFormat.ARGB32,false,true);
            }
            if(!zCurveTex)
            {
                zCurveTex = new Texture2D(256,1,TextureFormat.ARGB32,false,true);
            }

            rgbChannelTex.hideFlags = HideFlags.DontSave;
            rgbDepthChannelTex.hideFlags = HideFlags.DontSave;
            zCurveTex.hideFlags = HideFlags.DontSave;

            rgbChannelTex.wrapMode = TextureWrapMode.Clamp;
            rgbDepthChannelTex.wrapMode = TextureWrapMode.Clamp;
            zCurveTex.wrapMode = TextureWrapMode.Clamp;

            if(!isSupported)//对新建|已有的纹理进行检测
            {
                ReportAutoDisable();
            }
            return isSupported;
        }

        public void UpdateParameters()
        {
            CheckResources();//如果禁用时调整UI，则可能无法创建纹理

            if(redChannel != null && greenChannel != null && blueChannel != null)
            {
                float temp = 1.0f/255f;
                for(float i = 0.0f ; i<=1.0f ; i+= temp)
                {
                    float rCh = Mathf.Clamp(redChannel.Evaluate(i),0.0f,1.0f);
                    float gCh = Mathf.Clamp(greenChannel.Evaluate(i),0.0f,1.0f);
                    float bCh = Mathf.Clamp(blueChannel.Evaluate(i),0.0f,1.0f);

                    rgbChannelTex.SetPixel ((int) Mathf.Floor(i*255.0f), 0, new Color(rCh,rCh,rCh) );
                    rgbChannelTex.SetPixel ((int) Mathf.Floor(i*255.0f), 1, new Color(gCh,gCh,gCh) );
                    rgbChannelTex.SetPixel ((int) Mathf.Floor(i*255.0f), 2, new Color(bCh,bCh,bCh) );

                    float zC = Mathf.Clamp(zCurve.Evaluate(i),0.0f,1.0f);

                    zCurveTex.SetPixel ((int) Mathf.Floor(i*255.0f), 0, new Color(zC,zC,zC) );

                    rCh = Mathf.Clamp (depthRedChannel.Evaluate(i), 0.0f,1.0f);
                    gCh = Mathf.Clamp (depthGreenChannel.Evaluate(i), 0.0f,1.0f);
                    bCh = Mathf.Clamp (depthBlueChannel.Evaluate(i), 0.0f,1.0f);

                    rgbDepthChannelTex.SetPixel ((int) Mathf.Floor(i*255.0f), 0, new Color(rCh,rCh,rCh) );
                    rgbDepthChannelTex.SetPixel ((int) Mathf.Floor(i*255.0f), 1, new Color(gCh,gCh,gCh) );
                    rgbDepthChannelTex.SetPixel ((int) Mathf.Floor(i*255.0f), 2, new Color(bCh,bCh,bCh) );
                }

                rgbChannelTex.Apply();
                rgbDepthChannelTex.Apply();
                zCurveTex.Apply();
            }
        }

        void UpdateTextures ()
		{
            UpdateParameters ();
        }

        void OnRenderImage(RenderTexture source,RenderTexture destination)
        {
            if (CheckResources()==false)
			{
                Graphics.Blit (source, destination);
                return;
            }

            if (updateTexturesOnStartup)
			{
                UpdateParameters ();
                updateTexturesOnStartup = false;
            }

            if (useDepthCorrection)
                GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;

            RenderTexture renderTarget2Use = destination;

            if (selectiveColorCorrect)
			{
                renderTarget2Use = RenderTexture.GetTemporary (source.width, source.height);
            }

            if (useDepthCorrection)
			{
                colorCorrectDepthMaterial.SetTexture ("_RgbTex", rgbChannelTex);
                colorCorrectDepthMaterial.SetTexture ("_ZCurve", zCurveTex);
                colorCorrectDepthMaterial.SetTexture ("_RgbDepthTex", rgbDepthChannelTex);
                colorCorrectDepthMaterial.SetFloat ("_Saturation", saturation);

                Graphics.Blit (source, renderTarget2Use, colorCorrectDepthMaterial);
            }
            else
			{
                colorCorrectMaterial.SetTexture ("_RgbTex", rgbChannelTex);
                colorCorrectMaterial.SetFloat ("_Saturation", saturation);

                Graphics.Blit (source, renderTarget2Use, colorCorrectMaterial);
            }

            if (selectiveColorCorrect)
			{
                selectiveColorCorrectMaterial.SetColor ("selColor", selectiveFromColor);
                selectiveColorCorrectMaterial.SetColor ("targetColor", selectiveToColor);
                Graphics.Blit (renderTarget2Use, destination, selectiveColorCorrectMaterial);

                RenderTexture.ReleaseTemporary (renderTarget2Use);
            }
        }
    }
}