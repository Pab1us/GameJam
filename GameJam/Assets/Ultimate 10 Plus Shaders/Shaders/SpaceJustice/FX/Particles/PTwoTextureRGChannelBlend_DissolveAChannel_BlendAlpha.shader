﻿Shader "SpaceJustice/FX/Particle/PTwoTextureRGChannelBlend_DissolveAChannel_BlendAlpha"
{
	Properties
	{
		[Header(Texture (RG two scroll channel   A mask))]
		[NoScaleOffset]
		_Tex ("Texture", 2D) = "white" {}
		_Tex_TilingScroll_R("Tiling Scroll R", Vector) = (1, 1, 0, 0)
		_Tex_TilingScroll_G("Tiling Scroll G", Vector) = (1, 1, 0, 0)
		_Tex_ColorWhiteTint("Color white tint", Color) = (1, 1, 1, 1)
		_Tex_ColorBlackTint("Color black tint", Color) = (0, 0, 0, 0)
		_Tex_ColorLinear ("Linearity Color", Range(0, 3)) = 1.0
		_Brighness ("Brighness", Float) = 1.0

		[Space(20)]
		[Header(Dissolve)]
		_DissSmooth ("Smoothness", Range(-0.5, 0.5)) = 0.1
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

		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Back

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "../../Standard_Functions.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				half4 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				half4 uv : TEXCOORD0;
				half4 uv1 : TEXCOORD1;
				fixed4 color : COLOR0;
			};

			half _Brighness;

			sampler2D _Tex;
			half4 _Tex_TilingScroll_R;
			half4 _Tex_TilingScroll_G;
			fixed4 _Tex_ColorWhiteTint;
			fixed4 _Tex_ColorBlackTint;
			half _Tex_ColorLinear;
			half _DissSmooth;

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.uv.xy;
				o.uv.z = v.uv.z;
				o.uv1.xy = v.uv * _Tex_TilingScroll_R.xy + frac(_Tex_TilingScroll_R.zw * _Time.y + v.uv.w);
				o.uv1.zw = v.uv * _Tex_TilingScroll_G.xy + frac(_Tex_TilingScroll_G.zw * _Time.y + v.uv.w);
				o.color = v.color;
				o.color.rgb *= _Brighness;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = i.color;

				fixed tex_A = tex2D(_Tex, i.uv.xy).a;
				fixed tex_R = tex2D(_Tex, i.uv1.xy).r;
				fixed tex_G = tex2D(_Tex, i.uv1.zw).g;

				fixed tex_RG = tex_R * tex_G;
				fixed4 tex_RG_color = lerp(_Tex_ColorBlackTint, _Tex_ColorWhiteTint, sfPow(tex_RG, _Tex_ColorLinear));

				col.rgb *= tex_RG_color.rgb;

				fixed dissolve = saturate(((tex_A * tex_RG_color.a + i.uv.z) * 2.0f + (-1.0f)) * 50.0f * _DissSmooth);

				col.a *= dissolve;

				return col;
			}
			ENDCG
		}
	}
}