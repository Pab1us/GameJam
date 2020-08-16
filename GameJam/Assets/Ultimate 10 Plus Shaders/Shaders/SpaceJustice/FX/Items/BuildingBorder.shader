Shader "SpaceJustice/FX/Items/Building Border"
{
	Properties
	{
		[NoScaleOffset]
		_Tex1 ("Texture1 BW", 2D) = "white" {}
		_Tex1_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)
		_Bright ("Brightness", Float) = 1
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
				float2 uv : TEXCOORD0; //xy Tex1
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
			};

			//color
			sampler2D _Tex1;
			half4 _Tex1_TilingScroll;
			half _Bright;

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv * _Tex1_TilingScroll.xy + frac(_Tex1_TilingScroll.zw * _Time.y);

				o.color = v.color;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//color
				fixed4 col;
				fixed4 tex = tex2D(_Tex1, i.uv.xy);

				col.rgb = saturate(i.color.rgb + tex.a * _Bright * fixed3(0.299f, 0.587f, 0.114f));
				col.a = saturate(tex.r + tex.a) * i.color.a;

				return col;
			}
			ENDCG
		}
	}
}
