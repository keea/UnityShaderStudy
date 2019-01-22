Shader "Custom/toon"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("NormalMap", 2D) = "bump" {}
        _Band("Number of Band", Range(1, 10)) = 5 //색상 띠 갯수
        _SpecCol("Specular Color", color) = (1,1,1,1)
        _SpecPow("Specular Power", Range(100,3000)) = 1000
        _SpecBand("Number of Specular Band", Range(1,10)) = 2
        _FrePow("Fresnel Power", Range(0.01, 1)) = 0.2
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
        float4 _SpecCol;
        float _SpecPow;
        float _FrePow;
        float _SpecBand;

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

            float3 specColor;
            float3 H = normalize(lightDir + viewDir);
            float spec = saturate(dot(H, s.Normal));

            spec = pow(spec, _SpecPow);
            spec *= _SpecBand;
            spec = ceil(spec)/_SpecBand;
            specColor = spec * _SpecCol.rgb;

            
            float rim = abs(dot(s.Normal, viewDir));
            
            if(rim > _FrePow){
                rim = 1;
            }else{
                rim = -1;
            }
           
            float4 final;
            final.rgb = s.Albedo * ndotl * _LightColor0.rgb * rim + specColor;
            final.a = s.Alpha;

            return final;
        }
        ENDCG
    }
    FallBack "Diffuse"
}