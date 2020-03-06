Shader "Unlit/7.1.1"
{
    Properties
    {
        _Color ("Color Tint",Color) = (1,1,1,1)
        _MainTex ("Main Tex",2D) = "white"{}//声明了一个纹理 属性是2D 初始值是一个内置纹理的名字
        _Specualr("Specular",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(8.0,256)) =20
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;//命名格式必须是 纹理名_ST ST是缩放和平移的缩写
            fixed4 _Specualr;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;//会将模型的第一组纹理坐标存储到该变量中
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;//存储纹理坐标的量 以便再片元着色器中使用进行纹理采样
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = UnityObjectToWorldDir(v.vertex);

                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                //计算世界空间下的法线方向和光照方向
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                //tex2D函数对纹理进行采样
                fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;//第一个参数 需要被采样的纹理
                                                                      //第二个参数 float2型的纹理坐标
                                                                      //返回计算得到的值
                                                                      //采样结果和颜色属性乘积 作为 反射率
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;//与环境光相乘得到环境光部分
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir));//计算漫反射

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir+viewDir);
                fixed3 specular = _LightColor0.rgb * _Specualr.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);
                return fixed4(ambient+diffuse+specular,1.0);
            }
            ENDCG
        }
    }
    Fallback"Specular"
}
