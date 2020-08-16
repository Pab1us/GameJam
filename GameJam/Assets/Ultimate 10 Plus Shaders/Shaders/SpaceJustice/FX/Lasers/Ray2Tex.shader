Shader "SpaceJustice/FX/Lasers/Ray 2 Texture"
{
	Properties
	{
    _TilingLength("Tiling Length", Float) = 1.0

        [Space(10)]
		_Tex_ColorWhiteTint("Color white tint",Color) = (1.0, 1.0, 1.0, 1.0)
		_Tex_ColorBlackTint("Color black tint",Color) = (0.0, 0.0, 0.0, 0.0)
		[NoScaleOffset]
		_Tex ("Texture BW", 2D) = "white" {}
		_Tex_TilingScroll  ("Tiling Scroll ", Vector) = (1.0, 1.0, 0.0, 0.0)
        [NoScaleOffset]
        _Tex1 ("Texture1 BW", 2D) = "white" {}
        _Tex1_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)

		_TexControl ("Brgh VertA Lin LinDist", Vector) = (1.0, 1.0, 1.0, 1.0)

		[Space(10)]
		[Header(Dissolve  (mask in vertex A))]
		_Dissolve ("A0 A1 Lin Smooth", Vector) = (0.1, 0.1, 1.0, 0.1)

		[Space(10)]
		[Header(Distort (mask in vertex A))]
		[NoScaleOffset]
		_TexDistort ("Distort Texture", 2D) = "white" {}
		_TexDistort_TilingScroll ("Tiling Scroll", Vector) = (1.0, 1.0, 0.0, 0.0)
		_Distort ("Distort A=1  and A=0", Vector) = (0.0, 0.0, 0.0, 0.0)
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
				float4 color : COLOR;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0; //xy mainTex  zw Distort
                float2 uv1 : TEXCOORD1; // Tex1

				float4 vertex : SV_POSITION;
                
				float4 color : COLOR;
			};

			float _TilingLength;
            float _Brighness;
			float _AlphaVertEffect;
			//color
			sampler2D _Tex, _Tex1;
			half4 _Tex_TilingScroll, _Tex1_TilingScroll;
			half4 _Tex_ColorWhiteTint;
			half4 _Tex_ColorBlackTint;
			float4 _TexControl;

			//dissolve
			float4 _Dissolve;

			// distort
			sampler2D _TexDistort;
			float4 _TexDistort_TilingScroll;
			float4 _Distort;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex  = UnityObjectToClipPos(v.vertex);
				float2 length = float2(_TilingLength, 1.0f);
				o.uv.xy = v.uv * _Tex_TilingScroll.xy * length + frac(_Tex_TilingScroll.zw * _Time.y);
				o.uv.zw = v.uv * _TexDistort_TilingScroll.xy * length + frac(_TexDistort_TilingScroll.zw * _Time.y);
                o.uv1 =   v.uv * _Tex1_TilingScroll.xy * length + frac(_Tex1_TilingScroll.zw * _Time.y);
				o.color = v.color;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// distort
				half2 distortion = tex2D(_TexDistort, i.uv.zw).rg;
				float2 dist = (distortion - 0.5) * lerp(_Distort.zw, _Distort.xy, pow(i.color.a, _TexControl.w));
                i.uv.xy += dist;
                i.uv1   += dist;

				//color
				float4 col;
				float  tex_BW = tex2D(_Tex, i.uv.xy).r + tex2D(_Tex1, i.uv1).r;
				half4 color1 = lerp(_Tex_ColorBlackTint, _Tex_ColorWhiteTint, pow(tex_BW, _TexControl.z));
				col.rgb = color1.rgb  * _TexControl.x * i.color.rgb;

				//dissolve
				float dissolve = lerp(_Dissolve.x, _Dissolve.y, pow(i.color.a, _Dissolve.z));
				dissolve = saturate(((tex_BW + dissolve) * 50.0f - 25.0f) / _Dissolve.w);

				//alpha
				col.a = dissolve * (i.color.a * _TexControl.y + 1.0f -_TexControl.y) * _Tex_ColorWhiteTint.a;

				return col;
			}
			ENDCG
		}
	}
}
