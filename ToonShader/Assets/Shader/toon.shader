Shader "Custom/toon"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("NormalMap", 2D) = "bump" {}
        _Band("Number of Band", Range(1, 10)) = 5 //색상 띠 갯수
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        cull back
        CGPROGRAM
        #pragma surface surf Toon 

        sampler2D _MainTex;
        sampler2D _BumpMap;
        float _Band;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }

        float4 LightingToon(SurfaceOutput s, float3 lightDir, float3 viewDir ,float atten){
            float ndotl = dot(s.Normal, lightDir) * 0.5 + 0.5;

            ndotl *= _Band;
            ndotl = ceil(ndotl)/_Band;

            float4 final;
            final.rgb = s.Albedo * ndotl * _LightColor0.rgb;
            final.a = s.Alpha;

            return final;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
