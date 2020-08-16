#include "UnityCG.cginc"

sampler2D _Texture01;
float4 _Texture01_ST;
half4 _Texture01Params;
fixed4 _Color01;

sampler2D _TextureDistortion;
float4 _TextureDistortion_ST;
half4 _Params;

struct appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
	fixed4 color : COLOR;
};

struct v2f
{
	float4 pos : SV_POSITION;
	float4 uv : TEXCOORD0;// tex / dist
	fixed4 color : COLOR0;
};

v2f vert (appdata v)
{
	v2f o;

	o.pos = UnityObjectToClipPos(v.vertex);

	o.uv.xy = TRANSFORM_TEX(v.uv, _Texture01) + _Time.y * _Texture01Params.xy;
	o.uv.zw = TRANSFORM_TEX(v.uv, _TextureDistortion) + _Time.y * _Params.xy;

	o.color = v.color;

	return o;
}

fixed4 frag (v2f i) : SV_Target
{
	half2 dist = tex2D(_TextureDistortion, i.uv.zw).xy - 0.5f.xx;
	fixed4 tex = tex2D(_Texture01, i.uv.xy + dist * _Texture01Params.zw);

	fixed4 color = _Color01 * tex;
	color.rgb = color.rgb * color.a;

	return color * i.color;
}
