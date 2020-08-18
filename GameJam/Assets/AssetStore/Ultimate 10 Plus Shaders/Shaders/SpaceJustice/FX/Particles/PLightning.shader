Shader "SpaceJustice/FX/Particle/PLightning"
{
	Properties
	{
		_Tex_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_Tex_ColorBlackTint("Color black tint",Color) = (0,0,0,0)
		[NoScaleOffset]
		_Tex ("Texture BW", 2D) = "white" {}
		_Tex_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)
		_TexControl ("Brgh VertA Lin LinDist", Vector) = (1, 1, 1, 1)

		[Space(10)]
		[Header(Dissolve  (mask in vertex A))]
		_Dissolve ("A0 A1 Lin Smoth", Vector) = (0.1, 0.1, 1, 0.1)

		[Space(10)]
		[Header(Distort (mask in vertex A))]
		[NoScaleOffset]
		_TexDistort ("Distort Texture", 2D) = "white" {}
		_TexDistort_TilingScroll ("Tiling Scroll", Vector) = (1,1,0,0)
		_Distort ("Distort A=1  and A=0", Vector) = (0,0,0,0)
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		Blend SrcAlpha One
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
				half4 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half4 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			half _Brighness;
			half _AlphaVertEffect;

			sampler2D _Tex;
			half4 _Tex_TilingScroll;
			fixed4 _Tex_ColorWhiteTint;
			fixed4 _Tex_ColorBlackTint;
			half4 _TexControl;

			half4 _Dissolve;

			sampler2D _TexDistort;
			half4 _TexDistort_TilingScroll;
			half4 _Distort;

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex  = UnityObjectToClipPos(v.vertex);

				v.uv.x += v.uv.w;
				o.uv.xy = v.uv.xy * _Tex_TilingScroll.xy + frac(_Tex_TilingScroll.zw  * _Time.y) + float2(v.uv.z, 0.0f);
				o.uv.zw = v.uv.xy * _TexDistort_TilingScroll.xy + frac(_TexDistort_TilingScroll.zw * _Time.y) + float2(v.uv.z, 0.0f);

				o.color = v.color;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 distortion = tex2D(_TexDistort, i.uv.zw).rg;
				i.uv.xy += (distortion - 0.5f) * lerp(_Distort.zw, _Distort.xy, pow(i.color.a, _TexControl.w));

				fixed4 col;
				fixed tex_BW = tex2D(_Tex, i.uv.xy).r;
				fixed4 color1 = lerp(_Tex_ColorBlackTint, _Tex_ColorWhiteTint, pow(tex_BW, _TexControl.z));
				col.rgb = color1.rgb  * _TexControl.x * i.color.rgb;

				fixed dissolve = lerp(_Dissolve.x, _Dissolve.y, pow(i.color.a, _Dissolve.z));
				dissolve = saturate(((tex_BW + dissolve) * 50.0f - 25.0f) / _Dissolve.w);

				col.a = dissolve * (i.color.a * _TexControl.y + 1.0f -_TexControl.y) * _Tex_ColorWhiteTint.a;

				return col;
			}
			ENDCG
		}
	}
}
