Shader "SpaceJustice/FX/Items/EnergyFlow"
{
	Properties
	{
		[Header(Flow Color)]
		_Noise ("Noise Texture", 2D) = "black" {}
		_NoiseSpeed ("Noise Speed", float) = 1.
		_Mask ("Mask Texture", 2D) = "white" {}
		_Color ("Tint", color) = (1., 1., 1., 1.)
		_OverageColor ("Overage Color", color) = (1., 1., 1., 1.)
		_Color0 ("Glow Color 1", color) = (1., 1., 1., 1.)
		_Color1 ("Glow Color 2", color) = (1., 1., 1., 1.)
		[Space(10)]
    _Timer ("Timer", range(0., 2.)) = 0.
		_WaveLength ("Wave Length", range(0., 1.)) = 0.2
		_Intensity ("Intensity", float) = 1.
  }
	SubShader
	{
		Tags
		{
			"RenderType"="Transparent"
			"Queue" = "Transparent"
		}

		Blend One OneMinusSrcAlpha, Zero One
		ZWrite Off
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "../../Standard_Functions.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 color : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 uv : TEXCOORD0; //xy - noise, zw - mask
				float2 uv_flow : TEXCOORD1;
        float4 color : COLOR;
			};

			sampler2D _Noise;
			float4 _Noise_ST;
			float _NoiseSpeed;
			sampler2D _Mask;
			fixed4 _Color;
			fixed4 _OverageColor;
			fixed4 _Color0;
			fixed4 _Color1;
			float _Intensity;
			float _Timer;
			float _WaveLength;

			v2f vert (appdata i)
			{
				v2f o;
				o.vertex  = UnityObjectToClipPos(i.vertex);
				o.uv.xy = TRANSFORM_TEX(i.uv0, _Noise);
				o.uv.zw = i.uv0;
				o.uv_flow = i.uv1;
				o.color = i.color;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float4 color;

				float noise = tex2D(_Noise, i.uv.xy + _Time.yy * 0.2f * _NoiseSpeed).x;//+ tex2D(_Noise, i.uv.xy - _Time.yy * 0.2f).x;
        float mask = tex2D(_Mask, i.uv.zw);

				float wave = 1.0f - i.uv_flow.x;

				float overage = 1.0f - saturate(abs((wave - _Timer * 1.1f + 0.1f) * 2.0f / _WaveLength - 1.0f));
				wave = saturate((1.0f - (saturate(wave - _Timer * 1.1f + 0.1f) + 0.5f)) * 10.0f - 4.5f);

				color.rgb = wave * _Color.rgb + saturate(overage * _OverageColor);
				color.a = (wave + overage) * _Color.a;

				float shift = frac(noise + _Time.y);

				color.rgb += _Intensity * lerp(_Color1.rgb, _Color0.rgb, abs(shift - 0.5f) * 2.0f) *  wave;//((_Color0.rgb * abs(1.0f - 2.0f * shift) - 0.34f) / 0.66f + _Color1.rgb * saturate(1.0f - abs(shift / 0.33f - 1.0f)) + _Color2.rgb * saturate(1.0f - abs(shift / 0.33f - 2.0f))) * 0.4f * wave;
				color.rgb *= mask;

				color.a *= _Color.a * mask;

				return saturate(color);
			}
			ENDCG
		}
	}
}
