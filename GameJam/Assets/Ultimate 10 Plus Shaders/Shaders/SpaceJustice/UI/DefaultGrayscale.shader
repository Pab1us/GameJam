Shader "SpaceJustice/UI/DefaultGrayscale"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[Toggle] _Add_Sepia ("Add Sepia", Float) = 0
		_Sepia("Sepia", Color) = (1, 1, 0.9, 0.5)
		_Colorfulness("Colorfulness", Range(0, 1)) = 1.0
		_Blackness("Blackness", Range(0, 1)) = 0.0

		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
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

			#pragma shader_feature _ADD_SEPIA_ON
			#pragma multi_compile __ UNITY_UI_ALPHACLIP

			struct appdata_t
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
			};

			fixed4 _Color;
			fixed4 _Sepia;
			fixed4 _TextureSampleAdd;
			float4 _ClipRect;
			fixed _Colorfulness;
			fixed _Blackness;

			v2f vert(appdata_t i)
			{
				v2f o;
				o.worldPosition = i.vertex;
				o.vertex = UnityObjectToClipPos(o.worldPosition);

				o.texcoord = i.texcoord;

			#ifdef UNITY_HALF_TEXEL_OFFSET
				o.vertex.xy += (_ScreenParams.zw - 1.0f) * float2(-1.0f, 1.0f);
			#endif

				o.color = i.color * _Color;
				return o;
			}

			sampler2D _MainTex;

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 color = (tex2D(_MainTex, i.texcoord) + _TextureSampleAdd) * i.color;

				color.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);

			#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001f);
			#endif

				fixed gray = dot(color.rgb, fixed3(0.299f, 0.587f, 0.114f));
				gray += (1.0f - gray) * _Blackness;

			#ifdef _ADD_SEPIA_ON
				color.rgb = lerp(lerp(gray.xxx, gray * _Sepia * 2.0f, _Sepia.a), color.rgb, _Colorfulness);
			#else
				color.rgb = lerp(gray.xxx, color.rgb, _Colorfulness);
			#endif

				return color;
			}
		ENDCG
		}
	}
}
