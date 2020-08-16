
Shader "SpaceJustice/FX/Items/ProgressBar"
{
	Properties
	{
		_Level ("Level", float) = 0.5

		[Space(10)]
		[Header (Part Inactive)]
		_InactiveTex_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_InactiveTex_ColorBlackTint("Color black tint",Color) = (0,0,0,0)
		[NoScaleOffset]
		_InactiveTex("TextureBW", 2D) = "white" {}
		_InactiveTex_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)


		[Space(10)]
		[Header (Part Transition)]
		_TransitionTex_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_TransitionTex_ColorBlackTint("Color black tint",Color) = (0,0,0,0)
		_TransitionTex_BrightnessColor("Color brightness",Color) = (1,1,1,1)
		[NoScaleOffset]
		_TransitionTex("TextureBW", 2D) = "white" {}
		_TransitionTex_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)
		_Transition_Param ("LenFront LenBack LenBrigh Brightness", Vector) = (2, 60, 1, 1)
		_Transition_Dissolve ("Dissolve Smooth", Vector) = (0.1, 0.8, 20, 1)

		[Space(10)]
		[Header (Part Active)]
		_ActiveTex_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_ActiveTex_ColorBlackTint("Color black tint",Color) = (0,0,0,0)

		[Space(10)]
		[Header (Distort)]
		[NoScaleOffset]
		_TexDistort ("Distort Texture", 2D) = "white" {}
		_TexDistort_TilingScroll ("Tiling Scroll", Vector) = (1,1,0,0)
		_DistortParam ("Distort A=1  and A=0", Vector) = (0,0,0,0)







		
	}
	SubShader
	{
		Tags { 	
				"RenderType"="Geometry" 
				"Queue" = "Geometry" 
			 }
	

		ZWrite On
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
				float4 uv1  : TEXCOORD0; //xy mainTex  zw Distort
				float4 uv2 : TEXCOORD1;
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			float  _Level;

			// Part Inactive
			fixed4 _InactiveTex_ColorWhiteTint, _InactiveTex_ColorBlackTint;
			sampler2D _InactiveTex;
			float4 _InactiveTex_TilingScroll;


			// Part Transition
			fixed4 _TransitionTex_ColorWhiteTint, _TransitionTex_ColorBlackTint, _TransitionTex_BrightnessColor;
			sampler2D _TransitionTex;
			float4 _TransitionTex_TilingScroll;
			float4 _Transition_Param, _Transition_Dissolve;

			// Part Active
			fixed4 _ActiveTex_ColorWhiteTint, _ActiveTex_ColorBlackTint;

			//Distort
			sampler2D _TexDistort;
			float4 _TexDistort_TilingScroll;
			float4 _DistortParam;


			
			v2f vert (appdata v)
			{	
				v2f o;
				o.vertex  = UnityObjectToClipPos(v.vertex);
				o.uv1.xy = v.uv;
				o.uv1.zw = v.uv * _InactiveTex_TilingScroll.xy   + frac(_InactiveTex_TilingScroll.zw   * _Time.y); // Part Inactive
				o.uv2.xy = v.uv * _TransitionTex_TilingScroll.xy + frac(_TransitionTex_TilingScroll.zw * _Time.y); // Part Transition
				o.uv2.zw = v.uv * _TexDistort_TilingScroll.xy    + frac(_TexDistort_TilingScroll.zw    * _Time.y);; //Distort

				o.color = v.color;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				// distort
				fixed2 distortion = (tex2D(_TexDistort, i.uv2.zw).rg - 0.5) * _DistortParam.xy;


				fixed4 col;
				// Part Inactive
				float Inactive_Mask = step(i.uv1.y, _Level );
				float Inactive_Tex = tex2D(_InactiveTex, i.uv1.zw).r;
				col =  lerp(_InactiveTex_ColorWhiteTint, _InactiveTex_ColorBlackTint, Inactive_Tex) * (1-Inactive_Mask);

				// Part active
				float Transition_Tex = tex2D(_TransitionTex, i.uv2.xy + distortion).r;
				col += lerp(_ActiveTex_ColorWhiteTint, _ActiveTex_ColorBlackTint, Transition_Tex) * Inactive_Mask;



				// Part Transition

				float3 Transition = smoothstep(1, 0, abs((i.uv1.y -_Level) * _Transition_Param.xyz)) * float3(step(0,i.uv1.y - _Level), step(i.uv1.y - _Level,0), step(i.uv1.y - _Level,0));
				fixed dissolve = saturate(((Transition_Tex + lerp(_Transition_Dissolve.x, _Transition_Dissolve.y, Transition.x + Transition.y)) * 50 - 25 ) / _Transition_Dissolve.z);
				col = col * (1-dissolve) + lerp(_TransitionTex_ColorBlackTint, _TransitionTex_ColorWhiteTint, Transition_Tex) * dissolve + _Transition_Param.w * (Transition.x + Transition.z) * _TransitionTex_BrightnessColor;



				
				return col;
			}
			ENDCG
		}
	}
}
