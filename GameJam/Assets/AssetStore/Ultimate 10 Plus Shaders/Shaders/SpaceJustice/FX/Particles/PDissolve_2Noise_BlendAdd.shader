Shader "SpaceJustice/FX/Particle/PDissolve_2Noise_BlendAdd"
{
	Properties
	{
	[Header(Texture (RG two scroll channel   A mask))]
		[NoScaleOffset]
		_Tex ("Texture", 2D) = "white" {}

		[Space(10)]
		[NoScaleOffset]
		_Tex1 ("Texture", 2D) = "white" {}
		_Tex1_TilingScroll_R  ("Tiling Scroll R", Vector) = (1,1,0,0)
		_Tex1_TilingScroll_G  ("Tiling Scroll G", Vector) = (1,1,0,0)

		_Tex1_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_Tex1_ColorBlackTint("Color black tint",Color) = (0,0,0,0)

		[Space(10)]
		_Param ("Brigh Lin Smooth", Vector) = (1,1,0.1,1)
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
				half4 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				half4 uv : TEXCOORD0;
				half4 uv1 : TEXCOORD1;
				fixed4 color : COLOR0;
			};

			sampler2D _Tex, _Tex1;
			half4 _Tex1_TilingScroll_R;
			half4 _Tex1_TilingScroll_G;
			fixed4 _Tex1_ColorWhiteTint;
			fixed4 _Tex1_ColorBlackTint;

			float3 _Param;

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.uv.xy;
				o.uv.z = v.uv.z;
				o.uv1.xy = v.uv * _Tex1_TilingScroll_R.xy + frac(_Tex1_TilingScroll_R.zw * _Time.y + v.uv.w);
				o.uv1.zw = v.uv * _Tex1_TilingScroll_G.xy + frac(_Tex1_TilingScroll_G.zw * _Time.y + v.uv.w);
				o.color = v.color;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col;
				fixed tex = tex2D(_Tex, i.uv.xy ).r;
				fixed tex1_R = tex2D(_Tex1, i.uv1.xy).r;
				fixed tex1_G = tex2D(_Tex1, i.uv1.zw).g;

				fixed tex1_RG = tex1_R * tex1_G;
				fixed4 tex1_RG_color = lerp(_Tex1_ColorBlackTint, _Tex1_ColorWhiteTint, pow(tex1_RG , _Param.y));

				col.rgb = tex1_RG_color.rgb * _Param.x * i.color.rgb;

				fixed dissolve = saturate(((tex * tex1_RG * 2.0f + i.uv.z) * 2.0f + (-1.0f)) * 25.0f * _Param.z);

				col.a = dissolve * i.color.a;

				return col;
			}
			ENDCG
		}
	}
}
