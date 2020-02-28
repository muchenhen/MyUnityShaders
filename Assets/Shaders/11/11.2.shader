Shader "Unlit/11.2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DetailTex("2nd Layer",2D) = "white"{}
        _ScollX("Base layer Scroll Speed",Float) = 1.0//较远的一层
        _Scoll2X("2nd layer Scroll Speed",Float) = 1.0//较近的一层
        _Multiplier("Layer Multiplier",Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DetailTex;
            float4 _DetailTex_ST;
            float _ScollX;
            float _Scoll2X;
            float _Multiplier;

            struct a2v
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(_ScollX,0.0)*_Time.y);
                o.uv.zw = TRANSFORM_TEX(v.texcoord,_DetailTex)+ frac(float2(_Scoll2X,0.0)*_Time.y);
                return o;
            }
            
            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 firstLayer = tex2D(_MainTex,i.uv.xy);
                fixed4 secondLayer = tex2D(_DetailTex,i.uv.zw);
                fixed4 c = lerp(firstLayer,secondLayer,secondLayer.a);
                c.rgb *= _Multiplier;
                return c;
            }
            ENDCG
        }
    }
}
