Shader "SpaceJustice/FX/Items/Battleship_LogoHome Particles"
{
	Properties
	{
		[NoScaleOffset]
		_Tex ("Texture", 2D) = "white" {}

		_ColorContur("Contur A",Color) = (1,1,1,1)
		_ColorScan1("Scan1 R",Color) = (1,1,1,1)
		_ColorScan2("Scan2 R",Color) = (1,1,1,1)
		_ColorBack("Back G",Color) = (0,0,0,0)

		[Space(10)]
		[Header(Scanline)]

		_ScanParam ("Scan - Tiling Speed Level", Vector) = (1,1,1,1)
		_WaveParam ("Wave - Tiling Speed Level", Vector) = (1,1,1,1)
		_FlickerParam ("Flicker - Speed Level", Vector) = (1,1,1,1)
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
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
				float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
				float4 color : COLOR;
			};

			sampler2D _Tex;

			half4 _ColorScan1, _ColorScan2;
			half4 _ColorBack;
			half4 _ColorContur;
			float4 _ScanParam, _WaveParam, _FlickerParam;
			float _Brightness;

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex  = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.uv;
				o.color = v.color;
				o.color.a *= abs(frac(_Time.w * _FlickerParam.x) * 2.0f - 1.0f) * _FlickerParam.y + (1.0f - _FlickerParam.y);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 scan = abs(frac(i.uv.y * float2(_ScanParam.x, _WaveParam.x)  + _Time.w * float2(_ScanParam.y, _WaveParam.y)) * 2.0f - 1.0f) * float2(_ScanParam.z, _WaveParam.z);
				half4 tex = tex2D(_Tex, i.uv);
				half4 col;

				col = _ColorBack * half4(1.0f, 1.0f, 1.0f, tex.g);  //задник
        col = col * (1.0f - tex.r) + (lerp(_ColorScan1, _ColorScan2, scan.x) + scan.y * _WaveParam.z) * tex.r; // сканлинии
        col = col * (1.0f - tex.a) + _ColorContur * tex.a; // контур
        col = saturate(col);
				col *=  i.color;

				return col;
			}
			ENDCG
		}
	}
}
