#include "UnityCG.cginc"

#define COLOR_MULTIPLIER 3.0

struct appdata
{
	float4 vertex : POSITION;
	fixed4 color  : COLOR;
	float2 uv     : TEXCOORD0;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
	float4 pos : SV_POSITION;
	fixed4 color : COLOR0;
	float2 uv : TEXCOORD0;
};

sampler2D _MainTex;
float4 _MainTex_ST;

#ifdef UNITY_INSTANCING_ENABLED
    UNITY_INSTANCING_BUFFER_START(PerDrawSprite)
        UNITY_DEFINE_INSTANCED_PROP(fixed4, unity_SpriteRendererColorArray)
        UNITY_DEFINE_INSTANCED_PROP(fixed2, unity_SpriteFlipArray)
    UNITY_INSTANCING_BUFFER_END(PerDrawSprite)

    #define _RendererColor  UNITY_ACCESS_INSTANCED_PROP(PerDrawSprite, unity_SpriteRendererColorArray)
    #define _Flip           UNITY_ACCESS_INSTANCED_PROP(PerDrawSprite, unity_SpriteFlipArray)
#else
    fixed4 _RendererColor;
    fixed2 _Flip;
#endif

UNITY_INSTANCING_BUFFER_START(Props)
	UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
	UNITY_DEFINE_INSTANCED_PROP(float, _Offset)
UNITY_INSTANCING_BUFFER_END(Props)

inline float4 UnityFlipSprite(in float3 pos, in fixed2 flip)
{
    return float4(pos.xy * flip, pos.z, 1.0);
}

v2f vert(appdata i)
{
	UNITY_SETUP_INSTANCE_ID(i);

	v2f o;
	o.pos = UnityFlipSprite(i.vertex, _Flip);
	o.pos = UnityObjectToClipPos(i.vertex);

#ifdef PIXELSNAP_ON
	o.pos = UnityPixelSnap (o.pos);
#endif

	float offset = UNITY_ACCESS_INSTANCED_PROP(Props, _Offset);

#if defined(UNITY_REVERSED_Z)
	o.pos.z -= offset * 0.47;
#else
	o.pos.z += offset;
#endif

	o.color = i.color * UNITY_ACCESS_INSTANCED_PROP(Props, _Color) * _RendererColor;

#ifdef _SPECIAL_BLEND
	fixed alphaBlendFactor = saturate(max(max(o.color.r, o.color.g), o.color.b) * COLOR_MULTIPLIER - 1.0f); // 0 = alphablend, 1 = additive blend
	o.color.a *= (1.0f - alphaBlendFactor);

	o.color.rgb *= COLOR_MULTIPLIER * i.color.a;
#else
#if _BLENDADD
	o.color.rgb *= o.color.a;
#endif
#endif

	o.uv = TRANSFORM_TEX(i.uv, _MainTex);
	return o;
}

fixed4 frag (v2f i) : SV_Target
{
	fixed4 col = tex2D(_MainTex, i.uv);

	col.rgb *= i.color.rgb;

#ifdef _SPECIAL_BLEND
	col.rgb *= col.a;
#endif

	col.a *= i.color.a;

	return col;
}
