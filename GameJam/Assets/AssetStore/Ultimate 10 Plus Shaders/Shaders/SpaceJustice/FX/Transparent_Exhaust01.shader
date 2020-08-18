Shader "SpaceJustice/FX/Transparent_Exhaust01"
{
	Properties
	{
		[PerRendererData] _AlphaFactor ("Alpha Factor", Float) = 1.
		[NoScaleOffset]
		_MainTex ("Texture", 2D) = "white" {}
		_Amp ("Amplitude", Float) = 0.
		_Freq ("Frequency", Float) = 1.

		_Multiplier ("Color multiplier", Color) = (1., 1., 1., 1.)
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		fixed4 color : COLOR;
		float2 uv : TEXCOORD0;
		float3 normal : NORMAL;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		fixed4 color : COLOR0;
		float2 uv : TEXCOORD0;
	};

	sampler2D _MainTex;

	fixed4 _Multiplier;

	UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_DEFINE_INSTANCED_PROP(float, _Amp)
		UNITY_DEFINE_INSTANCED_PROP(float, _Freq)
		UNITY_DEFINE_INSTANCED_PROP(float, _AlphaFactor)
	UNITY_INSTANCING_BUFFER_END(Props)

	v2f vert(appdata i)
	{
		UNITY_SETUP_INSTANCE_ID(i);
		v2f o;
		float4 worldPos = mul(unity_ObjectToWorld, i.vertex);
		half3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
		half3 worldNormal = UnityObjectToWorldNormal(i.normal);

		float amp = UNITY_ACCESS_INSTANCED_PROP(Props, _Amp);
		float freq = UNITY_ACCESS_INSTANCED_PROP(Props, _Freq);
		float alphaFactor = UNITY_ACCESS_INSTANCED_PROP(Props, _AlphaFactor);

		i.vertex.xyz += abs(frac(_Time.a * freq) * 2.0f - 1.0f) * amp * (i.color.rgb - 0.5f) * 2.0f;

		o.pos = UnityObjectToClipPos(i.vertex);

		fixed falloff = smoothstep(0.0f, 1.0f, abs(dot(worldNormal, worldViewDir)));

		o.color = falloff * alphaFactor * _Multiplier;
		o.uv = i.uv;

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		return tex2D(_MainTex, i.uv) * i.color;
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

		Blend One One
		Cull Off
		ZWrite Off

		Pass
		{
		CGPROGRAM
		#pragma multi_compile_instancing
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}
