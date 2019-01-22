Shader "Custom/outline"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [Toggle]_OutLine("Show OutLine", Range(0,1)) = 1.0
        _Thickness("Outline Thickness", Range(0.001, 0.01)) = 0.005
        _Color("Outline Color", Color) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        cull front

        //1nd Pass
        CGPROGRAM
        #pragma surface surf Nolight vertex:vert noshadow noambient

        sampler2D _MainTex;
        float _Thickness;
        float4 _Color;
        float _OutLine;

        void vert(inout appdata_full v){
            v.vertex.xyz += v.normal.xyz * _Thickness * _OutLine;
        }

        struct Input
        {
            float4 color:COLOR;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
        }

        float4 LightingNolight(SurfaceOutput s, float3 lightDir, float atten){
            return _Color;
        }
        ENDCG

        //2nd Pass
        cull back
        
        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
