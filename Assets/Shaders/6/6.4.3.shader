// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'


Shader "Unlit/6.4.3"
{//半兰伯特模型
    Properties
    {
        //控制材质的漫反射颜色 Color类型属性 初始值为白色
        _Diffuse("Diffuse",Color) = (1,1,1,1)
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}//指明光照模式
            CGPROGRAM
            #pragma vertex vert//定义顶点着色器
            #pragma fragment frag//定义片元着色器
        // make fog work
        #pragma multi_compile_fog

        #include "UnityCG.cginc"// 使用Unity的内置的一些变量
        #include "Lighting.cginc"

        fixed4 _Diffuse;//为了使用在Properties中声明的属性 需要定义一个和该属性类型的变量
                        //此变量作为材质的漫反射属性 范围是0~1 所以使用fixed精度

            //vertex的输入结构体        
            struct a2v 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;//定义一个normal变量 使用NORMAL语义高速unity把模型顶点的法线信息存储在该变量
            };

            struct v2f 
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;//该变量是为了将顶点着色器计算到的光照颜色传递给片元着色器
                                               //TEXCOORD 通常是float2或float4类型
            };

            v2f vert(a2v v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);//首先完成坐标变换
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);//将世界空间的法线传递给片元着色器
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;//环境光
                fixed3 worldNormal = normalize(i.worldNormal);//归一化
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;//在这里修改了cos值的裁剪方式，这样背光面不会全都是0
                //原本dot的结果是（因为此时世界空间法线和光照方向都已经是单位向量）cos值 cos是[-1 1] 在原有的光照明模型中会裁剪到0~1 背面的无光照部分是0 黑的
                //cos*0.5 范围变成[-0.5 0.5] 再加0.5变成[0 1] 
                //即 原本整个从最亮区域到最暗区域的范围是-1~1 但是会裁剪掉小于0的一半 如果是个球则背面是黑的 
                //但是映射到0~1的之后 背面也会有深浅变化
                //该模型只是一种视觉增强效果 没有物理依据

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;
                fixed3 color = ambient + diffuse;
                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }
}
