#ifndef SPACEJUSTICE_SAMPLING_INCLUDED
#define SPACEJUSTICE_SAMPLING_INCLUDED

half4 Downsample(sampler2D tex, float2 texelSize, float2 uv)
{
	float4 d = texelSize.xyxy * float4(-1.0, -1.0, 1.0, 1.0);

	half4 s;
	s  = tex2D(tex, uv + d.xy);
	s += tex2D(tex, uv + d.zy);
	s += tex2D(tex, uv + d.xw);
	s += tex2D(tex, uv + d.zw);
	return s * 0.25;
}

half4 Upsample(sampler2D tex, float2 texelSize, float2 uv, float scale)
{
	float4 d = texelSize.xyxy * float4(-1.0, -1.0, 1.0, 1.0) * (scale * 0.5);

	half4 s;
	s  = tex2D(tex, uv + d.xy);
	s += tex2D(tex, uv + d.zy);
	s += tex2D(tex, uv + d.xw);
	s += tex2D(tex, uv + d.zw);
	return s * 0.25;
}

#endif
