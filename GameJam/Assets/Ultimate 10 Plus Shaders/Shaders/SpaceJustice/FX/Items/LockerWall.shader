
Shader "SpaceJustice/FX/Items/Energy Wall"
{
	Properties
	{
		[NoScaleOffset]
		_TexHex ("Texture Hex", 2D) = "white" {}
		_ColorHex ("Color Hex", Color) = (1,1,1,1)

		[Header (Wave)]
		_ColorWave ("Color", Color) = (1,1,1,1)
		_WaveParam ("Tiling Width Speed Scale", Vector) = (0.2, 0.5, 0.5, 0.8)


		[Header (Noise)]
		_ColorNoise ("Color", Color) = (1,1,1,1)
		_NoiseParam ("Scale Scroll", Vector) = (0.4, 0.05, 1, 1)

		[Header (Disassemble)]
		_ColorDis ("Color", Color) = (1,1,1,1)
		_DisParam ("Dis Trans Scale", Vector) = (1, 0.3, -1.89, 1)

	}
	SubShader
	{
		Tags { 	
				"RenderType"="Transparent"
				"Queue" = "Transparent" 

			 }
	
		ZWrite Off
		Blend SrcAlpha One
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
				float2 uv1 : TEXCOORD1;
				float3 normal : NORMAL;
				float4 color : COLOR;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0; 
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			sampler2D _TexHex;
			float4 _ColorHex;

			float4 _ColorWave;
			float4 _WaveParam;

			float4 _ColorNoise;
			float4 _NoiseParam;

			float4 _ColorDis;
			float4 _DisParam;

			
			v2f vert (appdata v)
			{	
				v2f o;

				o.uv = float4(v.uv, v.uv1 * _NoiseParam.x + frac(_NoiseParam.y * _Time.y));
				o.color = v.color;
				o.color.r = saturate(abs(frac(v.uv1.x * _WaveParam.x + frac(_WaveParam.z * _Time.y)) * 2 - 1)-_WaveParam.y)/(1-_WaveParam.y);
				o.color.g = 1 - saturate((_DisParam.x + v.uv1.x)*_DisParam.y);
				v.vertex.xyz += v.normal * lerp(_WaveParam.w * o.color.r, _DisParam.z, o.color.g);
				o.vertex  = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 hex  = tex2D(_TexHex, i.uv.xy);
				float noise = tex2D(_TexHex, i.uv.zw);
				float4 col = (_ColorHex + i.color.r * _ColorWave*2) * hex.r + hex.g * noise * _ColorNoise;
				col += hex.g * i.color.g * _ColorDis * 2;

				col.a = i.color.a;
				
				return col;
			}
			ENDCG
		}
	}
}
