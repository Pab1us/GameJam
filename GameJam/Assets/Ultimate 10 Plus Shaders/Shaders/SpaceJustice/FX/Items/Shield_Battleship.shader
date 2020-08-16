
Shader "SpaceJustice/FX/Shield/Shield Battleship"
{
	Properties
	{
		[Header (Main)]
        _TexMain_Color("Color",Color) = (1,1,1,1)
		[NoScaleOffset]
		_TexMain ("Texture", 2D) = "white" {}
		_TexMain_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)
        _TexMainParam("DistU DistV Bright ", Vector) = (0,0,1,1)

		[Space(10)]
		[Header (Border params)]
		_WaveColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_WaveColorBlackTint("Color black tint",Color) = (0,0,0,0)
		_WaveParam    ("Front Back Dist Pos", Vector) = (1,1,0,0)  //Front Back   DistortU DistortV



		[Space(10)]
		[Header (Distort)]
		[NoScaleOffset]
		_TexDistort ("Noise", 2D) = "white" {}
		_TexDistort_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)

	}
	SubShader
	{
		Tags { 	
				"RenderType" = "Transparent" 
				"Queue"      = "Transparent"
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
				float4 uv : TEXCOORD0;  // base , _TexMain
				float2 uv1 : TEXCOORD1;  //  _TexDistort
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};


			float4 _TexMain_Color;
            sampler2D _TexMain;
			float4 _TexMain_TilingScroll;
            float4 _TexMainParam;

			fixed4 _WaveColorWhiteTint, _WaveColorBlackTint;
			float4 _WaveParam;

			sampler2D _TexDistort;
			float4 _TexDistort_TilingScroll;



			
			v2f vert (appdata v)
			{	
				v2f o;
				o.vertex  = UnityObjectToClipPos(v.vertex);

				o.uv.xy  = v.uv; //базовый мапинг для местоположения бордюра
				o.uv.zw  = v.uv * _TexMain_TilingScroll.xy + frac(_TexMain_TilingScroll.zw * _Time.y);    // мапинг основной текстуры 
				o.uv1 = v.uv * _TexDistort_TilingScroll.xy + frac(_TexDistort_TilingScroll.zw * _Time.y); // мапинг текстуры искаджений

				o.color = v.color;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 texDistort = tex2D(_TexDistort, i.uv1).xy - 0.5;
				fixed4 texMain    = tex2D(_TexMain, i.uv.zw + texDistort * _TexMainParam.xy);
                fixed4 texMainColor = texMain.x * _TexMain_Color;

				//Маска бордюра x - передняя чась  y - задняя
				fixed2 bord = saturate(1 - (i.uv.x + texDistort.x * _WaveParam.z - _WaveParam.w) * _WaveParam.xy * float2(1,-1));

				fixed4 bordColor = lerp(_WaveColorBlackTint, _WaveColorWhiteTint, bord.y * bord.x);

				fixed4 col = texMainColor * i.color *_TexMainParam.z * (1-bord.y) + bordColor*bord.y * bord.x;

				return col;
			}
			ENDCG
		}
	}
}
