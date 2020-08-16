Shader "SpaceJustice/Background/Planet with Clouds"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_CloudsTex ("Clouds Texture", 2D) = "white" {}
		_SpeedScroll("SpeedScroll XY - Main UV, ZW - Clouds UV", Vector) = (0., 0., 0., 0.)
		_DiffuseColor ("Direct Lighting Color", Color) = (1., 1., 1., 1.)
		_CloudsColor ("Clouds Color", Color) = (1., 1., 1., 1.)

		[Header(Additional Light 1)]
		_AddLight1_Color ("Color", Color) = (0,0,0,0)
		_AddLight1_Dir ("Direction", Vector) = (1,1,0,1)

		[Header(Additional Light 2)]
		_AddLight2_Color ("Color", Color) = (0,0,0,0)
		_AddLight2_Dir ("Direction", Vector) = (1,1,0,1)

		[Space(10)]

		[Header(Rim)]
		_RimStart ("Start", Range(0., 1.)) = 1.
		_RimEnd ("End", Range(0., 1.)) = 1.
		_RimColor ("Color", Color) = (1., 1., 1., 1.)
		_RimOffset ("RimOffset XY",Vector) = (0,0,0,0)

		[Header(Fog)]
		[Toggle] _Fog("Fog Enabled", Float) = 0.
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 uv : TEXCOORD0;
	};

	struct v2f {
		float4 pos : SV_POSITION;
		float4 uv : TEXCOORD0;//zw - clouds
		float4 light : TEXCOORD1;
		float3 wpos : TEXCOORD2;
		half3 normal : TEXCOORD3;
		float3 cam : TEXCOORD4;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	sampler2D _CloudsTex;
	float4 _CloudsTex_ST;

	half4 _SpeedScroll;

	fixed4 _DiffuseColor;
	fixed4 _CloudsColor;

	fixed4 _AddLight1_Dir, _AddLight2_Dir;
	fixed4 _AddLight1_Color, _AddLight2_Color;

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

		float4 wpos = mul(unity_ObjectToWorld, i.vertex);

		o.pos = mul(UNITY_MATRIX_VP, wpos);
		o.uv = float4(TRANSFORM_TEX(i.uv, _MainTex) + frac(_SpeedScroll.xy * _Time.y), TRANSFORM_TEX(i.uv, _CloudsTex) + frac(_SpeedScroll.zw * _Time.y));
		o.light = mul(UNITY_MATRIX_I_V, unity_LightPosition[0]);
		o.wpos = wpos.xyz;
		o.normal = UnityObjectToWorldNormal(i.normal);

		float4 cameraLocalPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0f)) + _RimOffset;
		o.cam = mul(unity_ObjectToWorld, cameraLocalPos).xyz;

		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 color = tex2D(_MainTex, i.uv.xy);
		fixed4 clouds = tex2D(_CloudsTex, i.uv.zw);

		///амбиент
		fixed3 lightAmbient = UNITY_LIGHTMODEL_AMBIENT;

		///направленные света
		float3 wpos = i.wpos;
		half3 n = normalize(i.normal);
		half3 l = normalize(i.light.xyz - wpos * i.light.w);
		half3 v = normalize(_WorldSpaceCameraPos.xyz - wpos);
		half3 r = reflect(-v, n);

		fixed3 lightDirect = saturate(dot(n, l)) * _DiffuseColor.a * _DiffuseColor.rgb * unity_LightColor[0].rgb;
		lightDirect += _AddLight1_Color.rgb * _AddLight1_Color.a * _AddLight1_Dir.w * saturate(dot(n, normalize(_AddLight1_Dir.xyz)));
		lightDirect += _AddLight2_Color.rgb * _AddLight2_Color.a * _AddLight2_Dir.w * saturate(dot(n, normalize(_AddLight2_Dir.xyz)));

		///применяем все света
		color.rgb = color.rgb * (lightDirect + lightAmbient);

		///rim
		half3 v_rim = normalize(i.cam - wpos);
		fixed3 rim = smoothstep(_RimEnd, _RimEnd - _RimStart, dot(n, v_rim)) * _RimColor.a * _RimColor.rgb;
		color.rgb += rim;

		///туман

		fixed4 fog = tex2D(_FogLUT, float2(wpos.z * _FogLUTParams.x + _FogLUTParams.y, 0.5f));
		color.rgb = lerp(color.rgb, fog.rgb, _Fog * fog.a);

		///облака

		color.rgb += (clouds.xyz * _CloudsColor.xyz) * clouds.w * _CloudsColor.w;

		return color;
	}
	ENDCG

	SubShader
	{
		Tags
		{
			"Queue" = "Geometry"
			"RenderType" = "Opaque"
		}
		Pass
		{
			Tags { "LightMode" = "Vertex" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}