Shader "Unlit/12.2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Brightness("Brightness",Float) = 1
        _Saturation("Saturation",Float) = 1
        _Contrast("Contrast",Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZTest Always Cull Off ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            half _Brightness;
            half _Saturation;
            half _Contrast;
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
            };
            
            v2f vert (appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 renderTex = tex2D(_MainTex,i.uv);
                fixed3 finalColor = renderTex.rgb * _Brightness;//应用亮度
                
                //应用饱和度
                fixed luminance = 0.2125 * renderTex.rgb + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
                fixed3 luminaceColor = fixed3(luminance,luminance,luminance);
                finalColor = lerp(luminaceColor,finalColor,_Saturation);

                //应用对比度
                fixed3 avgColor = fixed3(0.5,0.5,0.5);
                finalColor = lerp(avgColor,finalColor,_Contrast);
                return fixed4(finalColor,renderTex.a);
            }
            ENDCG
        }
    }
    Fallback Off
}
