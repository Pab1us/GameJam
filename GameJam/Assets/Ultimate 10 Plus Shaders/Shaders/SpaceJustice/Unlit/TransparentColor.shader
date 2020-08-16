Shader "SpaceJustice/Unlit/TransparentColor"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		[Toggle] _PushToNearPlane ("Push to Near Plane Enabled", Float) = 0.
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Blend Operation", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFactor ("Source Blend Factor", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFactor ("Destination Blend Factor", Float) = 10
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOpA ("Alpha Blend Operation", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFactorA ("Source Alpha Blend Factor", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFactorA ("Destination Alpha Blend Factor", Float) = 10
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		float4 color : COLOR0;
	};

	UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
	UNITY_INSTANCING_BUFFER_END(Props)

	v2f vert(appdata i)
	{
		UNITY_SETUP_INSTANCE_ID(i);
		v2f o;

		o.pos = UnityObjectToClipPos(i.vertex);

#if _PUSHTONEARPLANE_ON
		o.pos.z = UNITY_NEAR_CLIP_VALUE;
#endif

		o.color = UNITY_ACCESS_INSTANCED_PROP(Props, _Color);

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
		Cull Off
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

		BlendOp [_BlendOp], [_BlendOpA]
		Blend [_SrcBlendFactor] [_DstBlendFactor], [_SrcBlendFactorA] [_DstBlendFactorA]
		Cull Off
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
