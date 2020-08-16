Shader "SpaceJustice/FX/Particle/Particle Add"
{
	Properties
	{
		_MainTex ("Particle Texture", 2D) = "white" {}
		[Toggle] _UseColor ("Use Tint", float) = 0.
		[Toggle] _KeepBright ("Keep Bright", float) = 0.
		[Enum(UnityEngine.Rendering.ZTest)] _ZTest ("ZTest", float) = 4

		_Bright ("Bright", range(0., 1.)) = 0.
		_Color ("Tint", Color) = (1., 1., 1., 1.)
		_Multiplier ("Multiplier", float) = 1.
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
		BlendOp Add
		Blend SrcAlpha One
		ZTest [_ZTest]
		ZWrite Off
		Cull Off

		Pass
		{
		CGPROGRAM
		#include "Particle.cginc"
		#pragma shader_feature _USECOLOR_ON
		#pragma shader_feature _KEEPBRIGHT_ON
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}
