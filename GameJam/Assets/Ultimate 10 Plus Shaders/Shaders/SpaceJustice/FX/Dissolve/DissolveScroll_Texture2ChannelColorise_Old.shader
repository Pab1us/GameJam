Shader "SpaceJustice/FX/Dissolve/Texture2ChannelColorise_Dissolve_Old"
{
	Properties
	{

		[Header(MainTex)]

		_Brightness ("Brightness", Float) = 1
		_Opacity ("Opacity", Float) = 1
		[Toggle] _BlendAlpha ("Blend Alpha", Float) = 1

		[NoScaleOffset]
		_MainTex ("Main Texture", 2D) = "white" {}
		_MainTex_Tiling ("Tiling UV R  UV G", Vector) = (1,1,1,1)
		_MainTex_SpeedScroll ("Speed Scroll UV R  UV G", Vector) = (0,0,0,0)

		[Header(Color)]
		_MainColorR1 ("Main Color R 1", Color) = (1,1,1,1)
		_MainColorR2 ("Main Color R 2", Color) = (1,1,1,1)
		_MainColorG1 ("Main Color G 1", Color) = (1,1,1,1)
		_MainColorG2 ("Main Color G 2", Color) = (1,1,1,1)

		[Header(Dissolve)]
		_DissTreshold ("Dissolve Treshold", Float) = 0.5
		_DissSmooth ("Dissolve Smooth", Float) = 0.01



        [Header(Distort)]
        _DistortTex ("Distort Texture", 2D) = "white" {}
        _DistortTex_SpeedScroll ("SpeedScroll", Vector) = (0,0,0,0)
        _PowerDistort ("PowerDistort ", Vector) = (0,0,0,0)


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
				fixed4 color  : COLOR;
				float2 uv     : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos     : SV_POSITION;
				fixed4 color   : COLOR0;
				float4 uv      : TEXCOORD0; // xy - Main texture R,  zw - Main texture G
				float2 uv1     : TEXCOORD1; // Distort
			};



			float _Brightness;
			float _Opacity;
			half _BlendAlpha;
			sampler2D _MainTex;
			float4 _MainTex_Tiling;
			float4  _MainTex_SpeedScroll;
			float4  _MainColorR1, _MainColorR2;
			float4  _MainColorG1, _MainColorG2;


            // Distort
            sampler2D _DistortTex;
            float4  _DistortTex_ST;
            float4  _PowerDistort;
            float4  _DistortTex_SpeedScroll;
			float  _DissTreshold, _DissSmooth;



			v2f vert(appdata v)
			{
				v2f o;
				o.pos   = UnityObjectToClipPos(v.vertex);

				o.uv.xy   = v.uv * _MainTex_Tiling.xy + frac(_MainTex_SpeedScroll.xy * _Time.y); // Main texture R
				o.uv.zw   = v.uv * _MainTex_Tiling.zw + frac(_MainTex_SpeedScroll.zw * _Time.y); // Main texture G
                o.uv1  = TRANSFORM_TEX(v.uv, _DistortTex) + frac(_DistortTex_SpeedScroll.xy * _Time.y); // Distort

                o.color = v.color;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{


				float4 colorOut = 1;
				_DissTreshold  *= (1-i.color.a);

				float2 distort = tex2D(_DistortTex, i.uv1).rg - float2(0.5, 0.5);

				float texRmask = tex2D(_MainTex, i.uv.xy + distort * _PowerDistort.xy).r;
				float texGmask = tex2D(_MainTex, i.uv.zw + distort * _PowerDistort.zw).g;

                float4 texR = lerp(_MainColorR2, _MainColorR1, texRmask);
				float4 texG = lerp(_MainColorG2, _MainColorG1, texGmask);





				colorOut = texR * (1-texGmask* texG.a * _BlendAlpha) + texG * texGmask * texG.a;
				colorOut.rgb *= _Brightness * i.color.rgb;


				colorOut.a = smoothstep(_DissTreshold, _DissTreshold + _DissSmooth, texRmask + texGmask ) * _Opacity;


				return colorOut;
			}


			ENDCG
		}
	}

}
