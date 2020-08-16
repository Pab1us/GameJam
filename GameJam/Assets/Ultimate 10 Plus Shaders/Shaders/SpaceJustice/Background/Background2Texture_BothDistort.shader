Shader "SpaceJustice/Background/Background 2Texture Both Distort"
{
	Properties
	{
		_MainTex("Main texture", 2D) = "black" {}
		_Offset ("Offset", float) = 0.0
		_TexColor ("Color", Color) = (1,1,1,1)

		[Toggle] _UseTimeScroll ("Use time scroll", Float) = 0.
		_ScrollSpeed ("Scroll Speed", range(0., 1.)) = 0.0

		_AddTex("Additional texture", 2D) = "black" {}
		_AddTexColor ("Color", Color) = (1,1,1,1)
		_AddTex_TileScroll ("Tile Scroll", Vector) = (1,1,0,0)

		[Header(Distort)]
		[NoScaleOffset]
		_DistTex ("Distortion (rg - first, ba - second)", 2D) = "black" {}
		_DistTex_TileScroll ("Tile Scroll", Vector) = (1,1,0,0)
		_DistPower ("Distortion power xy/zw", Vector) = (0,0,0,0)
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

  sampler2D _AddTex;
  float4 _AddTex_ST;

  sampler2D _DistTex;

  half4 _Tex_TileScroll;
	half4 _DistTex_TileScroll;
	half4 _AddTex_TileScroll;
	half4 _DistPower;
	fixed4 _TexColor;
	fixed4 _AddTexColor;
	float _Offset;
  half _ScrollSpeed;

	struct v2f
	{
		float4 pos : SV_POSITION;
		float4 uv  : TEXCOORD0;
		float2 uv1 : TEXCOORD1;
	};

	v2f vert (appdata i)
	{
		v2f o;

		o.pos = UnityObjectToClipPos(i.vertex);

		o.uv.xy = TRANSFORM_TEX(i.uv, _MainTex);

		#ifdef _USETIMESCROLL_ON
		o.uv.y += frac(_Time.y * _ScrollSpeed);
		#else
		o.uv.y += frac(_Offset);
		#endif

		o.uv.zw = i.uv * _DistTex_TileScroll.xy + frac(_DistTex_TileScroll.zw * _Time.y);

		o.uv1 = TRANSFORM_TEX(i.uv * _AddTex_TileScroll.xy + frac(_AddTex_TileScroll.zw * _Time.y), _AddTex);

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 distort = tex2D(_DistTex, i.uv.zw).rgrg - 0.5f.xxxx;
		fixed4 color = tex2D(_MainTex, i.uv.xy + distort.xy * _DistPower.xy) * _TexColor;
		fixed4 color_add = tex2D(_AddTex, i.uv1 + distort.zw * _DistPower.zw) * _AddTexColor;

		color.rgb = lerp(color.rgb, color_add.rgb, color_add.a);

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