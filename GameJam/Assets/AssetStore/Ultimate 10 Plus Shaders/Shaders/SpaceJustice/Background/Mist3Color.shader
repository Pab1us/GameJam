Shader "SpaceJustice/Background/Mist3Color"
{
	Properties
	{
		_MainTex ("Particle Texture", 2D) = "white" {}

		[Header(Color gradient)]
		_ColorTint("Color white tint",Color) = (1,1,1,1)
		_ColorMid("Color mid tint",Color) = (0.5,0.5,0.5,0.5)
		_ColorCleaner("Color black tint",Color) = (0,0,0,0)
		[Toggle(THREEPOINTGRAD_ON)]
		_3PointGrad ("use 3 point gradient", Float) = 0
		_Mid("gradient mid point", Range(0, 0.99999) ) = 0.5

		[Space(10)]
		_Offset ("Offset in Camera space", Float) = 0
		[Header(Blending)]
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Operation", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFactor ("Source", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFactor ("Destination", Float) = 10
		[Header(Alpha Blending)]
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOpA ("Operation", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFactorA ("Source", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFactorA ("Destination", Float) = 10
		[Header(Culling)]
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Culling Mode", Float) = 2
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	#pragma shader_feature THREEPOINTGRAD_ON

	struct appdata
	{
		float4 vertex : POSITION;
		fixed4 color  : COLOR;
		float2 uv     : TEXCOORD0;
	};

	struct v2f
	{
		float4 pos   : SV_POSITION;
		fixed4 color : COLOR0;
		float2 uv    : TEXCOORD0;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	fixed4 _ColorTint;
	fixed4 _ColorCleaner;
	fixed4 _ColorMid;
	half _Mid;
	half _Offset;

	v2f vert(appdata v)
	{
		v2f o;

		o.pos = UnityObjectToClipPos(v.vertex) + float4(0.0f, 0.0f, _Offset, 0.0f);

		o.color = v.color;
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		half4 mainTex = tex2D(_MainTex , i.uv.xy);
		half mask1 = (half) mainTex;

		#ifdef THREEPOINTGRAD_ON
		fixed4 upperGrad = lerp(_ColorMid, _ColorTint, (mask1 - _Mid) / (1.0f - _Mid));
		fixed4 lowerGrad = lerp(_ColorCleaner, _ColorMid, mask1 / _Mid);
		fixed gradsMask = saturate((mask1 - _Mid) * 999999.0f);
		fixed4 tex1 = lerp(lowerGrad, upperGrad, gradsMask);
		#else
		fixed4 tex1 = lerp(_ColorCleaner, _ColorTint, mask1);
		#endif

		fixed4 col = tex1;
		col.a *= mainTex.a;
		col *= i.color;
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
		}
		BlendOp [_BlendOp], [_BlendOpA]
		Blend [_SrcBlendFactor] [_DstBlendFactor], [_SrcBlendFactorA] [_DstBlendFactorA]
		Cull [_CullMode]
		ZWrite Off

		Pass
		{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}
