Shader "SpaceJustice/Unlit/OpaqueTexture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_Multiplier ("Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_Brightness ("Brightness", Range(0.0, 3.0)) = 1.0

		[Header(Fog)]
		[Toggle] _Fog("Fog Enabled", Float) = 0.
	}

	CGINCLUDE
    #include "UnityCG.cginc"
    #include "UnityInstancing.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		float4 uv_zb : TEXCOORD0;
		float4 mul : TEXCOORD1;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

UNITY_INSTANCING_BUFFER_START(Props)
	UNITY_DEFINE_INSTANCED_PROP(fixed4, _Multiplier)
	UNITY_DEFINE_INSTANCED_PROP(float, _Brightness)
UNITY_INSTANCING_BUFFER_END(Props)

	sampler2D _FogLUT;
	float2 _FogLUTParams;// x: -1/(end-start) y: end/(end-start)

	v2f vert(appdata i)
	{
		UNITY_SETUP_INSTANCE_ID(i);
		v2f o;

		o.pos = UnityObjectToClipPos(i.vertex);
		o.uv_zb = float4(TRANSFORM_TEX(i.uv, _MainTex),
			mul(unity_ObjectToWorld, i.vertex).z, UNITY_ACCESS_INSTANCED_PROP(Props, _Brightness));
		o.mul = UNITY_ACCESS_INSTANCED_PROP(Props, _Multiplier);

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.uv_zb.xy) * i.mul;
		col.rgb *= i.uv_zb.w;

		#if _FOG_ON
			fixed4 fog = tex2D(_FogLUT, float2(i.uv_zb.z * _FogLUTParams.x + _FogLUTParams.y, 0.5f));
			col.rgb = lerp(col.rgb, fog.rgb, fog.a);
		#endif

		return fixed4(col.rgb, 1.0f);
	}
	ENDCG

	SubShader
	{
		Tags
		{
			"Queue"="Geometry"
			"RenderType"="Opaque"
			"PreviewType"="Plane"
		}

		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma target 3.5
			#pragma multi_compile_instancing
			#pragma shader_feature _FOG_ON
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}

	SubShader
	{
		Tags
		{
			"Queue"="Geometry"
			"RenderType"="Opaque"
			"PreviewType"="Plane"
		}

		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma shader_feature _FOG_ON
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
