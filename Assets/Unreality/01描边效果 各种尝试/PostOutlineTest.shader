Shader "Unreality/PostOutlineTest"
{
    Properties
    {
        _MainTex("Main Tex",2D) = "white"{}
        _NormalTex("Normal Tex",2D) = "bump" {}
        _OutlineWidth("Outline Width",Range(0.01,1)) = 0.25
        _OutlineColor("Outline Coloir",Color) = (0,0,0,1)
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
            sampler2D _NormalTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v) : SV_POSITION
            {
                v2f o;
                //UNITY_INITIALIZE_OUTPUT(v2f, o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV,v.tangent.xyz);
                float3 projNormal = TransformViewToProjection(viewNormal.xyz);
                float3 NDCnormal = normalize(projNormal) * o.vertex.w;

                float4 nearUpperRight = mul(unity_CameraInvProjection,float4(1,1,UNITY_NEAR_CLIP_VALUE,_ProjectionParams.y));
                float aspect = abs(nearUpperRight.y/nearUpperRight.x);
                NDCnormal.x *= aspect;
                
                o.vertex.xy = o.vertex.xy + NDCnormal.xy * _OutlineWidth * 0.1;
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

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv :TEXCOORD0;
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
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