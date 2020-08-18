Shader "SpaceJustice/FX/Items/ShieldImmortal"
{
	Properties
	{

		_ColorHex ("Color Hex", Color) = (1,1,1,1)
		[NoScaleOffset]
		_TexHex ("Texture Hex", 2D) = "white" {}

		[Header (Fresnel)]
		_ColorFresnel ("Color", Color) = (1,1,1,1)
		_Fresnel ("Fresnel", Vector) = (1,1,1,1)

		[Header (Wave)]
		_ColorWave ("Color", Color) = (1,1,1,1)
		_WaveParam ("Tiling Width Speed", Vector) = (0.2, 0.5, 0.5, 0.8)
		_WaveTransform ("Normal Scale", Vector) = (0, 1, 0, 0)


		[Header (Noise)]
		_ColorNoise ("Color", Color) = (1,1,1,1)
		_NoiseParam ("Scale Scroll", Vector) = (0.4, 0.05, 1, 1)

		[Header (Disassemble)]
		_ColorDis ("Color", Color) = (1,1,1,1)
		_DisParam ("Dis Width Normal Scale", Vector) = (1, 0, 1, 1)

		_Transform ("Normal Scale", Vector) = (0,1,1,1)
	}
	SubShader
	{
		Tags
		{
			"RenderType"="Transparent"
			"Queue" = "Transparent"
		}

		ZWrite Off
		Blend SrcAlpha One
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
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float3 normal : NORMAL;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
			};

			sampler2D _TexHex;
			fixed4 _ColorHex;

			fixed4 _ColorWave;
			half3 _WaveParam;
			half2 _WaveTransform;

			fixed4 _ColorNoise;
			half4 _NoiseParam;

			fixed4 _ColorDis;
			half4 _DisParam;

			half4 _Fresnel;
			fixed4 _ColorFresnel;
			half2  _Transform;

			v2f vert (appdata v)
			{
				v2f o;
				o.color = v.color;

				//fresnel (b)
				half3 viewDir = normalize(ObjSpaceViewDir(v.vertex ) + half3(0, _Fresnel.z, 0));

				o.color.b = smoothstep(1.0f - saturate(dot(v.normal, viewDir)), _Fresnel.x - _Fresnel.y, _Fresnel.y);
				//uv
				o.uv = float4(v.uv, v.uv1 * _NoiseParam.x + frac(_NoiseParam.y * _Time.y));//основной мапинг и мапинг для нойза мерцания ячеек
				//Wave (r)
				o.color.r = saturate( abs( frac(v.uv1.x * _WaveParam.x + frac(_WaveParam.z * _Time.y)) * 2.0f - 1.0f) - _WaveParam.y) / (1.0f - _WaveParam.y); // движущаяся волна

				//Disassemble
				fixed disassm = 1.0f - saturate((_DisParam.x + v.uv1.x) * _DisParam.y);

				//Normal transform
				v.vertex.xyz += v.normal * lerp(o.color.r * _WaveTransform.x, _DisParam.z, disassm);

				// Scale transform
				half3 rej = v.vertex - (v.normal * dot(v.vertex, v.normal) / dot(v.normal,v.normal));
				v.vertex.xyz += rej * lerp(_WaveTransform.y * o.color.r, _DisParam.w, disassm); ;
				v.vertex.xyz += rej * _Transform.x;

				o.vertex  = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 hex  = tex2D(_TexHex, i.uv.xy);   // r контур ячеек  g заливка ячеек
				fixed noise = tex2D(_TexHex, i.uv.zw).a; // a нойз

				fixed4 col = _ColorHex * hex.r * 2.0f + hex.g * noise * _ColorNoise; // контур ячейки + заливка ячейки * нойз
				col+= _ColorWave * i.color.r * 2.0f;
				col += i.color.b * _ColorFresnel;
				col.a = i.color.b *_ColorHex.a;

				return col;
			}
			ENDCG
		}
	}
}
