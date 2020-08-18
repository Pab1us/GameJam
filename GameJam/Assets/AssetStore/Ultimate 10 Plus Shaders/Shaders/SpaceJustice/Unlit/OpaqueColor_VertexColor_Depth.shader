Shader "SpaceJustice/Unlit/OpaqueColor_VertexColor_Depth"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)

		[Toggle] _PushToNearPlane ("Push to Near Plane Enabled", Float) = 0.
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		fixed4 color : COLOR;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		fixed4 color : COLOR0;
	};

	struct foutput
	{
		fixed4 color : SV_Target0;
	};

	UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
	UNITY_INSTANCING_BUFFER_END(Props)

	v2f vert(appdata i)
	{
		UNITY_SETUP_INSTANCE_ID(i);
		v2f o;
		o.pos = UnityObjectToClipPos(i.vertex);

#if _PUSHTONEARPLANE_ON
		o.pos.z = UNITY_NEAR_CLIP_VALUE;
#endif

		o.color = UNITY_ACCESS_INSTANCED_PROP(Props, _Color) * i.color;
		return o;
	}

	foutput frag (v2f i) : SV_Target
	{
		foutput o;

		o.color = fixed4(i.color.rgb, 0);

		return o;
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

		Cull Back
		ZWrite On

		Pass
		{
			CGPROGRAM
			#pragma target 3.5
			#pragma shader_feature _PUSHTONEARPLANE_ON
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

		Cull Back
		ZWrite On

		Pass
		{
			CGPROGRAM
			#pragma shader_feature _PUSHTONEARPLANE_ON
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
