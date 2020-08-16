Shader "SpaceJustice/FX/Shield/Shield01"
{
	Properties
	{
       
		[Header(MainTex)]
        _Opacity ("Opacity", Float) = 1
		_MainTex ("Main Texture", 2D) = "white" {}
		_ColorWhiteTint_R("Color white tint R",Color) = (1,1,1,1)
		_ColorBlackTint_R("Color black tint R",Color) = (0,0,0,0)
		_ColorWhiteTint_G("Color white tint G",Color) = (1,1,1,1)
		_ColorBlackTint_G("Color black tint G",Color) = (0,0,0,0)
		_MainTex_Tiling("Tiling UV(R) UV(G)",Vector) = (1,1,1,1)
		_MainTex_SpeedScroll("SpeedScroll UV(R) UV(G)",Vector) = (0,0,0,0)
		_MultCol ("Color multiplier", Float) = 1
		_MultAlpha ("Alpha multiplier", Float) = 1

		[Header(Distortion)]
		_DistortTex ("Distort Texture", 2D) = "white" {}
		_DistortScrollAndPower ("Distort SpeedScroll Power",Vector) = (0,0,0,0)
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
		BlendOp Add
		Blend SrcAlpha One
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
				fixed4 color  : COLOR;
				float2 uv     : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos   : SV_POSITION;
				fixed4 color : COLOR0;
				float4 uv    : TEXCOORD0;
				float4 uv1   : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half4 _MainTex_SpeedScroll;
			half4 _MainTex_Tiling;

			half4 _ColorWhiteTint_R;
			half4 _ColorBlackTint_R;
			half4 _ColorWhiteTint_G;
			half4 _ColorBlackTint_G;
			half _MultCol;
			half _MultAlpha;


			sampler2D _DistortTex;
			float4 _DistortTex_ST;
			half4 _DistortScrollAndPower;



			v2f vert(appdata v)
			{
				v2f o;
				o.pos   = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.uv.xy   = TRANSFORM_TEX(v.uv * _MainTex_Tiling.xy, _MainTex) + frac(_MainTex_SpeedScroll.xy * _Time.y + v.color.r);
				o.uv.zw   = TRANSFORM_TEX(v.uv * _MainTex_Tiling.zw, _MainTex) + frac(_MainTex_SpeedScroll.zw * _Time.y + v.color.r);
				o.uv1.xy  = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv1.zw  = TRANSFORM_TEX(v.uv, _DistortTex) + frac(_DistortScrollAndPower.xy * _Time.y + v.color.r);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				half2 distortion = tex2D(_DistortTex, i.uv1.zw).rg;
				distortion = (distortion - 0.5) * _DistortScrollAndPower.zw;
				i.uv.xy += distortion;
				i.uv.zw += distortion;

				half4 col;
				half mask1 = tex2D(_MainTex, i.uv.xy).r;
				half4 tex1 = lerp( _ColorBlackTint_R, _ColorWhiteTint_R, mask1) * mask1;
				half mask2 = tex2D(_MainTex, i.uv.zw).a;
				half4 tex2 = lerp( _ColorBlackTint_G, _ColorWhiteTint_G, mask2) * mask2;
				col.rgb =( tex1.rgb + tex2.rgb ) * _MultCol * i.color.a;



				col.a = saturate(tex1.a + tex2.a) * i.color.a * _MultAlpha;
				return col;
			}
			
			
			ENDCG
		}
	}
}
