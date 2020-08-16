Shader "SpaceJustice/FX/Items/TransparentCutout"
// базовая текстура мпинг из uv
// текстура для cutout мапинг из uv1
// управление значением _VertMask.x "StartCut" через custom_param частиц
{
	Properties
	{
		[Header(Texture)]
		_Brightness ("Brightness", Float ) = 1

		[NoScaleOffset]
		_TexBase ("Base texture", 2D) = "white" {}
		_TexBase_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)

		[Header(Distort)]
		[NoScaleOffset]
		_TexDist ("Texture Distort", 2D) = "white" {}
		_TexDist_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)
		_Distort ("Distort UV", Vector) = (0,0,0,0)

        [Header(Cutout)]
		[NoScaleOffset]
		_TexCutout ("Texture Cutout", 2D) = "white" {}
		_TexCutout_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)

		_CutoutParam ("Cutout1 | Cutout2 | Smooth | SmoothBord ", Vector) = (0,1,0,0)
		_VertMask ("StartCut | WidthCut | WidthBord ", Vector) = (0,1,0,0)
        _CutoutBorder_Color ("Color Edge", Color) = (1,1,1,1)

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
				float4 uv  : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0; 
				float4 uv1 : TEXCOORD1; 
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
			};

			float _Brightness;
			sampler2D _TexBase;
			float4 _TexBase_TilingScroll;

			sampler2D _TexDist;
			float4 _TexDist_TilingScroll;
			float4 _Distort;

			sampler2D _TexCutout;
			float4 _TexCutout_TilingScroll;

            float4 _CutoutParam;
			float4 _VertMask;
			fixed4 _CutoutBorder_Color;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy  = v.uv.xy * _TexBase_TilingScroll.xy + frac(_TexBase_TilingScroll.zw   * _Time.y);
				o.uv.zw  = v.uv1 * _TexCutout_TilingScroll.xy + frac(_TexCutout_TilingScroll.zw * _Time.y);
				o.uv1.xy = v.uv1 * _TexDist_TilingScroll.xy   + frac(_TexDist_TilingScroll.zw   * _Time.y);
				o.color = v.color;
				o.uv1.zw = float2(v.uv.z, 0); // управление значением _VertMask.x "StartCut" через custom_param частиц
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 color_out;

				// distort
				fixed2 distortion = tex2D(_TexDist, i.uv1.xy).rg;
				i.uv.zw += (distortion - 0.5f) * _Distort.xy;

				fixed4 texBase   = tex2D(_TexBase,   i.uv.xy);
				fixed4 texCutout = tex2D(_TexCutout, i.uv.zw);

                color_out = texBase;
				color_out.rgb *= _Brightness;


				float2 vertMask = saturate((i.color.a - _VertMask.x * (1 + i.uv1.z) + _VertMask.yz)/_VertMask.yz);
				float2 cutoutVal = lerp(_CutoutParam.x, _CutoutParam.y, vertMask);
				fixed2 cutoutMask = smoothstep(cutoutVal, cutoutVal + _CutoutParam.zw, texCutout);

				color_out.a *= cutoutMask.x;
//				color_out.rgb = color_out.rgb * cutoutMask.y +  (1-cutoutMask.y) * _CutoutBorder_Color.rgb * _CutoutBorder_Color.a;  //normal наложение бордюра 
				color_out.rgb = color_out.rgb + (1-cutoutMask.y) * _CutoutBorder_Color.rgb * _CutoutBorder_Color.a ; //add наложение бордюра

				return color_out;
			}
			ENDCG
		}
	}
}
