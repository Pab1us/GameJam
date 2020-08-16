﻿Shader "SpaceJustice/FX/Particle/Particle"
{
	Properties
	{
		_MainTex ("Particle Texture", 2D) = "white" {}

		[Toggle] _UseColor ("Use Tint", float) = 0.
		[Toggle] _KeepBright ("Keep Bright", float) = 0.
		[Enum(UnityEngine.Rendering.ZTest)] _ZTest ("ZTest", float) = 4

		_Bright ("Bright", range(0., 1.)) = 0.
		_Color ("Tint", Color) = (1., 1., 1., 1.)
		_Multiplier ("Multiplier", float) = 1.

		[Header(Blending)]
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Operation", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFactor ("Source", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFactor ("Destination", Float) = 10
		[Header(Culling)]
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Culling Mode", Float) = 0
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		fixed4 color : COLOR;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		fixed4 color : COLOR0;
		float2 uv : TEXCOORD0;
	#ifdef _KEEPBRIGHT_ON
		fixed maxColor : TEXCOORD1;
	#endif
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	fixed4 _Color;
	half _Multiplier;

	#ifdef _KEEPBRIGHT_ON
	fixed _Bright;
	#endif

	v2f vert(appdata v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.color = v.color;

		#if _USECOLOR_ON
		o.color *= _Color;
		#endif

		o.uv = TRANSFORM_TEX(v.uv, _MainTex);

	#ifdef _KEEPBRIGHT_ON
		o.maxColor = max(o.color.r, max(o.color.g, o.color.b));
	#endif

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.uv);

	#ifdef _KEEPBRIGHT_ON
		fixed grayScale = dot(col.rgb, fixed3(0.299f, 0.587f, 0.114f));
		col.rgb *= lerp(i.color.rgb, i.maxColor.xxx, grayScale * _Bright);
		col.a *= i.color.a;
	#else
		col *= i.color;
	#endif

	#if _USECOLOR_ON
		col *= _Multiplier;
	#endif

		return col;
	}
	ENDCG

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}
		BlendOp [_BlendOp]
		Blend [_SrcBlendFactor] [_DstBlendFactor]
		ZTest [_ZTest]
		ZWrite Off
		Cull Off

		Pass
		{
		CGPROGRAM
		#pragma shader_feature _USECOLOR_ON
		#pragma shader_feature _KEEPBRIGHT_ON
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}