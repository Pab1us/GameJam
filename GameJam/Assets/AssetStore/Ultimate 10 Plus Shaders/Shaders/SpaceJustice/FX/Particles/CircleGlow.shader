Shader "SpaceJustice/FX/Particle/CircleGlow"
//Custom1.xy   (Vector2) x:CenterRadius   y:GlowRadius
//Custom2.xyzw (Color) Color Glow
{
	Properties
	{
		[Header(Center)]
		_CenterRadius ("Radius", Float) = 0.5
		_CenterSmooth ("Smooth", Float) = 0.1
		_CenterColor ("Color",Color) = (1,1,1,1)

		[Header(Glow)]
		_GlowRadius ("Radius", Float) = 0.5
		_GlowSmooth ("Smooth", Float) = 0.1
		_GlowColor ("Color",Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Transparent"
			"Queue" = "Transparent"
		}

		Blend One OneMinusSrcAlpha
		ZWrite Off
		Cull Back

		Pass
		{
			CGPROGRAM
			#include "../../Standard_Functions.cginc"
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				float4 color1 : TEXCOORD1;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 color1 : TEXCOORD1;
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
			};

			float _CenterRadius, _CenterSmooth;
			fixed4 _CenterColor;

			float _GlowRadius, _GlowSmooth;
			fixed4 _GlowColor;

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex  = UnityObjectToClipPos(v.vertex);
				o.uv.xy = (v.uv.xy - 0.5f) * 2.0f;
				o.uv.zw = v.uv.zw;
				o.color = v.color;
				o.color1 = v.color1;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col;
				fixed dist = sqrt(dot(i.uv, i.uv));
				_GlowColor *= i.color1;
				_CenterColor *= i.color;

				_CenterRadius *= (1.0f + i.uv.z);
				_GlowRadius *= (1.0f + i.uv.w);
				fixed center = sfSmoothstepLeftF(_CenterRadius, _CenterRadius - _CenterSmooth, dist) * _CenterColor.a;
				fixed glow = sfSmoothstepLeftF(_GlowRadius, _GlowRadius - _GlowSmooth, dist) * _GlowColor.a;

				col.rgb = lerp(_GlowColor.rgb * glow * (1.0f - center), _CenterColor.rgb, center);
				col.a = center;

				return col;
			}
			ENDCG
		}
	}
}
