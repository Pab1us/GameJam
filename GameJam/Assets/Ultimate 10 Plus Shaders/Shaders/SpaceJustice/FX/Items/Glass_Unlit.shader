Shader "SpaceJustice/FX/Items/Glass Unlit"
{
	Properties
	{
		[Header(Diffuse)]
		_ColorDiff ("Color refl 1",Color) = (1,1,1,1)

		[Toggle] _UseVertexColor ("Use Vertex Color", Float) = 0

		[Header(Reflect)]
		[NoScaleOffset]
		_TexReflection ("Reflection Tex", Cube) = "white" {}
		_TexReflection_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)
		_ColorRefl1("Color refl 1",Color) = (1,1,1,1)
		_ColorRefl2("Color refl 2",Color) = (0,0,0,0)

		[Header(Falloff)]
		_FalloffColor ("Color ", Color) = (1,1,1,1)
		_FalloffParam ("Start End", Vector) = (0,0,0,0)

		[Header(Specular)]
		_SpecularColor("Color",Color) = (1,1,1,1)
		_Shininess("Shininess",Float) = 1

		[Header(Hit)]
		[Toggle] _Hit("Enabled", Float) = 0.
		[PerRendererData] _HitColorNew ("Hit Color", Color) = (0,0,0,0)
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
		}

		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite On
		Cull Back

		Pass
		{
			Tags { "LightMode"="Vertex" }

			CGPROGRAM
			#pragma shader_feature _USEVERTEXCOLOR_ON
			#pragma shader_feature _HIT_ON
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "../../Standard_Functions.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				half3 normal : NORMAL;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				half4 light : TEXCOORD0;
				float3 wpos : TEXCOORD1;
				half3 normal : TEXCOORD2;
			#if _USEVERTEXCOLOR_ON
				fixed4 color : COLOR;
			#endif
			#if _HIT_ON
				fixed4 hit : COLOR1;
			#endif
			};

			fixed4 _ColorDiff;
			fixed4 _ColorRefl1, _ColorRefl2;
			samplerCUBE _TexReflection;
			half4 _FalloffParam;
			fixed4 _FalloffColor;
			fixed4 _SpecularColor;
			half _Shininess;

		#if _HIT_ON
			UNITY_INSTANCING_BUFFER_START(Props)
				UNITY_DEFINE_INSTANCED_PROP(fixed4, _HitColorNew)
			UNITY_INSTANCING_BUFFER_END(Props)
		#endif

			v2f vert (appdata i)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(i.vertex);
				o.wpos = mul(unity_ObjectToWorld, i.vertex).xyz;
				o.normal = UnityObjectToWorldNormal(i.normal);
				o.light = mul(UNITY_MATRIX_I_V, unity_LightPosition[0]);

			#if _USEVERTEXCOLOR_ON
				o.color = i.color;
			#endif

			#if _HIT_ON
				o.hit = UNITY_ACCESS_INSTANCED_PROP(Props, _HitColorNew);
			#endif

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = _ColorDiff;

				float3 wpos = i.wpos;
				half3 n = normalize(i.normal);
				half3 l = normalize(i.light.xyz - wpos * i.light.w);
				half3 v = normalize(_WorldSpaceCameraPos.xyz - wpos);
				half3 r = reflect(-v, n);

				fixed2 rim = smoothstep(half2(_FalloffParam.y, _FalloffParam.w), half2(_FalloffParam.x, _FalloffParam.z), saturate(dot(v, n)));

				fixed4 reflection = lerp(_ColorRefl1, _ColorRefl2, texCUBE(_TexReflection, r).r);

				col = lerp(col, reflection, rim.y);
				col = lerp(col, _FalloffColor, rim.x * _FalloffColor.a);

				fixed4 specular = sfSpecularCoeff(l, r, _Shininess * 64.0f) * _SpecularColor;

			#if _USEVERTEXCOLOR_ON
				col.a = lerp(col.a, 1.0f, specular.a);
				col *= i.color;
			#endif

				col.rgb += specular.rgb * specular.a;

			#if _HIT_ON
				fixed3 blend = BlendHardLight(col.rgb, i.hit.rgb);
				col.rgb = lerp(col.rgb, blend, i.hit.a);
				col.a = saturate(col.a + i.hit.a * 0.5f);
			#endif

				return col;
			}
			ENDCG
		}
	}
}
