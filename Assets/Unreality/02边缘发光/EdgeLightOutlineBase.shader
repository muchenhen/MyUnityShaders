Shader "Unreality/EdgeLightOutlineBase"
{
    Properties
    {
        _MainTex("Main Tex",2D) = "white"{}
        _OutlineWidth("Outline Width",Range(0.01,1)) = 0.25
        _OutlineColor("Edge Light Coloir",Color) = (0,0,0,1)
    }

    SubShader
    {
        Tags{"RenderType"="Opaque" "Queue"="Transparent"}

        pass
        {
            Tags{"LightMode"="ForwardBase" }

            Cull Front
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float _OutlineWidth;
            float4 _OutlineColor;
            sampler2D _MainTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata_base v) : SV_POSITION
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV,v.normal);
                float2 projNormal = mul((float2x2)UNITY_MATRIX_P,viewNormal.xy);
                o.vertex.xy = o.vertex.xy + projNormal * _OutlineWidth * 0.1;
                return o;
            }

            float4 frag(v2f i) : SV_TARGET
            {
                return _OutlineColor;
            }


            ENDCG
        }

        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv :TEXCOORD0;
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv:TEXCOORD0;
            };
            sampler2D _MainTex;     
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }   
            fixed4 frag (v2f i) : SV_Target
            {
                return tex2D(_MainTex,i.uv);
            }
            ENDCG
        }
    }


}