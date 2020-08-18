Shader "SpaceJustice/FX/Dissolve/Texture 2ChannelColorize Distort"
{
	Properties
	{
		[Header(MainTex)]

		_Brightness ("Brightness", Float) = 1
		_Opacity ("Opacity", Float) = 1
		_VertAlpha ("VertAlpha", Float) = 1

		[NoScaleOffset]
		_MainTex ("Main Texture", 2D) = "white" {}
		_MainTex_Tiling ("Tiling UV R  UV G", Vector) = (1,1,1,1)
		_MainTex_SpeedScroll ("Speed Scroll UV R  UV G", Vector) = (0,0,0,0)

		[Header(Color)]
		_MainColorR1 ("Main Color R 1", Color) = (1,1,1,1)
		_MainColorR2 ("Main Color R 2", Color) = (1,1,1,1)
		_MainColorG1 ("Main Color G 1", Color) = (1,1,1,1)
		_MainColorG2 ("Main Color G 2", Color) = (1,1,1,1)

		[Header(Distort)]
		_DistortTex ("Distort Texture", 2D) = "white" {}
		_DistortTex_SpeedScroll ("SpeedScroll", Vector) = (0,0,0,0)
		_PowerDistort ("PowerDistort ", Vector) = (0,0,0,0)
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
		}

		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				half4 uv : TEXCOORD0;
				half2 uv1 : TEXCOORD1;
				fixed4 color : COLOR0;
			};

			fixed _Brightness;
			fixed _Opacity;
			fixed _VertAlpha;

			sampler2D _MainTex;
			half4 _MainTex_Tiling;
			half4 _MainTex_SpeedScroll;
			fixed4 _MainColorR1, _MainColorR2;
			fixed4 _MainColorG1, _MainColorG2;

			sampler2D _DistortTex;
			float4 _DistortTex_ST;
			half4 _PowerDistort;
			half4 _DistortTex_SpeedScroll;

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.uv * _MainTex_Tiling.xy + frac(_MainTex_SpeedScroll.xy * _Time.y);//Main texture R
				o.uv.zw = v.uv * _MainTex_Tiling.zw + frac(_MainTex_SpeedScroll.zw * _Time.y);//Main texture G
				o.uv1 = TRANSFORM_TEX(v.uv, _DistortTex) + frac(_DistortTex_SpeedScroll.xy * _Time.y);//Distort

				o.color = v.color;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 distort = tex2D(_DistortTex, i.uv1).rg - 0.5f.xx;

				fixed texRmask = tex2D(_MainTex, i.uv.xy + distort * _PowerDistort.xy).r;
				fixed texGmask = tex2D(_MainTex, i.uv.zw + distort * _PowerDistort.zw).g;

				fixed4 colorizeR = lerp(_MainColorR2, _MainColorR1, texRmask);
				fixed4 colorizeG = lerp(_MainColorG2, _MainColorG1, texGmask);

				fixed4 colorOut = colorizeR + colorizeG * colorizeG.a;

				colorOut.rgb = colorOut.rgb * _Brightness * i.color.rgb;
				colorOut.a = (colorizeR.a + colorizeG.a) * lerp(1.0f, i.color.a, _VertAlpha) * _Opacity;

				return colorOut;
			}
			ENDCG
		}
	}
}
