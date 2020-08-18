Shader "SpaceJustice/FX/Scroll/Scroll2 Multiply"
{
	Properties
	{
		[Space(10)]
		[Header(Texture1)]
		[NoScaleOffset]
		_Tex1("Texture1", 2D) = "white" {}
		_Tex1_TilingScroll("Tiling Scroll", Vector) = (1,1,0,0)

		[Space(10)]
		[Header(Texture2)]
		[NoScaleOffset]
		_Tex2 ("Texture2", 2D) = "white" {}
		_Tex2_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)

		[Space(10)]
		_Brightness ("Brightness", Float) = 1.0

		[Space(10)]
		[Header(Blending)]
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Operation", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFactor ("Source", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFactor ("Destination", Float) = 10
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		BlendOp [_BlendOp]
		Blend [_SrcBlendFactor] [_DstBlendFactor]
		ZWrite Off
		Cull Off

		Pass
		{
			CGPROGRAM
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
				fixed4 color : COLOR;
			};

			sampler2D _Tex1;
			half4 _Tex1_TilingScroll;

			sampler2D _Tex2;
			half4 _Tex2_TilingScroll;

			half _Brightness;

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
				fixed4 col;

				fixed4 tex1 = tex2D(_Tex1, i.uv.xy);
				fixed4 tex2 = tex2D(_Tex2, i.uv.zw);

				fixed4 texMixed = tex1 * tex2;

				col = texMixed * i.color * _Brightness;

				return col;
			}
			ENDCG
		}
	}
}
