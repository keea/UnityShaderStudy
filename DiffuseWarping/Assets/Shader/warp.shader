Shader "Custom/warp"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("NormalMap", 2D) = "bump" {}
        _RampTex ("RampTex", 2D) = "white" {}
        _SpecPow("Specular Power", Range(0,100)) = 100
        _RimPow("Rim Power", Range(0,0.4)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf warp noambient

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _RampTex;
        float _SpecPow;
        float _RimPow;

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

        float4 Lightingwarp(SurfaceOutput s, float3 lightDir,float3 viewDir, float atten){
            float3 H = normalize(lightDir + viewDir);
            float spec = saturate(dot(s.Normal, H));
            spec = pow(spec, _SpecPow);
            

            float rim = abs(dot(s.Normal, viewDir)); 
            rim = min(0.8, rim + _RimPow); 

            bool temp = spec > rim;
            rim = temp * spec + !temp * rim;
            
            float ndotl = dot(s.Normal, lightDir)*0.5+0.5;
            float4 ramp = tex2D(_RampTex, float2(ndotl, rim));

            float4 final;
            final.rgb = (s.Albedo.rgb * ramp.rgb);
            final.a = s.Alpha;
            return final;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
