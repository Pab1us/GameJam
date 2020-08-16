Shader "SpaceJustice/FX/Particle/PAnimateWave"
{
	Properties
	{
		[NoScaleOffset]
		_TexMask ("Texture Mask", 2D) = "white" {}
		[Space(10)]

		[Space(10)]
		_Tex_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_Tex_ColorBlackTint("Color black tint",Color) = (0,0,0,0)
    _Param ("Brigh LinCol AlphaMul Size", Vector) = (1,1,1,0)
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
				fixed4 color : COLOR0;
			};

			sampler2D _TexMask;

			fixed4 _Tex_ColorWhiteTint;
			fixed4 _Tex_ColorBlackTint;
			half4 _Param;

			v2f vert(appdata v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.color = v.color;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col;

				fixed texMask = tex2D(_TexMask, i.uv.xy).r;

				col = lerp(_Tex_ColorBlackTint, _Tex_ColorWhiteTint, pow(texMask * _Param.x, _Param.y));

				col *= i.color;

				return col;
			}
			ENDCG
		}
	}
}
