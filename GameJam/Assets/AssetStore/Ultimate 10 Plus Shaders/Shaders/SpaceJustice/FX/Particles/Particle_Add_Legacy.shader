Shader "SpaceJustice/FX/Particle/Particle Add (Legacy)"
{
	Properties
	{
		_MainTex ("Particle Texture", 2D) = "white" {}
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
		Blend One One
		ZWrite Off
		Cull Back

		Pass
		{
		CGPROGRAM
		#define _LEGACY_ON 1

		#include "Particle.cginc"
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}
