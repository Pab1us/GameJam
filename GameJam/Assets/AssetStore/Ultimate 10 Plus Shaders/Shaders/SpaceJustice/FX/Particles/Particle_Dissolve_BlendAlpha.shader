Shader "SpaceJustice/FX/Particle/Particle Dissolve BlendAlpha"
{
	Properties
	{
		[Header(MainTex)]
		[NoScaleOffset]
		_Brightness ("Brightness", Float) = 1.0
		_MainTex ("Main Texture", 2D) = "white" {}
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
		Cull Back

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				half4 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				half4 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			sampler2D _MainTex;
			half _Brightness;

			v2f vert(appdata v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.uv = v.uv;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv.xy) * i.color;
				col.rgb *= _Brightness;

				col.a = saturate(((col.a + i.uv.z) * 2.0f + (-1.0f)) * 50.0f * i.uv.w) * i.color.a;

				return col;
			}
			ENDCG
		}
	}
}
