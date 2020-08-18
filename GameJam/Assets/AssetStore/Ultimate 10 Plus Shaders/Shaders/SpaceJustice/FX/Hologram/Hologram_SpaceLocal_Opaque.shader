Shader "SpaceJustice/FX/Hologram/Hologram_SpaceLocal_Opaque"
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
		_ScanTiling ("Scan Tiling", Range(0.01, 50.0)) = 0.05
		_ScanSpeed ("Scan Speed", Range(-2.0, 2.0)) = 1.0
		// Glow
		[Header(Glow)]
		_GlowColor ("GlowColor", Color) = (1,1,1,1)
		_GlowTiling ("Glow Tiling", Range(0.01, 4.0)) = 0.05
		_GlowSpeed ("Glow Speed", Range(-4.0, 4.0)) = 1.0
		_GlowOffset ("Glow Offset", Range(0.1, 0.9)) = 0.1
		// Glitch
		[Header(Glitch)]
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
		ColorMask RGB
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
				float4 uv1 : TEXCOORD1;
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

				// Glitches
				fixed4 dirMult = _DirectionScanlines * v.vertex;
				fixed dir = dirMult.x + dirMult.y + dirMult.z;
				v.vertex += _GlitchIntensity * (step(0.5, abs(frac(_Time.y * 3.0 + dir) * 2.0 - 1.0)) * step(0.95, abs(frac(_Time.y * _GlitchSpeed + 0.5) * 2.0 - 1.0))) ;

				// Flicker
				o.color = lerp( 1, abs(frac(_Time.w * _FlickerSpeed) *2.0 - 1.0), _FlickerPower);

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float4 worldVertex = mul(unity_ObjectToWorld, v.vertex);
				o.vertex = mul(UNITY_MATRIX_VP, worldVertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = normalize(UnityWorldSpaceViewDir(worldVertex.xyz));
				o.uv1 = v.vertex;
				return o;
			}


			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 texColor = tex2D(_MainTex, i.uv);
				fixed4 dirMult = _DirectionScanlines * i.vertex;
				fixed dir = dirMult.x + dirMult.y + dirMult.z;

				// Scanlines   i.worldVertex.y
				fixed scan = abs(frac(dir * _ScanTiling + _Time.w * _ScanSpeed) *2.0 - 1.0);

				// Glow
				fixed 	glowPre = frac(dir * _GlowTiling * 0.5 + _Time.w * _GlowSpeed) - _GlowOffset;
				fixed	glow = saturate(glowPre)/(1-_GlowOffset) + abs(saturate(-glowPre))/_GlowOffset;

				// Rim Light
				half rim = smoothstep(_RimOffset, _RimOffset - _RimSmoth, dot(i.viewDir, i.worldNormal));

				fixed4 col = texColor * _MainColor + scan * _ScanColor * i.color.a + glow * _GlowColor + _RimColor * rim;

				return col;
			}
			ENDCG
		}
	}


}