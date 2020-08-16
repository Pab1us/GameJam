#include "UnityCG.cginc"

struct appdata
{
	float4 vertex : POSITION;
	fixed4 color : COLOR;
	float2 uv : TEXCOORD0;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
	float4 pos : SV_POSITION;
	fixed4 color : COLOR0;
	fixed4 color1 : COLOR1;
	half2 uv : TEXCOORD0;
#ifdef _KEEPBRIGHT_ON
	fixed2 maxColor : TEXCOORD1;
#endif
};

sampler2D _MainTex;
float4 _MainTex_ST;

sampler2D _AdditionalTex;

#ifdef UNITY_INSTANCING_ENABLED
	UNITY_INSTANCING_BUFFER_START(PerDrawSprite)
		UNITY_DEFINE_INSTANCED_PROP(fixed4, unity_SpriteRendererColorArray)
		UNITY_DEFINE_INSTANCED_PROP(fixed2, unity_SpriteFlipArray)
	UNITY_INSTANCING_BUFFER_END(PerDrawSprite)

	#define _RendererColor UNITY_ACCESS_INSTANCED_PROP(PerDrawSprite, unity_SpriteRendererColorArray)
	#define _Flip UNITY_ACCESS_INSTANCED_PROP(PerDrawSprite, unity_SpriteFlipArray)
#else
	fixed4 _RendererColor;
	fixed2 _Flip;
#endif

#ifdef _KEEPBRIGHT_ON
	fixed2 _Bright;
#endif

UNITY_INSTANCING_BUFFER_START(Props)
	UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
	UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color1)
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
	o.color1 = i.color * UNITY_ACCESS_INSTANCED_PROP(Props, _Color1) * _RendererColor;

#ifdef _BLENDADD
	o.color.rgb *= o.color.a;
	o.color1.rgb *= o.color1.a;
#endif

	o.uv = TRANSFORM_TEX(i.uv, _MainTex);

#ifdef _KEEPBRIGHT_ON
	o.maxColor = fixed2(max(o.color.r, max(o.color.g, o.color.b)), max(o.color1.r, max(o.color1.g, o.color1.b)));
#endif

	return o;
}

fixed4 frag (v2f i) : SV_Target
{
	fixed4 col = tex2D(_MainTex, i.uv);
	fixed4 addCol = tex2D(_AdditionalTex, i.uv);
	fixed4 blendedCol;

#ifdef _KEEPBRIGHT_ON
	fixed grayScale = dot(col.rgb, fixed3(0.299f, 0.587f, 0.114f));
	col.rgb *= lerp(i.color.rgb, i.maxColor.r, grayScale * _Bright.x);
	grayScale = dot(addCol.rgb, fixed3(0.299f, 0.587f, 0.114f));
	addCol.rgb *= lerp(i.color1.rgb, i.maxColor.g, grayScale * _Bright.y);
#else
	col.rgb *= i.color.rgb;
	addCol.rgb *= i.color1.rgb;
#endif

#ifdef _BLENDADD
	blendedCol.rgb = col.rgb * col.a + addCol.rgb * addCol.a;
	blendedCol.a = 1.0f;
#else
	blendedCol.rgb = col.rgb + addCol.rgb;
	blendedCol.a = col.a * i.color.a + addCol.a * i.color1.a;
#endif

	return blendedCol;
}
