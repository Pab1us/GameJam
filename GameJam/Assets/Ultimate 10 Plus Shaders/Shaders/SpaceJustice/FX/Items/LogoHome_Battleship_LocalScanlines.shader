Shader "SpaceJustice/FX/Items/Battleship_LogoHome LocalScanlines"
{
	Properties
	{
		[NoScaleOffset]
		_Tex ("Texture", 2D) = "white" {}

		_Tex_ColorA("Color A",Color) = (1,1,1,1)
		_Tex_ColorR_Up("Color R Up",Color) = (1,1,1,1)
		_Tex_ColorR_Down("Color R Down",Color) = (1,1,1,1)
		_Tex_ColorG("Color G",Color) = (0,0,0,0)
		_Tex_ColorB("Color B",Color) = (0,0,0,0)

		[Space(10)]
		[Header(Scanline)]

		_ScanParam ("Scan - Tiling Speed Level", Vector) = (1,1,1,1)
		_WaveParam ("Wave - Tiling Speed Level", Vector) = (1,1,1,1)
		_FlickerParam ("Flicker - Speed Level", Vector) = (1,1,1,1)
		_GlowParam ("Glow - Brightness", Float) = 1.0

		[Space(10)]
		[Header(Shine)]
		[Toggle] _Shine ("Border Shine", Float) = 0
		_ShineColor ("Shine Color ", Color) = (1,1,1,1)
		_ShineParam ("Speed / Width / .. / ..", Vector) = (0,0,0,0)
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
			#pragma shader_feature _SHINE_ON

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;

				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			sampler2D _Tex;

			fixed4 _Tex_ColorR_Up, _Tex_ColorR_Down;
			fixed4 _Tex_ColorG;
			fixed4 _Tex_ColorB;
			fixed4 _Tex_ColorA;
			float4 _ScanParam, _WaveParam, _FlickerParam;
			float _Brightness;

			float _Shine;

			fixed4 _ShineColor;
			float4 _ShineParam;

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex  = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.uv;
				o.uv.zw = v.vertex.zx;
				o.color = v.color;
				o.color.a = abs(frac(_Time.w * _FlickerParam.x) * 2.0 - 1.0) * _FlickerParam.y + (1.0f - _FlickerParam.y);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 scan = abs(frac(i.uv.z * float2(_ScanParam.x, _WaveParam.x)  + _Time.w * float2(_ScanParam.y, _WaveParam.y)) * 2.0f - 1.0f) * float2(_ScanParam.z, _WaveParam.z);

				fixed4 tex = tex2D(_Tex, i.uv.xy);
				fixed4 col;

				col = _Tex_ColorG * (1.0f - tex.r);//задник
				col.a *= tex.g;

				fixed4 fillScanColor = tex.r * (lerp(_Tex_ColorR_Up, _Tex_ColorR_Down, scan.x) + scan.y * _WaveParam.z);//заливка сканлайн
				fillScanColor.a *= i.color.a;
				col *= (1.0f - tex.r);
				col += fillScanColor;

				col.rgb = lerp(col.rgb, _Tex_ColorB.rgb, tex.b * _Tex_ColorB.a);//свечение

				col *= (1.0f - tex.a * _Tex_ColorA.a);//контур

				#if _SHINE_ON
				col += lerp(_Tex_ColorA, _ShineColor, saturate(1.0f - abs(1.414f * (i.uv.w - i.uv.z) - frac(_Time.y * _ShineParam.x) * 48.0f + 24.0f) / _ShineParam.y)) * tex.a * _Tex_ColorA.a;//saturate(_ShineParam.y * abs(0.707f * (i.uv.w - i.uv.z) - frac(_ShineParam.x * _Time.y) * 16.0f + 8.0f)))) * tex.a * _Tex_ColorA.a;
				#else
				col += _Tex_ColorA * tex.a * _Tex_ColorA.a;
				#endif

				col.rgb *= i.color.rgb;

				return col;
			}
			ENDCG
		}
	}
}
