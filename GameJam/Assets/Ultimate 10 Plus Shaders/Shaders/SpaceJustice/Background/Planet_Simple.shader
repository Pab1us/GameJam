Shader "SpaceJustice/Background/Planet simple"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_MainTex_SpeedScroll("SpeedScroll UV",Vector) = (0,0,0,0)

		_AmbientColor ("Ambient Color", Color) = (1., 1., 1., 1.)
		_DiffuseColor ("Direct Lighting Color", Color) = (1., 1., 1., 1.)

		[Header(Rim)]
		_RimStart ("Start", Range(0., 1.)) = 1.
		_RimEnd ("End", Range(0., 1.)) = 1.
		_RimColor ("Color", Color) = (1., 1., 1., 1.)
		_RimOffset ("RimOffset XY",Vector) = (0,0,0,0)

		[Header(Specular (A channel))]
		_Shininess ("Shininess", Range(0.01, 1.)) = 1.
		_SpecularColor ("Color", Color) = (1., 1., 1., 1.)

		[Header(Fog)]
		[Toggle] _Fog("Fog Enabled", Float) = 0.
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	#include "../Standard_Functions.cginc"

	struct appdata {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 uv     : TEXCOORD0;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f {
		float4 pos : SV_POSITION;
		float4 uv : TEXCOORD0; // _MainTex _LightTex
		float4 light : TEXCOORD1;
		float3 wpos : TEXCOORD2;
		half3 normal : TEXCOORD3;
		float3 cam : TEXCOORD4;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	half4 _MainTex_SpeedScroll;

	sampler2D _MaskTex;

	fixed4 _AmbientColor;
	fixed4 _DiffuseColor;
	fixed _Shininess;
	fixed4 _SpecularColor;

	fixed _RimStart;
	fixed _RimEnd;
	fixed4 _RimColor;
	fixed4 _RimOffset;

	sampler2D _FogLUT;
	float _Fog;
	float2 _FogLUTParams; // x: -1/(end-start) y: end/(end-start)

	v2f vert(appdata i)
	{
		UNITY_SETUP_INSTANCE_ID(i);
		v2f o;

		float4 wpos = mul(unity_ObjectToWorld, float4(i.vertex.xyz, 1.0f));

		o.pos = mul(UNITY_MATRIX_VP, wpos);
		o.uv.xy = TRANSFORM_TEX(i.uv, _MainTex) + frac(_MainTex_SpeedScroll.xy * _Time.y);
		o.uv.zw = float2(0, 0);

		o.light = mul(UNITY_MATRIX_I_V, unity_LightPosition[0]);
		o.wpos = wpos;
		o.normal = UnityObjectToWorldNormal(i.normal);

		float4 cameraLocalPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0f)) + _RimOffset;
		o.cam = mul(unity_ObjectToWorld, cameraLocalPos).xyz;

		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 color = tex2D(_MainTex, i.uv.xy);
		fixed maskSpec = color.a;
		fixed4 mask = tex2D(_MaskTex, i.uv.xy);

		half3 wpos = i.wpos;
		half3 n = normalize(i.normal);
		half3 l = normalize(i.light.xyz - wpos * i.light.w);
		half3 v = normalize(_WorldSpaceCameraPos.xyz - wpos);
		half3 r = reflect(-v, n);
		fixed3 light = _AmbientColor.rgb * _AmbientColor.a;
		light *= UNITY_LIGHTMODEL_AMBIENT;

		fixed3 lightColor = unity_LightColor[0].rgb;
		light += saturate(dot(n, l)) * _DiffuseColor.a * _DiffuseColor.rgb * lightColor;

		fixed3 specular = sfSpecularCoeff(l, r, _Shininess * 64.0f) * _SpecularColor.a * _SpecularColor.rgb * lightColor;
		specular *= maskSpec;
		light += specular;
		color.rgb *= light;

		float3 v_rim = normalize(i.cam - wpos);
		fixed3 rim = smoothstep(_RimEnd, _RimEnd - _RimStart, dot(n, v_rim)) * _RimColor.a * _RimColor.rgb;

		color.rgb += rim;

		fixed4 fog = tex2D(_FogLUT, float2(wpos.z * _FogLUTParams.x + _FogLUTParams.y, 0.5f));
		color.rgb = lerp(color.rgb, fog.rgb, _Fog * fog.a);

		return color;
	}
	ENDCG

	SubShader
	{
		Tags
		{
			"Queue"="Geometry"
			"RenderType"="Opaque"
		}
		Pass
		{
			Tags { "LightMode"="Vertex" }
			CGPROGRAM
			#pragma shader_feature _MASK_ON
			#pragma multi_compile_instancing
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}