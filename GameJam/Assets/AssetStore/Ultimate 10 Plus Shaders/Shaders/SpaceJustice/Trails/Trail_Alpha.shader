Shader "SpaceJustice/Trails/Trail Alpha"
{
	Properties
	{
		_Color ("Multiplier", Color) = (1,1,1,1)
		_MainTex ("Sprite Texture", 2D) = "white" {}
		_Offset ("Z-Offset", Float) = 0
		[Toggle] _Alpha_Blend_Factor ("Alpha Blend Factor On", float) = 0.
	}

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
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Off

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature _ALPHA_BLEND_FACTOR_ON
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed4 color : COLOR0;
				#ifndef _ALPHA_BLEND_FACTOR_ON
				float2 uv : TEXCOORD0;
				#else
				float3 uv_alphaBlendFactor : TEXCOORD0;
				#endif
			};

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Offset;

			v2f vert(appdata i)
			{
				UNITY_SETUP_INSTANCE_ID(i);
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);

			#if defined(UNITY_REVERSED_Z)
				o.pos.z -= _Offset * 0.47;
			#else
				o.pos.z += _Offset;
			#endif

				o.color = i.color;

			#ifndef _ALPHA_BLEND_FACTOR_ON
				o.uv = TRANSFORM_TEX(i.uv, _MainTex);
			#else
				o.uv_alphaBlendFactor.xy = TRANSFORM_TEX(i.uv, _MainTex);
				o.color *= _Color;
				o.color.rgb *= o.color.a;
				o.uv_alphaBlendFactor.z = saturate(max(max(o.color.r, o.color.g), o.color.b) - 1.0f);

				fixed alphaFix = saturate(min(max(o.color.a, 0.5f), 0.6f) * 3.0f);

				o.color.a *= alphaFix;
			#endif

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv;

			#ifndef _ALPHA_BLEND_FACTOR_ON
				uv = i.uv;
			#else
				uv = i.uv_alphaBlendFactor.xy;
			#endif

				fixed4 col = tex2D(_MainTex, uv);

			#ifdef _ALPHA_BLEND_FACTOR_ON
				col.a *= 4.5f;

				col *= i.color;
				col.rgb *= saturate(col.a + i.uv_alphaBlendFactor.z) * 3.0f;
			#else
				col *= i.color;
			#endif

				return col;
			}
		ENDCG
		}
	}
}
