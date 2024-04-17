Shader "Custom/FogLighting" {
  Properties {
    _Color ("Color", Vector) = (1,1,1,1)
    [Space] _FogLightingStrength ("Fog Lighting Strength", Float) = 0.1
    [Space] _FogStartOffset ("Fog Start Offset", Float) = 0
    _FogScale ("Fog Scale", Float) = 1
  }

  SubShader {
    Tags { "Queue"="Geometry" "RenderType"="Opaque" }

    Pass {
      CGPROGRAM
      #pragma multi_compile __ _ENABLE_BLOOM_FOG
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      #include "UnityInstancing.cginc"
      #include "BloomFog.cginc"
      #include "BlueNoise.cginc"

      struct appdata_t {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
      };
      struct v2f {
        float4 vertex : SV_POSITION;
        float3 worldPos : TEXCOORD1;
        float3 worldNormal : TEXCOORD2;
        float4 screenPos : TEXCOORD3;
      };

      float4 _Color;
      float _FogLightingStrength;
      float _FogStartOffset;
      float _FogScale;

      v2f vert(appdata_t v) {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex);
        o.worldNormal = UnityObjectToWorldNormal(v.normal);
        o.screenPos = ComputeNonStereoScreenPos(o.vertex);
        return o;
      }

      float4 frag(v2f i) : SV_Target {
        float4 col = _Color;
        float2 screenUV = i.screenPos.xy / i.screenPos.w;
        BLOOM_FOG_APPLY_LIGHTING(col, screenUV, i.worldNormal, i.worldPos, _FogStartOffset, _FogScale, _FogLightingStrength);
        BLUE_NOISE_APPLY(col, screenUV);
        return col;
      }
      ENDCG
    }
  }
  Fallback "Diffuse"
}
