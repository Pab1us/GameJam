Shader "SpaceJustice/FX/Items/HornetWingsMini"
{
	Properties
	{
		[Header(Main texture)]
		[NoScaleOffset]
		_TexMain ("Texture", 2D) = "white" {}
		_TexMain_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_TexMain_ColorBlackTint("Color black tint",Color) = (0,0,0,0)

		[Space(20)]
		[Header(Tiling)]
		[NoScaleOffset]
		_TexTiling ("Texture", 2D) = "white" {}
		_TexTiling_TilingScroll ("Tiling Scroll ", Vector) = (1,1,0,0)
		_TexTiling_Color("Color tiling",Color) = (1,1,1,1)

		[Space(20)]
		[Header(Distort)]
		[NoScaleOffset]
		_TexDistort ("Distort Texture", 2D) = "white" {}
		_TexDistort_TilingScroll ("Tiling Scroll", Vector) = (1,1,0,0)
		_Distort ("Distort MainUV Wave", Vector) = (0,0,0,0)
	}
	SubShader
	{
		Tags
		{
			"Queue"="Geometry"
			"RenderType"="Opaque"
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;//xy mainTex  zw Distort
				float2 uv1 : TEXCOORD1;//xy tiling
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
			};

			//color
			sampler2D _TexMain;
			half4 _TexMain_TilingScroll;
			fixed4 _TexMain_ColorWhiteTint;
			fixed4 _TexMain_ColorBlackTint;

			//tiling
			sampler2D _TexTiling;
			half4 _TexTiling_TilingScroll;
			fixed4 _TexTiling_Color;

			// distort
			sampler2D _TexDistort;
			half4 _TexDistort_TilingScroll;
			half4 _Distort;

			v2f vert(appdata v)
			{
				v2f o;

				o.vertex  = UnityObjectToClipPos(v.vertex);
				o.uv.xy =  v.uv1;
				o.uv.zw =  v.uv2 * _TexDistort_TilingScroll.xy + frac(_TexDistort_TilingScroll.zw * _Time.y);
				o.uv1.xy = v.uv2 * _TexTiling_TilingScroll.xy  + frac(_TexTiling_TilingScroll.zw  * _Time.y);
				o.color = v.color;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// distort
				fixed2 distortion = tex2D(_TexDistort, i.uv.zw).rg - 0.5f.xx;

				fixed4 col;

				//main
				fixed texMainBW = tex2D(_TexMain, i.uv.xy).r;
				col = lerp(_TexMain_ColorBlackTint, _TexMain_ColorWhiteTint, texMainBW);
				//tiling
				fixed texTilingBW = tex2D(_TexTiling, i.uv1.xy + distortion * _Distort.xy).r * (1.0f - texMainBW);
				//col *= (1.0f - texTilingBW * _TexTiling_Color.a);
				//col += texTilingBW * _TexTiling_Color * _TexTiling_Color.a;
				col = lerp(col, _TexTiling_Color, texTilingBW * _TexTiling_Color.a);

				col *= i.color;

				return col;
			}
			ENDCG
		}
	}
}
