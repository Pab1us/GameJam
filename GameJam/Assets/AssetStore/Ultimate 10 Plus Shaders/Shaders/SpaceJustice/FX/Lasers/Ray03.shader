Shader "SpaceJustice/FX/Lasers/Ray03"
{
	Properties
	{
    _TilingLength("Tiling Length", Float) = 1.0
    _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
    _ColorCenter ("Color Center", Color) = (1.0, 1.0, 1.0, 1.0)

    [Header(MainTex)]
    [NoScaleOffset]
    _TexMain ("Texture", 2D) = "white" {}
    _TexMain_TilingOffset ("Tiling Offset", Vector) = (1.0, 1.0, 0.0, 0.0)

    [Header(Distort)]
    [NoScaleOffset]
    _TexDist1 ("TexDist1", 2D) = "black" {}
    _TexDist1_TilingScroll ("Tiling Scroll", Vector) = (1,1,0,0)

    _DistValue ("Distortion Value", Float) = 0
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
		}

		BlendOp Add
		Blend One OneMinusSrcAlpha
		ZWrite Off
		Cull Back

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				fixed4 color  : COLOR;
				float4 uv     : TEXCOORD0;
			};

			struct v2f
			{
                float4 pos   : SV_POSITION;
                fixed4 color : COLOR;
                float2 uv    : TEXCOORD0;
                float2 uv1   : TEXCOORD1; // - Dist1
			};


            float _TilingLength;
            half4 _Color, _ColorCenter;
            sampler2D _TexMain, _TexDist1;
            float4 _TexMain_TilingOffset;
            float4 _TexDist1_TilingScroll;
            float _DistValue;

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

                o.uv  = v.uv.xy * _TexMain_TilingOffset.xy  + _TexMain_TilingOffset.zw + v.uv.zw;
                o.uv1 = v.uv.xy * _TexDist1_TilingScroll.xy + frac(_TexDist1_TilingScroll.zw * _Time.y);

                o.uv1.x *= _TilingLength;

				o.color = v.color;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{

                //Distort
                half distValue  = tex2D(_TexDist1,  i.uv1).r * _DistValue ;

                //Color
                half4 col = tex2D(_TexMain, i.uv + float2(0.0f, distValue));
                

                col.rgb = col.rgb * _Color.rgb * i.color * i.color.a * _Color.a + col.a * _Color.a * _ColorCenter.rgb;
                col.a *= _Color.a * i.color.a;

                

                

                return col;
			}
			ENDCG
		}
	}
}
