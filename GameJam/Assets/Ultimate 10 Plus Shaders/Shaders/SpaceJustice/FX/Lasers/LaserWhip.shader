Shader "SpaceJustice/FX/Lasers/LaserWhip"
{
	Properties
	{
		_Tex_ColorWhiteTint ("Color White Tint", Color) = (1,1,1,1)
		_Tex_ColorBlackTint ("Color Black Tint", Color) = (0,0,0,0)
		[NoScaleOffset]
		_MainTex ("Main Texture", 2D) = "white" {}
		_MainTex_TilingScroll ("Tiling Scroll", Vector) = (1,1,0,0)
		_MainTex_Offset ("Offset XY", Vector) = (0,0,0,0)

		[Header(Distort)]
		[NoScaleOffset]
		_DistortTex ("Distort Texture", 2D) = "white" {}
		_DistortTex_TilingScroll ("Tiling Scroll", Vector) = (1,1,0,0)

		_DistortPower ("Power UV", Vector) = (0,0,0,0)

		[Header(Blending)]
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Operation", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFactor ("Source", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFactor ("Destination", Float) = 10
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Transparent"
			"Queue" = "Transparent"
		}

		BlendOp [_BlendOp]
		Blend [_SrcBlendFactor] [_DstBlendFactor]
		ZWrite Off

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
			};

			fixed4 _Tex_ColorWhiteTint;
			fixed4 _Tex_ColorBlackTint;

			sampler2D _MainTex;
			half4 _MainTex_TilingScroll;
			half2 _MainTex_Offset;
			half _PhaseOffset;

			sampler2D _DistortTex;
			half4 _DistortTex_TilingScroll;
			half4 _DistortPower;

			float3 _CurrentPoint;
			float3 _NextPoint;

			v2f vert (appdata v)
			{
				v2f o;

				float4 worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0f));
				worldPos.xyz += _CurrentPoint * v.color.r + _NextPoint * v.color.g;

				o.vertex = mul(UNITY_MATRIX_VP, worldPos);//UnityObjectToClipPos(v.vertex);

				half stretch = length(_CurrentPoint - _NextPoint);

				half2 tiling = _MainTex_TilingScroll.xy;
				tiling.x += stretch;

				o.uv.xy = v.uv * tiling + frac(_MainTex_TilingScroll.zw * _Time.y) + _MainTex_Offset;
				o.uv.x += _PhaseOffset;
				o.uv.zw = v.uv * _DistortTex_TilingScroll.xy + frac(_DistortTex_TilingScroll.zw * _Time.y);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 dissTex = tex2D(_DistortTex, i.uv.zw);

				fixed mainTex = tex2D(_MainTex, i.uv.xy + (dissTex - 0.5f.xx) * _DistortPower.xy).x;
				fixed4 col = lerp(_Tex_ColorBlackTint, _Tex_ColorWhiteTint, mainTex);

				return col;
			}
			ENDCG
		}
	}
}
