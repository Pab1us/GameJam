Shader "SpaceJustice/Buildings"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}

		[Header(Ambient)]
		_AmbientColor ("Color", Color) = (1., 1., 1., 1.)

		[Header(Direct Lighting)]
		_DiffuseColor ("Color", Color) = (1., 1., 1., 1.)
		_ShadowColor ("Shadow Color", Color) = (0., 0., 0., 0.)
		[Header(Hardness And Offset (XY direct ZW shadow))]
		_HardnessAndShift ("Parameters", Vector) = (1.,0.,1.,0.)

		[Header(Mask)]
		[Toggle] _Mask ("Enabled", Float) = 0.
		[NoScaleOffset] _MaskTex ("Texture  (R - rim G - specular)", 2D) = "white" {}

		[Header(Rim (R mask channel))]
		[Toggle] _Rim ("Enabled", Float) = 0.
		_RimStart ("Start", Range(0., 1.)) = 1.
		_RimEnd ("End", Range(0., 1.)) = 1.
		_RimColor ("Color", Color) = (1., 1., 1., 1.)

		[Header(Specular (G mask channel))]
		[Toggle] _Specular ("Enabled", Float) = 0.
		_Shininess ("Shininess", Range(0.01, 1.)) = 1.
		_SpecularColor ("Color", Color) = (1., 1., 1., 1.)

		[Header(Self Illumination (B mask channel))]
		[Toggle] _Illumination ("Enabled", Float) = 0.
		_IlluminationColor ("Color", Color) = (1., 1., 1., 1.)

		[Header(Gray Scale)]
		[Toggle] _GrayScale ("Gray Scale Enabled", Float) = 0.
		_GrayScaleColor ("Color", Color) = (1., 1., 1., 0.5)
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
			Tags { "LightMode"="Vertex" }
			CGPROGRAM
			#pragma shader_feature _MASK_ON
			#pragma shader_feature _SPECULAR_ON
			#pragma shader_feature _ILLUMINATION_ON
      #pragma shader_feature _RIM_ON
			#pragma shader_feature _GRAYSCALE_ON
			#define _AMBIENTREACT_ON 1
			#pragma multi_compile_instancing

			#include "Default_fragment.cginc"
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}