﻿Shader "SpaceJustice/Background/BiplanarProjectionFog"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}

		[Header(Ambient)]
		_AmbientColor ("Color", Color) = (1., 1., 1., 1.)

		[Header(Direct Lighting)]
		_DiffuseColor ("Color", Color) = (1., 1., 1., 1.)
		_ShadowColor ("Shadow Color", Color) = (0., 0., 0., 0.)
		[Header(Hardness And Offset (XY direct ZW shadow))]
		_HardnessAndShift ("Parameters", Vector) = (1.,0.,1.,0.)

		[NoScaleOffset] _LightTex ("Light Texture", 2D) = "white" {}

		[Header(Mask)]
		[Toggle] _Mask("Enabled", Float) = 0.
		[NoScaleOffset] _MaskTex ("Texture  (R - rim G - specular)", 2D) = "white" {}

		[Header(Rim (R mask channel))]
		[Toggle] _Rim("Enabled", Float) = 0.
		_RimStart ("Start", Range(0., 1.)) = 1.
		_RimEnd ("End", Range(0., 1.)) = 1.
		_RimColor ("Color", Color) = (1., 1., 1., 1.)

		[Header(Specular (G mask channel))]
		[Toggle] _Specular("Enabled", Float) = 0.
		_Shininess ("Shininess", Range(0.01, 1.)) = 1.
		_SpecularColor ("Color", Color) = (1., 1., 1., 1.)

		[Header(Fog)]
		[Toggle] _Fog("Fog Enabled", Float) = 0.
		[NoScaleOffset] _NoiseTex ("Noise Texture", 2D) = "white" {}
		_Scale ("Scale", Vector) = (1., 1., 1., 1.)
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
			#pragma shader_feature _SPECULAR_ON
			#pragma shader_feature _RIM_ON
			#pragma shader_feature _FOG_ON
			#pragma multi_compile_instancing

			#include "UnityCG.cginc"
			#include "UnityInstancing.cginc"
			#include "../Standard_Functions.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				#if _VERTEXCOLOR_ON || _VERTEXCOLOR_MAP
				fixed4 color : COLOR;
				#endif
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0; // _MainTex _LightTex
				float4 light : TEXCOORD2;
				float3 wpos : TEXCOORD3;
				float3 normal : TEXCOORD4;
				#if _VERTEXCOLOR_ON || _VERTEXCOLOR_MAP
				fixed4 color : COLOR0;
				#endif
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _LightTex;
			float4 _LightTex_ST;
			sampler2D _MaskTex;

			fixed4 _AmbientColor;
			fixed4 _DiffuseColor;
			fixed4 _ShadowColor;
			half4 _HardnessAndShift;

			fixed _Shininess;
			fixed4 _SpecularColor;

			fixed _RimStart;
			fixed _RimEnd;
			fixed4 _RimColor;

			sampler2D _FogLUT;
			float2 _FogLUTParams; // x: -1/(end-start) y: end/(end-start)
			sampler2D _NoiseTex;
			float4 _Scale;

			fixed4 _rColor;
			fixed4 _gColor;
			fixed4 _bColor;
			fixed4 _aColor;

			v2f vert(appdata i)
			{
				UNITY_SETUP_INSTANCE_ID(i);
				v2f o;
				float4 wpos = mul(unity_ObjectToWorld, i.vertex);

				o.pos = UnityObjectToClipPos(i.vertex);//mul(UNITY_MATRIX_VP, wpos);

				o.uv.xy = TRANSFORM_TEX(i.uv, _MainTex);
				o.light = mul(UNITY_MATRIX_I_V, unity_LightPosition[0]);

				o.uv.zw = TRANSFORM_TEX(i.uv1, _LightTex);

				o.wpos = wpos.xyz;
				o.normal = UnityObjectToWorldNormal(i.normal);

				#if _VERTEXCOLOR_ON || _VERTEXCOLOR_MAP
				o.color = i.color;
				#endif
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv.xy);
				color.a = 1.0f;

				color.rgb *= 2.0 * tex2D(_LightTex, i.uv.zw).r;

				#if _VERTEXCOLOR_ON
				color *= i.color;
				#endif

				#if _VERTEXCOLOR_MAP
				fixed3 rColor = i.color.r * _rColor.rgb;
				fixed3 gColor = i.color.g * _gColor.rgb;
				fixed3 bColor = i.color.b * _bColor.rgb;
				fixed3 aColor = i.color.a * _aColor.rgb;

				color.rgb *= (rColor + gColor + bColor + aColor) * avoidDBZ(i.color.r + i.color.g + i.color.b + i.color.a);
				#endif

				#if _MASK_ON
				fixed4 mask = tex2D(_MaskTex, i.uv.xy);
				#endif

				half3 wpos = i.wpos;
				half3 n = normalize(i.normal);

				half3 l = normalize(i.light.xyz - wpos * i.light.w);

				#if _SPECULAR_ON || _RIM_ON
				half3 v = normalize(_WorldSpaceCameraPos.xyz - wpos);
				#endif

				#if _SPECULAR_ON
				half3 r = reflect(-v, n);
				#endif

				fixed3 light = _AmbientColor.rgb * _AmbientColor.a;
				light *= UNITY_LIGHTMODEL_AMBIENT;

				fixed3 lightColor = unity_LightColor[0].rgb * _DiffuseColor.a * _DiffuseColor.rgb;
				fixed3 shadowColor =  _ShadowColor.rgb * _ShadowColor.a;
				half3 ndl = dot(n, l);
				light += max(ndl * _HardnessAndShift.x + _HardnessAndShift.y, 0) * lightColor;
				light += max((1 - max(ndl * _HardnessAndShift.z + _HardnessAndShift.w, 0)), 0) * shadowColor;

				#if _SPECULAR_ON
				fixed3 specular = sfSpecularCoeff(l, r, _Shininess * 64.0f) * _SpecularColor.a * _SpecularColor.rgb * lightColor;
				#if _MASK_ON
				specular *= mask.g;
				#endif
				light += specular;
				#endif

				#if _ILLUMINATION_ON
				fixed illuminationIntensity = _IlluminationColor.a;
				#if _MASK_ON
				illuminationIntensity *= mask.b;
				#endif
				light = lerp(light, _IlluminationColor.rgb, illuminationIntensity);
				#endif

				color.rgb *= light;

				#if _RIM_ON
				fixed4 rimColor;
				#if _GLOBALRIMCOLOR_ON
				rimColor = GlobalRimColor;
				#else
				rimColor = _RimColor;
				#endif
				fixed3 rim = sfSmoothstepRight(_RimEnd, _RimEnd - _RimStart, dot(n, v)) * rimColor.a * rimColor.rgb;
				#if _MASK_ON
				rim *= mask.r;
				#endif
				color.rgb += rim;
				#endif

				#if _FOG_ON
				fixed4 fog = tex2D(_FogLUT, float2(wpos.z * _FogLUTParams.x + _FogLUTParams.y, 0.5));

				float3 scroll = float3(wpos.x * 0.25f + wpos.y * 0.25f + 0.5f, wpos.y * 0.25f + wpos.z * 0.25f + 0.5f, wpos.z * 0.25f*0 + wpos.x * 0.25f + 0.5f*0) + _Time.xyz * 0.1f*float3(1,1,0);

				fixed noiseX = tex2D(_NoiseTex, scroll.xy * _Scale.x).x;
				fixed noiseY = tex2D(_NoiseTex, scroll.yz * _Scale.y).x;

				color.rgb = lerp(color.rgb, lerp((noiseX.xxx + noiseY.xxx) * fog.rgb, fog.rgb, fog.a), fog.a);
				#endif

				return color;
			}

			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}