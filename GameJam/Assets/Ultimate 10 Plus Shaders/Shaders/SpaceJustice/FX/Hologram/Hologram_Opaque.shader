Shader "SpaceJustice/FX/Hologram/Hologram_Opaque"
{
	Properties
	{
		// General
		_MainColor ("MainColor", Color) = (1,1,1,1)
		_DirectionScanlines ("DirectionScanlines", Vector)  = (0,1,0,0)

		// Main Color
		_MainTex ("MainTexture", 2D) = "white" {}

		// Rim/Fresnel
		[Header(Rim Fresnel)]

		_RimColor ("Rim Color", Color) = (1,1,1,1)
		_RimSmoth ("_RimSmoth", Range(0., 1.)) = 1.
		_RimOffset ("RimOffset", Range(0., 1.)) = 1.


		// Scanline
		[Header(Scanline)]
		_ScanColor ("ScanColor", Color) = (1,1,1,1)
		_ScanTiling ("Scan Tiling", Range(0.01, 10.0)) = 0.05
		_ScanSpeed ("Scan Speed", Range(-2.0, 2.0)) = 1.0
		// Glow
		[Header(Glow)]
		_GlowColor ("GlowColor", Color) = (1,1,1,1)
		_GlowTiling ("Glow Tiling", Range(0.01, 1.0)) = 0.05
		_GlowSpeed ("Glow Speed", Range(-4.0, 4.0)) = 1.0
		_GlowOffset ("Glow Offset", Range(0.1, 0.9)) = 0.1
		// Glitch
		[Header(Glitch)]
		_GlitchColor ("Glitch Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_GlitchSpeed ("Glitch Speed", Range(0, 50)) = 1.0
		_GlitchIntensity ("Glitch Intensity", Float) = 0
		// Alpha Flicker
		[Header(Alpha Flicker)]
		_FlickerPower ("Flicker Power", Range(0.0, 1)) = 0
		_FlickerSpeed ("Flicker Speed", Range(0.0, 5)) = 1.0
	}
	SubShader
	{
		Tags
		{
			"Queue"="Geometry"
			"RenderType"="Opaque"
		}

		Cull Back

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 worldVertex : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
				float3 worldNormal : NORMAL;
				half4 color : COLOR;
			};

			float4 _DirectionScanlines;

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainColor;

			float4 _RimColor;

			fixed  _RimSmoth;
			fixed  _RimOffset;

			fixed4 _GlitchColor;
			float _GlitchSpeed;
			float _GlitchIntensity;

			float4 _ScanColor;
			float _ScanTiling;
			float _ScanSpeed;

			float4 _GlowColor;
			float _GlowTiling;
			float _GlowSpeed;
			float _GlowOffset;

			float _FlickerPower;
			float _FlickerSpeed;

			v2f vert (appdata v)
			{
				v2f o;

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.worldVertex = mul(unity_ObjectToWorld, v.vertex);
				o.vertex = mul(UNITY_MATRIX_VP, o.worldVertex);

				float shift = sin(o.vertex.y * 10.0f + _Time.y) * step(0.95f, abs(frac(_Time.y * _GlitchSpeed + 0.5f) * 2.0f - 1.0f));

				o.vertex.x += shift * _GlitchIntensity / abs(1.0f + o.worldVertex.x * 0.01f);

				o.color.r = abs(shift);
				o.color.gb = 1.0f.xx;
				o.color.a = lerp(1.0f, abs(frac(_Time.w * _FlickerSpeed) * 2.0f - 1.0f), _FlickerPower);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = normalize(UnityWorldSpaceViewDir(o.worldVertex.xyz));

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 texColor = tex2D(_MainTex, i.uv);

				//world space, temporary delayed
				float4 dirMult = _DirectionScanlines * i.worldVertex;
				float dir = dot(dirMult.xyz, 1.0f.xxx);

				// Scanlines   i.worldVertex.y
				fixed scan = abs(frac(dir * _ScanTiling + _Time.w * _ScanSpeed) * 2.0f - 1.0f);

				// Glow
				fixed glowPre = frac(dir * _GlowTiling + _Time.w * _GlowSpeed) - _GlowOffset;

				fixed glow = saturate(glowPre) / (1.0f - _GlowOffset) + saturate(-glowPre) / _GlowOffset;

				// Rim Light
				half rim = smoothstep(_RimOffset, _RimOffset - _RimSmoth, dot(i.viewDir, i.worldNormal));

				fixed4 col;
				col.rgb = texColor.rgb * _MainColor.rgb + scan * _ScanColor.rgb * i.color.a + glow * _GlowColor.rgb + _RimColor.rgb * rim;
				col.rgb = lerp(col.rgb, dot(col.rgb, 0.333f.xxx) * _GlitchColor.rgb, saturate(i.color.r * 2.0f));
				col.a = 1.0f;

				return col;
			}
			ENDCG
		}
	}
}
