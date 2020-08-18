#include "UnityCG.cginc"

#define BlendHardLight(base, blend) (blend < 0.5 ? (2.0 * blend * base) : (1.0 - 2.0 * (1.0 - blend) * (1.0 - base)))

struct appdata {
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float2 uv : TEXCOORD0;
	float2 uvWave : TEXCOORD1;
	#if _SEPARATELIGHT_ON
	float2 uv1 : TEXCOORD2;
	#endif
	//#if _VERTEXCOLOR_ON || _VERTEXCOLOR_MAP
	fixed4 color : COLOR;
	//#endif
};

struct v2f {
	float4 pos    : SV_POSITION;
	float4 uv     : TEXCOORD0; // _MainTex _LightTex
	float4 light  : TEXCOORD1;
	float2 uvWave : TEXCOORD2;
	#if _BUMP_ON
	float4 tS0 : TEXCOORD3;
	float4 tS1 : TEXCOORD4;
	float4 tS2 : TEXCOORD5;
	#else
	float3 wpos   : TEXCOORD3;
	float3 normal : TEXCOORD4;
	#endif
	//#if _VERTEXCOLOR_ON || _VERTEXCOLOR_MAP
	fixed4 color  : COLOR0;
	//#endif
};

sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _WaveTex;
float4 _WaveTex_ST;
#if _SEPARATELIGHT_ON
sampler2D _LightTex;
float4 _LightTex_ST;
#endif
#if _BUMP_ON
sampler2D _BumpMap;
#endif
sampler2D _MaskTex;
#if _REFLECTION_ON
samplerCUBE _ReflectionTex;
#endif

float _WaveSize;
fixed4 _WaveColor;

float2 _WaveDirection;
float _WaveSpeed;
float _WaveEffectDuration;
float _WavePauseDuration;
float _WaveTimer;

fixed4 _AmbientColor;
fixed4 _DiffuseColor;
fixed4 _ShadowColor;
float4 _HardnessAndShift;

fixed _Shininess;
fixed4 _SpecularColor;
fixed4 _ReflectionColor;

fixed _RimStart;
fixed _RimEnd;
fixed4 _RimColor;
fixed4 GlobalRimColor;

fixed4 _IlluminationColor;

fixed4 _GrayScaleColor;

sampler2D _FogLUT;
float2 _FogLUTParams; // x: -1/(end-start) y: end/(end-start)

fixed4 _rColor;
fixed4 _gColor;
fixed4 _bColor;
fixed4 _aColor;

fixed _Translucency;

float avoidDBZ (float value)
{
  float signValue = abs(sign(value));
  return (1. * signValue) / (value + (signValue - 1.));
}

inline float2 planeRotation(float2 direction, float2 XY)
{
	return float2(XY.x * direction.x + XY.y * direction.y, -XY.x * direction.y + XY.y * direction.x);
}

v2f vert(appdata i)
{
	v2f o;

	float4 wpos = mul(unity_ObjectToWorld, i.vertex);

	o.pos = mul(UNITY_MATRIX_VP, wpos);

	o.uv.xy = TRANSFORM_TEX(i.uv, _MainTex);
	o.light = mul(UNITY_MATRIX_I_V, unity_LightPosition[0]);

	#if _SEPARATELIGHT_ON
	o.uv.zw = TRANSFORM_TEX(i.uv1, _LightTex);
	#else
	o.uv.zw = float2(0, 0);
	#endif

	o.uvWave = i.uvWave;

	#if _BUMP_ON
	fixed3 wnorm = UnityObjectToWorldNormal(i.normal);
	fixed3 wtang = UnityObjectToWorldDir(i.tangent);
	fixed tangS = i.tangent.w * unity_WorldTransformParams.w;
	fixed3 wbi = cross(wnorm, wtang) * tangS;
	o.tS0 = float4(wtang.x, wbi.x, wnorm.x, wpos.x);
	o.tS1 = float4(wtang.y, wbi.y, wnorm.y, wpos.y);
	o.tS2 = float4(wtang.z, wbi.z, wnorm.z, wpos.z);
	#else
	o.wpos = wpos.xyz;
	o.normal = UnityObjectToWorldNormal(i.normal);
	#endif

	//#if _VERTEXCOLOR_ON || _VERTEXCOLOR_MAP
	o.color = i.color;
	//#endif
	return o;
}

fixed4 frag(v2f i) : SV_Target
{
	fixed4 color = tex2D(_MainTex, i.uv.xy);

	#if _SEPARATELIGHT_ON
	color *= 2.0 * tex2D(_LightTex, i.uv.zw);
	#endif

	#if _VERTEXCOLOR_ON
	color *= i.color;
	#endif

	#if _VERTEXCOLOR_MAP
	float3 rColor = i.color.r * _rColor.rgb;
	float3 gColor = i.color.g * _gColor.rgb;
	float3 bColor = i.color.b * _bColor.rgb;
	float3 aColor = i.color.a * _aColor.rgb;

	color.rgb *= (rColor + gColor + bColor + aColor) * avoidDBZ(i.color.r + i.color.g + i.color.b + i.color.a);
	#endif

	//#if _MASK_ON
	fixed4 mask = tex2D(_MaskTex, i.uv.xy);
	//#endif

	#if _BUMP_ON
	float3 wpos = float3(i.tS0.w, i.tS1.w, i.tS2.w);
	float3 norm = normalize(UnpackNormal(tex2D(_BumpMap, i.uv.xy)));
	fixed3 n;
	n.x = dot(i.tS0.xyz, norm);
	n.y = dot(i.tS1.xyz, norm);
	n.z = dot(i.tS2.xyz, norm);
	#else
	float3 wpos = i.wpos;
	fixed3 n = normalize(i.normal);
	#endif
	float3 l = normalize(i.light.xyz - wpos * i.light.w);

	#if _SPECULAR_ON || _RIM_ON || _REFLECTION_ON
	float3 v = normalize(_WorldSpaceCameraPos.xyz - wpos);
	#endif
	#if _SPECULAR_ON || _REFLECTION_ON
	float3 r = reflect(-v, n);
	#endif

	#if _REFLECTION_ON
	fixed4 reflection = texCUBE(_ReflectionTex, r);
	float reflectionIntensity = _ReflectionColor.a;
	#if _MASK_ON
	reflectionIntensity *= mask.g;
	#endif
	color.rgb = lerp(color.rgb, reflection.rgb * _ReflectionColor.rgb, reflectionIntensity);
	#endif

	fixed3 light = _AmbientColor.rgb * _AmbientColor.a;
	#if _AMBIENTREACT_ON
	light *= UNITY_LIGHTMODEL_AMBIENT;
	#endif

	fixed3 lightColor = unity_LightColor[0].rgb * _DiffuseColor.a * _DiffuseColor.rgb;
	fixed3 shadowColor =  _ShadowColor.rgb * _ShadowColor.a;
	float3 ndl = dot(n, l);
	light += max(ndl * _HardnessAndShift.x + _HardnessAndShift.y, 0) * lightColor;
	light += max((1 - max(ndl * _HardnessAndShift.z + _HardnessAndShift.w, 0)), 0) * shadowColor;

	#if _SPECULAR_ON
	float3 specular = pow(max(dot(l, r), 0), _Shininess * 128) * _SpecularColor.a * _SpecularColor.rgb * lightColor;
	#if _MASK_ON
	specular *= mask.g;
	#endif
	light += specular;
	#endif

	#if _ILLUMINATION_ON
	float illuminationIntensity = _IlluminationColor.a;
	#if _MASK_ON
	illuminationIntensity *= mask.b;
	#endif
	light = lerp(light, _IlluminationColor.rgb, illuminationIntensity);
	#endif

	color.rgb	*= light;

	#if _RIM_ON
	fixed4 rimColor;
	#if _GLOBALRIMCOLOR_ON
	rimColor = GlobalRimColor;
	#else
	rimColor = _RimColor;
	#endif
	fixed rim = smoothstep(_RimEnd, _RimEnd - _RimStart, dot(n, v));
	float3 rim3 = rim * rimColor.a * rimColor.rgb;
	#if _MASK_ON
	rim3 *= mask.r;
	#endif
	color.rgb += rim3;

	//#if _GLASIFY_ON
	color.a = lerp(color.a, color.a * rim, _Translucency);
	//#endif
	#endif

	#if _FOG_ON
	fixed4 fog = tex2D(_FogLUT, float2(wpos.z * _FogLUTParams.x + _FogLUTParams.y, 0.5));
	color.rgb = lerp(color.rgb, fog.rgb, fog.a);
	#endif

	#if _GRAYSCALE_ON
	color.rgb = dot(color.rgb, fixed3(0.299, 0.587, 0.114)) * _GrayScaleColor.rgb * 2.0 * _GrayScaleColor.a;
	#endif

	//Add wave

	if (i.color.r > 0.0f)
	{
		float timer;
		#ifdef _WAVE_HANDLED_TIMER_ON
		timer = _WaveTimer;
		#else
		timer = frac(_Time.y * _WaveSpeed);
		#endif

		float fullCycleDuration = _WaveEffectDuration + _WavePauseDuration;
		float wavePauseMomentDuration = _WavePauseDuration / fullCycleDuration;
		float waveEffectMomentDuration = _WaveEffectDuration / fullCycleDuration;

		if (timer * fullCycleDuration > _WavePauseDuration)
		{
			float2 direction = normalize(_WaveDirection);

			fixed4 wave;

			#ifdef _WAVE_TEXTURED_ON
			float2 uv = planeRotation(direction, i.uvWave - direction * (saturate(timer - wavePauseMomentDuration) * 2.0f / waveEffectMomentDuration - 1.0f) - 0.5f.xx) + 0.5f.xx;
			wave = tex2D(_WaveTex, uv / float2(_WaveSize, 1.0f)) * _WaveColor * i.color.r;
			#else
			float2 uv = planeRotation(direction, i.uvWave - 0.5f.xx) + 0.5f.xx;
			wave = saturate(1.0f - abs(uv.x - saturate(timer - wavePauseMomentDuration) * 3.0f / waveEffectMomentDuration + 1.0f) * 2.0f / _WaveSize) * _WaveColor * i.color.r;
			#endif

			color.rgb += (wave * _WaveColor).xyz * i.color.r;
		}
	}

	return color;
}
