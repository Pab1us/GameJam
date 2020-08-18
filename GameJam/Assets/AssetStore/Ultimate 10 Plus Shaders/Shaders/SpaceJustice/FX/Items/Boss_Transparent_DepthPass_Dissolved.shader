Shader "SpaceJustice/FX/Items/Boss (Transparent) Depth Pass Dissolved"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}

		[Header(Ambient)]
		_AmbientColor ("Color", Color) = (1., 1., 1., 1.)

		[Header(Direct Lighting)]
		_DiffuseColor ("Color", Color) = (1., 1., 1., 1.)
		_ShadowColor ("Shadow Color", Color) = (0., 0., 0., 0.)
		_HardnessAndShift ("Hardness And Shift (XY - Direct ZW - Shadow)", Vector) = (1.,0.,1.,0.)

		[Header(Mask)]
		[Toggle] _Mask("Enabled", Float) = 0.
		[NoScaleOffset] _MaskTex ("Texture  (A - rim G - spec/refl B - self illum)", 2D) = "white" {}

		[Header(Rim (R mask channel))]
		_RimStart ("Start", Range(0., 1.)) = 1.
		_RimEnd ("End", Range(0., 1.)) = 1.

		[Header(Specular (G mask channel))]
		[Toggle] _Specular("Enabled", Float) = 0.
		_Shininess ("Shininess", Range(0.01, 1.)) = 1.
		_SpecularColor ("Color", Color) = (1., 1., 1., 1.)
		
		[Header(SelfIllumination (B mask channel))]
		[Toggle] _Illumination("Enabled", Float) = 0.
		_IlluminationColor ("Color", Color) = (1,1,1,1)

		[Header(Transparency)]
		_Transparency ("Transparency", Range(0., 1.)) = 1.

		[Header(Fog)]
		[Toggle] _Fog("Fog Enabled", Float) = 0.

		[Header(Hit)]
		[Toggle] _Hit("Enabled", Float) = 0.
		[PerRendererData] _HitColorNew ("Hit Color", Color) = (0,0,0,0)
		[PerRendererData] _HitRatio ("Hit Ratio", Range (0, 1)) = 0.

		////Dissolve
		[Space(10)]
		[Header (Dissolve params)]
		[NoScaleOffset]
		_TexDiss ("Dissolve tex", 2D) = "white" {}
		_TexDiss_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)

		_DissColorBorder("Diss Color Border",Color) = (1,1,1,1)
		_DissParam("Diss Width Border Smoth", Vector) = (1,1,1,1)

		[Space(10)]
		[NoScaleOffset]
		_TexDistort ("Distort tex", 2D) = "white" {}
		_TexDistort_TilingScroll ("Tiling Scroll ", Vector) = (1,1,0,0)
		_DistParam ("Dist", Vector) = (0,0,0,0)

		[Space(10)]
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Culling Mode", Float) = 0
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
			"IgnoreProjector" = "true"
		}

		Pass
		{
			ZWrite On
			ColorMask 0
		}

		Pass
		{
			Tags {"LightMode" = "Vertex"}

			BlendOp Add
			Blend SrcAlpha OneMinusSrcAlpha
			Cull [_CullMode]
			ZWrite Off

			CGPROGRAM
			#pragma shader_feature _MASK_ON
			#pragma shader_feature _SPECULAR_ON
			#pragma shader_feature _ILLUMINATION_ON
			#pragma shader_feature _FOG_ON
			#pragma shader_feature _HIT_ON

			struct appdata_over
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				fixed4 color : COLOR;
			};

			struct v2f_over
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;//_MainTex _LightTex
				float4 light : TEXCOORD1;
				float4 uvDiss : TEXCOORD2;//_TexDiss , _TexDistort
				float2 uvDissBase : TEXCOORD3;
				float3 wpos : TEXCOORD4;
				half3 normal : TEXCOORD5;
				fixed4 color : COLOR0;
			};

			//Dissolve
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _AmbientColor;
			fixed4 _DiffuseColor;
			fixed4 _ShadowColor;
			float4 _HardnessAndShift;
			fixed _Shininess;
			fixed4 _SpecularColor;
			fixed _RimStart;
			fixed _RimEnd;
			fixed4 _RimColor;
			fixed4 _IlluminationColor;
			sampler2D _MaskTex;
			sampler2D _FogLUT;
			float2 _FogLUTParams;

			fixed4 _rColor;
			fixed4 _gColor;
			fixed4 _bColor;
			fixed4 _aColor;

			fixed4 _HitColorNew;
			float _HitRatio;
			sampler2D _TexDiss;
			half4 _TexDiss_TilingScroll;
			fixed4 _DissColorBorder;
			half4 _DissParam;
			sampler2D _TexDistort;
			half4 _TexDistort_TilingScroll;
			float2 _DistParam;

			#include "../../Standard_Functions.cginc"

			v2f_over vert_over(appdata_over i)
			{
				v2f_over o;

				float4 wpos = mul(unity_ObjectToWorld, i.vertex);

				o.pos = mul(UNITY_MATRIX_VP, wpos);

				o.uv.xy = TRANSFORM_TEX(i.uv, _MainTex);
				o.light = mul(UNITY_MATRIX_I_V, unity_LightPosition[0]);

				o.uv.zw = 0.0f.xx;

				o.wpos = wpos.xyz;
				o.normal = UnityObjectToWorldNormal(i.normal);

				o.color = i.color;

				//Dissolve
				o.uvDissBase = i.uv1;
				o.uvDiss.xy = i.uv1 * _TexDiss_TilingScroll.xy + frac(_TexDiss_TilingScroll.zw * _Time.y);
				o.uvDiss.zw = i.uv1 * _TexDistort_TilingScroll.xy + frac(_TexDistort_TilingScroll.zw * _Time.y);

				return o;
			}

			fixed _Transparency;

			fixed4 frag_transparency(v2f_over i) : SV_Target
			{
					fixed4 color = tex2D(_MainTex, i.uv.xy);

					color.rgb *= i.color.rgb;

					#if _MASK_ON
					fixed4 mask = tex2D(_MaskTex, i.uv.xy);
					#endif

					float3 wpos = i.wpos;
					half3 n = normalize(i.normal);
					half3 l = normalize(i.light.xyz - wpos * i.light.w);
					half3 v = normalize(_WorldSpaceCameraPos.xyz - wpos);
					half3 r = reflect(-v, n);

					fixed3 light = _AmbientColor.rgb * _AmbientColor.a;
					#if _AMBIENTREACT_ON
					light *= UNITY_LIGHTMODEL_AMBIENT;
					#endif

					fixed3 lightColor = unity_LightColor[0].rgb * _DiffuseColor.a * _DiffuseColor.rgb;
					fixed3 shadowColor =  _ShadowColor.rgb * _ShadowColor.a;
					fixed ndl = dot(n, l);
					light += max(ndl * _HardnessAndShift.x + _HardnessAndShift.y, 0) * lightColor;
					light += max((1.0f - max(ndl * _HardnessAndShift.z + _HardnessAndShift.w, 0)), 0) * shadowColor;

					fixed3 specular = pow(max(dot(l, r), 0), _Shininess * 128) * _SpecularColor.a * _SpecularColor.rgb * lightColor;
					#if _MASK_ON
					specular *= mask.g;
					#endif
					light += specular;

					#if _ILLUMINATION_ON
					fixed illuminationIntensity = _IlluminationColor.a;
					#if _MASK_ON
					illuminationIntensity *= mask.b;
					#endif
					light = lerp(light, _IlluminationColor.rgb, illuminationIntensity);
					#endif

					color.rgb *= light;

					fixed4 rimColor;
					rimColor = _RimColor;

					fixed3 rim = smoothstep(_RimEnd, _RimEnd - _RimStart, dot(n, v)) * rimColor.a * rimColor.rgb;
					#if _MASK_ON
					rim *= mask.r;
					#endif
					color.rgb += rim;
					
					#if _FOG_ON
					fixed4 fog = tex2D(_FogLUT, float2(wpos.z * _FogLUTParams.x + _FogLUTParams.y, 0.5f));
					color.rgb = lerp(color.rgb, fog.rgb, fog.a);
					#endif

					#if _HIT_ON
					fixed3 blend = BlendHardLight(color.rgb, _HitColorNew.rgb);
					color.rgb = lerp(color.rgb, blend, _HitColorNew.a);
					#endif

					color.a *= _Transparency;

					//Dissolve
					fixed2 texDistort = tex2D(_TexDistort, i.uvDiss.zw).xy - 0.5f;
					fixed texDiss = tex2D(_TexDiss, i.uvDiss.xy + texDistort * _DistParam.xy).r;

					half mask_vertexAlpha = lerp(_DissParam.x, _DissParam.x + _DissParam.y, i.uvDissBase.y);
					fixed2 dis = saturate(((texDiss + float2(mask_vertexAlpha, mask_vertexAlpha + _DissParam.z)) * 50.0f - 25.0f) / _DissParam.w);

					color.rgb += (1.0f - dis.y) * _DissColorBorder.rgb *_DissColorBorder.a * 2.0f;
					color.a *= dis.x;

					return color;
			}

			#pragma vertex vert_over
			#pragma fragment frag_transparency
			ENDCG
		}
	}
}