Shader "SpaceJustice/FX/Particle/PScroll2BW_Dissolve_Alpha"
{
	Properties
	{
		[NoScaleOffset]
		_TexMask ("Texture Mask", 2D) = "white" {}
		[Space(10)]

		[NoScaleOffset]
		_Tex01 ("Texture Scroll 1", 2D) = "white" {}
		_Tex01_TilingScroll  ("Tiling Scroll", Vector) = (1,1,0,0)

		[NoScaleOffset]
		_Tex02 ("Texture Scroll 2", 2D) = "white" {}
		_Tex02_TilingScroll  ("Tiling Scroll", Vector) = (1,1,0,0)

		[Space(10)]
		_Tex_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_Tex_ColorBlackTint("Color black tint",Color) = (0,0,0,0)
		[Space(10)]
		_Param ("Brigh LinCol Smooth AlphaMul", Vector) = (1,1,0.1,0)
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
		}

		BlendOp Add
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Back

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float4 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed4 color : COLOR0;
				float4 uv : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
			};

			sampler2D _TexMask, _Tex01, _Tex02;
			float4 _Tex01_TilingScroll, _Tex02_TilingScroll;

			fixed4 _Tex_ColorWhiteTint;
			fixed4 _Tex_ColorBlackTint;
			half4 _Param;

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.uv.xy;
				o.uv.z = v.uv.z;
				o.uv1.xy = v.uv * _Tex01_TilingScroll.xy + frac(_Tex01_TilingScroll.zw * _Time.y + v.uv.w);
				o.uv1.zw = v.uv * _Tex02_TilingScroll.xy + frac(_Tex02_TilingScroll.zw * _Time.y - v.uv.w);
				o.color = v.color;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col;
				fixed texMask = tex2D(_TexMask, i.uv.xy).r;
				fixed tex01 = tex2D(_Tex01, i.uv1.xy).r;
				fixed tex02 = tex2D(_Tex02, i.uv1.zw).r;

				fixed texSum = tex01 * tex02;
				fixed4 texSum_color = lerp(_Tex_ColorBlackTint, _Tex_ColorWhiteTint, pow(texSum * texMask * _Param.x, _Param.y));

				col.rgb = texSum_color.rgb * i.color.rgb;

				fixed dissolve = saturate(((texSum * texMask * _Param.w + i.uv.z) * 2.0 + (-1.0f)) * 50.0 * _Param.z);

				col.a = dissolve * i.color.a;

				return col;
			}
			ENDCG
		}
	}
}