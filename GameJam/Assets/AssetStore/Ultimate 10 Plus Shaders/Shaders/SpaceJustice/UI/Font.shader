Shader "SpaceJustice/UI/Font"
{
	Properties
	{
		_MainTex ("Font Texture", 2D) = "white" {}
		_Color ("Text Color", Color) = (1,1,1,1)
		[Header(Blending)]
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Operation", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFactor ("Source", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFactor ("Destination", Float) = 10
		[Header(Alpha Blending)]
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOpA ("Operation", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFactorA ("Source", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFactorA ("Destination", Float) = 10
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
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	fixed4 _Color;

	v2f vert(appdata v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.color = v.color * _Color;
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 col = i.color;
		col.a = tex2D(_MainTex, i.uv).a;
		return col;
	}
	ENDCG

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}

		BlendOp [_BlendOp], [_BlendOpA]
		Blend [_SrcBlendFactor] [_DstBlendFactor], [_SrcBlendFactorA] [_DstBlendFactorA]
		ZWrite Off
		Cull Off

		Pass
		{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}
