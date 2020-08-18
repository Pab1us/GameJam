Shader "SpaceJustice/FX/Scroll/Scroll Separated Alpha Mask"
{
	Properties
	{
		[NoScaleOffset]
		_MainTex ("Main Texture", 2D) = "white" {}
		_MainTex_TilingScroll ("Tiling Scroll ", Vector) = (1,1,0,0)
		_Color ("Tint", color) = (1, 1, 1, 1)

		[Header(AlphaMask)]
		[NoScaleOffset]
		_AlphaTex ("Mask (one channel texture)", 2D) = "white" {}
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		BlendOp Add
		Blend SrcAlpha OneMinusSrcAlpha

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
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
        float4 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_TilingScroll;

			sampler2D _AlphaTex;

			fixed4 _Color;

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex  = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.uv * _MainTex_TilingScroll.xy + frac(_MainTex_TilingScroll.zw * _Time.y);
				o.uv.zw = v.uv;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv.xy) * _Color;

				fixed alpha = tex2D(_AlphaTex, i.uv.zw).x;

				color.a *= alpha;

				return color;
			}
			ENDCG
		}
	}
}