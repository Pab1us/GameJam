Shader "SpaceJustice/FX/Items/Fluctuation"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}

		[Header(Ambient)]
		_AmbientColor("Color", Color) = (1., 1., 1., 1.)

		[Header(Direct Lighting)]
		_DiffuseColor("Color", Color) = (1., 1., 1., 1.)
		_ShadowColor("Shadow Color", Color) = (0., 0., 0., 0.)
		[Header(Hardness And Offset (XY direct ZW shadow))]
		_HardnessAndShift("Parameters", Vector) = (1.,0.,1.,0.)

		[Header(Mask)]
		[Toggle] _Mask("Enabled", Float) = 0.
		[NoScaleOffset]_MaskTex ("Texture  (R - rim G - specular B - self illum)", 2D) = "white" {}

		[Header(Rim (R mask channel))]
		[Toggle]_Rim("Enabled", Float) = 0.
		_RimStart("Start", Range(0., 1.)) = 1.
		_RimEnd("End", Range(0., 1.)) = 1.
		_RimColor("Color", Color) = (1., 1., 1., 1.)

		[Header(Specular (G mask channel))]
		[Toggle]_Specular("Enabled", Float) = 0.
		_Shininess("Shininess", Range(0.01, 1.)) = 1.
		_SpecularColor("Color", Color) = (1., 1., 1., 1.)

		[Header(Self Illumination (B mask channel))]
		[Toggle]_Illumination ("Enabled", Float) = 0.
		_IlluminationColor("Color", Color) = (1., 1., 1., 1.)

		[Header(Fog)]
		[Toggle]_Fog("Fog Enabled", Float) = 0.

		[Header(Hit)]
		[Toggle]_Hit("Enabled", Float) = 0.
		[PerRendererData] _HitColorNew ("Hit Color", Color) = (0,0,0,0)

		[Header(Fluctuations)]
		_ForceDir("Force Direction XYZ", Vector) = (0.1, 0.0, 0.0, 0.0)
		_Speed("Speed", Float) = 1.0
		_Amplitude("Amplitude", Float) = 0.0
		_Frequency("Frequency", Float) = 1.0
		[PerRendererData] _PhaseOffset ("Phase Offset", Float) = 0.0

		[Toggle]_Delayed("Delayed", Float) = 0.
		_DelayLength("Delay Length", Range(-0.99, 0.99)) = 0.0

		[Toggle]_Circular("Circular", Float) = 0.
		_BasisDir("First Basis vector XYZ", Vector) = (1.0, 0.0, 0.0, 0.0)
		_MeshCenter("Mesh Center Offset XYZ", Vector) = (0.0, 0.0, 0.0, 0.0)

		[Toggle]_Pulsation("Pulsation", Float) = 0.
		_PulseAmplitude("Amplitude", Float) = 0.0
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	#include "UnityInstancing.cginc"
	#include "../../Standard_Functions.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 uv : TEXCOORD0;
		fixed4 color : COLOR;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;// _MainTex _LightTex
		float4 light : TEXCOORD1;
		float3 wpos : TEXCOORD2;
		half3 normal : TEXCOORD3;
		#if _HIT_ON
		half4 hit : COLOR0;
		#endif
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	sampler2D _MaskTex;

	fixed4 _AmbientColor;
	fixed4 _DiffuseColor;
	fixed4 _ShadowColor;
	half4 _HardnessAndShift;

	fixed _Shininess;
	fixed4 _SpecularColor;
	fixed4 _ReflectionColor;

	fixed _RimStart;
	fixed _RimEnd;
	fixed4 _RimColor;
	fixed4 GlobalRimColor;

	fixed4 _IlluminationColor;

	fixed4 _GrayScaleColor;

	sampler2D _FogLUT;
	float2 _FogLUTParams; // x: -1/(end-start) y: end/(end-start)

	half3 _ForceDir;
	half _Speed;
	half _Amplitude;
	half _Frequency;
	half _DelayLength;
	half3 _BasisDir;
	half3 _MeshCenter;
	half _PulseAmplitude;

UNITY_INSTANCING_BUFFER_START(Props)
	UNITY_DEFINE_INSTANCED_PROP(fixed4, _HitColorNew)
	UNITY_DEFINE_INSTANCED_PROP(float, _PhaseOffset)
UNITY_INSTANCING_BUFFER_END(Props)

	v2f vert(appdata i)
	{
		UNITY_SETUP_INSTANCE_ID(i);
		v2f o;

		fixed delay = 1.0f;

		float3 iVecFullSize = i.vertex.xyz - _MeshCenter;
		float iVecLength = length(iVecFullSize) + UNITY_ACCESS_INSTANCED_PROP(Props, _PhaseOffset);

	#if _DELAYED_ON
		delay = saturate(sin(_Time.y - iVecLength) + _DelayLength);
	#endif

		float wave = sin(_Time.y * _Speed - _Frequency * iVecLength);

		float3 dynamic;

	#if _CIRCULAR_ON
		float3 iVec = normalize(iVecFullSize);
		float3 jVec = normalize(_BasisDir);
		float3 kVec = normalize(cross(iVec, jVec));

		dynamic = kVec * wave * _Amplitude * delay * i.color.r;
	#else
		dynamic = normalize(_ForceDir) * wave * _Amplitude * delay * i.color.r;
	#endif

	#if _PULSATION_ON
		dynamic += i.normal * (wave + 1.0f) * 0.5f * _PulseAmplitude * delay * i.color.g;
	#endif

		float4 position = i.vertex;

		position.xyz += dynamic;

		o.pos = UnityObjectToClipPos(position);

		float4 wpos = mul(unity_ObjectToWorld, position);

		o.wpos = wpos.xyz;
		o.normal = UnityObjectToWorldNormal(i.normal);

		o.uv = TRANSFORM_TEX(i.uv, _MainTex);
		o.light = mul(UNITY_MATRIX_I_V, unity_LightPosition[0]);

	#if _HIT_ON
		o.hit = UNITY_ACCESS_INSTANCED_PROP(Props, _HitColorNew);
	#endif

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 color = tex2D(_MainTex, i.uv.xy);
		color.a = 1.0f;

		#if _MASK_ON
		fixed4 mask = tex2D(_MaskTex, i.uv.xy);
		#endif

		float3 wpos = i.wpos;
		half3 n = normalize(i.normal);
		half3 l = normalize(i.light.xyz - wpos * i.light.w);

		#if _SPECULAR_ON || _RIM_ON
		half3 v = normalize(_WorldSpaceCameraPos.xyz - wpos);
		#endif
		#if _SPECULAR_ON
		half3 r = reflect(-v, n);
		#endif

		fixed3 light = _AmbientColor.rgb * _AmbientColor.a;
		#if _AMBIENTREACT_ON
		light *= UNITY_LIGHTMODEL_AMBIENT;
		#endif

		fixed3 lightColor = unity_LightColor[0].rgb * _DiffuseColor.a * _DiffuseColor.rgb;
		fixed3 shadowColor = _ShadowColor.rgb * _ShadowColor.a;
		half ndl = dot(n, l);
		light += saturate(ndl * _HardnessAndShift.x + _HardnessAndShift.y) * lightColor;
		light += saturate(1.0f - max(ndl * _HardnessAndShift.z + _HardnessAndShift.w, 0.0f)) * shadowColor;

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
		fixed4 fog = tex2D(_FogLUT, float2(wpos.z * _FogLUTParams.x + _FogLUTParams.y, 0.5f));
		color.rgb = lerp(color.rgb, fog.rgb, fog.a);
		#endif

		#if _HIT_ON
		fixed3 blend = BlendHardLight(color.rgb, i.hit.rgb);
		color.rgb = lerp(color.rgb, blend, i.hit.a);
		#endif

		return color;
	}
	ENDCG

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
		}
		BlendOp Add
		Blend One Zero
		Cull Back
		ZWrite On

		Pass
		{
			CGPROGRAM
			#pragma shader_feature _MASK_ON
			#pragma shader_feature _SPECULAR_ON
			#pragma shader_feature _ILLUMINATION_ON
			#pragma shader_feature _RIM_ON
			#pragma shader_feature _FOG_ON
			#pragma shader_feature _HIT_ON
			#pragma shader_feature _DELAYED_ON
			#pragma shader_feature _CIRCULAR_ON
			#pragma shader_feature _PULSATION_ON
			#pragma multi_compile_instancing

			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}