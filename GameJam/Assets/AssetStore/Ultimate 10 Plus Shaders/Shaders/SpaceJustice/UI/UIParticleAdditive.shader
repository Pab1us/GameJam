// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "IFly/UI/Particles/Additive" {
	Properties
	{
		_Color ("Tint", Color) = (1,1,1,1)
		_MainTex ("Particle Texture", 2D) = "white" {}

		_StencilComp ("Stencil Comparison", Float) = 8
	    _Stencil ("Stencil ID", Float) = 0
	    _StencilOp ("Stencil Operation", Float) = 0
	    _StencilWriteMask ("Stencil Write Mask", Float) = 255
	    _StencilReadMask ("Stencil Read Mask", Float) = 255

	    _ColorMask ("Color Mask", Float) = 15

	    [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
	}

	Category
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha One
		ColorMask [_ColorMask]

		SubShader {

			Stencil
	        {
	            Ref [_Stencil]
	            Comp [_StencilComp]
	            Pass [_StencilOp]
	            ReadMask [_StencilReadMask]
	            WriteMask [_StencilWriteMask]
	        }

			Pass
			{

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0

				#include "UnityCG.cginc"
				#include "UnityUI.cginc"

	            #pragma multi_compile __ UNITY_UI_ALPHACLIP

				sampler2D _MainTex;
				fixed4 _Color;
				fixed4 _TextureSampleAdd;
				float4 _ClipRect;

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

				v2f vert (appdata_t IN)
				{
					v2f v;
					v.worldPosition = IN.vertex;
					v.vertex = UnityObjectToClipPos(v.worldPosition);

					v.texcoord = IN.texcoord;

					#ifdef UNITY_HALF_TEXEL_OFFSET
					v.vertex.xy += (_ScreenParams.zw-1.0)*float2(-1,1);
					#endif

					v.color = IN.color * _Color;
					return v;
				}

#define _LEGACY_ON

				fixed4 frag (v2f IN) : SV_Target
				{
					half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

					color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);

					#ifdef UNITY_UI_ALPHACLIP
					clip (color.a - 0.001);
					#endif

					/*#if _LEGACY_ON
					bool p = fmod(16 * i.uv.x,2) < 1;
					bool q = fmod(16 * i.uv.y,2) > 1;
					bool c = p != q;
					color = lerp(color, float4(1, 0, 0, color.a), c);
					#endif*/

					return color;
				}
				ENDCG
			}
		}
	}
}