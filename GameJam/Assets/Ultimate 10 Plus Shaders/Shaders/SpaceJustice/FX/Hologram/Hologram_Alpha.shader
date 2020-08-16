Shader "SpaceJustice/FX/Hologram/Hologram_Alpha"
{
	Properties
	{
		_MainColor ("MainColor", Color) = (1,1,1,1)
		_DirectionScanlines ("DirectionScanlines", Vector)  = (0,1,0,0)

		_MainTex ("MainTexture", 2D) = "white" {}

		[Header(Rim Fresnel)]

		_RimColor ("Rim Color", Color) = (1,1,1,1)
		_RimSmoth ("_RimSmoth", Range(0., 1.)) = 1.
		_RimOffset ("RimOffset", Range(0., 1.)) = 1.
		_RimInvert ("Rim Mode", Range(0, 2.)) = 1

		[Header(Scanline)]
		_ScanTiling ("Scan Tiling", Range(0.01, 10.0)) = 0.05
		_ScanSpeed ("Scan Speed", Range(-2.0, 2.0)) = 1.0

		[Header(Glow)]
		_GlowColor ("GlowColor", Color) = (1,1,1,1)
		_GlowTiling ("Glow Tiling", Range(0.01, 1.0)) = 0.05
		_GlowSpeed ("Glow Speed", Range(-4.0, 4.0)) = 1.0
		_GlowOffset ("Glow Offset", Range(0.1, 0.9)) = 0.1

		[Header(Glitch)]
		_GlitchSpeed ("Glitch Speed", Range(0, 50)) = 1.0
		_GlitchIntensity ("Glitch Intensity", Float) = 0

		[Header(Alpha Flicker)]
		_FlickerPower ("Flicker Power", Range(0.0, 1)) = 0
		_FlickerSpeed ("Flicker Speed", Range(0.0, 5)) = 1.0
	}

	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 100
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
				half3 normal : NORMAL;
				half2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 uv : TEXCOORD0;
				half4 worldVertex : TEXCOORD1;
				half3 viewDir : TEXCOORD2;
				half3 worldNormal : NORMAL;
				fixed4 color : COLOR;
			};

			float4 _DirectionScanlines;

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _MainColor;

			fixed4 _RimColor;

			fixed _RimSmoth;
			fixed _RimOffset;
			fixed _RimInvert;

			half _GlitchSpeed;
			half _GlitchIntensity;

			half _ScanTiling;
			half _ScanSpeed;

			fixed4 _GlowColor;
			half _GlowTiling;
			half _GlowSpeed;
			half _GlowOffset;

			half _FlickerPower;
			half _FlickerSpeed;

			v2f vert (appdata v)
			{
				v2f o;

				fixed4 dirMult = _DirectionScanlines * v.vertex;
				fixed dir = dot(dirMult.xyz, 1.0f);

				v.vertex += _GlitchIntensity * (step(0.5, abs(frac(_Time.y * 3.0f + dir) * 2.0f - 1.0f)) * step(0.95f, abs(frac(_Time.y * _GlitchSpeed + 0.5f) * 2.0f - 1.0f)));

				o.color = lerp(1.0f, abs(frac(_Time.w * _FlickerSpeed) * 2.0f - 1.0f), _FlickerPower);

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldVertex = mul(unity_ObjectToWorld, v.vertex);
				o.vertex = mul(UNITY_MATRIX_VP, o.worldVertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = normalize(UnityWorldSpaceViewDir(o.worldVertex.xyz));

				return o;
			}


			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 texColor = tex2D(_MainTex, i.uv);
				fixed4 dirMult = _DirectionScanlines * i.worldVertex;
				fixed dir = dot(dirMult.xyz, 1.0f.xxx);

				fixed scan = abs(frac(dir * _ScanTiling + _Time.w * _ScanSpeed) * 2.0f - 1.0f);

				fixed glowPre = frac(dir * _GlowTiling + _Time.w * _GlowSpeed) - _GlowOffset;
				fixed glow = saturate(glowPre) / (1.0f - _GlowOffset) + saturate(-glowPre) / _GlowOffset;

				half rim = smoothstep(_RimOffset, _RimOffset - _RimSmoth, dot(i.viewDir, i.worldNormal));
				fixed4 rimColor = _RimColor * lerp(0.0f, rim, saturate(_RimInvert));
				fixed rimAlpha = _RimColor.a * lerp(lerp((1.0f - rim), rim, saturate(_RimInvert)), 1.0f, saturate(_RimInvert - 1.0f));

				fixed4 col = (texColor * _MainColor + (glow * _GlowColor) + rimColor);
				col.a = texColor.a * _MainColor.a * i.color.a * (scan + glow * _GlowColor.a) * rimAlpha;

				return col;
			}
			ENDCG
		}
	}
}