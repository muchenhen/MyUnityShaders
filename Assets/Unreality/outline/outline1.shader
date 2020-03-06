Shader "Unreality/outline1"
{
    //Back Facing方法
    Properties
    {
        _OutlineWidth ("Outline Width", Range(0.01, 1)) = 0.24
        _OutLineColor ("OutLine Color", Color) = (0.5,0.5,0.5,1)
    }
    SubShader
    {
        Tags{"RenderType"="Opaque"}

        pass
        {
            Tags{"LightMode"="ForwardBAse"}
            
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 vert(appdata_base v):SV_POSITION
            {
                return UnityObjectToClipPos(v.vertex);
            }

            half4 frag() : SV_TARGET
            {
                return half4(1,1,1,1);//直接把颜色设置为白色
            }

            ENDCG
        }

        pass
        {
            Tags{"LightMode"="ForwardBase"}
            
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            half _OutlineWidth;
            half4 _OutLineColor;

            struct a2v
            {
                float4 vertex : POSITION;//顶点
                float3 normal : NORMAL;//法线
                float2 uv : TEXCOORD0;//贴图uv
                float4 vertColor : COLOR;//顶点颜色
                float4 tangent : TANGENT;//渲染目标
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert (a2v v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                float4 pos = UnityObjectToClipPos(v.vertex);
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal.xyz);
                float3 ndcNormal = normalize(TransformViewToProjection(viewNormal.xyz)) * pos.w;//将法线变换到NDC空间
                pos.xy += 0.01 * _OutlineWidth * ndcNormal.xy;
                o.pos = pos;
                return o;
            }

            half4 frag(v2f i) : SV_TARGET
            {
                return _OutLineColor;
            }

            ENDCG
        }
    }
}
