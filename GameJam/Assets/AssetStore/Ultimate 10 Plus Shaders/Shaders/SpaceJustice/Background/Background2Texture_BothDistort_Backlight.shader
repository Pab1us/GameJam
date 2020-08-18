Shader "SpaceJustice/Background/Background 2Texture BothDistort Backlight"
{
	Properties
	{
		_MainTex("Main texture", 2D) = "black" {}
		_Offset ("Offset", float) = 0.0
		_TexColor ("Color", Color) = (1,1,1,1)
		_Brightening ("Brightening", Float) = 1.0

		[Toggle] _UseTimeScroll ("Use time scroll", Float) = 0.
		_ScrollSpeed ("Scroll Speed", range(0., 1.)) = 0.0

		[NoScaleOffset]
		_NormTex("Normal texture", 2D) = "black" {}

		[Header(Backlight)]
		_LightPosition ("Position (xyz)", Vector) = (0.0,0.0,-10.0,0.0)
		_LightAttenuation ("Attenuation", range(0.01, 1.0)) = 0.1

		_BacklightColor ("Color", Color) = (1,1,1,1)

		[Header(Distort)]
		[NoScaleOffset]
		_DistTex ("Distortion (rg)", 2D) = "black" {}
		_DistTex_TileScroll ("Tile Scroll", Vector) = (1,1,0,0)
		_DistPower ("Distortion power xy", Vector) = (0,0,0,0)
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	#include "../Standard_Functions.cginc"

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
		float2 uv1 : TEXCOORD1;
		fixed4 color : TEXCOORD2;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

  sampler2D _NormTex;
  sampler2D _DistTex;

	half4 _Tex_TileScroll;
	half4 _DistTex_TileScroll;
	half4 _DistPower;
	fixed4 _TexColor;
	fixed4 _BacklightColor;
	float4 _LightPosition;
	fixed _LightAttenuation;
	float _Offset;
	float _ScrollSpeed;
	half _Brightening;

	v2f vert (appdata i)
	{
		v2f o;

		float4 wpos = mul(unity_ObjectToWorld, i.vertex);

		o.pos = mul(UNITY_MATRIX_VP, wpos);

		o.uv.xy = TRANSFORM_TEX(i.uv, _MainTex);

		#ifdef _USETIMESCROLL_ON
		o.uv.y += frac(_Time.y * _ScrollSpeed);
		#else
		o.uv.y += frac(_Offset);
		#endif

		o.uv.zw = i.uv * _DistTex_TileScroll.xy + frac(_DistTex_TileScroll.zw * _Time.y);

		o.uv1 = i.vertex;

		o.color = saturate(i.color * _Brightening);

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 distort = tex2D(_DistTex, i.uv.zw).rgrg - 0.5f.xxxx;
		fixed4 color = tex2D(_MainTex, i.uv.xy + distort.xy * _DistPower.xy) * _TexColor;
		fixed4 norm = tex2D(_NormTex, i.uv.xy + distort.xy * _DistPower.xy);

		float3 N = normalize(norm.xyz - 0.5f.xxx);
		float3 L = normalize(float3(i.uv1, 0.0f) - _LightPosition);

		fixed Lit = saturate(dot(-N, L)) * (1.0f - 2.0f * color.r) + color.r;

		color.rgb = lerp(color.rgb, _BacklightColor.rgb * _BacklightColor.a * (Lit + sfPow(1.0f - color.b, 4.0f) * (1.0f - color.r)), sfPow(1.0f - color.r, 2.0f)  / (1.0f + length(i.uv1) * _LightAttenuation));

		return color * i.color;
	}
	ENDCG

	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"Queue" = "Geometry"
		}

		Cull Back

		Pass
		{
			CGPROGRAM
			#pragma shader_feature _USETIMESCROLL_ON

			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}