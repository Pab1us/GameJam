Shader "SpaceJustice/FX/Universal"
{
	Properties
	{
		_Texture01 ("Texture 01", 2D) = "white" {}
		_Color01 ("Tint", Color) = (1,1,1,1)
		_Texture01Params ("Speed (XY) Dist Pow (ZW)", Vector) = (0,0,0,0)

		[Header(Distortion)]
		_TextureDistortion ("Texture Distortion", 2D) = "white" {}
		_Params ("Params", Vector) = (0,0,0,0)

		[Header(Blending)]
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Operation", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFactor ("Source", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFactor ("Destination", Float) = 10
		[Header(Culling)]
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Culling Mode", Float) = 2
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _Texture01;
	float4 _Texture01_ST;
	half4 _Texture01Params;
	fixed4 _Color01;

	sampler2D _TextureDistortion;
	float4 _TextureDistortion_ST;
	half4 _Params;

	struct appdata
	{
		float4 vertex : POSITION;
		half2 uv : TEXCOORD0;
		fixed4 color : COLOR;
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		half4 uv : TEXCOORD0;
		fixed4 color : COLOR0;
	};

	v2f vert (appdata v)
	{
		v2f o;

		o.pos = UnityObjectToClipPos(v.vertex);

		o.uv.xy = TRANSFORM_TEX(v.uv, _Texture01) + frac(_Time.y * _Texture01Params.xy);
		o.uv.zw = TRANSFORM_TEX(v.uv, _TextureDistortion) + frac(_Time.y * _Params.xy);

		o.color = v.color;

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		half2 dist = tex2D(_TextureDistortion, i.uv.zw).xy - 0.5f.xx;
		fixed4 tex = tex2D(_Texture01, i.uv.xy + dist * _Texture01Params.zw);

		fixed4 color = _Color01 * tex;

		color.rgb = color.rgb * color.a;

		return color * i.color;
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
		}

		BlendOp [_BlendOp]
		Blend [_SrcBlendFactor] [_DstBlendFactor]
		ZWrite Off
		Cull [_CullMode]

		Pass
		{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}
