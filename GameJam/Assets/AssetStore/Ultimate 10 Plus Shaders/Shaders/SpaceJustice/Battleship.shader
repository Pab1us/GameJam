Shader "SpaceJustice/Battleship"
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

		[Header(Vertex Map)]
		[KeywordEnum(None, Map)] _VertexColor ("Mode", Float) = 0
		_rColor ("R Color", Color) = (1., 1., 1., 1.)
		_gColor ("G Color", Color) = (1., 1., 1., 1.)
		_bColor ("B Color", Color) = (1., 1., 1., 1.)
		_aColor ("A Color", Color) = (1., 1., 1., 1.)

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

		[Header(Hit)]
		[Toggle] _Hit("Enabled", Float) = 0.
		[PerRendererData] _HitColorNew ("Hit Color", Color) = (0,0,0,0)
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
			#pragma shader_feature _VERTEXCOLOR_MAP
			#pragma multi_compile_instancing

			#include "Default_fragment.cginc"
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}