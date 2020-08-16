Shader "SpaceJustice/FX/ScrollTextures/OneTextureBW Distort Dissolve BlendAlpha Old"
{
	Properties
	{
		_Transparency ("Transparency", Range(0,1)) = 1.0
		_AlphaVertEffect ("Vertex Alpha effect", Range(0,1)) = 1.0

		[Space(20)]
		[Header(Color)]
		[NoScaleOffset]
		_Tex1 ("Texture BW", 2D) = "white" {}
		_Tex1_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)
		_Tex1_ColorWhiteTint("Color white tint (A - power dissolve)",Color) = (1,1,1,1)
		_Tex1_ColorBlackTint("Color black tint (A - power dissolve)",Color) = (0,0,0,0)
		_Tex1_ColorLinear ("Linearity Color", Range(0,3)) = 1.0
		_Brighness ("Brighness", Float) = 1.0

		[Space(20)]
		[Header(Dissolve  (mask in vertex A))]
		_DissLinear ("Linearity",  Range(0,3)) = 1.0
		_DissSmooth ("Smoothness", Range(-0.5,0.5)) = 0.1

		[Space(20)]
		[Header(Distort (mask in vertex A))]
		[NoScaleOffset]
		_TexDistort ("Distort Texture", 2D) = "white" {}
		_TexDistort_TilingScroll ("Tiling Scroll", Vector) = (1,1,0,0)

		_Tex1_Distort ("Distort for A=1  and A=0", Vector) = (0,0,0,0)
		_DistortLinear ("Linearity", Range(0,3)) = 1.0
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half4 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			half _Brighness;
			half _Transparency;
			fixed _AlphaVertEffect;

			sampler2D _Tex1;
			half4 _Tex1_TilingScroll;
			fixed4 _Tex1_ColorWhiteTint;
			fixed4 _Tex1_ColorBlackTint;
			half _Tex1_ColorLinear;

			half _DissSmooth, _DissLinear;

			sampler2D _TexDistort;
			half4 _TexDistort_TilingScroll;
			half4 _Tex1_Distort;
			half _DistortLinear;

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.uv * _Tex1_TilingScroll.xy + frac(_Tex1_TilingScroll.zw * _Time.y);
				o.uv.zw = v.uv * _TexDistort_TilingScroll.xy + frac(_TexDistort_TilingScroll.zw * _Time.y);
				o.color = v.color;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 distortion = tex2D(_TexDistort, i.uv.zw).rg;
				i.uv.xy += (distortion - 0.5f) * lerp(_Tex1_Distort.zw, _Tex1_Distort.xy, pow(i.color.a, _DistortLinear));

				fixed4 col;
				fixed tex1_BW = tex2D(_Tex1, i.uv.xy).r;
				fixed4 color1 = lerp(_Tex1_ColorBlackTint, _Tex1_ColorWhiteTint, pow(tex1_BW , _Tex1_ColorLinear));
				col.rgb = color1.rgb * _Brighness * i.color.rgb;

				half dissolve = lerp(_Tex1_ColorBlackTint.a, _Tex1_ColorWhiteTint.a, pow(i.color.a, _DissLinear)) * 4.0f - 2.0f;
				dissolve = saturate(((tex1_BW + dissolve) * 2.0f + (-1.0f)) * 50.0f * _DissSmooth);

				col.a = dissolve * (i.color.a * _AlphaVertEffect + 1.0f -_AlphaVertEffect) * _Transparency;

				return col;
			}
			ENDCG
		}
	}
}
