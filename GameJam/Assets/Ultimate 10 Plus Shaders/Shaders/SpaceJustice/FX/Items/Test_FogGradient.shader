Shader "SpaceJustice/FX/Items/Test Fog Grafient"
{
	Properties
	{
        [Header (Greed)]
        
        _StepGreed ("StepGreed", Float) = 10
        _ColorGreed ("ColorGreed", Color) = (0,0,0,0)
        _WidthGreed ("WidthGreed", Float) = 0.1

        [Header (Labels)]
        _ColorLabel1 ("ColorLabel", Color) = (1,1,1,1)
		_ColorLabel2 ("ColorLabe2", Color) = (1,1,1,1)
		_ColorLabel3 ("ColorLabe3", Color) = (1,1,1,1)
		_ColorLabel4 ("ColorLabe4", Color) = (1,1,1,1)

        _DepthLabel ("Depth Label", Vector) = (1,1,1,1)
        _WidthLabel ("WidthLabel", Float) = 0.1

	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv     : TEXCOORD0;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 pos   : SV_POSITION;
		fixed4 color : COLOR0;
		float2 uv    : TEXCOORD0;

	};

    float _WidthGreed, _StepGreed, _WidthLabel;
	float4 _DepthLabel;
    fixed4 _ColorGreed;
	fixed4 _ColorLabel1, _ColorLabel2, _ColorLabel3, _ColorLabel4;


    sampler2D _FogLUT;
    float2 _FogLUTParams; // x: -1/(end-start) y: end/(end-start)


	v2f vert(appdata i)
	{
		v2f o;
		o.pos   = UnityObjectToClipPos(i.vertex);
        float4 wpos = mul(unity_ObjectToWorld, i.vertex);
        o.uv.x = wpos.z;
		o.uv.y = i.uv.x;

		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 col;
        fixed4 fog = tex2D(_FogLUT, float2(i.uv.x * _FogLUTParams.x + _FogLUTParams.y, 0.5));

        _WidthGreed /= _StepGreed;
        fixed  greed = smoothstep(1 - _WidthGreed, 1 - _WidthGreed + 0.01, frac(i.uv.x / _StepGreed)) + smoothstep(1 - _WidthGreed, 1 - _WidthGreed + 0.01, frac(-i.uv.x / _StepGreed));
		fixed4 greedColor = _ColorGreed * greed * _ColorGreed.a;

        
        fixed4 label = smoothstep(_WidthLabel + 0.01, _WidthLabel, abs(i.uv.x - _DepthLabel) );
        fixed4 labelColor = _ColorLabel1 * label.x + _ColorLabel2 * label.y + _ColorLabel3 * label.z + _ColorLabel4 * label.w;

		fixed mask = step(i.uv.y, 0.5);
		col.rgb = fog.a * (1-mask) + fog.rgb * mask;
		col.rgb += greedColor.rgb + labelColor.rgb;
		return col;
	}
	ENDCG

	SubShader
	{
		Tags
        {
			"Queue"="Geometry"
			"RenderType"="Opaque"
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
