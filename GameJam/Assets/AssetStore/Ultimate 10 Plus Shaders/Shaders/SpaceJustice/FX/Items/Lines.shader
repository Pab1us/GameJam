Shader "SpaceJustice/FX/Items/LinesBack"
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,1)

		[Header(Texture1)]
		_Tex1_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_Tex1_ColorBlackTint("Color black tint",Color) = (0,0,0,0)
		[NoScaleOffset]
		_Tex1 ("Texture1 BW", 2D) = "white" {}
		_Tex1_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Transparent"
			"Queue" = "Transparent"
		}

		Blend SrcAlpha One
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
				float2 uv : TEXCOORD0; //xy Tex1
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
			};

			fixed4 _Color;

			sampler2D _Tex1;
			half4 _Tex1_TilingScroll;
			fixed4 _Tex1_ColorWhiteTint;
			fixed4 _Tex1_ColorBlackTint;
		

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv * _Tex1_TilingScroll.xy + frac(_Tex1_TilingScroll.zw * _Time.y);;
				o.color = v.color * _Color;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//color
				fixed4 col = i.color;
				fixed tex1_BW = tex2D(_Tex1, i.uv.xy).r;
				fixed4 color1 = lerp(_Tex1_ColorBlackTint, _Tex1_ColorWhiteTint, tex1_BW);
				col *= color1;

				return col;
			}
			ENDCG
		}
	}
}
