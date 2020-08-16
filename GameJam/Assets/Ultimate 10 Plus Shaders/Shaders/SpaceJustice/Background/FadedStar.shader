Shader "SpaceJustice/Background/FadedStar"
{
	Properties
	{
		_MainTex ("Main Texture (RGB - Diffuse)", 2D) = "white" {}
		_AmbientColor ("Ambient Lighting Color", Color) = (1., 1., 1., 1.)

		[Header(Additional Light)]
		_AddLight1_Color ("Color", Color) = (0,0,0,0)
		_AddLight1_Dir ("Direction", Vector) = (1,0,0,1)

		[Space(10)]

		[Header(Mask)]
		[NoScaleOffset] _MaskTex ("Texture  (R - Rim, G - Specular, B - Emissive)", 2D) = "black" {}

		[Header(Noise)]
		[NoScaleOffset] _NoiseTex ("Texture  (R - Noise)", 2D) = "black" {}
		_TilingUV_OffsetUV (" Tiling XY/Offset XY", Vector) = (1., 1., 0., 0.)

		_AnimationSpeed ("Animation Speed", Float) = 1.

		[Header(Rim (R mask channel))]
		_RimStart ("Start", Range(0., 1.)) = 1.
		_RimEnd ("End", Range(0., 1.)) = 1.
		_RimColor ("Color", Color) = (1., 1., 1., 1.)
		_RimOffset ("RimOffset XY",Vector) = (0,0,0,0)

		[Header(Specular (G mask channel))]
		_Shininess ("Shininess", Range(0.01, 1.)) = 1.
		_SpecularColor ("Color", Color) = (1., 1., 1., 1.)

		[Header(Emissive (B mask channel))]
		_Intensity ("Intensity", Range(0., 3.)) = 1.
		_GradientColor1 ("Gradient Color 1", Color) = (1, 0, 0, 1)
		_GradientColor2 ("Gradient Color 2", Color) = (0, 1, 0, 1)
		[Toggle] _TexturedGradient("Textured Gradient Enabled", Float) = 0.
		[NoScaleOffset] _GradTex ("Gradient Texture", 2D) = "white" {}

		[Header(Fog)]
		[Toggle] _Fog("Fog Enabled", Float) = 0.
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	#include "../Standard_Functions.cginc"
	#pragma shader_feature _TEXTUREDGRADIENT_ON

	struct appdata {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 uv : TEXCOORD0;
	};

	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		float2 uvNoise : TEXCOORD1;
		float3 wpos : TEXCOORD2;
		half3 normal : TEXCOORD3;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	fixed4 _AddLight1_Color;
	float4 _AddLight1_Dir;

	sampler2D _MaskTex;
	fixed4 _AmbientColor;
	fixed _Shininess;
	fixed4 _SpecularColor;

	sampler2D _NoiseTex;
	half4 _TilingUV_OffsetUV;
	half _Intensity;
	fixed4 _GradientColor1;
	fixed4 _GradientColor2;
	sampler2D _GradTex;

	half _AnimationSpeed;

	fixed _RimStart;
	fixed _RimEnd;
	fixed4 _RimColor;
	float4 _RimOffset;

	sampler2D _FogLUT;
	float _Fog;
	float2 _FogLUTParams; // x: -1/(end-start) y: end/(end-start)

	v2f vert(appdata i)
	{
		v2f o;
		float4 wpos = mul(unity_ObjectToWorld, i.vertex);
		o.pos = mul(UNITY_MATRIX_VP, wpos);
		o.uv = TRANSFORM_TEX(i.uv, _MainTex);
		o.uvNoise = o.uv * _TilingUV_OffsetUV.xy + _TilingUV_OffsetUV.zw;
		o.wpos = wpos.xyz;
		o.normal = UnityObjectToWorldNormal(i.normal);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 color = tex2D(_MainTex, i.uv.xy);
		fixed4 mask = tex2D(_MaskTex, i.uv.xy);

		/// амбиент
		fixed3 lightAmbient = _AmbientColor.rgb * _AmbientColor.a * UNITY_LIGHTMODEL_AMBIENT;

		/// направленные света
		float3 wpos = i.wpos;
		half3 n = normalize(i.normal);
		half3 l = normalize(_AddLight1_Dir);
		half3 v = normalize(_WorldSpaceCameraPos.xyz - wpos);
		half3 r = reflect(-v, n);

		fixed3 lightDirect = _AddLight1_Color.rgb * _AddLight1_Color.a * _AddLight1_Dir.w * saturate(dot(n, l));

		/// спекуляр
		fixed3 specular = sfSpecularCoeff(l, r, _Shininess * 64.0f) * _SpecularColor.a * _SpecularColor.rgb * lightDirect;
		specular *= mask.g;

		fixed emissiveMask = tex2D(_NoiseTex, i.uvNoise.xy).x;
		emissiveMask = sfLWave(_Time.y * _AnimationSpeed * 0.5f + emissiveMask);

		fixed3 emissiveGradient;

		#ifdef _TEXTUREDGRADIENT_ON
		emissiveGradient = tex2D(_GradTex, float2(0.5f, emissiveMask));
		#else
		emissiveGradient = lerp(lerp(_GradientColor1, _GradientColor2, clamp(emissiveMask, 0.0f, 0.5f) * 2.0f), 0.0f.xxx, clamp(emissiveMask - 0.5f, 0.0f, 0.5f) * 2.0f);
		#endif

		///применяем все света
		color.rgb = color.rgb * (lightDirect + lightAmbient + specular) + emissiveGradient * mask.b * _Intensity;

		///rim
		float4 cameraLocalPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0f)) + _RimOffset;
		float4 cameraWorldPos = mul(unity_ObjectToWorld, cameraLocalPos);
		float3 v_rim = normalize(cameraWorldPos.xyz - wpos);
		fixed3 rim = smoothstep(_RimEnd, _RimEnd - _RimStart, dot(n, v_rim)) * _RimColor.a * _RimColor.rgb;
		color.rgb += rim * mask.r;

		///туман

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
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}