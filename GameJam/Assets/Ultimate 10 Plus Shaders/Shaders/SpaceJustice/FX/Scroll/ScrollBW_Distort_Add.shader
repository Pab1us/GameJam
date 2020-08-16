Shader "SpaceJustice/FX/Scroll/ScrollBW_Distort_Add"
{
	Properties
	{
		_Offset ("Depth Offset", Float) = 0
		_Tex_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_Tex_ColorBlackTint("Color black tint",Color) = (0,0,0,0)
		[NoScaleOffset] _Tex ("Texture BW", 2D) = "white" {}
		_Tex_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)
		_TexControl ("Brgh VertA LinCol LinDist", Vector) = (1, 1, 1, 1)
		[Space(10)]
		[Header(Distort (mask in vertex A))]
		[NoScaleOffset] _TexDistort ("Distort Texture", 2D) = "white" {}
		_TexDistort_TilingScroll ("Tiling Scroll", Vector) = (1,1,0,0)
		_Distort ("Distort A=1  and A=0", Vector) = (0,0,0,0)

		_AlphaFactor ("Alpha Factor", Float) = 1.
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		half2 uv : TEXCOORD0;
		fixed4 color : COLOR;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		half4 uv : TEXCOORD0;
		fixed alpha : TEXCOORD1;
		fixed4 color : COLOR;
	};

	half _Brighness;
	fixed _AlphaVertEffect;

	sampler2D _Tex;
	half4 _Tex_TilingScroll;
	fixed4 _Tex_ColorWhiteTint;
	fixed4 _Tex_ColorBlackTint;
	half4 _TexControl;

	sampler2D _TexDistort;
	half4 _TexDistort_TilingScroll;
	half4 _Distort;

	UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_DEFINE_INSTANCED_PROP(float, _Offset)
		UNITY_DEFINE_INSTANCED_PROP(float, _AlphaFactor)
	UNITY_INSTANCING_BUFFER_END(Props)

	v2f vert (appdata i)
	{
		UNITY_SETUP_INSTANCE_ID(i);
		v2f o;

		float offset = UNITY_ACCESS_INSTANCED_PROP(Props, _Offset);
		float alphaFactor = UNITY_ACCESS_INSTANCED_PROP(Props, _AlphaFactor);

		o.pos = UnityObjectToClipPos(i.vertex);

#if defined(UNITY_REVERSED_Z)
		o.pos.z -= offset * 0.47;
#else
		o.pos.z += offset;
#endif

		o.uv.xy = i.uv * _Tex_TilingScroll.xy + frac(_Tex_TilingScroll.zw * _Time.y);
		o.uv.zw = i.uv * _TexDistort_TilingScroll.xy + frac(_TexDistort_TilingScroll.zw * _Time.y);
		o.color = i.color;
		o.alpha = alphaFactor;

		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed2 distortion = tex2D(_TexDistort, i.uv.zw).rg;
    i.uv.xy += (distortion - 0.5f) * lerp(_Distort.zw, _Distort.xy, i.color.a);

		fixed4 col;
		fixed tex_BW = tex2D(_Tex, i.uv.xy).r;
		fixed4 color1 = lerp(_Tex_ColorBlackTint, _Tex_ColorWhiteTint, pow(tex_BW, _TexControl.z));
		col.rgb = color1.rgb * _TexControl.x * i.color.rgb * i.alpha;

		col.a = tex_BW * (i.color.a * _TexControl.y + 1.0f -_TexControl.y) * _Tex_ColorWhiteTint.a * i.alpha;

		return col;
	}
	ENDCG

	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		Blend SrcAlpha One
		ZWrite Off
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma multi_compile_instancing
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
