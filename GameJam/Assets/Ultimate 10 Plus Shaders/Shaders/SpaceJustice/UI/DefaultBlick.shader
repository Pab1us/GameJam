// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "IFly/UI/DefaultBlick"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)

		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0

		_BlickThickness ("Blick Thickness", Range(0, 1)) = 0.5
		_BlickSpeed ("Blick Speed", Float) = 8

		[Toggle] _SecondVersion("Enable Second Version", Float) = 0.
		_BlickDirectionX ("Blick DirectionX", Range(-1.0, 1.0)) = 1.0
		_BlickDirectionY ("Blick DirectionY", Range(-1.0, 1.0)) = 0.0
		_BlickDuration ("Blick Duration", Float) = 1.
		_BlickPauseDuration ("Blick Pause Duration", Float) = 0.
		_BlickColor ("Blick Color", Color) = (1.0, 1.0, 1.0, 1.0)
		[Toggle] _ManualTime("Manual Time Control", Float) = 0.
		_BlickMoment ("Blick Moment", Range(0.0, 1.0)) = 0.
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

		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma shader_feature _SECONDVERSION_ON
			#pragma shader_feature _MANUALTIME_ON
			#pragma multi_compile __ UNITY_UI_ALPHACLIP

			struct appdata_t
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
			};

			sampler2D _MainTex;
			fixed4 _Color;
			fixed4 _TextureSampleAdd;
			float4 _ClipRect;
			half _BlickThickness;
			half _BlickSpeed;
			#if _SECONDVERSION_ON
			half _BlickDirectionX;
			half _BlickDirectionY;
			half _BlickDuration;
			half _BlickPauseDuration;
			fixed4 _BlickColor;
			#endif
			#if _MANUALTIME_ON
			half _BlickMoment;
			#endif

			v2f vert(appdata_t IN)
			{
				v2f OUT;

				OUT.worldPosition = IN.vertex;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

				OUT.texcoord = IN.texcoord;

				#ifdef UNITY_HALF_TEXEL_OFFSET
				OUT.vertex.xy += (_ScreenParams.zw - 1.0f) * float2(-1.0f, 1.0f);
				#endif

				OUT.color = IN.color * _Color;

				return OUT;
			}

			inline half2 planeRotation(half2 direction, half2 XY)
			{
				return half2(XY.x * direction.x + XY.y * direction.y, -XY.x * direction.y + XY.y * direction.x);
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

				color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);

				#ifdef UNITY_UI_ALPHACLIP
				clip(color.a - 0.001f);
				#endif

				#if _SECONDVERSION_ON
				half divider = 1.0f;
				#else
				half divider = 2.0f;
				#endif

				half x = (IN.worldPosition.x + _ScreenParams[0] / divider) / _ScreenParams[0];
				half y = (IN.worldPosition.y + _ScreenParams[1] / divider) / _ScreenParams[1];

				#if _SECONDVERSION_ON
				float fullCycleDuration = _BlickDuration + _BlickPauseDuration;
				float wavePauseMomentDuration = _BlickPauseDuration / fullCycleDuration;
				float waveEffectMomentDuration = _BlickDuration / fullCycleDuration;

				half timer;

				#ifdef _MANUALTIME_ON
				timer = _BlickMoment;
				#else
				timer = frac(_Time.y * _BlickSpeed);
				#endif

				half2 direction = normalize(half2(_BlickDirectionX, _BlickDirectionY));

				float2 uv = planeRotation(direction, half2(x, y) - 0.5f.xx) + 0.5f.xx;

				fixed3 blickColor = _BlickColor.rgb * _BlickColor.a;

				color.rgb += saturate(1.0f - abs(uv.x - saturate(timer - wavePauseMomentDuration) * 3.0f / waveEffectMomentDuration + 1.0f) * 2.0f / _BlickThickness) * blickColor;
				#else

				half t;

				#ifdef _MANUALTIME_ON
				t = _BlickMoment * 2.0f - 1.0f;
				#else
				t = _SinTime[3];
				#endif

				half f = (1.0f + x - t * _BlickSpeed);

				if (_CosTime[3] > 0.0f)
				{
					if (y >= f && y <= f + _BlickThickness)
						color /= 1.0f - (f - y) - _BlickThickness;
					if (y >= f - _BlickThickness && y <= f)
						color /= 1.0f + (f - y) - _BlickThickness;
				}
				#endif

				return color;
			}
		ENDCG
		}
	}
}
