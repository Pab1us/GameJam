Shader "SpaceJustice/FX/Translucent/Water"
{
	Properties
	{
		[Header(Caustic)]
		_MainTex ("Texture", 2D) = "white" {}

		_CausticScroll("Caustic Scroll", Vector) = (0,0,0,0)
		_CausticColor("Caustic Color", Color) = (1, 1, 1, 1)
		_WaterColor("Water Color", Color) = (1, 1, 1, 1)

		_CausticBright("Caustic Bright", Float) = 1

		[Space(10)]
		[Header(Rim Light)]
		[Toggle] _Rim("Enabled", Float) = 0.
		_RimColor("Rim Color", Color) = (1, 1, 1, 1)
		_RimStart("Rim Start", Range(0.0, 1.0)) = 1.0
		_RimEnd("Rim End", Range(0.0, 1.0)) = 1.0

		[Space(10)]
		[Header(Specular Light)]
		[Toggle] _Specular("Enabled", Float) = 0.
		_SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
		_SpecularSharp("Specular Sharpness", Range(0.01, 64.0)) = 2.5

		[Space(10)]
		[Header(Depth)]
		[Toggle] _LinearDepth("Linear Depth Enabled", Float) = 0.
		_DepthPoint("Depth Point", Float) = 0
		_DepthInvLength("Depth Inv Length", Range(0.01, 1.0)) = 1.0

		_RefractForce("Refract Force", Range(0.0, 1.0)) = 1.0

		[Space(10)]
		[Header(Ripple)]
		[Toggle] _Ripple("Enabled", Float) = 0.
		_RippleForce("Ripple Force", Vector) = (0,0,0,0)
		_RippleSpeed("Ripple Speed", Range(0.01, 2.0)) = 1.0
		_RippleSize("Ripple Size", Float) = 1.0
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
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			half3 normal : NORMAL;
			half4 uv : TEXCOORD0;
			float3 wpos : TEXCOORD1;
		#if !_LINEARDEPTH_ON
			fixed depth : TEXCOORD2;
		#if _SPECULAR_ON
			half4 lightDir : TEXCOORD3;
		#endif
		#elif _SPECULAR_ON
			half4 lightDir : TEXCOORD2;
		#endif
		};

		sampler2D _MainTex;
		half4 _MainTex_ST;

		half4 _CausticScroll;
		fixed4 _CausticColor;

		half _CausticBright;

	#if _RIM_ON
		fixed4 _RimColor;
		fixed _RimStart;
		fixed _RimEnd;
	#endif

	#if _SPECULAR_ON
		fixed4 _SpecularColor;
		half _SpecularSharp;
	#endif

		fixed4 _WaterColor;
		fixed _RefractForce;

	#if _RIPPLE_ON
		half3 _RippleForce;
		half _RippleSpeed;
		half _RippleSize;
	#endif

		float _DepthPoint;
		half _DepthInvLength;

		sampler2D _FogLUT;
		float2 _FogLUTParams;

		v2f vert(appdata i)
		{
			v2f o;

			float4 wPos = mul(unity_ObjectToWorld, i.vertex);

		#if _RIPPLE_ON
			float3 displace = (abs(frac(wPos.xyz * _RippleSize + _Time.yyy * _RippleSpeed) - 0.5f) * 2.0f - 0.5f) * 2.0f;

			o.pos = UnityObjectToClipPos(i.vertex + displace * _RippleForce);
		#else
			o.pos = UnityObjectToClipPos(i.vertex);
		#endif

			half2 uv = TRANSFORM_TEX(i.uv, _MainTex);

			o.uv.xy = uv + frac(_CausticScroll.xy * _Time.y);
			o.uv.zw = uv + frac(_CausticScroll.zw * _Time.y);

			o.normal = normalize(mul((half3x3)unity_ObjectToWorld, i.normal).xyz);

		#if !_LINEARDEPTH_ON
			o.depth = saturate(length(unity_ObjectToWorld[2].w - _DepthPoint - wPos.z) * _DepthInvLength);
		#endif

			o.wpos = wPos;

		#if _SPECULAR_ON
			o.lightDir = mul(UNITY_MATRIX_I_V, unity_LightPosition[0]);
		#endif

			return o;
		}

		fixed4 frag (v2f i) : SV_Target
		{
			fixed4 color;

			half2 refract = (abs(frac(i.wpos.xy * 0.5f) - 0.5f) * 2.0f - 0.5f) * 2.0f * _RefractForce;

			half caustic = tex2D(_MainTex, i.uv.xy + refract).x * tex2D(_MainTex, i.uv.zw + refract).x * _CausticBright;

		#if _LINEARDEPTH_ON
			color = caustic * _CausticColor + _WaterColor;//lerp(caustic * _CausticColor, _WaterColor, _DepthInvLength);
		#else
			color = lerp(caustic * _CausticColor, _WaterColor, i.depth);
		#endif

		#if _RIM_ON || _SPECULAR_ON
			half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.wpos.xyz);
		#endif

		#if _RIM_ON
			fixed rimLight = sfSmoothstepRight(_RimEnd, _RimEnd - _RimStart, saturate(dot(normalize(i.normal), viewDir)));

			fixed4 rim = rimLight * _RimColor;

			color += rim;
		#endif

		#if _SPECULAR_ON
			half3 lightDir = normalize(i.lightDir.xyz - i.wpos.xyz * i.lightDir.w);

			half3 reflectionDir = reflect(-viewDir, i.normal);

			fixed4 specularLight = sfSpecularCoeff(lightDir.xyz, reflectionDir, _SpecularSharp) * _SpecularColor;

			color += specularLight;
		#endif

			return saturate(color);
		}

		#pragma shader_feature _LINEARDEPTH_ON
		#pragma shader_feature _RIM_ON
		#pragma shader_feature _SPECULAR_ON
		#pragma shader_feature _RIPPLE_ON

		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}