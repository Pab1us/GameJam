#ifndef SPACEJUSTICE_CG_INCLUDED
#define SPACEJUSTICE_CG_INCLUDED

#include "UnityCG.cginc"

inline float4 ObjectToClipPos(float3 pos, float4 curvature)
{
#if CURVED_ON
	float3 vpos = UnityObjectToViewPos(pos);
	float rxy = length(vpos.xy);
	float dist = vpos.z;
	if (rxy > 0)
	{
		float phi = atan2(rxy, -dist);
		vpos.xy *= (phi * curvature.zw / rxy);
	}
	vpos.xy += curvature.xy * dist * dist;
	return UnityViewToClipPos(vpos);
#else
	return UnityObjectToClipPos(pos);
#endif
}

inline float4 ObjectToClipPos(float4 pos, float4 curvature)
{
#if CURVED_ON
	return ObjectToClipPos(pos.xyz, curvature);
#else
	return UnityObjectToClipPos(pos.xyz);
#endif
}

#endif // SPACEJUSTICE_CG_INCLUDED