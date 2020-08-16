
Shader "SpaceJustice/FX/Shield/Shield Energy Curtain"
{
	Properties
	{
		_CurtainPos ("Curtain Pos", Float) = 0

		[Header (Main)]
		[NoScaleOffset]
		_ColorMainBack ("Color back",Color) = (0,0,0,0)
		_ColorMainFront1 ("Color 1",Color) = (1,1,1,1)
		_ColorMainFront2 ("Color 2",Color) = (1,1,1,1)

		[NoScaleOffset]
		_TexMask("TextureMask", 2D) = "white" {}
		_TexMask_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)

		[NoScaleOffset]
		_TexMain ("Texture", 2D) = "white" {}
		_TexMain_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)

		[Space(10)]
		[Header (Fresnel)]
		_ColorFresnel ("Color", Color) = (1,1,1,1)	
		_Fresnel ("Fresnel Start End", Vector) = (1,1,1,1)
		
		[Space(10)]
		[Header (Wave params)]
		_WaveColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_WaveColorBlackTint("Color black tint",Color) = (0,0,0,0)
		_WaveParam    ("Front Back DistU DistV", Vector) = (120,8,0,0)  //Front Back   DistortU DistortV
		_WaveDissolve ("Dissolve", Vector) = (1,1,0,0)  //Min Max Smooth+


		[NoScaleOffset]
		_TexCurtainNoise ("Noise", 2D) = "white" {}
		_TexCurtainNoise_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)


	}
	SubShader
	{
		Tags { 	
				"RenderType" = "Transparent" 
				"Queue"      = "Transparent"
			 }

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
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;  // base , _TexMain
				float4 uv1 : TEXCOORD1;  // _TexCurtainNoise , _TexMask
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
				float3 wpos   : TEXCOORD2;
				float3 normal : TEXCOORD3;
				
			};


			float _CurtainPos;
			fixed4 _ColorMainBack, _ColorMainFront1, _ColorMainFront2;

			sampler2D _TexMain;
			float4 _TexMain_TilingScroll;

			sampler2D _TexMask;
			float4 _TexMask_TilingScroll;

			sampler2D _TexCurtainNoise;
			float4 _TexCurtainNoise_TilingScroll;

			fixed4  _ColorFresnel;
			float4 _Fresnel;

			fixed4 _WaveColorWhiteTint, _WaveColorBlackTint;
			float4 _WaveParam, _WaveDissolve;


			
			v2f vert (appdata v)
			{	
				v2f o;
				o.vertex  = UnityObjectToClipPos(v.vertex);
				o.color = v.color;

				//fresnel
				o.wpos = mul(unity_ObjectToWorld, v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);

				o.uv.xy  = v.uv;
				o.uv.zw  = v.uv * _TexMain_TilingScroll.xy         + frac(_TexMain_TilingScroll.zw * _Time.y);
				o.uv1.xy = v.uv * _TexCurtainNoise_TilingScroll.xy + frac(_TexCurtainNoise_TilingScroll.zw * _Time.y);
				o.uv1.zw = v.uv * _TexMask_TilingScroll.xy         + frac(_TexMask_TilingScroll.zw * _Time.y);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{	
				//  основной визуал
				fixed texMask = tex2D(_TexMask, i.uv1.zw).r;
				fixed texMain = tex2D(_TexMain, i.uv.zw ).r;
				fixed4 col = lerp (_ColorMainBack, lerp(_ColorMainFront1, _ColorMainFront2, texMain),texMask) * fixed4(i.color.rgb,1);
				
				//Маска волны x - фронт  y - хвост
				fixed  texCurtainNoise = tex2D(_TexCurtainNoise, i.uv1.xy).r;
				fixed2 waveMask  = saturate(1 - (i.uv.x - _CurtainPos) * _WaveParam.xy * float2(1,-1));
				fixed2 waveDiss  = saturate(((texCurtainNoise + lerp(_WaveDissolve.y, _WaveDissolve.x, pow(waveMask, _WaveDissolve.z) )) * 50 - 25 ) / _WaveDissolve.w);
				fixed4 waveColor = lerp(_WaveColorBlackTint, _WaveColorWhiteTint, texCurtainNoise) * waveDiss.y * _WaveColorWhiteTint.a * 3;

				//fresnel

				float3 v = normalize(_WorldSpaceCameraPos.xyz - i.wpos);
				float3 rim = smoothstep(_Fresnel.y, _Fresnel.y - _Fresnel.x, dot(normalize(i.normal), v)) * _ColorFresnel.a * _ColorFresnel.rgb;

				col.rgb += rim * i.color.a;
				col += waveColor;
				col.a *= waveDiss.x;


		
				return col;
			}
			ENDCG
		}
	}
}
