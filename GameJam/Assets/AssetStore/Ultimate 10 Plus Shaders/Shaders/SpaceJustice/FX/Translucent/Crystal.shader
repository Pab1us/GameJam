Shader "SpaceJustice/FX/Translucent/Crystal"
{
	Properties
	{
		[Header(Diffuse)]
		[NoScaleOffset]
		_MainTex ("Texture", 2D) = "white" {}

		_DirectLightColor("Direct Light Color", Color) = (1, 1, 1, 1)

		[Header(Mask)]
		_TranslucencyTex ("Rim / Spec / Transl", 2D) = "white" {}

		[Header(Inner Layer)]
		_InnerTex ("Texture", 2D) = "white" {}
		_DeepColor("Deep Color", Color) = (1, 1, 1, 1)

		_RimColor("Rim Color", Color) = (1, 1, 1, 1)
		_RimStart("Rim Start", Range(0.0, 1.0)) = 1.0
		_RimEnd("Rim End", Range(0.0, 1.0)) = 1.0

		_SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
		_SpecularSharp("Specular Sharpness", Range(0.01, 64.0)) = 2.5

		_TranslucentColor("Translucent Color", Color) = (1, 1, 1, 1)
		_Transparency("Transparency", Range(0.0, 1.0)) = 1
		_DepthPoint("Depth Point", Vector) = (0,0,0,0)
		_DepthInvLength("Depth Length", Range(0.01, 10.0)) = 1.0
		_Depth("Deep Layer Length", Range(0.01, 1.0)) = 1.0
		_RefractForce ("Refract Force", Range(0.001, 1.0)) = 0.3
		_RefractColor ("Refract Color", Color) = (1, 1, 1, 1)
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Geometry"
			"IgnoreProjector" = "True"
			"RenderType" = "Opaque"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}

		BlendOp Add
		Blend One Zero
		ZWrite On
		Cull Back

		Pass
		{
		CGPROGRAM
		#include "UnityCG.cginc"
		#include "../../Standard_Functions.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			half3 normal : NORMAL;
			half2 uv : TEXCOORD0;
			fixed4 color : COLOR;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			half3 normal : NORMAL;
			half4 uv : TEXCOORD0;
			float3 wpos : TEXCOORD1;
			float3 lpos : TEXCOORD2;
			half3 viewDir : TEXCOORD3;
			fixed4 specularLight : COLOR0;
			fixed4 diffuseLight : COLOR1;
		};

		sampler2D _MainTex;

		fixed4 _DirectLightColor;

		sampler2D _TranslucencyTex;

		sampler2D _InnerTex;
		half4 _InnerTex_ST;

		fixed4 _DeepColor;
		fixed4 _RimColor;
		fixed _RimStart;
		fixed _RimEnd;
		fixed4 _SpecularColor;
		half _SpecularSharp;
		fixed4 _TranslucentColor;
		fixed _Transparency;
		float3 _DepthPoint;
		half _DepthInvLength;
		half _Depth;
		fixed _RefractForce;
		fixed4 _RefractColor;

		sampler2D _FogLUT;
		float2 _FogLUTParams;

		v2f vert(appdata i)
		{
			v2f o;

			o.pos = UnityObjectToClipPos(i.vertex);

			o.uv.xy = i.uv;
			o.uv.zw = TRANSFORM_TEX(i.uv, _InnerTex);

			o.wpos = mul(unity_ObjectToWorld, i.vertex);

			o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.wpos.xyz);

			o.lpos = float3(unity_ObjectToWorld[0].w, unity_ObjectToWorld[1].w, unity_ObjectToWorld[2].w) - _DepthPoint;

			o.normal = normalize(mul((half3x3)unity_ObjectToWorld, i.normal).xyz);

			half4 lightDir = mul(UNITY_MATRIX_I_V, unity_LightPosition[0]);
			lightDir.xyz = normalize(lightDir.xyz - o.wpos.xyz * lightDir.w);

			half3 reflectionDir = reflect(-o.viewDir, o.normal);

			fixed specularLight = sfSpecularCoeff(lightDir.xyz, reflectionDir, _SpecularSharp);

			fixed3 specularSpectrum;

			half3 refractedRayX = reflect(-o.viewDir, normalize(o.normal + frac(o.wpos.xyz * _RefractForce / 5.0f) * 0.4f));
			half3 refractedRayY = reflect(-o.viewDir, normalize(o.normal + frac(o.wpos.xyz * _RefractForce / 8.0f) * 0.4f));
			half3 refractedRayZ = reflect(-o.viewDir, normalize(o.normal + frac(o.wpos.xyz * _RefractForce / 11.0f) * 0.4f));

			specularSpectrum.x = saturate(dot(-lightDir.xyz, refractedRayX));
			specularSpectrum.y = saturate(dot(-lightDir.xyz, refractedRayY));
			specularSpectrum.z = saturate(dot(-lightDir.xyz, refractedRayZ));

			fixed specularShadow = 1.0f - sfSpecularCoeff(-o.viewDir, normalize(refractedRayX + o.normal * 0.2f), _SpecularSharp) * 2.0f;

			o.specularLight.xyz = specularLight * _SpecularColor.xyz + specularSpectrum * _RefractColor.xyz;
			o.specularLight.w = specularShadow;

			o.diffuseLight = saturate(dot(lightDir.xyz, o.normal)) * _DirectLightColor;

			return o;
		}

		fixed4 frag (v2f i) : SV_Target
		{
			fixed3 color;

			fixed4 diffuse = tex2D(_MainTex, i.uv.xy).xxxw;
			fixed4 translucency = tex2D(_TranslucencyTex, i.uv.xy);

			fixed deepLayer = tex2D(_InnerTex, i.uv.zw).x;

			fixed backLight = saturate(length(i.wpos - i.lpos + deepLayer * i.normal * _Depth) * _DepthInvLength);

			backLight = (1.0f - backLight) * translucency.z * _TranslucentColor.w;

			fixed rimLight = sfSmoothstepRight(_RimEnd, _RimEnd - _RimStart, saturate(dot(normalize(i.normal), i.viewDir)));

			fixed invRim = 1.0f - rimLight;

			fixed invTranslucency = 1.0f - translucency.z;

			fixed3 specularLight = i.specularLight.xyz * invRim;
			fixed specularShadow = saturate(i.specularLight.w + invTranslucency);

			fixed3 rim = rimLight * translucency.x * _RimColor.xyz;

			fixed3 deepColor = lerp(_DeepColor.xyz, 1.0f.xxx, backLight) * specularShadow;

			color = lerp(deepColor.xyz, diffuse.xyz * i.diffuseLight.xyz, saturate(invTranslucency + _Transparency));

			color += specularLight * translucency.y + rim + backLight * _TranslucentColor.xyz;

		#if _FOG_ON
			fixed4 fog = tex2D(_FogLUT, float2(wpos.z * _FogLUTParams.x + _FogLUTParams.y, 0.5f));
			color.rgb = lerp(color.rgb, fog.rgb, fog.a);
		#endif

			return fixed4(saturate(color), 1.0f);
		}

		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}
