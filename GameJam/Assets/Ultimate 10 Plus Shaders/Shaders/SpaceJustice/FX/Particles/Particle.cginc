#include "UnityCG.cginc"

struct appdata
{
	float4 vertex : POSITION;
	fixed4 color  : COLOR;
	float2 uv     : TEXCOORD0;
};

struct v2f
{
	float4 pos : SV_POSITION;
	fixed4 color : COLOR0;
	float2 uv : TEXCOORD0;
#ifdef _KEEPBRIGHT_ON
	fixed maxColor : TEXCOORD1;
#endif
};

sampler2D _MainTex;
float4 _MainTex_ST;

fixed4 _Color;
half _Multiplier;

#ifdef _KEEPBRIGHT_ON
fixed _Bright;
#endif

v2f vert(appdata v)
{
	v2f o;
	o.pos = UnityObjectToClipPos(v.vertex);
	o.color = v.color;
	
	#if _USECOLOR_ON
	o.color *= _Color;
	#endif
	
	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	
#ifdef _KEEPBRIGHT_ON
	o.maxColor = max(o.color.r, max(o.color.g, o.color.b));
#endif
	
	return o;
}

fixed4 frag (v2f i) : SV_Target
{
	fixed4 col = tex2D(_MainTex, i.uv);
	
#ifdef _KEEPBRIGHT_ON
	fixed grayScale = dot(col.rgb, fixed3(0.299f, 0.587f, 0.114f));
	col.rgb *= lerp(i.color.rgb, i.maxColor.xxx, grayScale * _Bright);
	col.a *= i.color.a;
#else
	col *= i.color;
#endif
	
#if _USECOLOR_ON
	col *= _Multiplier;
#endif
	
/*
	#if _LEGACY_ON
	bool p = fmod(16 * i.uv.x,2) < 1;
	bool q = fmod(16 * i.uv.y,2) > 1;
	bool c = p != q;
	col = lerp(col, float4(1, 0, 0, col.a), c);
	#endif
*/
	return col;
}
