Shader "SpaceJustice/FX/Translucent/Ice"
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
		_DepthInvLength("Depth Length", Range(0.01, 1.0)) = 1.0
		_Depth("Deep Layer Length", Range(0.0, 10.0)) = 1.0
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}

		BlendOp Add
		Blend SrcAlpha OneMinusSrcAlpha
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
			half backLight : TEXCOORD2;
			half3 viewDir : TEXCOORD3;
			fixed4 light : COLOR;
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

			float3 wpoint = float3(unity_ObjectToWorld[0].w, unity_ObjectToWorld[1].w, unity_ObjectToWorld[2].w) - _DepthPoint;

			o.normal = normalize(mul((half3x3)unity_ObjectToWorld, i.normal).xyz);

			o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.wpos.xyz);

			half4 lightDir = mul(UNITY_MATRIX_I_V, unity_LightPosition[0]);
			lightDir.xyz = normalize(lightDir.xyz - o.wpos.xyz * lightDir.w);

			half3 reflectionDir = reflect(-o.viewDir, o.normal);

			fixed specularLight = sfSpecularCoeff(lightDir.xyz, reflectionDir, _SpecularSharp);
			fixed diffuseLight = saturate(dot(lightDir.xyz, o.normal));

			o.backLight = length(o.wpos.xyz - wpoint);

			o.light = fixed4(saturate(fixed3(1.0f, specularLight, diffuseLight)), 1.0f);

			return o;
		}

		fixed4 frag (v2f i) : SV_Target
		{
			fixed3 color;

			fixed4 diffuse = tex2D(_MainTex, i.uv.xy);
			fixed4 translucency = tex2D(_TranslucencyTex, i.uv.xy);

			fixed deepLayer = tex2D(_InnerTex, i.uv.zw + frac(i.wpos.xy * 0.1f) * 0.05f).xyz;

			fixed backLight = saturate((i.backLight + deepLayer * _Depth) * _DepthInvLength);

			backLight = (1.0f - backLight) * translucency.z * _TranslucentColor.w;

			half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.wpos.xyz);

			fixed rimLight = sfSmoothstepRight(_RimEnd, _RimEnd - _RimStart, saturate(dot(normalize(i.normal), i.viewDir)));

			fixed invRim = 1.0f - rimLight;

			fixed invTranslucency = 1.0f - translucency.z;

			fixed3 specularLight = i.light.y * invRim * 2.0f * _SpecularColor.xyz;

			fixed3 diffuseLight = i.light.z * _DirectLightColor.xyz;

			fixed3 rim = rimLight * translucency.x * _RimColor.xyz;

			fixed3 deepColor = lerp(_DeepColor.xyz, 1.0f.xxx, backLight);

			color = lerp(deepColor.xyz, diffuse.xyz * diffuseLight, saturate(invTranslucency + _Transparency));

			color += specularLight * translucency.y + rim + backLight * _TranslucentColor.xyz;

			fixed transparency = saturate(_Transparency + (1.0f - deepLayer) * 0.3f + invTranslucency + rimLight + (1.0f - backLight) * 0.3f + specularLight);

			return fixed4(color, transparency);
		}

		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}
