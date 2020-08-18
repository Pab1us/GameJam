Shader "SpaceJustice/FX/Items/AntigravityTurret_Sphere"
{
	Properties
	{
		[Header(Falloff)]
		_Main_Color ("Main Color", Color) = (1,1,1,1)
		_Border_Color ("Border Color", Color) = (1,1,1,1)
		_Highlight_Color ("Highlight Color", Color) = (1,1,1,1)
		_FalloffParam ("Offset Width", Vector) = (0,1,0,0)
		_Offset ("Offset", Vector) = (0,0,0,0)

		[Header(Wave)]
		_Wave_Color ("Color", Color) = (1,1,1,1)
		_WaveParam ("Wave param", Vector) = (0,1,0,0)
	}

	SubShader
	{
		Tags
		{
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
				float4 color : COLOR;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 wpos : TEXCOORD1;
				float3 wnormal : TEXCOORD2;
				float4 color : COLOR;
			};

			float4 _Border_Color, _Highlight_Color;
			float4 _Main_Color;
			float4 _FalloffParam;
			float3 _Offset;

			float4 _WaveParam;
			float4 _Wave_Color;


			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.wpos = mul(unity_ObjectToWorld, v.vertex ).xyz;
				o.wnormal = UnityObjectToWorldNormal(v.normal + _Offset);
				o.uv = v.uv * _WaveParam.z + frac(_WaveParam.w * _Time.y);;
				o.color = v.color;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{

				fixed2 falloff = smoothstep(_FalloffParam.xz + _FalloffParam.yw, _FalloffParam.xz , dot(normalize(_WorldSpaceCameraPos.xyz - i.wpos), normalize(i.wnormal)));
				fixed4 col = lerp(_Main_Color, _Border_Color, falloff.x);
				col = lerp(col, _Highlight_Color, falloff.y * _Highlight_Color.a);

				fixed2 wave = saturate((frac(i.uv.y) * _WaveParam.y - fixed2(0.0f, 1.0f)) / (saturate(_WaveParam.x) * 0.99f - fixed2(0.0f, 1.0f)));
				//col = lerp(col, _Wave_Color, min(wave.x, wave.y) * _Wave_Color.a);
				col += min(wave.x, wave.y) * _Wave_Color * _Wave_Color.a;

				return col;
			}
			ENDCG
		}
	}
}