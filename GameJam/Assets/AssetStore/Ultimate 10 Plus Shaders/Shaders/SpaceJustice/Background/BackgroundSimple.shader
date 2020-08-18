Shader "SpaceJustice/Background/Background Simple"
{
	Properties
	{
		_MainTex("Background", 2D) = "black" {}
		_Offset ("Offset", float) = 0.0
		[Header(Obsolete)]
		_SpeedMove ("Speed", float) = 0.0
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata {
		float4 vertex : POSITION;
		float2 uv     : TEXCOORD0;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	float _Offset;

	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv  : TEXCOORD0;
	};

	v2f vert (appdata i) {
		v2f o;
		o.pos = UnityObjectToClipPos(i.vertex);
		o.uv  = TRANSFORM_TEX(i.uv, _MainTex);
		o.uv.y += frac(_Offset);
		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 color = tex2D(_MainTex, i.uv);
		return color;
	}
	ENDCG

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry" }
		Cull Back

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}