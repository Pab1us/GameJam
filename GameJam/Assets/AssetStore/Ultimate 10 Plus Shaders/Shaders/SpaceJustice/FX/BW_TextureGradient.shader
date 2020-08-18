Shader "SpaceJustice/FX/BW Texture Gradient"
{
	Properties
	{
		_MainTex ("Sprite Texture", 2D) = "white" {}
		_ColorBlack ("Color Black", Color) = (1,1,1,1)
		_ColorWhite ("Color White", Color) = (1,1,1,1)
		_Bright ("Bright", Float) = 1.0

		_Offset ("Z-Offset", Float) = 0.0

		[Header(Blending)]
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Operation", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFactor ("Source", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFactor ("Destination", Float) = 10
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	fixed4 _ColorBlack;
	fixed4 _ColorWhite;
	half _Bright;
	half _Offset;

	v2f vert(appdata i)
	{
		v2f o;

		o.pos = UnityObjectToClipPos(i.vertex);

#if defined(UNITY_REVERSED_Z)
		o.pos.z -= _Offset * 0.47f;
#else
		o.pos.z += _Offset;
#endif

		o.uv = TRANSFORM_TEX(i.uv, _MainTex);

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 col;
		fixed gradient = tex2D(_MainTex, i.uv).x;

		col = lerp(_ColorBlack, _ColorWhite, saturate(gradient * _Bright));
		col.a = saturate(col.a * _Bright);

		return col;
	}
	ENDCG

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"RenderType"="Transparent"
		}
		BlendOp [_BlendOp]
		Blend [_SrcBlendFactor] [_DstBlendFactor]
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
