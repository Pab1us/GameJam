Shader "SpaceJustice/FX/Scroll/Scroll Distort Alpha"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_MainTex_TilingScroll ("Tiling Scroll", Vector) = (1,1,0,0)
		_MainTex_Offset ("Offset XY", Vector) = (0,0,0,0)

		[Header(Distort)]
		[NoScaleOffset]
		_DistortTex ("Distort Texture", 2D) = "white" {}
		_DistortTex_TilingScroll ("Tiling Scroll", Vector) = (1,1,0,0)

		_DistortPower ("Power UV", Vector) = (0,0,0,0)

		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0

		_ZWrite ("ZWrite", Float) = 1
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Transparent"
			"Queue" = "Transparent"
		}

		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp]
		}

		BlendOp Add
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite [_ZWrite]

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
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
        float4 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			sampler2D _MainTex;
			half4 _MainTex_TilingScroll;
			half2 _MainTex_Offset;

			sampler2D _DistortTex;
			half4 _DistortTex_TilingScroll;
			half4 _DistortPower;

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex  = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.uv * _MainTex_TilingScroll.xy + frac(_MainTex_TilingScroll.zw * _Time.y) + _MainTex_Offset;
				o.uv.zw = v.uv * _DistortTex_TilingScroll.xy + frac(_DistortTex_TilingScroll.zw * _Time.y);

				o.color = v.color;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 dissTex = tex2D(_DistortTex, i.uv.zw);

				fixed4 mainTex = tex2D(_MainTex, i.uv.xy + (dissTex.xy - 0.5f) * _DistortPower.xy);

				return mainTex * i.color;
			}
			ENDCG
		}
	}
}
