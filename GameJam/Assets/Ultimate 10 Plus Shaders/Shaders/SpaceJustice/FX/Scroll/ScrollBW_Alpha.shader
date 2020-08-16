Shader "SpaceJustice/FX/Scroll/ScrollBW_Alpha"
{
	Properties
	{
		[Header(Texture1)]
		_Tex1_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_Tex1_ColorBlackTint("Color black tint",Color) = (0,0,0,0)
		[NoScaleOffset]
		_Tex1 ("Texture1 BW", 2D) = "white" {}
		_Tex1_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)

		[Space(20)]
		_TexControl ("Brgh VertA LinCol ", Vector) = (1,1,1,0)
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma multi_compile_instancing

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;//xy Tex1
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
			};

			//color
			sampler2D _Tex1;
			half4 _Tex1_TilingScroll;
			fixed4 _Tex1_ColorWhiteTint;
			fixed4 _Tex1_ColorBlackTint;

			half4 _TexControl;

			v2f vert (appdata v)
			{
				UNITY_SETUP_INSTANCE_ID(v);

				v2f o;

				o.vertex  = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv * _Tex1_TilingScroll.xy + frac(_Tex1_TilingScroll.zw * _Time.y);

				o.color = v.color;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//color
				float4 col;

				fixed tex1_BW = tex2D(_Tex1, i.uv.xy).r;
				fixed4 color1 = lerp(_Tex1_ColorBlackTint, _Tex1_ColorWhiteTint, pow(tex1_BW, _TexControl.z));

				col.rgb = color1.rgb * _TexControl.x * i.color.rgb;

				//alpha
				col.a = (i.color.a * _TexControl.y + 1.0f - _TexControl.y) * _Tex1_ColorWhiteTint.a * color1.a;

				return col;
			}
			ENDCG
		}
	}
}
