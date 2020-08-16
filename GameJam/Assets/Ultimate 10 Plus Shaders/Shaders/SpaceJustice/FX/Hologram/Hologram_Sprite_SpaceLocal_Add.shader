
Shader "SpaceJustice/FX/Hologram/Hologram_Sprite_SpaceLocal_Add"
{
	Properties
	{

		// General
		_DirectionScanlines ("DirectionScanlines", Vector)  = (0,1,0,0)

		// Scanline
		[Header(Scanline)]
		_ScanTiling ("Scan Tiling", Range(0.01, 50.0)) = 1.0
		_ScanSpeed ("Scan Speed", Range(-2.0, 2.0)) = 0.0
		_ScanTransparency ("Scan Transparency", Range(0.0, 1.0)) = 0.0
		// Glow
		[Header(Glow)]
		_GlowColor ("GlowColor", Color) = (1,1,1,1)
		_GlowTiling ("Glow Tiling", Range(0.01, 2.0)) = 0.05
		_GlowSpeed ("Glow Speed", Range(-4.0, 4.0)) = 1.0
		_GlowOffset ("Glow Offset", Range(0.1, 0.9)) = 0.1


		// Alpha Flicker
		[Header(Alpha Flicker)]
		_FlickerPower ("Flicker Power", Range(0.0, 1)) = 0
		_FlickerSpeed ("Flicker Speed", Range(0.0, 5)) = 1.0



		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)

		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha One
		ColorMask [_ColorMask]

		Pass
		{
			Name "Default"
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_ALPHACLIP

			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

            float4 _DirectionScanlines;

			fixed4 _Color;
			fixed4 _TextureSampleAdd;
			float4 _ClipRect;

            float _ScanTiling;
			float _ScanSpeed;
			float _ScanTransparency;

			float4 _GlowColor;
			float _GlowTiling;
			float _GlowSpeed;
			float _GlowOffset;

			float _FlickerPower;
			float _FlickerSpeed;

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				OUT.worldPosition = IN.vertex;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

				OUT.texcoord = IN.texcoord;
                OUT.color = lerp( 1, abs(frac(_Time.w * _FlickerSpeed) *2.0 - 1.0), _FlickerPower) * IN.color * _Color; // Flicker

				return OUT;
			}

			sampler2D _MainTex;

			fixed4 frag(v2f IN) : SV_Target
			{
				half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

                fixed2 dirMult = _DirectionScanlines.xy * IN.texcoord;
				fixed dir = dirMult.x + dirMult.y;

                // Scanlines
				fixed scan = abs(frac(dir * _ScanTiling + _Time.w * _ScanSpeed) * 2.0 - 1.0);
				scan = _ScanTransparency + scan * (1 - _ScanTransparency);

				// Glow
				fixed 	glowPre = frac(dir * _GlowTiling * 0.5 + _Time.w * _GlowSpeed) - _GlowOffset;
				fixed	glow = saturate(glowPre)/(1-_GlowOffset) + abs(saturate(-glowPre))/_GlowOffset;

				color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);

				color.rgb += _GlowColor.rgb * glow * _GlowColor.a;
                color.a *=scan;
				#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001);
				#endif

				return color;
			}
		ENDCG
		}
	}
}
