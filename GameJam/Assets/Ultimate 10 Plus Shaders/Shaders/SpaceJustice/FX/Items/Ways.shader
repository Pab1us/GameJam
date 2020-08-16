Shader "SpaceJustice/FX/Items/Ways"
{
	Properties
	{
		_Tiling ("Tiling", Float) = 1.0

		[Header(Texture)]
		_MainTex ("Texture", 2D) = "black" {}

		[Header(Foreground)]
		_Foregr_TilingScroll ("Tiling Scroll ", Vector) = (1,1,0,0)
		_Foregr_Color("Color",Color) = (1,1,1,1)

		[Header(Background)]
		_Back_TilingScroll ("Tiling Scroll ", Vector) = (1,1,0,0)
		_Back_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_Back_ColorBlackTint("Color black tint",Color) = (0,0,0,0)
		_ColorLinear ("ColorLinear", Float) = 1.0

		[Header(Wave)]
		_Wave_TilingScroll ("Tiling Scroll ", Vector) = (1,1,0,0)
		_Wave_Color ("Color",Color) = (1,1,1,1)

	}

	CGINCLUDE

	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 uv : TEXCOORD0;//xy Foreground  zw Background
		float2 uv1 : TEXCOORD1;//xy Wave
		float4 vertex : SV_POSITION;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	//foreground
	half4 _Foregr_TilingScroll;
	fixed4 _Foregr_Color;
	half _ColorLinear;

	//background
	half4 _Back_TilingScroll;
	fixed4 _Back_ColorWhiteTint;
	fixed4 _Back_ColorBlackTint;

	//wave
	half4 _Wave_TilingScroll;
	fixed4 _Wave_Color;

	UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_DEFINE_INSTANCED_PROP(float, _Tiling)
	UNITY_INSTANCING_BUFFER_END(Props)

	v2f vert (appdata i)
	{
		UNITY_SETUP_INSTANCE_ID(i);

		float tiling = UNITY_ACCESS_INSTANCED_PROP(Props, _Tiling);

		v2f o;
		o.vertex = UnityObjectToClipPos(i.vertex);
		o.uv.xy = i.uv * _Foregr_TilingScroll.xy * float2(tiling, 1.0f) + frac(_Foregr_TilingScroll.zw * _Time.y);
		o.uv.xy = o.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
		o.uv.zw = i.uv * _Back_TilingScroll.xy + frac(_Back_TilingScroll.zw * _Time.y);
		o.uv.zw = o.uv.zw * _MainTex_ST.xy + _MainTex_ST.zw;
		o.uv1 = i.uv * _Wave_TilingScroll.xy + frac(_Wave_TilingScroll.zw * _Time.y);
		o.uv1 = o.uv1 * _MainTex_ST.xy + _MainTex_ST.zw;

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 col;
		fixed4 foregr = _Foregr_Color * tex2D(_MainTex, i.uv.xy).r;

		fixed backMask = tex2D(_MainTex, i.uv.zw).g;
		fixed4 back = lerp(_Back_ColorBlackTint,  _Back_ColorWhiteTint, pow( backMask, _ColorLinear));

		fixed4 wave = _Wave_Color * tex2D(_MainTex, i.uv1).a;

		col = back + lerp(foregr * foregr.a, foregr * wave * 2.0f, wave.a);
		col.a = back.a * (1.0f - foregr.a) + foregr.a;

		return col;
	}
	ENDCG

	SubShader
	{
		Tags
		{
			"RenderType"="Transparent"
			"Queue" = "Transparent"
			"PreviewType"="Plane"
		}

		BlendOp Add
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Back

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
