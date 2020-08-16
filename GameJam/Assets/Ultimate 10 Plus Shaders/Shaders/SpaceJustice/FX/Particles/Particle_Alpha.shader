Shader "SpaceJustice/FX/Particle/Particle Alpha"
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
		Blend SrcAlpha OneMinusSrcAlpha//, Zero One
		ZWrite Off
		Cull Back

		Pass
		{
		CGPROGRAM
		#include "Particle.cginc"
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}
