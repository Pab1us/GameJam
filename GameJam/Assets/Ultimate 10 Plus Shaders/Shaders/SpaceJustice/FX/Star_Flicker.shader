Shader "SpaceJustice/FX/Star_Flicker"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_ColorTint ("Color tint", Color) = (1,1,1,1)
		_ScanTiling ("Ratio", Float) = 10.0
		_Width ("Pulse width", Float) = 0.6

		_ScaleOffset ("ScaleOffset", Float) = 1.0
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
				float2 uv : TEXCOORD0;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				fixed4 color : COLOR0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _ColorTint;
			half _ScanTiling;
			half _Period;
			half _Width;
			half _Number;
			half _ScaleOffset;

			v2f vert (appdata v)
			{
				v2f o;
				float4 wpos = mul(unity_ObjectToWorld, v.vertex);
				half3 wnorm = UnityObjectToWorldNormal(v.normal);
				half3 wtang = normalize(UnityObjectToWorldDir(v.tangent.xyz));
				half tangS  = v.tangent.w * unity_WorldTransformParams.w;
				half3 wbi = normalize(cross(wnorm, wtang) * tangS);

				fixed tris_new = saturate(frac(_Time.x * _ScanTiling + v.color.a) - _Width) / (1.0f - _Width);
				fixed tris_add = 2.0f * min(tris_new, 1.0f - tris_new);

				_ScaleOffset *= tris_add;

				half3 tangOffset = wtang * (v.uv.x - 0.5f) * _ScaleOffset;
				half3 bitangOffset = wbi * (v.uv.y - 0.5f) * _ScaleOffset;

				half3 offsetVec = (tangOffset + bitangOffset) * 0.5f;

				o.vertex = mul(UNITY_MATRIX_VP, wpos + float4(offsetVec, 0.0f));

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color;
				o.uv1 = v.vertex;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 tex = tex2D(_MainTex, i.uv.xy);

				//fixed tris_new = saturate(frac(i.uv1.x * _ScanTiling)-_Width)/(1-_Width);
				//fixed tris_add = 1.5 * min (tris_new, 1- tris_new);

				fixed4 col;
				col.rgb = _ColorTint.rgb * tex.rgb * i.color;
				col.a = tex.a;

				return col;
			}
			ENDCG
		}
	}
}
