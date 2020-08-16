Shader "SpaceJustice/FX/Contours/BWTextureContour"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BaseColor ("Base Color", Color) = (1., 1., 1., 1.)
		_Brightness ("Brightness", Range(0., 5.)) = 1.

		[Space(10)]
		[Header(Contour)]
		_ContourColor ("Contour Color", Color) = (1., 0., 0., 1.)
		_CoreColor ("Core Color", Color) = (1., 1., 1., 1.)
		_Width ("Contour Width", Range(0., 1.)) = 0.2
		_Hardness ("Contour Hardness", Range(0., 1.)) = 0.2
		_CoreWidth ("Core Width", Range(0., 1.)) = 0.1
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		BlendOp Add
		Blend One OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _BaseColor;
			half _Brightness;
			fixed4 _ContourColor;
			fixed4 _CoreColor;
			fixed _Width;
			fixed _Hardness;
			fixed _CoreWidth;

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed grad = tex2D(_MainTex, i.uv).r;

				fixed curve = saturate((1.0f - grad / _Width) * (1.0f + _Hardness * 5.0f) + _Hardness);
				fixed core = saturate(grad * (1.0f + _CoreWidth) - 1.0f);

				fixed4 color = lerp(_BaseColor, _ContourColor, curve) * grad;
				color.rgb = lerp(color.rgb, _CoreColor.rgb, core) * _Brightness * i.color.a;
				color.a = grad;

				return color * i.color;
			}
			ENDCG
		}
	}
}
