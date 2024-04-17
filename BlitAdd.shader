Shader "Hidden/BlitAdd" {
  Properties {
    _MainTex ("Texture", any) = "" {}
    _Alpha ("Alpha", Float) = 1
  }

  SubShader {
    Blend SrcAlpha One, SrcAlpha One
    ZTest Always ZWrite Off Cull Off

    Pass {
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag

      #include "UnityCG.cginc"

      struct appdata_t {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
      };
      struct v2f {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
      };

      sampler2D _MainTex;
      float4 _MainTex_ST;
      float _Alpha;

      v2f vert(appdata_t v) {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        return o;
      }

      float4 frag(v2f i) : SV_Target {
        return float4(tex2D(_MainTex, i.uv).rgb, _Alpha);
      }
      ENDCG
    }
  }
}
