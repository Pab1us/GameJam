
Shader "SpaceJustice/FX/Items/Laser"
{
	Properties
	{
        [Header(Texture)]
		_TilingLength("Tiling Length", Float) = 1.0
		_Tex1_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_Tex1_ColorBlackTint("Color black tint",Color) = (0,0,0,0)
		[NoScaleOffset]
		_Tex1 ("Texture BW", 2D) = "white" {}
		_Tex1_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)

        [Space(20)]
		_TexControl ("Brgh Alpha LinCol ", Vector) = (1, 1, 1, 0)
 		[Space(20)]
		[Header(Waves)]
		_Waves1Param ("Freq1 Speed1 Amp1", Vector) = (1, 0, 1, 0)
		_Waves2Param ("Freq2 Speed2 Amp2", Vector) = (1, 0, 1, 0)
		
	}
	SubShader
	{
		Tags { 	
				"RenderType"="Transparent" 
				"Queue" = "Transparent" 
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
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0; //xy Tex1 
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			//color
			sampler2D _Tex1;
			half4  _Tex1_TilingScroll;
			fixed4  _Tex1_ColorWhiteTint;
			fixed4  _Tex1_ColorBlackTint;

			float4 _TexControl;
			float3 _Waves1Param, _Waves2Param;
			float _TilingLength;


			
			v2f vert (appdata v)
			{	
				v2f o;
				o.vertex  = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv * _Tex1_TilingScroll.xy + frac(_Tex1_TilingScroll.zw * _Time.y);
				o.uv *= float2(_TilingLength, 1);


				o.color = v.color;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				//color
				float4 col;
				fixed tex1_BW = tex2D(_Tex1, i.uv.xy).r;

				fixed4 color1 = lerp(_Tex1_ColorBlackTint, _Tex1_ColorWhiteTint, pow(tex1_BW, _TexControl.z));

				col.rgb = color1.rgb  * _TexControl.x * i.color.rgb;

				fixed2 wave = (saturate(abs(frac(i.uv.x * fixed2(_Waves1Param.x, _Waves2Param.x) + fixed2(_Waves1Param.y, _Waves2Param.y)  * _Time.y) * 2 - 1)) - 1) * fixed2(_Waves1Param.z, _Waves2Param.z)+ 1;
		
				

				//alpha
				col.a = tex1_BW * _TexControl.y * i.color.a *_Tex1_ColorWhiteTint.a * wave.x * wave.y;

				
				return col;
			}
			ENDCG
		}
	}
}
