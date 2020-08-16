Shader "SpaceJustice/Sprite/Sprite Double Texture Add"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		[NoScaleOffset] _AdditionalTex ("Additional Texture", 2D) = "black" {}
		_Color ("First Tint", Color) = (1,1,1,1)
		_Color1 ("Second Tint", Color) = (1,1,1,1)
		[Toggle] _KeepBright ("Keep Bright", Float) = 0
		_Bright ("Bright First / Bright Second", Vector) = (1,1,0,0)
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
		Blend SrcAlpha One
		ZWrite Off
		Cull Off

		Pass
		{
		CGPROGRAM
		#pragma target 3.5
		#pragma multi_compile_instancing
		#pragma multi_compile _ PIXELSNAP_ON
		#pragma shader_feature _KEEPBRIGHT_ON
		#define _BLENDADD
		#include "Sprite_DoubleTexture.cginc"
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
		Blend SrcAlpha One
		ZWrite Off
		Cull Off

		Pass
		{
		CGPROGRAM
		#pragma multi_compile _ PIXELSNAP_ON
		#define _BLENDADD
		#include "Sprite_DoubleTexture.cginc"
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}