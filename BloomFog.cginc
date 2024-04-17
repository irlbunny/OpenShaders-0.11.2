#ifndef BLOOM_FOG_CG_INCLUDED
#define BLOOM_FOG_CG_INCLUDED

float4 _CustomFogColor;
float _CustomFogColorMultiplier;
float _CustomFogAttenuation;
float _CustomFogOffset;

#define BLOOM_FOG_CALC_FACTOR(distance, fogStartOffset, fogScale) \
  float bloomFogFactor = max(sqrt(dot(distance, distance)) + -fogStartOffset, 0); \
  bloomFogFactor = clamp(bloomFogFactor * fogScale + -_CustomFogOffset, 0, 9999); \
  bloomFogFactor = max(-exp2(-bloomFogFactor * _CustomFogAttenuation * 1.44269502) + 1, 0)

#if _ENABLE_BLOOM_FOG

sampler2D _BloomPrePassTexture;
float _CustomFogTextureToScreenRatio;
float _StereoCameraEyeOffset;

inline float2 GetBloomPrePassUV(float4 screenPos) {
  float2 screenUV = screenPos.xy / screenPos.w;
#if UNITY_SINGLE_PASS_STEREO
  float eyeOffset = (unity_StereoEyeIndex * _StereoCameraEyeOffset + _StereoCameraEyeOffset) + -_StereoCameraEyeOffset;
#else
  float eyeOffset = 0;
#endif
  return float2(eyeOffset + screenUV.x + -0.5, screenUV.y + -0.5) * _CustomFogTextureToScreenRatio + 0.5;
}

#define BLOOM_FOG_APPLY(col, screenPos, worldPos, fogStartOffset, fogScale) \
  float3 bloomFogDistance = worldPos - _WorldSpaceCameraPos; \
  BLOOM_FOG_CALC_FACTOR(bloomFogDistance, fogStartOffset, fogScale); \
  float4 bloomFogCol = tex2D(_BloomPrePassTexture, GetBloomPrePassUV(screenPos)); \
  col = bloomFogFactor * (_CustomFogColor * _CustomFogColorMultiplier + float4(bloomFogCol.rgb, 0) + -col) + col

#else

#define BLOOM_FOG_APPLY(col, screenPos, worldPos, fogStartOffset, fogScale) \
  float3 bloomFogDistance = worldPos - _WorldSpaceCameraPos; \
  BLOOM_FOG_CALC_FACTOR(bloomFogDistance, fogStartOffset, fogScale); \
  col = bloomFogFactor * (_CustomFogColor * _CustomFogColorMultiplier + -col) + col

#endif

#define BLOOM_FOG_APPLY_TRANSPARENT(col, worldPos, fogStartOffset, fogScale) \
  float3 bloomFogDistance = worldPos - _WorldSpaceCameraPos; \
  BLOOM_FOG_CALC_FACTOR(bloomFogDistance, fogStartOffset, fogScale); \
  bloomFogFactor = (1 - bloomFogFactor) * col.a; \
  col = float4(bloomFogFactor * col.rgb, bloomFogFactor)

#endif // BLOOM_FOG_CG_INCLUDED
