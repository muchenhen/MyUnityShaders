
Shader "Unlit/6.4.1"
{//逐顶点光照
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
    struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;//定义一个normal变量 使用NORMAL语义高速unity把模型顶点的法线信息存储在该变量
            };

    struct v2f {
        float4 pos : SV_POSITION;
        fixed3 color : COLOR;//该变量是为了将顶点着色器计算到的光照颜色传递给片元着色器
                            //并不是必须是COLOR语义，也可以使用TEXCOOED0语义
    };

    v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);//首先完成坐标变换
        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;//该变量代表环境光 由系统自动提供 通过后面的函数获得
                                                      //最后计算出的漫反射光的颜色需要跟环境光相加的到最后的颜色值
        fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));//模型传过来的法线是在物体坐标系，要转换到世界空间与光照所处同一个坐标系
        fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);//获取光源方向 并归一化 归一化之后可以用点乘直接计算出光线和法线的夹角cos值
        fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));//saturate将cos值截取到0~1 因为cos值是-1~1 但是该系数是0~1
                        //按照漫反射公式将参数相乘得到漫反射颜色值
        o.color = ambient + diffuse;//漫反射光照和环境光相加得到最终的顶点颜色
        return o;
    }

    fixed4 frag(v2f i) : SV_Target{
        return fixed4(i.color, 1.0);
    }
            
            ENDCG
        }
    }
}
