Shader "SpaceJustice/FX/Items/Chest Podium"
{
	Properties
	{
		[Header(Checker)]
		_CheckerTex ("Texture", 2D) = "white" {}
		_BorderTex ("Texture border", 2D) = "white" {}

		_Color ("Tint", Color) = (1,1,1,1)

		_Offset ("Z-Offset", Float) = 0

		[Header(Backlight and occlusion)]
		_CenterLitOcc ("Center XY, Light range Z, Occlusion range W", vector) = (0.5, 0.5, 1., 1.)
		_OcclusionRatio ("Occlusion ratio", range(0.01, 1.)) = 0.5

		_ColorBacklight ("Light color", Color) = (1,1,1,1)

		[Header(Grid)]
		_GridTex ("Texture", 2D) = "white" {}

		[Header(Scroll Texture)]
		_ScrollTex0 ("Texture", 2D) = "black" {}
		_ColorS ("Tint", Color) = (1,1,1,1)
		_Speed ("Scroll Speed XY", vector) = (0., 0., 0., 0.)
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
		Blend One One//OneMinusSrcAlpha//, Zero One
		ZWrite Off
		Cull Off

		Pass
		{
		CGPROGRAM
		#include "../../Standard_Functions.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			fixed4 color  : COLOR;
			float2 uv     : TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			float4 uv0 : TEXCOORD0;
			float4 uv1 : TEXCOORD1;
			float2 uvUntransformed : TEXCOORD2;
		};

		sampler2D _CheckerTex;
		float4 _CheckerTex_ST;
		sampler2D _BorderTex;
		float4 _BorderTex_ST;
		fixed4 _Color;

		float _Offset;

		sampler2D _GridTex;
	  float4 _GridTex_ST;

	  float4 _CenterLitOcc;
	  float _OcclusionRatio;
	  fixed4 _ColorBacklight;

		sampler2D _ScrollTex0;
		float4 _ScrollTex0_ST;
		fixed4 _ColorS;
		float2 _Speed;

		v2f vert(appdata i)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(i.vertex);

		#if defined(UNITY_REVERSED_Z)
			o.pos.z -= _Offset * 0.47;
		#else
			o.pos.z += _Offset;
		#endif

			o.uv0.xy = TRANSFORM_TEX(i.uv, _CheckerTex);
			o.uv0.zw = TRANSFORM_TEX(i.uv, _GridTex);
			o.uv1.xy = TRANSFORM_TEX(i.uv, _ScrollTex0);
			o.uv1.zw = TRANSFORM_TEX(i.uv, _BorderTex);
			o.uvUntransformed = i.uv;

			return o;
		}

		fixed4 frag (v2f i) : SV_Target
		{
			float checker = tex2D(_CheckerTex, i.uv0.xy).r;
			float border = tex2D(_BorderTex, i.uv1.zw).r;
			float checkerMultiplier = tex2D(_CheckerTex, frac(i.uv0.xy + 0.5f.xx)).r;
			checker = sfLWave(checker * 10.0f + _Time.y * (checker + 0.5f) * 0.3f) * sfLWave(checkerMultiplier * 5.0f + _Time.y * (checker + 0.5f) * 0.5f * 0.3f);
			checker *= checker;

			float grid = tex2D(_GridTex, i.uv0.zw).r;

			float range = length((i.uvUntransformed - _CenterLitOcc.xy) * float2(_OcclusionRatio, 1.0f));

			float lightIntensity = range * _CenterLitOcc.z;
			lightIntensity = 1.0f - saturate(4.0f * lightIntensity * lightIntensity);

			float occlusion = 1.0f - saturate(range * _CenterLitOcc.w);
			float weakOcclusion = saturate(occlusion * 2.0f);

			fixed4 backLight = _ColorBacklight * lightIntensity;

			float scr = tex2D(_ScrollTex0, i.uv1.xy + frac(_Speed * _Time.y)).r;

			fixed4 result;
			result.rgb = saturate(checker * _Color.rgb * weakOcclusion * (1.0f + border * 2.0f) + (backLight.rgb + saturate(grid - 0.5f.xxx) * scr * _ColorS.rgb * 0.35f + saturate(scr * _ColorS.rgb - 0.5f.xxx) * 2.5f * grid) * occlusion);
			result.a = saturate(checker * _Color.a * weakOcclusion * (1.0f + border * 2.0f) + (backLight.a + grid * scr * 1.0f) * occlusion);

			return result;
		}

		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}
