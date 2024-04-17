#ifndef BLUE_NOISE_CG_INCLUDED
#define BLUE_NOISE_CG_INCLUDED

sampler2D _GlobalBlueNoiseTex;
float2 _GlobalBlueNoiseParams;
float _GlobalRandomValue;

#define BLUE_NOISE_APPLY(col, screenUV) \
  float2 blueNoiseUV = screenUV * _GlobalBlueNoiseParams + _GlobalRandomValue; \
  float blueNoiseCol = tex2D(_GlobalBlueNoiseTex, blueNoiseUV).a + -0.5; \
  col.rgb = float3(blueNoiseCol * 0.00390625 + col.rgb)

#endif // BLUE_NOISE_CG_INCLUDED
