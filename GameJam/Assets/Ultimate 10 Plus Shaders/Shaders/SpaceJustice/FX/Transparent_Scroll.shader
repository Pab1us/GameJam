Shader "SpaceJustice/FX/Transparent Scroll"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex_SpeedScroll ("Speed Scroll (XY) ", Vector) = (0,0,0,0)

		[Header(Fog)]
		[Toggle] _Fog("Fog Enabled", Float) = 0.

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
#if _FOG_ON
		half3 uv : TEXCOORD0;
#else
		half2 uv : TEXCOORD0;
#endif
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	fixed4 _Color;
	half2 _MainTex_SpeedScroll;

#if _FOG_ON
	sampler2D _FogLUT;
	float2 _FogLUTParams;
#endif

	v2f vert(appdata v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.color = v.color * _Color;
		o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex) + _MainTex_SpeedScroll * _Time.y;

#if _FOG_ON
		o.uv.z = mul(unity_ObjectToWorld, v.vertex).z;
#endif
		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.uv.xy);
		col *= i.color;

#if _FOG_ON
		fixed4 fog = tex2D(_FogLUT, float2(i.uv.z * _FogLUTParams.x + _FogLUTParams.y, 0.5f));

		col.rgb = lerp(col.rgb, fog.rgb, fog.a);
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
		}

		BlendOp [_BlendOp], [_BlendOpA]
		Blend [_SrcBlendFactor] [_DstBlendFactor], [_SrcBlendFactorA] [_DstBlendFactorA]
		Cull [_CullMode]
		ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma shader_feature _FOG_ON
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
