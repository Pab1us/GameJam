Shader "SpaceJustice/Sprite/Sprite Special Blend"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		_Offset ("Z-Offset", Float) = 0
		[HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
		[HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
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
		Blend One OneMinusSrcAlpha, Zero One
		ZWrite Off
		Cull Off

		Offset -3, -3

		Pass
		{
		CGPROGRAM
		#pragma target 3.5
		#pragma multi_compile_instancing
		#define _SPECIAL_BLEND
		#include "Sprite.cginc"
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
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
		Blend One OneMinusSrcAlpha, Zero One
		ZWrite Off
		Cull Off

		Offset -3, -3

		Pass
		{
		CGPROGRAM
		#pragma multi_compile _ PIXELSNAP_ON
		#define _SPECIAL_BLEND
		#include "Sprite.cginc"
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}
