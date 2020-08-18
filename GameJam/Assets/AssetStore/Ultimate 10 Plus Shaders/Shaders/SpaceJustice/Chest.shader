Shader "SpaceJustice/Chest"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}

		[Header(Wave)]

		[Toggle] _Wave_Textured("Wave Texture Enabled", float) = 1.
		_WaveSize ("Wave Textured Size", float) = 0.3
		_WaveColor ("Color", color) = (1., 1., 1., 1.)

    _WaveTex ("Wave Texture", 2D) = "black" {}

		_WaveDirection ("Wave Direction (vector XY)", vector) = (1.0, 1.0, 0.0, 0.0)

		[space(10)]
		_WaveSpeed ("Wave Speed", float) = 1.
		_WaveEffectDuration ("Wave Effect Duration", float) = 7.
		_WavePauseDuration ("Wave Pause Duration", float) = 7.
		[Toggle] _Wave_Handled_Timer("Wave Handled Timer Enabled", Float) = 0.
		_WaveTimer ("Wave Timer", range(0., 1.)) = 0.

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

		[Header(Gray Scale)]
		[Toggle] _GrayScale ("Gray Scale Enabled", Float) = 0.
		_GrayScaleColor ("Color", Color) = (1., 1., 1., 0.5)

		[Toggle] _VertexColor ("Use Vertex Color", Float) = 0.
		[Toggle] _Glassify ("Glassify", Float) = 0.
		_Translucency ("Translucency", Range(0.0, 1.0)) = 0.
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
		}

		BlendOp Add
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			Tags
			{
				"LightMode" = "Vertex"
			}

			CGPROGRAM
			#pragma shader_feature _WAVE_TEXTURED_ON
			#pragma shader_feature _WAVE_HANDLED_TIMER_ON
			#pragma shader_feature _MASK_ON
			#pragma shader_feature _REFLECTION_ON
			#pragma shader_feature _SPECULAR_ON
			#pragma shader_feature _ILLUMINATION_ON
			#pragma shader_feature _RIM_ON
			#pragma shader_feature _FOG_ON
			#pragma shader_feature _VERTEXCOLOR_ON
			#pragma shader_feature _GLASIFY_ON
			#pragma multi_compile __ _GRAYSCALE_ON

			#include "Default_wave.cginc"
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
