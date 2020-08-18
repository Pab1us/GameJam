Shader "SpaceJustice/Unlit/TransparentColor Dissolve"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)

		[Space(10)]
		[Header (Dissolve)]
		[NoScaleOffset]
		_TexDiss ("Dissolve", 2D) = "white" {}
		_TexDiss_TilingScroll ("Tiling Scroll ", Vector) = (1,1,0,0)

		_DissColorBorder("Diss Color Border",Color) = (1,1,1,1)
		_DissParam("Diss Width Border Smooth", Vector) = (1,1,1,1)

		[Space(10)]
		[NoScaleOffset]
		_TexDistort ("Distort", 2D) = "white" {}
		_TexDistort_TilingScroll ("Tiling Scroll ", Vector) = (1,1,0,0)

		_DistParam ("Dist", Vector) = (0,0,0,0)

		[Space(10)]
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Blend Operation", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFactor ("Source Blend Factor", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFactor ("Destination Blend Factor", Float) = 10

		[Space(10)]
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Culling Mode", Float) = 0
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		float2 uv1 : TEXCOORD1;
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		float4 uvDiss : TEXCOORD2;//_TexDiss , _TexDistort
		float2 uvDissBase : TEXCOORD3;
	};

	sampler2D _TexDiss;
	sampler2D _TexDistort;

	fixed4 _Color;
	fixed4 _DissColorBorder;
	half4 _DissParam;
	half2 _DistParam;
	half4 _TexDiss_TilingScroll;
	half4 _TexDistort_TilingScroll;

	v2f vert(appdata i)
	{
		v2f o;

		o.pos = UnityObjectToClipPos(i.vertex);

		o.uvDissBase = i.uv1;
		o.uvDiss.xy = i.uv1 * _TexDiss_TilingScroll.xy + frac(_TexDiss_TilingScroll.zw * _Time.y);
		o.uvDiss.zw = i.uv1 * _TexDistort_TilingScroll.xy + frac(_TexDistort_TilingScroll.zw * _Time.y);

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 color = _Color;

		fixed2 texDistort = tex2D(_TexDistort, i.uvDiss.zw).xy - 0.5f;
		fixed texDiss = tex2D(_TexDiss, i.uvDiss.xy + texDistort * _DistParam.xy).r;

		half mask_vertexAlpha = lerp(_DissParam.x, _DissParam.x + _DissParam.y, i.uvDissBase.y);
		fixed2 dis = saturate(((texDiss + float2(mask_vertexAlpha, mask_vertexAlpha + _DissParam.z)) * 50.0f - 25.0f) / _DissParam.w);

		color.rgb += (1.0f - dis.y) * _DissColorBorder.rgb *_DissColorBorder.a * 2.0f;
		color.a *= dis.x;

		return color;
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
		Cull [_CullMode]
		ZWrite On

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			ENDCG
		}
	}
}