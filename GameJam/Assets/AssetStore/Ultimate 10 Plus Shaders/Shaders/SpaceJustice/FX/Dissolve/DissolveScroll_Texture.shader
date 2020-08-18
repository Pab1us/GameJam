Shader "SpaceJustice/FX/Dissolve/DissolveScroll_Texture"
{
	Properties
	{
		_Brighness ("Brighness", Float) = 1.0
		_ColorDiss1 ("Color Diss 1", Color) = (1,1,1,1)
		_ColorDiss2 ("Color Diss 2", Color) = (1,1,1,1)
		[NoScaleOffset]
		_MainTex ("Main Texture", 2D) = "white" {}
		_MainTex_TilingScroll ("Tiling Scroll ", Vector) = (1,1,0,0)

		[Header(Dissolve)]
		_DissPower1 ("Power1", Range(-0.5,0.5)) = 0.1
		_DissPower2 ("Power2", Range(-0.5,0.5)) = 0.1
		_DissLinear ("Linearity", Range(0,3)) = 1.0
		_DissSmooth ("Smoothness", Range(-0.5,0.5)) = 0.1

		[Header(Distort)]
		[NoScaleOffset]
		_DistortTex ("Distort Texture", 2D) = "white" {}
		_DistortTex_TilingScroll ("Tiling Scroll", Vector) = (1,1,0,0)

		_DistortPower ("Power UV", Vector) = (0,0,0,0)
		_DistortLinear ("Linearity", Range(0,3)) = 1.0


	}
	SubShader
	{
		Tags {
				"RenderType"="Transparent"
				"Queue" = "Transparent"
			 }

		Blend SrcAlpha OneMinusSrcAlpha

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
				float4 uv : TEXCOORD0; //xy mainTex  zw Dissolve
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			float _Brighness;
            float4 _ColorDiss1, _ColorDiss2;
			sampler2D _MainTex;
			float4 _MainTex_TilingScroll;

			float _DissPower1, _DissPower2;
			float _DissSmooth, _DissLinear;

			sampler2D _DistortTex;
			float4 _DistortTex_TilingScroll;
			float4 _DistortPower;
			float  _DistortLinear;


			v2f vert (appdata v)
			{
				v2f o;
				o.vertex  = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.uv * _MainTex_TilingScroll.xy + frac(_MainTex_TilingScroll.zw * _Time.y);
				o.uv.zw = v.uv * _DistortTex_TilingScroll.xy + frac(_DistortTex_TilingScroll.zw * _Time.y);
				o.color = v.color;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float4 dissTex = tex2D(_DistortTex, i.uv.zw);

				float2 distortValue = lerp(_DistortPower.xy, _DistortPower.zw, pow(i.color.a, _DistortLinear));

				float4 mainTex = tex2D(_MainTex, i.uv.xy + (dissTex.xy - 0.5) * distortValue);

				float4 col = mainTex * _Brighness * lerp(_ColorDiss1, _ColorDiss2, pow(i.color.a, _DissLinear)) * i.color;

				float dissValue = lerp(_DissPower1, _DissPower2, pow(i.color.a, _DissLinear));
				col.a = saturate((mainTex.a + dissValue) * 50.0 * _DissSmooth * 2.0 - 50.0 * _DissSmooth);


				return col;
			}
			ENDCG
		}
	}
}
