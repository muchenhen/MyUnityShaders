Shader "Unlit/11.1"
{
    Properties
    {
        _Color("Color Tint",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _HorizontalAmount("Gorizontal Amount",Float) = 4//水平方向关键帧的个数
        _VerticalAmount("Vertical Amount",Float) = 4//垂直方向关键帧个数
        _Speed("Speed",Range(1,100)) = 30//控制动画播放速度
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _HorizontalAmount;
            float _VerticalAmount;
            float _Speed;

            struct a2v {  
			    float4 vertex : POSITION; 
			    float2 texcoord : TEXCOORD0;
			};  
			
			struct v2f {  
			    float4 pos : SV_POSITION;
			    float2 uv : TEXCOORD0;
			}; 

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                //_Time.y 是场景加载开始后经过的时间 与_Speed相乘得到时间
                float time = floor(_Time.y * _Speed);
                //时间除以水平关键帧数量得到行索引 
                float row = floor(time/_HorizontalAmount);
                //除法结果的余数是列索引
                float column = time - row * _VerticalAmount;

                half2 uv = i.uv + half2(column,-row);
                uv.x /= _HorizontalAmount;
                uv.y /= _VerticalAmount;

                fixed4 c = tex2D(_MainTex,uv);
                c.rgb *= _Color;
                return c;
            }

            ENDCG
        }
    }
}
