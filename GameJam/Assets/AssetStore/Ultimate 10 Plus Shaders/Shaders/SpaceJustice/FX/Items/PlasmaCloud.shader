Shader "SpaceJustice/FX/Items/PlasmaCloud"
{
	Properties
	{
		[Header (Main)]
		_TexMain_Color("Color",Color) = (1, 1, 1, 1)
		[NoScaleOffset]
		_TexMain ("Texture", 2D) = "white" {}
		_TexMain_TilingScroll  ("Tiling Scroll ", Vector) = (1, 1, 0, 0)

		[Space(10)]
		_BaseColor ("Color Base", Color) = (1, 1, 1, 1)
		_GlowColor ("Color Glow", Color) = (1, 1, 1, 1)
		_BorderColor ("Color Border", Color) = (1, 1, 1, 1)

		[Space(10)]
		[Header (Distort)]
		[NoScaleOffset]
		_TexDistort ("Noise", 2D) = "white" {}
		_DistParam ("DistPowerXY LinesDistPower LineWidth", Vector) = (1, 1, 0.1, 0.1)  //Front Back   DistortU DistortV
		_TexDistort_TilingScroll  ("Tiling Scroll ", Vector) = (1, 1, 0, 0)
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		BlendOp Add
		Blend SrcAlpha OneMinusSrcAlpha
    ZWrite Off
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			float4 _TexMain_Color;
			sampler2D _TexMain;
			float4 _TexMain_TilingScroll;

			fixed4 _BaseColor;
			fixed4 _GlowColor;
			fixed4 _BorderColor;
			float4 _DistParam;

			sampler2D _TexDistort;
			float4 _TexDistort_TilingScroll;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex  = UnityObjectToClipPos(v.vertex);

				o.uv.xy  = v.uv; //базовый мапинг для местоположения бордюра
				o.uv.zw  = v.uv * _TexMain_TilingScroll.xy + frac(_TexMain_TilingScroll.zw * _Time.y); // мапинг основной текстуры
				o.uv1 = v.uv * _TexDistort_TilingScroll.xy + frac(_TexDistort_TilingScroll.zw * _Time.y); // мапинг текстуры искаджений

				o.color = v.color;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 texDistort = tex2D(_TexDistort, i.uv1).xy;
				fixed4 texMain = _TexMain_Color * tex2D(_TexMain, i.uv.zw + texDistort * _DistParam.xy);
				fixed4 col = i.color * (_BaseColor + texMain);

				fixed wave = _DistParam.w + texDistort.x * _DistParam.w; //0.1f

				col.a = smoothstep(wave, wave + _DistParam.z, 1.0f - i.uv.x);
				col.rgb = col.rgb * col.a + _GlowColor.rgb * (1.0f - col.a) + (0.5f - abs(col.a - 0.5f)) * _BorderColor * 2.0f;
				col.a = saturate(col.a + 1.0f - i.uv.x * i.uv.x) * i.color.a;

				return col;
			}
			ENDCG
		}
	}
}
