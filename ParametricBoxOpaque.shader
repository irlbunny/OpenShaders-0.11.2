Shader "Custom/ParametricBoxOpaque" {
  Properties {
    [HideInInspector] _Color ("Color", Vector) = (1,0,0,0)
    [HideInInspector] _SizeParams ("Width, Length and Center", Vector) = (0.2,2,0.5,0)
    _FogStartOffset ("Fog Start Offset", Float) = 1
    _FogScale ("Fog Scale", Float) = 1
  }

  SubShader {
    Tags { "Queue"="Geometry" "RenderType"="Opaque" }

    Pass {
      CGPROGRAM
      #pragma multi_compile __ _ENABLE_BLOOM_FOG
      #pragma multi_compile_instancing
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      #include "UnityInstancing.cginc"
      #include "BloomFog.cginc"

      struct appdata_t {
        float4 vertex : POSITION;
        UNITY_VERTEX_INPUT_INSTANCE_ID
      };
      struct v2f {
        float4 vertex : SV_POSITION;
        float3 worldPos : TEXCOORD1;
        float4 screenPos : TEXCOORD2;
        UNITY_VERTEX_INPUT_INSTANCE_ID
      };

      UNITY_INSTANCING_BUFFER_START(MyProperties)
        UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
        UNITY_DEFINE_INSTANCED_PROP(float3, _SizeParams)
      UNITY_INSTANCING_BUFFER_END(MyProperties)

      float _FogStartOffset;
      float _FogScale;

      v2f vert(appdata_t v) {
        v2f o;
        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_TRANSFER_INSTANCE_ID(v, o);
        float3 sizeParams = UNITY_ACCESS_INSTANCED_PROP(MyProperties, _SizeParams);
        float4 vertex = v.vertex;
        vertex.y = (v.vertex.y - sizeParams.z) * sizeParams.y;
        vertex.xz = v.vertex.xz * sizeParams.x;
        o.vertex = UnityObjectToClipPos(vertex);
        o.worldPos = mul(unity_ObjectToWorld, vertex);
        o.screenPos = ComputeNonStereoScreenPos(o.vertex);
        return o;
      }

      float4 frag(v2f i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        float4 col = UNITY_ACCESS_INSTANCED_PROP(MyProperties, _Color);
        float2 screenUV = i.screenPos.xy / i.screenPos.w;
        BLOOM_FOG_APPLY(col, screenUV, i.worldPos, _FogStartOffset, _FogScale);
        return col;
      }
      ENDCG
    }
  }
}
