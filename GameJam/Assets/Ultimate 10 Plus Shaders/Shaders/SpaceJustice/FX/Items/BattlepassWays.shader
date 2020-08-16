Shader "SpaceJustice/FX/Items/BattlepassWays"
{
	Properties
	{
		_Tiling ("Tiling", Float) = 1.0

		[Header(Texture)]
		_MainTex ("Texture", 2D) = "black" {}

		[Header(Progress)]
		_Progress0 ("Progress0", Float) = 0.0
		_Progress0ColorWhiteTint("Progress0 Color White Tint",Color) = (1,1,1,1)
		_Progress0ColorBlackTint("Progress0 Color Black Tint",Color) = (1,1,1,1)

		_Progress1 ("Progress1", Float) = 0.0
		_Progress1ColorWhiteTint("Progress1 Color White Tint",Color) = (1,1,1,1)
		_Progress1ColorBlackTint("Progress1 Color Black Tint",Color) = (1,1,1,1)

		[Header(Background)]
		_Back_Scroll ("Scroll Speed", Float) = 0.0
		_Back_ColorWhiteTint("Color White Tint",Color) = (1,1,1,1)
		_Back_ColorBlackTint("Color Black Tint",Color) = (0,0,0,0)

		[Header(Wave)]
		_Wave_Tiling ("Tiling", Float) = 1.0
		_Wave_Bright ("Bright", Range(0.0, 1.0)) = 1.0

		[Toggle] _VertexColor("Use Vertex Color", Float) = 0.
	}

	CGINCLUDE

	#include "UnityCG.cginc"
	#include "../../Standard_Functions.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		fixed4 color : COLOR;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 vertex : SV_POSITION;
		float4 uv : TEXCOORD0;//xy Foreground  zw Background
		float3 uvProgress : TEXCOORD1;
		fixed4 color : COLOR;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	fixed4 _Progress0ColorWhiteTint;
	fixed4 _Progress0ColorBlackTint;

	fixed4 _Progress1ColorWhiteTint;
	fixed4 _Progress1ColorBlackTint;

	//background
	half _Back_Scroll;
	fixed4 _Back_ColorWhiteTint;
	fixed4 _Back_ColorBlackTint;

	//wave
	half _Wave_Tiling;
	fixed _Wave_Bright;

	UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_DEFINE_INSTANCED_PROP(float, _Tiling)
		UNITY_DEFINE_INSTANCED_PROP(float, _Progress0)
		UNITY_DEFINE_INSTANCED_PROP(float, _Progress1)
	UNITY_INSTANCING_BUFFER_END(Props)

	v2f vert (appdata i)
	{
		UNITY_SETUP_INSTANCE_ID(i);

		float tiling = UNITY_ACCESS_INSTANCED_PROP(Props, _Tiling);
		float progress0 = UNITY_ACCESS_INSTANCED_PROP(Props, _Progress0);
		float progress1 = UNITY_ACCESS_INSTANCED_PROP(Props, _Progress1);

		v2f o;
		o.vertex = UnityObjectToClipPos(i.vertex);
		o.uv.xy = i.uv * _MainTex_ST.xy + _MainTex_ST.zw + float2(0.0f, 0.5f);
		o.uv.zw = float2(tiling, 1.0f) * i.uv;
		o.uv.z += frac(_Back_Scroll * _Time.y);
		o.uv.zw = o.uv.zw * _MainTex_ST.xy + _MainTex_ST.zw;

		o.uvProgress.x = TRANSFORM_TEX(i.uv, _MainTex).x * 0.5f;
		o.uvProgress.yz = float2(progress0, progress1);

	#if _VERTEXCOLOR_ON
		o.color = i.color;
	#endif

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 col;
		fixed backMask = tex2D(_MainTex, i.uv.zw).r;
		fixed4 back = lerp(_Back_ColorBlackTint, _Back_ColorWhiteTint, backMask);

		fixed progressBar = tex2D(_MainTex, i.uv.xy).r;

		fixed4 progressBar0 = lerp(_Progress0ColorBlackTint, _Progress0ColorWhiteTint, progressBar);
		fixed4 progressBar1 = lerp(_Progress1ColorBlackTint, _Progress1ColorWhiteTint, progressBar);

		fixed progressCoord0 = saturate((1.004f - i.uvProgress.x - i.uvProgress.y) * 200.0f);
		fixed progressCoord1 = saturate((1.004f - i.uvProgress.x - i.uvProgress.z) * 200.0f);

		fixed wave = sfLWave(i.uvProgress.x * _Wave_Tiling + _Time.y) * _Wave_Bright;

		col = lerp(progressBar1, back, progressCoord1);
		col = lerp(progressBar0, col, progressCoord0);

		col.rgb += wave.xxx;

	#if _VERTEXCOLOR_ON
		col *= i.color;
	#endif

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
			#pragma shader_feature _VERTEXCOLOR_ON
			#pragma multi_compile_instancing
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
