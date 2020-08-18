Shader "SpaceJustice/FX/Items/Sirena_DiscoSphere"
{
	Properties
	{
		[Header(Diffuse)]
		_ColorFrame("Color frame", Color) = (1,1,1,1)

		[Header(Reflect)]
		[NoScaleOffset]
		_TexReflection ("Reflection Tex", Cube) = "white" {}
		_TexReflection_TilingScroll  ("Tiling Scroll ", Vector) = (1,1,0,0)
		[NoScaleOffset]
		_Mask ("Mask", 2D) = "white" {}
		_ColorRefl1("Color refl 1",Color) = (1,1,1,1)
		_ColorRefl2("Color refl 2",Color) = (0,0,0,0)

		[Header(Falloff)]
		_FalloffColor ("Color ", Color) = (1,1,1,1)
		_FalloffParam ("Start End", Vector) = (0,0,0,0)
	}
	SubShader
	{
		Tags
		{
			"Queue"="Geometry"
			"RenderType"="Opaque"
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
				half3 normal : NORMAL;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				half3 normalDir : TEXCOORD1;
				half3 viewDir : TEXCOORD2;
			};

			//color
			fixed4 _ColorFrame;
			// reflection
			fixed4 _ColorRefl1, _ColorRefl2;
			sampler2D _Mask;
			samplerCUBE _TexReflection;
			half2  _FalloffParam;
			//falloff
			fixed4 _FalloffColor;

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex  = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.uv;
				o.color = v.color;

				//reflect
				float4x4 modelMatrix = unity_ObjectToWorld;
				float4x4 modelMatrixInverse = unity_WorldToObject;

				o.viewDir = normalize(mul(modelMatrix, v.vertex).xyz - _WorldSpaceCameraPos);
				o.normalDir = normalize(mul(float4(v.normal, 0.0f), modelMatrixInverse).xyz);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = _ColorFrame;

				//reflect
				fixed mask = tex2D(_Mask, i.uv).r;
				half3 reflectedDir = reflect(i.viewDir, normalize(i.normalDir));
				fixed reflectBW = texCUBE(_TexReflection, reflectedDir).r;
				fixed4 reflectCol = lerp(_ColorRefl1, _ColorRefl2, reflectBW);
				col = lerp(_ColorFrame, reflectCol, mask) * i.color;

				//falloff
				fixed rim = smoothstep(_FalloffParam.y, _FalloffParam.x, dot(i.normalDir, i.viewDir));
				col = lerp(col, _FalloffColor, rim * _FalloffColor.a);

				return col;
			}
			ENDCG
		}
	}
}
