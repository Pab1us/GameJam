Shader "SpaceJustice/Background/Planet"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_MainTex_SpeedScroll("SpeedScroll UV",Vector) = (0,0,0,0)
		_AmbientColor ("Ambient Color", Color) = (1., 1., 1., 1.)
		_DiffuseColor ("Direct Lighting Color", Color) = (1., 1., 1., 1.)

		[Header(Mask)]
		[NoScaleOffset] _MaskTex ("Texture  (G - spec B - self illum)", 2D) = "white" {}

		[Header(Rim)]
		_RimStart ("Start", Range(0., 1.)) = 1.
		_RimEnd ("End", Range(0., 1.)) = 1.
		_RimColor ("Color", Color) = (1., 1., 1., 1.)
		_RimOffset ("RimOffset XY",Vector) = (0,0,0,0)

		[Header(Specular (G mask channel))]
		_Shininess ("Shininess", Range(0.01, 1.)) = 1.
		_SpecularColor ("Color", Color) = (1., 1., 1., 1.)

		[Header(Self Illumination (B mask channel))]
		_IlluminationColor ("Color", Color) = (1., 1., 1., 1.)

		[Header(Fog)]
		[Toggle] _Fog("Fog Enabled", Float) = 0.
	}

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
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

		struct appdata {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			float4 uv : TEXCOORD0;//_MainTex _LightTex
			float4 light : TEXCOORD1;
			float3 wpos : TEXCOORD2;
			half3 normal : TEXCOORD3;
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

		fixed4 _IlluminationColor;

		sampler2D _FogLUT;
		float _Fog;
		float2 _FogLUTParams; // x: -1/(end-start) y: end/(end-start)

		v2f vert(appdata i)
		{
			v2f o;

			float4 wpos = mul(unity_ObjectToWorld, i.vertex);

			o.pos = mul(UNITY_MATRIX_VP, wpos);
			o.uv.xy = TRANSFORM_TEX(i.uv, _MainTex) + frac(_MainTex_SpeedScroll.xy * _Time.y);
			o.uv.zw = float2(0, 0);

			o.light = mul(UNITY_MATRIX_I_V, unity_LightPosition[0]);
			o.wpos = wpos;
			o.normal = UnityObjectToWorldNormal(i.normal);

			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			fixed4 color = tex2D(_MainTex, i.uv.xy);
			fixed4 mask = tex2D(_MaskTex, i.uv.xy);
			float3 wpos = i.wpos;
			half3 n = normalize(i.normal);
			half3 l = normalize(i.light.xyz - wpos * i.light.w);
			half3 v = normalize(_WorldSpaceCameraPos.xyz - wpos);
			half3 r = reflect(-v, n);
			fixed3 light = _AmbientColor.rgb * _AmbientColor.a;
			light *= UNITY_LIGHTMODEL_AMBIENT;

			fixed3 lightColor = unity_LightColor[0].rgb;
			light += saturate(dot(n, l)) * _DiffuseColor.a * _DiffuseColor.rgb * lightColor;

			fixed3 specular = pow(max(dot(l, r), 0.0f), _Shininess * 128.0f) * _SpecularColor.a * _SpecularColor.rgb * lightColor;
			specular *= mask.g;
			light += specular;

			fixed illuminationIntensity = _IlluminationColor.a;
			illuminationIntensity *= mask.b;
			light = lerp(light, _IlluminationColor.rgb, illuminationIntensity);

			color.rgb *= light;

			float4 cameraLocalPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0f)) + _RimOffset;
			float4 cameraWorldPos = mul(unity_ObjectToWorld, cameraLocalPos);
			float3 v_rim = normalize(cameraWorldPos.xyz - wpos);
			fixed3 rim = smoothstep(_RimEnd, _RimEnd - _RimStart, dot(n, v_rim)) * _RimColor.a * _RimColor.rgb;

			color.rgb += rim;

			fixed4 fog = tex2D(_FogLUT, float2(wpos.z * _FogLUTParams.x + _FogLUTParams.y, 0.5f));
			color.rgb = lerp(color.rgb, fog.rgb, _Fog * fog.a);

			return color;
		}
		ENDCG
		}
	}
}