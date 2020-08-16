Shader "SpaceJustice/FX/Lasers/AddScroll"
{
	Properties
	{
		_Color ("Multiplier", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex ("MainTex", 2D) = "white" {}
		_AddTex ("Additional Tex", 2D) = "black" {}
		_ScrollingSpeed ("Scroll Speed UV", vector) = (0.5, 0.5, 0.0, 0.0)
		[PerRendererData] _TilingLength ("Tiling Length", Float) = 1.0
		_AlphaFactor ("Alpha Factor", Float) = 1.0
	}

	CGINCLUDE
	#define COLOR_MULTIPLIER 2.0f
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		fixed4 color : COLOR;
		half2 uv : TEXCOORD0;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		fixed4 color : COLOR;
		half4 uv : TEXCOORD0;
	};

	sampler2D _MainTex;
	half4 _MainTex_ST;
	sampler2D _AddTex;
	half4 _AddTex_ST;

	UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
		UNITY_DEFINE_INSTANCED_PROP(float, _AlphaFactor)
		UNITY_DEFINE_INSTANCED_PROP(float, _TilingLength)
		UNITY_DEFINE_INSTANCED_PROP(half4, _ScrollingSpeed)
	UNITY_INSTANCING_BUFFER_END(Props)

	v2f vert(appdata i)
	{
		UNITY_SETUP_INSTANCE_ID(i);
		v2f o;

		fixed4 color = UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
		half alphaFactor = (half)UNITY_ACCESS_INSTANCED_PROP(Props, _AlphaFactor);
		half length = (half)UNITY_ACCESS_INSTANCED_PROP(Props, _TilingLength);
		half4 speed = UNITY_ACCESS_INSTANCED_PROP(Props, _ScrollingSpeed);

		o.pos = UnityObjectToClipPos(i.vertex);
		o.color = color * i.color;
		o.color.rgb *= o.color.a * COLOR_MULTIPLIER * alphaFactor;

		o.uv.xy = (i.uv * _MainTex_ST.xy * half2(1.0f, length) + _MainTex_ST.zw + frac(half(_Time.z) * speed.xy));
		o.uv.zw = (i.uv * _AddTex_ST.xy * half2(1.0f, length) + _AddTex_ST.zw + frac(half(_Time.z) * speed.zw));
		return o;
	}

	fixed4 frag(v2f i) : COLOR
	{
		fixed4 color = tex2D(_MainTex, i.uv.xy) + tex2D(_AddTex, i.uv.zw);
		color.rgb *= i.color.rgb;

		return color;
	}
	ENDCG

	SubShader
	{
		Tags
		{
			"IgnoreProjector"="True"
			"Queue"="Transparent"
			"RenderType"="Transparent"
		}
		Pass
		{
			ZWrite Off
			Cull Off
			Blend One One

			CGPROGRAM
			#pragma multi_compile_instancing
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}


