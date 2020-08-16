Shader "SpaceJustice/FX/Items/Lightning_Grow"
{
	Properties
	{
		_Evolution ("Evolution lengtn", Float) = 1.0
		_EvolutionFallOff ("Evolution falloff", Float) = 0.1
		[Space(20)]
		_Brightness ("Brightness", Float) = 1.0
		_Power ("Power", Float) = 0.7
		[Space(20)]
		_ColorCenter ("Color Center", Color) = (1,1,1,1)
		_ColorGlow ("Color Glow", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

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
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			fixed4 _ColorCenter;
			fixed4 _ColorGlow;

			float _Brightness;
			float _Power;
			float _Evolution;
			float _EvolutionFallOff;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.color = v.color;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed maskU = saturate((i.uv.x - _EvolutionFallOff - _Evolution)/ -_EvolutionFallOff);

				float x = saturate(1-abs(i.uv.y * 2.0f - 1.0f));
				fixed maskV = saturate(x * x * 1.3f * i.color.a * maskU - 1.3f * saturate(1.0f - _Power));

				fixed4 col = lerp(_ColorGlow, _ColorCenter, maskV) * _Brightness;

				col.a = maskV;
				return col;
			}
			ENDCG
		}
	}
}
