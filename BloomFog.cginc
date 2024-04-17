#ifndef BLOOM_FOG_CG_INCLUDED
#define BLOOM_FOG_CG_INCLUDED

float4 _CustomFogColor;
float _CustomFogColorMultiplier;
float _CustomFogAttenuation;
float _CustomFogOffset;

#define BLOOM_FOG_CALC_FACTOR(distance, fogStartOffset, fogScale) \
  float bloomFogFactor = max(sqrt(dot(##distance, ##distance)) + -##fogStartOffset, 0); \
  bloomFogFactor = clamp(bloomFogFactor * ##fogScale + -_CustomFogOffset, 0, 9999); \
  bloomFogFactor = max(-exp2(-bloomFogFactor * _CustomFogAttenuation * 1.44269502) + 1, 0)

#if _ENABLE_BLOOM_FOG

sampler2D _BloomPrePassTexture;
float _CustomFogTextureToScreenRatio;
float _StereoCameraEyeOffset;

inline float2 GetBloomPrePassUV(float2 screenUV) {
#if UNITY_SINGLE_PASS_STEREO
  float eyeOffset = (unity_StereoEyeIndex * (_StereoCameraEyeOffset + _StereoCameraEyeOffset)) + -_StereoCameraEyeOffset;
#else
  float eyeOffset = 0;
#endif
  return float2(
    (eyeOffset + screenUV.x + -0.5) * _CustomFogTextureToScreenRatio + 0.5,
    (screenUV.y + -0.5) * _CustomFogTextureToScreenRatio + 0.5
  );
}

#define BLOOM_FOG_APPLY(col, screenUV, worldPos, fogStartOffset, fogScale) \
  float3 bloomFogDistance = ##worldPos - _WorldSpaceCameraPos; \
  BLOOM_FOG_CALC_FACTOR(bloomFogDistance, ##fogStartOffset, ##fogScale); \
  float4 bloomFogCol = _CustomFogColor * _CustomFogColorMultiplier + float4(tex2D(_BloomPrePassTexture, GetBloomPrePassUV(##screenUV)).rgb, 0); \
  ##col = bloomFogFactor * (bloomFogCol + -##col) + ##col

#define BLOOM_FOG_APPLY_LIGHTING(col, screenUV, worldNormal, worldPos, fogStartOffset, fogScale, fogLightingStrength) \
  float3 bloomFogDistance = ##worldPos - _WorldSpaceCameraPos; \
  BLOOM_FOG_CALC_FACTOR(bloomFogDistance, ##fogStartOffset, ##fogScale); \
  float bloomFogLighting = (-abs(dot(normalize(##worldPos), ##worldNormal)) + 1) * ##fogLightingStrength; \
  float4 bloomFogCol = _CustomFogColor * _CustomFogColorMultiplier + float4(tex2D(_BloomPrePassTexture, GetBloomPrePassUV(##screenUV)).rgb, 0); \
  float4 bloomFogLightingCol = bloomFogLighting * (bloomFogCol + -##col) + ##col; \
  ##col = bloomFogFactor * (bloomFogCol + -bloomFogLightingCol) + bloomFogLightingCol

#else

#define BLOOM_FOG_APPLY(col, screenUV, worldPos, fogStartOffset, fogScale) \
  float3 bloomFogDistance = ##worldPos - _WorldSpaceCameraPos; \
  BLOOM_FOG_CALC_FACTOR(bloomFogDistance, ##fogStartOffset, ##fogScale); \
  float4 bloomFogCol = _CustomFogColor * _CustomFogColorMultiplier; \
  ##col = bloomFogFactor * (bloomFogCol + -##col) + ##col

#define BLOOM_FOG_APPLY_LIGHTING(col, screenUV, worldNormal, worldPos, fogStartOffset, fogScale, fogLightingStrength) \
  float3 bloomFogDistance = ##worldPos - _WorldSpaceCameraPos; \
  BLOOM_FOG_CALC_FACTOR(bloomFogDistance, ##fogStartOffset, ##fogScale); \
  float bloomFogLighting = (-abs(dot(normalize(##worldPos), ##worldNormal)) + 1) * ##fogLightingStrength; \
  float4 bloomFogCol = _CustomFogColor * _CustomFogColorMultiplier; \
  float4 bloomFogLightingCol = bloomFogLighting * (bloomFogCol + -##col) + ##col; \
  ##col = bloomFogFactor * (bloomFogCol + -bloomFogLightingCol) + bloomFogLightingCol

#endif

#define BLOOM_FOG_APPLY_TRANSPARENT(col, worldPos, fogStartOffset, fogScale) \
  float3 bloomFogDistance = ##worldPos - _WorldSpaceCameraPos; \
  BLOOM_FOG_CALC_FACTOR(bloomFogDistance, ##fogStartOffset, ##fogScale); \
  bloomFogFactor = (1 - bloomFogFactor) * col.a; \
  ##col = float4(bloomFogFactor * ##col.rgb, bloomFogFactor)

#endif // BLOOM_FOG_CG_INCLUDED
