Shader "SpaceJustice/UI/Border Camera"
{
	Properties
	{
		_MainTex ("Particle Texture", 2D) = "white" {}
		_ColorBack ("Color background", Color) = (0,0,0,0)
		_ColorForward ("Color forward", Color) = (1,1,1,1)
		[Header( Gradient parameters     x scale     y offset )]
		_Gradient ("Parameters", Vector) = (15, 0.4, 0.7, 0)

		_Offset ("Offset in Camera space", Float) = 0

	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		fixed4 color  : COLOR;
		float2 uv     : TEXCOORD0;
	};

	struct v2f
	{
		float4 pos   : SV_POSITION;
		float4 uv    : TEXCOORD0;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	fixed4 _ColorBack, _ColorForward;
	float _Offset;
	float4 _Gradient;

	v2f vert(appdata v)
	{
		v2f o;
	
		o.pos   = UnityObjectToClipPos(v.vertex) + float4(0,0,_Offset,0);
		o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
		o.uv.zw = v.uv;

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 col = _ColorBack;
		col += tex2D(_MainTex, i.uv).r * _ColorForward * _ColorForward.a * (1 - i.uv.z);             // основная текстура с градиентом по U
		col += smoothstep(1, 0, i.uv.z * _Gradient.x + _Gradient.y) * _ColorForward * _ColorBack.a;   // отдельный нрадиент по U
	
		return col;
	}
	ENDCG

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
			"PreviewType"="Plane"

		}

		Pass
		{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}
