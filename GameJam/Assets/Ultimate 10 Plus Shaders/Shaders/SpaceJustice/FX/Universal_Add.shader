Shader "SpaceJustice/FX/Universal Add"
{
	Properties
	{
		[Header(Texture 01)]
		_Color01 ("Color", Color) = (1,1,1,1)
		_Texture01 ("Texture 01", 2D) = "white" {}
		_Texture01Params ("Speed (XY) Dist Pow (ZW)", Vector) = (0,0,0,0)

		[Header(Distorttion)]
		_TextureDistortion ("Texture Distorttion", 2D) = "white" {}
		[Header(Distorttion Speed (XY) Color Grading Speed (Z))]
		_Params ("Params", Vector) = (0,0,0,0)
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
		}

		BlendOp Add
		Blend One One
		ZWrite Off
		Cull Back

		Pass
		{
		CGPROGRAM
		#include "Universal.cginc"
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
	Fallback "SpaceJustice/FX/Universal Add (fallback)"
}
