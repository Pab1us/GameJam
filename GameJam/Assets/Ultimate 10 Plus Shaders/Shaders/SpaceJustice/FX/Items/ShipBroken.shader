Shader "SpaceJustice/FX/Items/ShipBroken"
{
	Properties
	{
		[Header(Background)]
		_Back_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_Back_ColorBlackTint("Color black tint",Color) = (0,0,0,0)
		[NoScaleOffset]
		_TexBack ("Texture Back RG", 2D) = "white" {}
		_TexBack_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)

		[Header(Foreground)]
		_Foregr_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_Foregr_ColorBlackTint("Color black tint",Color) = (0,0,0,0)
		[NoScaleOffset]
		_TexForegr ("Texture Foregr R", 2D) = "white" {}
		_TexForegr_TilingScroll ("Tiling Scroll ", Vector) = (1,1,0,0)
		[Space(10)]
		_TexControl ("Brgh LinBack LinForegr", Vector) = (1, 1, 1, 1)
	}
	SubShader
	{
		Tags
		{
				"Queue"="Geometry"
				"RenderType"="Opaque"
		}

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
				float4 uv : TEXCOORD0;//xy Back    zw Back invers
				float2 uv1 : TEXCOORD1;//Foregr
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
			};

			fixed _Brighness;
			//color
			sampler2D _TexBack, _TexForegr;
			half4 _TexBack_TilingScroll, _TexForegr_TilingScroll;
			fixed4 _Back_ColorWhiteTint, _Back_ColorBlackTint;
			fixed4 _Foregr_ColorWhiteTint, _Foregr_ColorBlackTint;
			half3 _TexControl;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.uv * _TexBack_TilingScroll.xy + frac(_TexBack_TilingScroll.zw * _Time.y);
				o.uv.zw = v.uv * _TexBack_TilingScroll.xy + frac(-_TexBack_TilingScroll.zw * _Time.y);
				o.uv1 = v.uv * _TexForegr_TilingScroll.xy + frac(_TexForegr_TilingScroll.zw * _Time.y);

				o.color = v.color;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//color
				fixed4 col;
				fixed4 back = lerp(_Back_ColorBlackTint, _Back_ColorWhiteTint, pow(tex2D(_TexBack, i.uv.xy).r + tex2D(_TexBack, i.uv.zw).g, _TexControl.y));
				fixed4 foregr = lerp(_Foregr_ColorWhiteTint, _Foregr_ColorBlackTint, pow(tex2D(_TexForegr, i.uv1).r, _TexControl.z));

				col.rgb = back.rgb * _TexControl.x * i.color.rgb;
				col.rgb = col.rgb * (1.0f - foregr.a) + foregr.rgb;

				return col;
			}
			ENDCG
		}
	}
}
