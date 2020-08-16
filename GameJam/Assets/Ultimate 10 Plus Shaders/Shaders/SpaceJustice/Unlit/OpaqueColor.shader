Shader "SpaceJustice/Unlit/OpaqueColor"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		float4 color : COLOR0;
	};

	UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
	UNITY_INSTANCING_BUFFER_END(Props)

	v2f vert(appdata i)
	{
		UNITY_SETUP_INSTANCE_ID(i);
		v2f o;
		o.pos = UnityObjectToClipPos(i.vertex);
		o.color = UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		return fixed4(i.color.rgb, 0);
	}
	ENDCG

	SubShader
	{
		Tags
		{
			"Queue"="Geometry"
			"RenderType"="Opaque"
			"PreviewType"="Plane"
		}

		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma target 3.5
			#pragma multi_compile_instancing
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}

	SubShader
	{
		Tags
		{
			"Queue"="Geometry"
			"RenderType"="Opaque"
			"PreviewType"="Plane"
		}

		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
