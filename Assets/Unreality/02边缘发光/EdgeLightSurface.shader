Shader "Unreality/EdgeLightSurface"
{
    Properties
    {
        _MainColor("主颜色",Color) = (0.5,0.5,0.5,1)
        _MainTex("纹理" , 2D) = "white" {}
        _BumpTex("凹凸纹理",2D) = "bump" {}
        _RimColor("边缘颜色",Color) = (1,1,1,1)
        _RimPower("边缘强度",Range(0.5,36.0)) = 8.0
        _RimIntensity("边缘强度系数",Range(0.0,100.0)) = 1.0
    }

    SubShader
    {
        Tags{"RenderType"="Opaque"}

        CGPROGRAM
    

        #pragma surface surf Lambert

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float3 viewDir;
        };

        float4 _MainColor;
        sampler2D _MainTex;
        sampler2D _BumpMap;
        float4 _RimColor;
        float _RimPower;
        float _RimIntensity;

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D(_MainTex,IN.uv_MainTex).rgb * _MainColor.rgb;
            o.Normal = UnpackNormal(tex2D(_BumpMap,IN.uv_BumpMap));
            half rim = 1.0 - saturate(dot(normalize(IN.viewDir),o.Normal));
            o.Emission = _RimColor.rgb * pow(rim,_RimPower) * _RimIntensity;
        }
        ENDCG
    }
}