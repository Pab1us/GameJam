Shader "SpaceJustice/FX/Items/AndromedaWays"
{
	Properties
	{
		_Tiling ("Tiling", Float) = 1.0

		[Header(Texture)]
		_MainTex ("Texture", 2D) = "black" {}

		[Header(Progress)]
		_Progress0 ("Progress", Float) = 1.0
		_ProgressColor ("Progress Color", Color) = (1,1,1,1)

		[Header(Arrow)]
		_Scroll ("Scroll Speed", Float) = 0.0
		_ArrowColor ("Arrow Color", Color) = (1,1,1,1)
		_BackColor ("Glow Color", Color) = (0,0,0,0)

		[Header(Wave)]
		_Wave_Tiling ("Tiling", Float) = 1.0
		_Wave_Scroll ("Scroll Speed", Float) = 1.0
		_Wave_Bright ("Bright", Range(0.0, 1.0)) = 1.0
	}

	CGINCLUDE

	#include "UnityCG.cginc"
	#include "../../Standard_Functions.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		half2 uv : TEXCOORD0;
		fixed4 color : COLOR;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 vertex : SV_POSITION;
		half4 uv : TEXCOORD0;
		fixed4 color : COLOR;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	fixed4 _ProgressColor;

	half _Scroll;
	fixed4 _ArrowColor;
	fixed4 _BackColor;

	half _Wave_Tiling;
	half _Wave_Scroll;
	fixed _Wave_Bright;

	UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_DEFINE_INSTANCED_PROP(float, _Tiling)
		UNITY_DEFINE_INSTANCED_PROP(float, _Progress0)
	UNITY_INSTANCING_BUFFER_END(Props)

	v2f vert (appdata i)
	{
		UNITY_SETUP_INSTANCE_ID(i);

		float tiling = UNITY_ACCESS_INSTANCED_PROP(Props, _Tiling);
		float progress = UNITY_ACCESS_INSTANCED_PROP(Props, _Progress0);

		v2f o;
		o.vertex = UnityObjectToClipPos(i.vertex);
		o.uv.xy = i.uv;
		o.uv.x *= tiling;
		o.uv.xy = o.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
		o.uv.x += frac(_Scroll * _Time.y);

		o.uv.z = i.uv.x * _MainTex_ST.x + _MainTex_ST.z;
		o.uv.w = o.uv.z;
		o.uv.z = o.uv.z + progress;

		o.color = i.color;

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 mask = tex2D(_MainTex, i.uv.xy);

		fixed4 arrow = mask.x * _ArrowColor;
		fixed4 back = mask.g * _BackColor;

		fixed progressCoord = saturate((i.uv.z - 1.004f) * 200.0f);

		fixed wave = sfLWave(i.uv.w * _Wave_Tiling + _Time.y * _Wave_Scroll) * _Wave_Bright;

		arrow.xyz += wave.xxx;

		fixed4 col = lerp(back, arrow, arrow.a);

		fixed4 desaturated = dot(col, 0.333f) * _ProgressColor;

		col = lerp(desaturated, col, progressCoord);

		col *= i.color;
		col.a += wave * mask.x;

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
