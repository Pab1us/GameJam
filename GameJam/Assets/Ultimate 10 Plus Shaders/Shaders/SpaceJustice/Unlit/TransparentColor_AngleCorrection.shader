Shader "SpaceJustice/Unlit/TransparentColor Angle Correction"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)

		[Header(Blending)]
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Blend Operation", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFactor ("Source Blend Factor", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFactor ("Destination Blend Factor", Float) = 10

		[Header(Culling)]
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Culling Mode", Float) = 2
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		half3 normal : NORMAL;
		fixed4 color : COLOR;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		fixed4 color : COLOR0;
	};

	fixed4 _Color;

	v2f vert(appdata i)
	{
		UNITY_SETUP_INSTANCE_ID(i);
		v2f o;

		o.pos = UnityObjectToClipPos(i.vertex);

		float4 worldPos = mul(unity_ObjectToWorld, i.vertex);
		half3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
		half3 worldNormal = UnityObjectToWorldNormal(i.normal);

		o.color = i.color * _Color;
		o.color.a *= abs(dot(worldNormal, worldViewDir));

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

		BlendOp [_BlendOp]
		Blend [_SrcBlendFactor] [_DstBlendFactor]
		Cull [_CullMode]
		ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma target 3.5
			#pragma multi_compile_instancing
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
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

		BlendOp [_BlendOp]
		Blend [_SrcBlendFactor] [_DstBlendFactor]
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
