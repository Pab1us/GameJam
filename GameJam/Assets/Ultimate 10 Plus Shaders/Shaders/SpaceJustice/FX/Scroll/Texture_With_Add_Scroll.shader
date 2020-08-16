Shader "SpaceJustice/FX/Scroll/Texture With Add Scroll"
{
	Properties
	{
		[Header(Base Texture)]
		_MainTex ("Texture (r - base, g - mask)", 2D) = "white" {}
		_Color0 ("Tint 0", Color) = (1,1,1,1)
		_Color1 ("Tint 1", Color) = (1,1,1,1)
		_Offset ("Z-Offset", Float) = 0

		[Header(Scroll Texture)]
		_ScrollTex ("Texture", 2D) = "black" {}
		_ColorS ("Tint", Color) = (1,1,1,1)
		_Speed ("Scroll Speed (x, y)", Vector) = (0.0, 0.0, 0.0, 0.0)
		_Tiling_Offset ("Tiling X/Y, Offset Z/W", vector) = (1., 1., 0., 0.)
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}

		BlendOp Add
		Blend One OneMinusSrcAlpha//, Zero One
		ZWrite Off
		Cull Off

		Pass
		{
		CGPROGRAM
		#include "../../Standard_Functions.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			fixed4 color : COLOR;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;
		fixed4 _Color0;
		fixed4 _Color1;
		float _Offset;

		sampler2D _ScrollTex;
		fixed4 _ColorS;
		half2 _Speed;
		half4 _Tiling_Offset;

		v2f vert(appdata i)
		{
			v2f o;

			o.pos = UnityObjectToClipPos(i.vertex);

		#if defined(UNITY_REVERSED_Z)
			o.pos.z -= _Offset * 0.47;
		#else
			o.pos.z += _Offset;
		#endif

			o.uv = TRANSFORM_TEX(i.uv, _MainTex);

			return o;
		}

		fixed4 frag (v2f i) : SV_Target
		{
			fixed2 col = tex2D(_MainTex, i.uv).rg;

			fixed4 Color = lerp(_Color0, _Color1, col.r);

			fixed3 base = col.r * Color.rgb;
			fixed mask = col.g;

			fixed alpha = Color.a;

			fixed scr = tex2D(_ScrollTex, i.uv * _Tiling_Offset.xy + frac(_Speed.xy * _Time.y + _Tiling_Offset.zw)).r * mask;

			return fixed4(base + _ColorS.rgb * scr, saturate(alpha + scr));
		}

		#pragma vertex vert
		#pragma fragment frag

		ENDCG
		}
	}
}
