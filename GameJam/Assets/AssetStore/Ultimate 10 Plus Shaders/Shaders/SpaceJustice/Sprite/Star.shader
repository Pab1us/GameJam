Shader "SpaceJustice/Sprite/Star"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
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
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Off

		Pass
		{
		CGPROGRAM
		#pragma multi_compile _ PIXELSNAP_ON
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
			fixed4 color : COLOR0;
			float2 uv    : TEXCOORD0;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;
		fixed4 _Color;

		v2f vert(appdata v)
		{
			v2f o;
			o.pos   = UnityObjectToClipPos(v.vertex);
			#ifdef PIXELSNAP_ON
			o.pos = UnityPixelSnap (o.pos);
			#endif
			o.color = v.color * _Color;
			o.uv    = TRANSFORM_TEX(v.uv, _MainTex);
			return o;
		}

		fixed4 frag (v2f i) : SV_Target
		{
			fixed4 col = tex2D(_MainTex, i.uv);
			col *= i.color;
			return col;
		}
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}
