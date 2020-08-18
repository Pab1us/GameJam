Shader "SpaceJustice/Background/Background 2Texture"
{
	Properties
	{
		_MainTex("Main texture", 2D) = "black" {}
		_Offset ("Offset", float) = 0.0

		[Toggle] _UseTimeScroll ("Use time scroll", Float) = 0.
		_ScrollSpeed ("Scroll Speed", range(0., 1.)) = 0.0

		[Header(Obsolete)]
		_SpeedMove ("Speed", float) = 0.0

		[Header(Additional texture)]
		_AddTexColor ("Color", Color) = (1,1,1,1)
		[NoScaleOffset]
		_AddTex ("Additional texture", 2D) = "black" {}
		_AddTex_TileScroll ("Tile Scroll", Vector) = (1,1,0,0)

		[Header(Distort)]
		[NoScaleOffset]
		_DistTex ("Distortion texture", 2D) = "black" {}
		_DistTex_TileScroll ("Tile Scroll", Vector) = (1,1,0,0)
		_DistPowerUV ("Distortion power UV", Vector) = (0,0,0,0)
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata {
		float4 vertex : POSITION;
		float2 uv     : TEXCOORD0;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	float _Offset;
	half _ScrollSpeed;
	sampler2D _AddTex;
	sampler2D _DistTex;
	half4 _AddTex_TileScroll, _DistTex_TileScroll;
	half2 _DistPowerUV;
	fixed4 _AddTexColor;

	struct v2f {
		float4 pos : SV_POSITION;
		float4 uv  : TEXCOORD0; // xy main zw additional
		float2 uv1 : TEXCOORD1; // distort
	};

	v2f vert (appdata i) {
		v2f o;
		o.pos = UnityObjectToClipPos(i.vertex);
		o.uv.xy = TRANSFORM_TEX(i.uv, _MainTex);

		#ifdef _USETIMESCROLL_ON
		o.uv.y += _Time.y * _ScrollSpeed;
		#else
		o.uv.y += frac(_Offset);
		#endif

		o.uv.zw = i.uv * _AddTex_TileScroll.xy  + frac(_AddTex_TileScroll.zw * _Time.y);
		o.uv1 = i.uv * _DistTex_TileScroll.xy + frac(_DistTex_TileScroll.zw * _Time.y);

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 color = tex2D(_MainTex, i.uv.xy);
		fixed2 distort = tex2D(_DistTex, i.uv1).rg;

		color += tex2D(_AddTex, i.uv.zw + (distort - 0.5f.xx) * _DistPowerUV) * _AddTexColor;

		return color;
	}
	ENDCG

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry" }
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