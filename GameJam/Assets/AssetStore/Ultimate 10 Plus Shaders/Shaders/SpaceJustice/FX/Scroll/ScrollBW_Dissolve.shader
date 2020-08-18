Shader "SpaceJustice/FX/Scroll/ScrollBW Dissolve"
{
	Properties
	{
		_Tex_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_Tex_ColorBlackTint("Color black tint",Color) = (0,0,0,0)
		[NoScaleOffset]
		_Tex ("Texture BW", 2D) = "white" {}
		_Tex_TilingScroll ("Tiling Scroll ", Vector) = (1,1,0,0)
		_TexControl ("Brgh VertA LinCol ", Vector) = (1, 1, 1, 0)

		[Space(10)]
		[Header(Dissolve (mask in vertex A))]
		_Dissolve ("A0 A1 LinDist Smoth", Vector) = (0.1, 0.1, 1, 0.1)

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

			struct appdata
			{
				float4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			half _Brighness;
			fixed _AlphaVertEffect;
			sampler2D _Tex;
			half4 _Tex_TilingScroll;
			fixed4 _Tex_ColorWhiteTint;
			fixed4 _Tex_ColorBlackTint;
			half4 _TexControl;

			half4 _Dissolve;

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.uv * _Tex_TilingScroll.xy + frac(_Tex_TilingScroll.zw * _Time.y);

				o.color = v.color;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col;
				fixed tex_BW = tex2D(_Tex, i.uv).r;
				fixed4 color1 = lerp(_Tex_ColorBlackTint, _Tex_ColorWhiteTint, pow(tex_BW, _TexControl.z));
				col.rgb = color1.rgb * _TexControl.x * i.color.rgb;

				half dissolve = lerp(_Dissolve.x, _Dissolve.y, pow(i.color.a, _Dissolve.z));
				dissolve = saturate(((tex_BW + dissolve) * 50.0f - 25.0f) / _Dissolve.w);

				col.a = saturate(dissolve * (i.color.a * _TexControl.y + 1.0f - _TexControl.y) * _Tex_ColorWhiteTint.a);

				return col;
			}
			ENDCG
		}
	}
}
