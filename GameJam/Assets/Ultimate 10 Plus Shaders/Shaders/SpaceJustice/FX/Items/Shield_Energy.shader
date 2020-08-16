Shader "SpaceJustice/FX/Shield/Shield Energy"
{
	Properties
	{
       
		[Header(MainTex)]
        _Opacity ("Opacity", Float) = 1
		_MainTex ("Main Texture", 2D) = "white" {}

		_MainTex_Color ("Main Texture Color 1", Color) = (1,1,1,1)


		[Header(Fill)]
        _FillTex ("Fill Texture", 2D) = "white" {}
        _FillTex_Tiling ("Tiling R and G", Vector) = (1,1,1,1)
		_FillTex_SpeedScroll ("SpeedScroll R and G", Vector) = (0,0,0,0)


        _FillTexR_Color ("Fill Texture R Color 1", Color) = (1,1,1,1)



        _FillTexG_Color1 ("Fill Texture G Color 1", Color) = (1,1,1,1)
        _FillTexG_Color2 ("Fill Texture G Color 2", Color) = (1,1,1,1)

        [Header(Distort)]
        _DistortTex ("Distort Texture", 2D) = "white" {}
        _DistortTex_SpeedScroll ("SpeedScroll", Vector) = (0,0,0,0)
        _PowerDistort ("PowerDistort ", Vector) = (0,0,0,0)

        [Header(Flicker alpha)]
        _Flicker  ("MainSpeed MainAmp FillSpeed FillAmp", Vector) = (0,0,0,0)


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
                float2 uv1     : TEXCOORD1;
			};

			struct v2f
			{
				float4 pos     : SV_POSITION;
				fixed4 color   : COLOR0;
				float4 uv      : TEXCOORD0; // xy Main texture   zw Fill texture R
				float4 uv1     : TEXCOORD1; // xy Fill texture G  zw  Distort  
                float2 flicker : TEXCOORD2; 
			};
            float _Opacity;
            // Main 
			sampler2D _MainTex;
			float4 _MainTex_ST;
			half4 _MainTex_Color;


            // Fill 
            sampler2D _FillTex;
            float4  _FillTex_ST;
            half4   _FillTex_Tiling;
            half4   _FillTex_SpeedScroll;

            half4   _FillTexR_Color;


            half4   _FillTexG_Color1;
            half4   _FillTexG_Color2;

            // Distort 
            sampler2D _DistortTex;
            float4  _DistortTex_ST;
            float4  _PowerDistort;
            float4  _DistortTex_SpeedScroll;

            // Flicker
            float4 _Flicker;





			v2f vert(appdata v)
			{
				v2f o;
				o.pos   = UnityObjectToClipPos(v.vertex);
				
				o.uv.xy   = TRANSFORM_TEX(v.uv, _MainTex); // Main texture
				o.uv.zw   = TRANSFORM_TEX(v.uv1 * _FillTex_Tiling.xy, _FillTex) + frac(_FillTex_SpeedScroll.xy * _Time.y); // Fill texture R
				o.uv1.xy  = TRANSFORM_TEX(v.uv1 * _FillTex_Tiling.zw, _FillTex) + frac(_FillTex_SpeedScroll.zw * _Time.y); // Fill texture G
                o.uv1.zw  = TRANSFORM_TEX(v.uv1, _DistortTex) + frac(_DistortTex_SpeedScroll.xy * _Time.y); // Distort

				o.flicker.x = abs(frac(_Time.w * _Flicker.x) *2.0 - 1.0); //flicker main
                o.flicker.y = abs(frac(_Time.w * _Flicker.z) *2.0 - 1.0); //flicker fill

                o.color = v.color;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
                half4 colorOut;

                // distortion
                half2 distort = tex2D(_DistortTex, i.uv1.zw).rg - float2(0.5, 0.5);

                // main color
                half4 mainTex_Color = tex2D(_MainTex, i.uv.xy);
                colorOut = _MainTex_Color * lerp(_MainTex_Color.a, _MainTex_Color.a - _Flicker.y, i.flicker.x) * mainTex_Color.r;

                // fill foreground 
                half4 FillTexR = _FillTexR_Color * lerp(_FillTexR_Color.a , _FillTexR_Color.a - _Flicker.w, i.flicker.y) * tex2D(_FillTex, i.uv.zw + distort * _PowerDistort.xy).r;
                colorOut += mainTex_Color.g * FillTexR;

                // fill background
                half4 FillTexG = lerp( _FillTexG_Color1, _FillTexG_Color2, tex2D(_FillTex, i.uv1  + distort * _PowerDistort.zw).g);
                colorOut += FillTexG * mainTex_Color.b;
                colorOut.a *= _Opacity;

				return colorOut;
			}
			
			
			ENDCG
		}
	}
}
