Shader "SpaceJustice/FX/Items/Plankton BlendAlpha"
{
	Properties
	{
		_Tex ("Texture", 2D) = "white" {}
		_ColorMaxDist ("Color DistMax", Color) = (1,1,1,1)
		_ColorMinDist ("Color DistMin", Color) = (1,1,1,1)
		_DistCameraMax ("Dist Max", Float) = 10
		_DistCameraMin ("Dist Min", Float) = 0
	}
	SubShader
	{
		Tags {
				"RenderType" = "Transparent"
				"Queue" = "Transparent"
			 }

		Blend SrcAlpha OneMinusSrcAlpha

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
				float2 uv : TEXCOORD0;
				float4 distPic : TEXCOORD1;
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
			};

			sampler2D _Tex;
			float4 _Tex_ST;

			fixed4 _ColorMaxDist, _ColorMinDist;
			half _DistCameraMax;
			half _DistCameraMin;

			v2f vert (appdata v)
			{
				v2f o;
				float4 wpos = mul(unity_ObjectToWorld, v.vertex);

				o.vertex = mul(UNITY_MATRIX_VP, wpos);
				o.uv = TRANSFORM_TEX(v.uv, _Tex);

				half dist = distance(wpos, _WorldSpaceCameraPos);
				half distNorm = saturate((dist - _DistCameraMin) / (_DistCameraMax - _DistCameraMin));

				fixed4 v1 = fixed4( 0.2f, 0.6f, 1.0f, 1.4f);
				fixed4 v2 = fixed4(-0.4f, 0.0f, 0.4f, 0.8f);
				o.distPic = saturate((distNorm - v1) * -5.0f) * saturate((distNorm - v2) * 5.0f);

				o.color = v.color * lerp(_ColorMinDist, _ColorMaxDist, distNorm);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = i.color;

				fixed4 tex = tex2D(_Tex, i.uv.xy) * i.distPic;

				//col.a = 0;
				//col.a = col.a * (1-tex.r) + tex.r;
				col.a = tex.r * (1.0f - tex.g) + tex.g;//col.a = col.a * (1.0f - tex.g) + tex.g;
				col.a = col.a *(1.0f - tex.b) + tex.b;
				col.a = col.a *(1.0f - tex.a) + tex.a;
				col.a *= i.color.a;

				return col;
			}
			ENDCG
		}
	}
}
