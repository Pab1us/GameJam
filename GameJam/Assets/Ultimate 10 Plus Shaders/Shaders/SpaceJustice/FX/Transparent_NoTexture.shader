Shader "SpaceJustice/FX/Transparent_NoTexture"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_Offset ("Offset in Camera space", Float) = 0
		[Toggle] _PushToNearPlane ("Push to Near Plane Enabled", Float) = 0.
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
		float4 pos   : SV_POSITION;
		fixed4 color : COLOR0;
	};

	fixed4 _Color;
	float _Offset;

	v2f vert(appdata v)
	{
		v2f o;

		o.pos = UnityObjectToClipPos(v.vertex);

#if _PUSHTONEARPLANE_ON
		o.pos.z = UNITY_NEAR_CLIP_VALUE;
#endif

		o.pos.z += _Offset;

		o.color = v.color * _Color;

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		return i.color;
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
		#pragma shader_feature _PUSHTONEARPLANE_ON
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}
