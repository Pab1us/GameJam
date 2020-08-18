Shader "SpaceJustice/FX/Items/Glowing Grid"
{
	Properties
	{
		[Header(R Node. G Border. B Lines)]
		_MainTex ("Texture", 2D) = "white" {}

		_GlowOffset ("Glow Offset", Range(0.0, 1.0)) = 0.0
		_GlowSpeed ("Grid Glow Speed", Float) = 1.0
		_GlowColor ("Glow Collor", Color) = (1.0, 1.0, 1.0, 1.0)
		_GridIntensity ("Grid Intensity", Float) = 1.0
		_LinesIntensity ("Lines Intensity", Float) = 1.0

		[Header(Scroll Texture)]
		[Toggle] _UseNoise ("UseNoise", float) = 0.
		_ScrollTex ("Texture", 2D) = "black" {}
		_Speed ("Scroll Speed XY", vector) = (0., 0., 0., 0.)

		[Header(Z Offset)]
		_Offset ("Z-Offset", Float) = 0
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}
		BlendOp Add
		Blend One One
		ZWrite Off
		Cull Off

		Pass
		{
		CGPROGRAM
		#include "../../Standard_Functions.cginc"
		#pragma shader_feature _USENOISE_ON

		struct appdata
		{
			float4 vertex : POSITION;
			fixed4 color : COLOR;
			half2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			half4 uv : TEXCOORD0;
			fixed4 color : COLOR;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;

		fixed _GlowOffset;
		half _GlowSpeed;
		fixed4 _GlowColor;
		half _GridIntensity;
		half _LinesIntensity;


		sampler2D _ScrollTex;
		half4 _ScrollTex_ST;
		half2 _Speed;

		float _Offset;


		v2f vert(appdata i)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(i.vertex);

		#if defined(UNITY_REVERSED_Z)
			o.pos.z -= _Offset * 0.47;
		#else
			o.pos.z += _Offset;
		#endif

			o.uv.xy = TRANSFORM_TEX(i.uv, _MainTex);
			o.uv.zw = TRANSFORM_TEX(i.uv, _ScrollTex) + frac(_Speed * _Time.y);

			o.color = i.color;

			return o;
		}

		fixed4 frag (v2f i) : SV_Target
		{
			fixed4 data = tex2D(_MainTex, i.uv.xy);

			fixed checker = data.x;
			fixed border = data.y;
			fixed grid = data.z;

			#if _USENOISE_ON
			fixed noise = tex2D(_ScrollTex, i.uv.zw).r;
			#else
			fixed noise = 1.0f;
			#endif

			checker = _GlowOffset + sfLWave(checker * 10.0f + _Time.y * _GlowSpeed * (checker + 0.5f) * 0.3f) * (1.0f - _GlowOffset);
			checker *= checker * (1.0f - border);

			fixed4 result = checker * (1.0f + border * 2.0f) * _GlowColor * _GridIntensity;
			result = saturate(result + saturate(grid - 0.5f) * noise * 0.35f * i.color * _LinesIntensity + saturate(noise * i.color * _LinesIntensity - 0.5f.xxxx) * 2.5f * grid);

			return result;
		}

		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}
