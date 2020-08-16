Shader "SpaceJustice/FX/Transparent"
{
	Properties
	{
		_MainTex ("Particle Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_Offset ("Depth Offset", Float) = 0
		_AlphaFactor ("Alpha Factor", Float) = 1.
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
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		fixed4 color : COLOR0;
		float2 uv : TEXCOORD0;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
		UNITY_DEFINE_INSTANCED_PROP(float, _Offset)
		UNITY_DEFINE_INSTANCED_PROP(float, _AlphaFactor)
	UNITY_INSTANCING_BUFFER_END(Props)


	v2f vert(appdata i)
	{
		UNITY_SETUP_INSTANCE_ID(i);
		v2f o;

		fixed4 color = UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
		float offset = UNITY_ACCESS_INSTANCED_PROP(Props, _Offset);
		float alphaFactor = UNITY_ACCESS_INSTANCED_PROP(Props, _AlphaFactor);

		o.pos = UnityObjectToClipPos(i.vertex);

#if defined(UNITY_REVERSED_Z)
		o.pos.z -= offset * 0.47f;
#else
		o.pos.z += offset;
#endif

		o.color = i.color * color;
		o.color.rgb *= alphaFactor;
		o.uv = TRANSFORM_TEX(i.uv, _MainTex);
		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.uv);
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
			#pragma multi_compile_instancing
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
