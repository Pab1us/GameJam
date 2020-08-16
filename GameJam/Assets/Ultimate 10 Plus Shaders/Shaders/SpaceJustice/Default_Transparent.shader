Shader "SpaceJustice/Default Transparent (Legacy)"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}

		[Toggle] _VertexColor ("Vertex Color", Float) = 0.

		[Space(10)]
		[Header(Ambient lightning)]
		[Toggle] _AmbReact("Ambient reaction", Float) = 1.
		_Ambient ("Intensity", Range(0., 2.)) = 0.1
		_AmbColor ("Color", Color) = (1., 1., 1., 1.)

		[Header(Direct lightning)]
		_Diffuse ("Intensity", Range(0., 2.)) = 1.
		_DifColor ("Color", Color) = (1., 1., 1., 1.)

		[Space(40)]

		[NoScaleOffset] _MaskTex ("Mask Texture  (R - vert specular,  G - reflection, B - rim light, A - self illumination)", 2D) = "white" {}

		[Header(Specular Vertex  (R mask channel))]
		[Toggle] _SpecVert("Enabled", Float) = 0.
		_Shininess ("Shininess", Range(0.1, 10)) = 1.
		_SpecColor ("Specular color", Color) = (1., 1., 1., 1.)

		[Space(10)]
		[Header(Reflection Fake (G mask channel))]
		[Toggle] _Refl("Enabled", Float) = 0.
		_ReflColor ("Color", Color) = (1., 1., 1., 1.)
		_ReflectTex ("Reflection Texture", 2D) = "black" {}
		_ReflectScale ("Reflection Distance", Range(0, 1)) = 0.1

		[Space(10)]
		[Header(Rim Light  (B mask channel))]
		[Toggle] _Cont("Enabled", Float) = 0.
		_ContColor ("Color", Color) = (1., 1., 1., 1.)
		[NoScaleOffset] _ContourTex ("Contour Texture", 2D) = "black" {}

		[Space(10)]
		[Header(Self Illumination (A mask channel))]
		[Toggle] _Illum("Enabled", Float) = 0.
		_IllumColor ("Color", Color) = (1., 1., 1., 1.)

		[Header(Transparency)]
		_Transparency ("Transparency", Range(0., 1.)) = 1.

		[Space(10)]
		[Header(Hit)]
		[Toggle] _Hit("Enabled", Float) = 0.
		[PerRendererData] _HitColorNew ("Hit Color", Color) = (0,0,0,0)

		[Header(Fog)]
		[Toggle] _Fog("Fog Enabled", Float) = 0.

		[Header(Z Buffer)]
		[Toggle] _ZWrite ("ZWrite", Float) = 1
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 4
	}

	CGINCLUDE
	#pragma shader_feature _VERTEXCOLOR_ON
	#pragma shader_feature _HIT_ON
	#pragma shader_feature _FOG_ON
	#pragma shader_feature _SPECVERT_ON
	#pragma shader_feature _REFL_ON
	#pragma shader_feature _CONT_ON
	#pragma shader_feature _ILLUM_ON
	#pragma shader_feature _AMBREACT_ON

	#define _LEGACY_ON 1

	#include "UnityCG.cginc"

	#define BlendHardLight(base, blend) (blend < 0.5 ? (2.0 * blend * base) : (1.0 - 2.0 * (1.0 - blend) * (1.0 - base)))

	struct appdata {
		float4 vertex : POSITION;
		float4 tangent : TANGENT;
		float3 normal : NORMAL;
		float4 texcoord : TEXCOORD0;
		#if _VERTEXCOLOR_ON
		fixed4 color : COLOR;
		#endif
	};

	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		fixed4 light : COLOR0;
		#if _SPECVERT_ON
		fixed4 specular : COLOR1;
		#endif
		#if _REFL_ON
		float2 uvRefl : TEXCOORD1;
		#endif
		#if _CONT_ON
		float2 uvCont : TEXCOORD2;
		#endif
		#if _FOG_ON
		float fogCoord : TEXCOORD3;// a: worldPos.z
		#endif
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	sampler2D _MaskTex;

	//Ambient
	fixed _Ambient;
	fixed4 _AmbColor;

	// Diffuse
	fixed _Diffuse;
	fixed4 _DifColor;

	//Specular
	fixed _Shininess;
	fixed4 _SpecColor;

	//Reflection Fake
	sampler2D _ReflectTex;
	float4 _ReflectTex_ST;
	fixed4 _ReflColor;
	half _ReflectScale;

	//Specular Fake (Rim Light)
	sampler2D _ContourTex;
	fixed4 _ContColor;

	// Illumination
	fixed4 _IllumColor;

	// Transparency
	fixed _Transparency;

	// Hit
	fixed4 _HitColorNew;
	half _HitRatio;

	//Fog
	sampler2D _FogLUT;
	float2 _FogLUTParams; // x: -1/(end-start) y: end/(end-start)

	v2f vert(appdata v)
	{
		v2f o;

		float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
		half4 worldLightPos = mul(unity_LightPosition[0], UNITY_MATRIX_I_V);
		half3 worldLightDir = normalize(worldLightPos.xyz);
		half3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
		half3 worldNormal = UnityObjectToWorldNormal(v.normal);
		#if _REFL_ON || _CONT_ON
		half3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
		half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
		half3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
		half3 ts0 = half3(worldTangent.x, worldBinormal.x, worldNormal.x);
		half3 ts1 = half3(worldTangent.y, worldBinormal.y, worldNormal.y);
		half3 ts2 = half3(worldTangent.z, worldBinormal.z, worldNormal.z);
		half3 tanViewDir = ts0.xyz * worldViewDir.x + ts1.xyz * worldViewDir.y + ts2.xyz * worldViewDir.z;
		#endif

		o.pos = mul(UNITY_MATRIX_VP, worldPos);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

		// ambient lighting
		fixed4 amb = _Ambient * _AmbColor;
		#if _AMBREACT_ON
 		amb *= UNITY_LIGHTMODEL_AMBIENT;
		#endif

		fixed4 lightColor = unity_LightColor[0];
		// diffuse lighting
		fixed NdotL = saturate(dot(worldNormal, worldLightDir) * lightColor);
		fixed4 dif = NdotL * _Diffuse * lightColor * _DifColor;

		o.light = dif + amb;
		#if _VERTEXCOLOR_ON
		o.light *= v.color;
		#endif

		#if _SPECVERT_ON
		// specular lighting
		half3 refl = reflect(-worldLightDir, worldNormal);
		half RdotV = max(0.0f, dot(refl, worldViewDir));
		fixed4 spec = pow(RdotV, _Shininess) * lightColor * ceil(NdotL) * _SpecColor;
		o.specular = spec;
		#endif

		#if _REFL_ON
		half3 norm = half3(0.0f, 0.0f, 1.0f);
		half scale = (1.0f - _ReflectScale);
		half coeff = dot(abs(normalize(tanViewDir)),norm);
		half3 offset = 0.5f *(tanViewDir + norm) * scale * (2.0f - coeff);
		o.uvRefl = TRANSFORM_TEX(v.texcoord, _ReflectTex) * _ReflectScale + 0.5f * scale - offset.xy;
		#endif

		#if _CONT_ON
		o.uvCont = tanViewDir.xy * 0.5f + 0.5f;
		#endif

		#if _FOG_ON
		o.fogCoord = worldPos.z;
		#endif
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.uv);
		fixed4 mask = tex2D(_MaskTex, i.uv);

		fixed3 col_ambient = col.rgb * i.light;

		#if _SPECVERT_ON
		col_ambient += i.specular * mask.r;
		#endif

		#if _REFL_ON
		fixed4 refl = tex2D(_ReflectTex, i.uvRefl);
		col_ambient += refl * mask.g * _ReflColor;
		#endif

		#if _CONT_ON
		fixed cont = tex2D(_ContourTex, i.uvCont);
		col_ambient += cont * mask.b * _ContColor;
		#endif

		#if _ILLUM_ON
		col_ambient = lerp(col_ambient, col.rgb * _IllumColor, mask.a);
		#endif

		col.rgb = col_ambient;
		col.a *= _Transparency;

		#if _HIT_ON
		fixed3 blend = BlendHardLight(col.rgb, _HitColorNew.rgb);
		col.rgb = lerp(col.rgb, blend, _HitColorNew.a);
		#endif

		#if _FOG_ON
		fixed4 fogColor = tex2D(_FogLUT, float2(i.fogCoord * _FogLUTParams.x + _FogLUTParams.y, 0.5f));
		col.rgb = lerp(col.rgb, fogColor.rgb, fogColor.a);
		#endif

		/*#if _LEGACY_ON
		bool p = fmod(16 * i.uv.x,2) < 1;
		bool q = fmod(16 * i.uv.y,2) > 1;
		bool c = p != q;
		col = lerp(col, float4(1, 0, 0, col.a), c);
		#endif*/

		return col;
	}
	ENDCG

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
			"IgnoreProjector" = "true"
		}
		Pass
		{
			Tags { "LightMode"="Vertex" }
			BlendOp Add
			Blend SrcAlpha OneMinusSrcAlpha, Zero One
			Cull Back
			ZWrite On
			ZTest LEqual
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}