Shader "SpaceJustice/Boss (Transparent)"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}

		[Header(Separate Light)]
		[Toggle] _SeparateLight ("Enabled", Float) = 0.
		[NoScaleOffset] _LightTex ("Light Texture", 2D) = "white" {}

		[Header(Bump)]
		[Toggle] _Bump ("Enabled", Float) = 0.
		[NoScaleOffset] _BumpMap ("Normal Map", 2D) = "bump" {}

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
		[Toggle] _Rim("Enabled", Float) = 0.
		_RimStart ("Start", Range(0., 1.)) = 1.
		_RimEnd ("End", Range(0., 1.)) = 1.
		[Toggle] _GlobalRimColor ("Use Global Color", Float) = 0.
		_RimColor ("Color", Color) = (1., 1., 1., 1.)

		[Header(Reflection (G mask channel))]
		[Toggle] _Reflection("Enabled", Float) = 0.
		_ReflectionColor ("Color", Color) = (1., 1., 1., 1.)
		_ReflectionTex ("Reflection Texture", CUBE) = "black" {}

		[Header(Specular (G mask channel))]
		[Toggle] _Specular("Enabled", Float) = 0.
		_Shininess ("Shininess", Range(0.01, 1.)) = 1.
		_SpecularColor ("Color", Color) = (1., 1., 1., 1.)

		[Header(Self Illumination (B mask channel))]
		[Toggle] _Illumination ("Enabled", Float) = 0.
		_IlluminationColor ("Color", Color) = (1., 1., 1., 1.)

		[Header(Transparency)]
		_Transparency ("Transparency", Range(0., 1.)) = 1.

		[Header(Fog)]
		[Toggle] _Fog("Fog Enabled", Float) = 0.

		[Header(Hit)]
		[Toggle] _Hit("Enabled", Float) = 0.
		[PerRendererData] _HitColorNew ("Hit Color", Color) = (0,0,0,0)
		[PerRendererData] _HitRatio ("Hit Ratio", Range (0, 1)) = 0.
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"RenderType"="Transparent"
			"IgnoreProjector"="true"
		}
		Pass
		{
			Tags { "LightMode"="Vertex" }
			BlendOp Add
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back
			ZWrite Off
			CGPROGRAM
			#pragma shader_feature _SEPARATELIGHT_ON
			#pragma shader_feature _BUMP_ON
			#pragma shader_feature _MASK_ON
			#pragma shader_feature _REFLECTION_ON
			#pragma shader_feature _SPECULAR_ON
			#pragma shader_feature _ILLUMINATION_ON
			#pragma shader_feature _RIM_ON
			#pragma shader_feature _GLOBALRIMCOLOR_ON
			#pragma shader_feature _FOG_ON
			#pragma shader_feature _HIT_ON
			#pragma multi_compile_instancing

			#include "../../Default_fragment.cginc"

			fixed _Transparency;

			fixed4 frag_transparency(v2f i) : SV_Target
			{
				fixed4 color = frag(i);
				color.a *= _Transparency;
				return color;
			}

			#pragma vertex vert
			#pragma fragment frag_transparency
			ENDCG
		}
	}
}