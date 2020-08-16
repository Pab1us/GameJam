Shader "SpaceJustice/Boss"
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
		[Header(Hardness And Offset (XY direct ZW shadow))]
		_HardnessAndShift ("Parameters", Vector) = (1.,0.,1.,0.)

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

		[Header(Fog)]
		[Toggle] _Fog("Fog Enabled", Float) = 0.
		[Toggle] _IllumInfluence("Illumination Influence Enabled", Float) = 0.
		_IllumInfluenceValue("Illumination Influence", Range(0.0, 1.0)) = 0.

		[Header(Hit)]
		[Toggle] _Hit("Enabled", Float) = 0.
		[PerRendererData] _HitColorNew ("Hit Color", Color) = (0,0,0,0)

		[Header(Portal Fog)]
		[Toggle] _PortalFog ("Enabled", Float) = 0
		_PortalFogColor ("Fog Color", Color) = (1, 1, 1, 1)
		_PortalFogContourColor ("Contour Color", Color) = (1, 1, 1, 1)
		_PortalCenter ("Center Point", Vector) = (0, 0, 0, 0)
		_PortalDepth ("Depth", Float) = 1.
		_PortalDirection ("Direction", Vector) = (0, 0, 0, 0)

		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
	}

	SubShader
	{
		Tags
		{
			"Queue"="Geometry"
			"RenderType"="Opaque"
		}

		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp]
		}

		Pass
		{
			Tags { "LightMode"="Vertex" }
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
			#pragma shader_feature _ILLUMINFLUENCE_ON
			#pragma shader_feature _HIT_ON
			#pragma shader_feature _PORTALFOG_ON
			#pragma multi_compile_instancing

			#include "Default_fragment.cginc"
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
