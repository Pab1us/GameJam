Shader "SpaceJustice/Background/Background 1Texture"
{
	Properties
	{
		_MainTex("Main texture", 2D) = "black" {}
		_Offset ("Offset", float) = 0.0
		_TexColor ("Color", Color) = (1,1,1,1)

		[Toggle] _UseTimeScroll ("Use time scroll", Float) = 0.
		_ScrollSpeed ("Scroll Speed", range(0., 1.)) = 0.0

		[Header(Distort)]
		[NoScaleOffset]
		_DistTex ("Distortion texture", 2D) = "black" {}
		_DistTex_TileScroll ("Tile Scroll", Vector) = (1,1,0,0)
		_DistPowerUV ("Distortion power UV", Vector) = (0,0,0,0)
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		fixed4 color : COLOR;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	float _Offset;
	float _ScrollSpeed;
	sampler2D _DistTex;
	float4 _DistTex_ST;
	float4 _Tex_TileScroll, _DistTex_TileScroll;
	float2 _DistPowerUV;
	fixed4 _TexColor;

	struct v2f
	{
		float4 pos : SV_POSITION;
		float4 uv  : TEXCOORD0;
		float4 uv1 : TEXCOORD1;
		fixed4 color : COLOR;
	};

	v2f vert (appdata i)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(i.vertex);
		o.uv.xy = TRANSFORM_TEX(i.uv, _MainTex);

		#ifdef _USETIMESCROLL_ON
		o.uv.y += _Time.y * _ScrollSpeed;
		#else
		o.uv.y += frac(_Offset);
		#endif

		o.uv.zw = TRANSFORM_TEX(i.uv * _DistTex_TileScroll.xy + frac(_DistTex_TileScroll.zw * _Time.y), _DistTex);
		
		o.color = i.color;

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed2 distort = tex2D(_DistTex, i.uv.zw).rg - 0.5f.xx;
		fixed4 color = tex2D(_MainTex, i.uv.xy + distort * _DistPowerUV) * _TexColor * i.color;

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