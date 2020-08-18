Shader "SpaceJustice/FX/Particle/Scroll2Texture Emmisive Dissolve BlendAlpha"
{
	Properties
	{
		[Header(MainTex)]
		_MainTex ("Main Texture", 2D) = "white" {}
		_ColorWhiteTint_R("Color white tint R",Color) = (1,1,1,1)
		_ColorBlackTint_R("Color black tint R",Color) = (0,0,0,0)
		_ColorWhiteTint_G("Color white tint G",Color) = (1,1,1,1)
		_ColorBlackTint_G("Color black tint G",Color) = (0,0,0,0)
		_MainTex_Tiling("Tiling UV(R) UV(G)",Vector) = (1,1,1,1)
		_MainTex_SpeedScroll("SpeedScroll UV(R) UV(G)",Vector) = (0,0,0,0)
		_MultCol ("Color multiplier", Float) = 1

		[Header(Emmisive)]
		_ColorEmmisive("Color Emmisive",Color) = (1,1,1,1)
		_EmmPower1 ("Dissolve min", Range(-0.5,0.5)) = 0.1
		_EmmPower2 ("Dissolve max", Range(-0.5,0.5)) = 0.1
		_EmmSmooth ("Smoothness", Range(-0.5,0.5)) = 0.1

		[Header(Dissolve)]
		_DissPower1 ("Dissolve min", Range(-0.5,0.5)) = 0.1
		_DissPower2 ("Dissolve max", Range(-0.5,0.5)) = 0.1
		_DissSmooth ("Smoothness", Range(-0.5,0.5)) = 0.1
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
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
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
				half4 uv : TEXCOORD0;
				half2 uv1 : TEXCOORD1;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed4 color : COLOR0;
				half4 uv : TEXCOORD0;
				half4 uv1 : TEXCOORD1;
				fixed emmOpacity : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half4 _MainTex_SpeedScroll;
			half4 _MainTex_Tiling;

			fixed4 _ColorWhiteTint_R;
			fixed4 _ColorBlackTint_R;
			fixed4 _ColorWhiteTint_G;
			fixed4 _ColorBlackTint_G;
			half _MultCol;

			sampler2D _DistortTex;
			float4 _DistortTex_ST;
			half4 _DistortScrollAndPower;

			half _DissPower1, _DissPower2;
			half _DissSmooth;

			fixed4 _ColorEmmisive;
			half _EmmPower1, _EmmPower2;
			half _EmmSmooth;

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.uv.xy = TRANSFORM_TEX(v.uv.xy * _MainTex_Tiling.xy, _MainTex) + frac(_MainTex_SpeedScroll.xy * _Time.y + v.uv.z);
				o.uv.zw = TRANSFORM_TEX(v.uv.xy * _MainTex_Tiling.zw, _MainTex) + frac(_MainTex_SpeedScroll.zw * _Time.y + v.uv.z);
				o.uv1.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
				o.uv1.zw = half2(v.uv.w, v.uv1.x);
				o.emmOpacity = v.uv1.y;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				half4 col;
				half4 main = tex2D(_MainTex, i.uv1.xy);

				fixed mask1 = tex2D(_MainTex, i.uv.xy).r;
				fixed4 tex1 = lerp( _ColorBlackTint_R, _ColorWhiteTint_R, mask1);
				fixed mask2 = tex2D(_MainTex, i.uv.zw).g;
				fixed4 tex2 = lerp( _ColorBlackTint_G, _ColorWhiteTint_G, mask2);

				half emmValue = lerp(_EmmPower1, _EmmPower2, i.uv1.w);
				half3 emmisive = (saturate(((tex1.a * tex2.a * main.a + emmValue) * 2.0f + (-1.0f)) * 50.0f * _EmmSmooth) * i.color.a * i.uv1.w) * _ColorEmmisive.rgb;

				col.rgb = tex1.rgb * tex2.rgb * i.color.rgb * _MultCol + emmisive * i.emmOpacity * 2.0f;

				float dissValue = lerp(_DissPower1, _DissPower2, i.uv1.z);
				col.a = saturate(((tex1.a * tex2.a * main.a + dissValue) * _DissSmooth * 2.0f - _DissSmooth) * 50.0f) * i.color.a;

				return col;
			}
			ENDCG
		}
	}
}
