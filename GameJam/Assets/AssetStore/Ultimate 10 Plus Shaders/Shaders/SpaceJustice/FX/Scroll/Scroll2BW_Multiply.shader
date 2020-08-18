Shader "SpaceJustice/FX/Scroll/Scroll2BW Multiply"
{
	Properties
	{
		_Tex1_ColorWhiteTint("Color White Tint", Color) = (1,1,1,1)
		_Tex1_ColorBlackTint("Color Black Tint", Color) = (0,0,0,0)

		[Toggle] _Glow("Glowing Enable", Float) = 0.0
		_GlowSpeed("Glow Speed", Float) = 0.0
		_GlowIntensity("Glow Intensity", Float) = 1.0
		_GlowAmplitude("Glow Amplitude", Float) = 0.0

		[Space(10)]
		[Header(Texture1)]
		[NoScaleOffset]
		_Tex1("Texture1 BW", 2D) = "white" {}
		_Tex1_TilingScroll("Tiling Scroll", Vector) = (1,1,0,0)

		[Space(10)]
		[Header(Texture2)]
		[NoScaleOffset]
		_Tex2 ("Texture2 BW", 2D) = "white" {}
		_Tex2_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)

		[Space(10)]
		[Header(Blending)]
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Operation", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFactor ("Source", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFactor ("Destination", Float) = 10
		[Header(Alpha Blending)]
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOpA ("Operation", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFactorA ("Source", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFactorA ("Destination", Float) = 10
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		BlendOp [_BlendOp], [_BlendOpA]
		Blend [_SrcBlendFactor] [_DstBlendFactor], [_SrcBlendFactorA] [_DstBlendFactorA]
		ZWrite Off
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma shader_feature _GLOW_ON
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "..\..\Standard_Functions.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half4 uv : TEXCOORD0;
			#if _GLOW_ON
				half4 color : COLOR;
			#else
				fixed4 color : COLOR;
			#endif
			};

			fixed4 _Tex1_ColorWhiteTint;
			fixed4 _Tex1_ColorBlackTint;

			half _GlowSpeed;
			half _GlowIntensity;
			half _GlowAmplitude;

			sampler2D _Tex1;
			half4 _Tex1_TilingScroll;

			sampler2D _Tex2;
			half4 _Tex2_TilingScroll;

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.uv * _Tex1_TilingScroll.xy + frac(_Tex1_TilingScroll.zw * _Time.y);
				o.uv.zw = v.uv * _Tex2_TilingScroll.xy + frac(_Tex2_TilingScroll.zw * _Time.y);

				o.color = v.color;

			#if _GLOW_ON
				o.color *= _GlowIntensity - _GlowAmplitude * sfLWave(_Time.y * _GlowSpeed);
			#endif

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col;

				fixed tex1_BW = tex2D(_Tex1, i.uv.xy).r;
				fixed tex2_BW = tex2D(_Tex2, i.uv.zw).r;

				fixed texMixed = tex1_BW * tex2_BW;

				col = lerp(_Tex1_ColorBlackTint, _Tex1_ColorWhiteTint, texMixed) * i.color;

				return col;
			}
			ENDCG
		}
	}
}
