Shader "SpaceJustice/FX/Items/Crystal"
{
	Properties
	{
		[Header(Diffuse)]
		_MainTex ("Texture", 2D) = "white" {}

		_LightColor ("Light Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_PenumbraColor ("Penumbra Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_UmbraColor ("Umbra Color", Color) = (1.0, 1.0, 1.0, 1.0)

		[Header(Refracted Back)]
		_BackTex ("Cube Texture", CUBE) = "black" {}

		[Header(Noise)]
		_NoiseTex ("Texture", 2D) = "black" {}

		[Header(Z Offset)]
		_Offset ("Z-Offset", Float) = 0

		[Header(Blending)]
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Operation", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFactor ("Source", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFactor ("Destination", Float) = 10
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
		BlendOp [_BlendOp]
		Blend [_SrcBlendFactor] [_DstBlendFactor]
		ZWrite Off
		Cull Back

		Pass
		{
		CGPROGRAM
		#include "UnityCG.cginc"
		#include "../../Standard_Functions.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			half3 normal : NORMAL;
			half2 uv : TEXCOORD0;
			fixed4 color : COLOR;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			half4 uv : TEXCOORD0;
			float3 wpos : TEXCOORD1;
			float3 normal : NORMAL;
			fixed4 color : COLOR;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;

		fixed4 _LightColor;
		fixed4 _PenumbraColor;
		fixed4 _UmbraColor;

		samplerCUBE _BackTex;

		sampler2D _NoiseTex;
		half4 _NoiseTex_ST;

		float _Offset;

		v2f vert(appdata i)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(i.vertex);

		#if defined(UNITY_REVERSED_Z)
			o.pos.z -= _Offset * 0.47;
		#else
			o.pos.z += _Offset;
		#endif

			o.uv.xy = TRANSFORM_TEX(i.uv, _MainTex);
			o.uv.zw = TRANSFORM_TEX(i.uv, _NoiseTex);

			o.wpos = mul(unity_ObjectToWorld, i.vertex);

			o.normal = i.normal;

			o.color = i.color;

			return o;
		}

		fixed4 frag (v2f i) : SV_Target
		{
			fixed4 color;

			fixed4 diffuse = tex2D(_MainTex, i.uv.xy);
			fixed4 noise = tex2D(_NoiseTex, i.uv.zw);

			half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.wpos);//UNITY_MATRIX_IT_MV[2].xyz;//
			half3 reflectionDir = reflect(-viewDir, i.normal);

			half shine = 1.0f - saturate(pow(dot(normalize(i.normal + diffuse.xyz * 0.0f + noise.xyz * 0.25f), viewDir), 5.0f));

			fixed3 light = lerp(_UmbraColor.rgb, _LightColor.rgb, shine);

			fixed4 back = texCUBE(_BackTex, normalize(reflectionDir + noise * 0.25f));
			back.a = 0.5f;

			color = lerp(back, diffuse, shine);

			color = lerp(color, fixed4(light, 1.25f), pow(shine, 5.0f) * 0.5f);
			color.a = 1.0f;

			return color;
		}

		#pragma vertex vert
		#pragma fragment frag
		ENDCG
		}
	}
}
