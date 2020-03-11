// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unreality/EdgeLightBasic"
{
    Properties
    {
        //主颜色 || Main Color
		_MainColor("【主颜色】Main Color", Color) = (0.5,0.5,0.5,1)
		//漫反射纹理 || Diffuse Texture
		_TextureDiffuse("【漫反射纹理】Texture Diffuse", 2D) = "white" {}	
		//边缘发光颜色 || Rim Color
		_RimColor("【边缘发光颜色】Rim Color", Color) = (0.5,0.5,0.5,1)
		//边缘发光强度 ||Rim Power
		_RimPower("【边缘发光强度】Rim Power", Range(0.0, 36)) = 0.1
		//边缘发光强度系数 || Rim Intensity Factor
		_RimIntensity("【边缘发光强度系数】Rim Intensity", Range(0.0, 100)) = 3
    }

    SubShader
    {
        Tags{"RenderType" = "Opaque"}

        pass
        {
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            float4 _LightColor0;
            float4 _MainColor;
            sampler2D _TextureDiffuse;
            float4 _TextureDiffuse_ST;
            float4 _RimColor;
            float _RimPower;
            float _RimIntensity;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 posWorld : TEXCOORD1;
                
                LIGHTING_COORDS(3,4)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.texcoord = v.texcoord;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld,v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
                
                return o;
            }

            fixed4 frag(v2f i) : Color
            {
                float3 viewDirection = normalize(UnityWorldSpaceViewDir(i.posWorld));
                float3 normalDirection = normalize(i.normal);
                float3 lightDirection = normalize(UnityWorldSpaceLightDir(i.posWorld));

                //计算光照衰减
                float attenuation = LIGHT_ATTENUATION(i);
                //计算衰减后的颜色值
                float3 attenColor = attenuation * _LightColor0.xyz;

                //计算漫反射光照
                float normalDotLight = dot(normalDirection,lightDirection) / 2 + 0.5;
                float3 diffuse = max(0.0,normalDotLight) * attenColor + UNITY_LIGHTMODEL_AMBIENT.xyz;

                //z自发光部分
                //边缘强度
                half Rim = 1.0 - max(0,dot(i.normal,viewDirection));
                //边缘发光强度
                float3 emissive = _RimColor.rgb * pow(Rim,_RimPower) * _RimIntensity;

                //计算最终颜色
                float3 finalColor = diffuse * (tex2D(_TextureDiffuse,TRANSFORM_TEX(i.texcoord,_TextureDiffuse)).rgb * _MainColor.rgb)  + emissive;

                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
}