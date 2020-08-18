Shader "SpaceJustice/FX/Items/Liquid_In_Glass"
{
	Properties
	{
		_ColorDiff ("Base Color",Color) = (1,1,1,1)
		_Tex_ColorWhiteTint("Color white tint",Color) = (1,1,1,1)
		_Tex_ColorBlackTint("Color black tint",Color) = (0,0,0,0)
		[NoScaleOffset]
		_Tex ("Texture BW", 2D) = "white" {}
		_Tex_TilingScroll0 ("Tiling Scroll 0", Vector) = (1,1,0,0)
		_Tex_TilingScroll1 ("Tiling Scroll 1", Vector) = (1,1,0,0)

		[Header(Falloff)]
		_FalloffColor ("Color ", Color) = (1,1,1,1)
		_FalloffParams ("Falloff Start(X,Z)/End(Y,W)", Vector) = (0, 0, 0, 0)

		[Header(Specular)]
		_SpecularColor("Color",Color) = (1,1,1,1)
		_Shininess("Shininess",Float) = 1

		[Header(Culling)]
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Culling Mode", Float) = 2
	}

	SubShader
	{
		Tags
		{
			"Queue"="Geometry"
			"RenderType"="Opaque"
		}

		ZWrite On
		Cull [_CullMode]

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "../../Standard_Functions.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				half3 normal : NORMAL;
				half2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half3 normal : NORMAL;
				half4 uv : TEXCOORD0;
				half4 light : TEXCOORD1;
				float3 wpos : TEXCOORD2;
			};

			sampler2D _Tex;
			half4 _Tex_TilingScroll0;
			half4 _Tex_TilingScroll1;
			fixed4 _Tex_ColorWhiteTint;
			fixed4 _Tex_ColorBlackTint;

			fixed4 _ColorDiff;
			half4 _FalloffParams;
			fixed4 _FalloffColor;
			fixed4 _SpecularColor;
			half _Shininess;

			v2f vert(appdata v)
			{
				v2f o;

				o.vertex  = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.uv.xy = v.uv * _Tex_TilingScroll0.xy + frac(_Tex_TilingScroll0.zw * _Time.y);
				o.uv.zw = v.uv * _Tex_TilingScroll1.xy + frac(_Tex_TilingScroll1.zw * _Time.y);
				o.light = mul(UNITY_MATRIX_I_V, unity_LightPosition[0]);
				o.wpos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed grad = tex2D(_Tex, i.uv.xy).x * tex2D(_Tex, i.uv.zw).x;

				fixed4 col = lerp(_Tex_ColorBlackTint, _Tex_ColorWhiteTint, grad);

				float3 wpos = i.wpos;
				half3 n = normalize(i.normal);
				half3 l = normalize(i.light.xyz - wpos * i.light.w);
				half3 v = normalize(_WorldSpaceCameraPos.xyz - wpos);
				half3 r = reflect(-v, n);

				fixed2 rim = smoothstep(_FalloffParams.yw, _FalloffParams.xz, saturate(dot(v, n)));

				fixed4 baseColor = _ColorDiff;

				col = lerp(col, baseColor, rim.y);
				col = lerp(col, _FalloffColor, rim.x * _FalloffColor.a);

				fixed4 specular = sfSpecularCoeff(l, r, _Shininess * 64.0f) * _SpecularColor;

				col.rgb += specular.rgb * specular.a;

				return col;
			}
			ENDCG
		}
	}
}
