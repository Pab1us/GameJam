Shader "SpaceJustice/FX/ShadowShip"
{
	Properties
	{
		[NoScaleOffset] _MainTex ("Main Texture", 2D) = "white" {}
		_Opacity ("Opacity", Range(0., 1.)) = 1.
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		half2 uv : TEXCOORD0;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		half2 uv : TEXCOORD0;
		fixed4 color : COLOR0;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	fixed4 ShadowColor;

	UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_DEFINE_INSTANCED_PROP(fixed, _Opacity)
	UNITY_INSTANCING_BUFFER_END(Props)

	v2f vert(appdata i)
	{
		UNITY_SETUP_INSTANCE_ID(i);
		v2f o;

		o.pos = UnityObjectToClipPos(i.vertex);
		o.color = fixed4(ShadowColor.rgb, UNITY_ACCESS_INSTANCED_PROP(Props, _Opacity));
		o.uv = TRANSFORM_TEX(i.uv, _MainTex);

		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 col;

		fixed tex = tex2D(_MainTex, i.uv).r;
		col = i.color;
		col.a *= tex.r;

		return col;
	}
	ENDCG

	SubShader
	{
		Tags
		{
			"Queue"="Geometry"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
		}

		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
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
