
Shader "SpaceJustice/FX/Scroll/Scroll2BWAdd_Alpha"
{
	Properties
	{
		[Header(Texture1)]
		_Tex1_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_Tex1_ColorBlackTint("Color black tint",Color) = (0,0,0,0)
		[NoScaleOffset]
		_Tex1 ("Texture1 BW", 2D) = "white" {}
		_Tex1_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)

		[Space(10)]
		[Header(Texture2)]
		_Tex2_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_Tex2_ColorBlackTint("Color black tint",Color) = (0,0,0,0)
		[NoScaleOffset]
		_Tex2 ("Texture2 BW", 2D) = "white" {}
		_Tex2_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)

		[Space(20)]
		_TexControl ("Brgh VertA LinCol ", Vector) = (1, 1, 1, 0)
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Transparent"
			"Queue" = "Transparent"
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
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;//xy Tex1  zw Tex2
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
			};

			//color
			sampler2D _Tex1;
			half4 _Tex1_TilingScroll;
			fixed4 _Tex1_ColorWhiteTint;
			fixed4 _Tex1_ColorBlackTint;

			sampler2D _Tex2;
			half4 _Tex2_TilingScroll;
			fixed4 _Tex2_ColorWhiteTint;
			fixed4 _Tex2_ColorBlackTint;

			half4 _TexControl;

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.uv * _Tex1_TilingScroll.xy + frac(_Tex1_TilingScroll.zw * _Time.y);
				o.uv.zw = v.uv * _Tex2_TilingScroll.xy + frac(_Tex2_TilingScroll.zw * _Time.y);

				o.color = v.color;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//color
				fixed4 col;

				fixed tex1_BW = tex2D(_Tex1, i.uv.xy).r;
				fixed tex2_BW = tex2D(_Tex2, i.uv.zw).r;

				fixed4 color1 = lerp(_Tex1_ColorBlackTint, _Tex1_ColorWhiteTint, pow(tex1_BW, _TexControl.z));
				fixed4 color2 = lerp(_Tex2_ColorBlackTint, _Tex2_ColorWhiteTint, pow(tex2_BW, _TexControl.w));

				col.rgb = color1.rgb  * _TexControl.x * i.color.rgb + color2.rgb * color2.a ;

				//alpha
				col.a = (i.color.a * _TexControl.y + 1 -_TexControl.y) * _Tex1_ColorWhiteTint.a * color1.a ;

				return col;
			}
			ENDCG
		}
	}
}
