Shader "SpaceJustice/FX/Items/Battleship_LogoHome"
{
	Properties
	{
		_Brightness ("Brightness", Float) = 1.0

		[NoScaleOffset]
		_Tex ("Texture", 2D) = "white" {}

		_Tex_ColorA("Color A",Color) = (1,1,1,1)
		_Tex_ColorR_Up("Color R Up",Color) = (1,1,1,1)
		_Tex_ColorR_Down("Color R Down",Color) = (1,1,1,1)
		_Tex_ColorG("Color G",Color) = (0,0,0,0)

		[Space(10)]
		[Header(Scanline)]

		_ScanParam ("Scan Tiling Speed Level", Vector) = (1,1,1,1)
		_WaveParam ("Wave Tiling Speed Level", Vector) = (1,1,1,1)
		_FlickerParam ("Speed Level", Vector) = (1,1,1,1)
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
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
			};

			sampler2D _Tex;

			fixed4 _Tex_ColorR_Up, _Tex_ColorR_Down;
			fixed4 _Tex_ColorG;
			fixed4 _Tex_ColorA;
			half4 _ScanParam, _WaveParam, _FlickerParam;
			half _Brightness;

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex  = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.color = lerp(_Tex_ColorR_Down, _Tex_ColorR_Up, v.uv.y * _ScanParam.w);
				o.color.a = abs(frac(_Time.w * _FlickerParam.x) * 2.0f - 1.0f) * _FlickerParam.y + (1.0f - _FlickerParam.y);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 scan = abs(frac(i.uv.y * float2(_ScanParam.x, _WaveParam.x)  + _Time.w * float2(_ScanParam.y, _WaveParam.y)) *2.0 - 1.0) * float2(_ScanParam.z, _WaveParam.z);
				_Tex_ColorR_Up.a = i.color.a * saturate(_Tex_ColorR_Up.a * scan.x + (1-_ScanParam.z) + scan.y);

				fixed4 tex = tex2D(_Tex, i.uv);
				fixed4 col;
				col = _Tex_ColorG * fixed4(1.0f, 1.0f, 1.0f, tex.g);//задник
				col = col * (1.0f - tex.r * _Tex_ColorR_Up.a) + fixed4(i.color.rgb, 1.0f) * tex.r * _Tex_ColorR_Up.a;//заливка с интелейсом
				col = col * (1.0f - tex.a * _Tex_ColorA.a) + _Tex_ColorA * tex.a * _Tex_ColorA.a;//контур
				col = col + tex.g * clamp(_Brightness - 1.0f, 0.0f, 10.0f) * step(1.0f, _Brightness) * _Tex_ColorG;
				col.a *= clamp(_Brightness, 0.0f, 1.0f);

				return col;
			}
			ENDCG
		}
	}
}
