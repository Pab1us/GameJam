/*шейдер для создания партикловых колец
//из партиклов передаем два вектора в которых определяются параметры:
//1.Радиус кольца
//2.Толщина кольца
//3. Жесткость переходов на всех краях

//1.Начало сектора   (0..1)
//2.Конец сектора   (0..1)
//3.Частота повтора пунктира  (от 1)
//4.Величина пробелов в пунктире   (0..1)*/

Shader "SpaceJustice/FX/Items/Parametric Circle Particles1"
{
	Properties
	{
		_ColorMain("Color main",Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 params1 : TEXCOORD0;
				float4 params2 : TEXCOORD1;
				float2 uv : TEXCOORD2;
				fixed4 color : COLOR;
				half3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 params1 : TEXCOORD0;
				float4 params2 : TEXCOORD1;
				float2 uv : TEXCOORD2;
				fixed4 color : COLOR;
			};

			fixed4 _ColorMain;

			v2f vert(appdata v)
			{
				v2f o;

				// точки сдвигаем по нормали, величина сдвига зависит от положения на мапинге по V
				// v=0 - базовая часть   v=1 - точки сдвинутые относительно базовых на заданную величину
				v.vertex.xyz += v.normal * lerp(v.params1.x, v.params1.x + v.params1.y, v.uv.y);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.params1 = v.params1;
				o.params2 = v.params2;
				o.color = v.color * _ColorMain;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = i.color;

				//fixed maskV = smoothstep(0.5, 0.5 - abs(i.params1.z / (1 - i.params1.y)),  abs(i.uv.y - 0.5));
				//здесь линия с псевдо глоу генерится, ширина глоу не зависит от ширины кольца, кто разберется как оно работает - мои поздравления!

				fixed par = 1.0f - 1.0f / i.params1.y - i.params1.w;
				fixed res1 = abs(i.uv.y - 0.5f) * 2.0f;
				fixed res2 = saturate((res1 - par * 0.8f - 0.2f) / ((par - 1.0f) * 0.2f));
				fixed res3 = saturate((res1 - 1.0f) / (par - 1.0f)) * 0.35f;
				fixed maskV = max(res2, res3);
				//маска сектора
				fixed2 maskSector = smoothstep(i.params2.xy, i.params2.xy - i.params1.z / (6.28f * i.params1.x + i.params1.y), i.uv.x);// x - старт сектора  y - конец сектора
				//маска пунктира
				fixed triangleFunc = saturate(abs(frac(i.uv.x * i.params2.z) * 2.0f - 1.0f));
				fixed maskDot = smoothstep(i.params2.w, i.params2.w - i.params1.z / (3.14f * i.params1.x + i.params1.y) * i.params2.z, triangleFunc);

				col.a *= maskV * (1.0f - maskSector.y) * maskSector.x * maskDot;

				return col;
			}
			ENDCG
		}
	}
}
