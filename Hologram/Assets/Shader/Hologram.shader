Shader "Custom/holo"
{
    Properties
    {
        _RimColor("RimColor", color) = (1,1,1,1)
        _RimPower("RimPower", Range(1,10)) = 3

        [Space]
        [Header(Flicker)]
        [Toggle]_UseFlickerEffect("Use", Range(0,1)) = 1.0
        _FlickerSpeed("Speed", Range(1,50)) = 3

        [Space]
        [Header(Line)]
        [Toggle]_UseLineEffect("Use", Range(0,1)) = 1.0
        _IncreaseLine("Increase", Range(1,50)) = 3
        _LineThickness("Thickness", Range(1,50)) = 30
        _LineSpeed("Speed", Range(1,10)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        CGPROGRAM
        #pragma surface surf nolight noambient alpha:fade

        float4 _RimColor;
        float _RimPower;
        float _FlickerSpeed;
        float _IncreaseLine;
        float _LineThickness;
        float _LineSpeed;
        float _UseLineEffect;
        float _UseFlickerEffect;

        struct Input
        {
            float3 viewDir;
            float3 worldPos;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Emission = _RimColor;

            //내적 연산 -1로 가는 것 방지.
            float rim = saturate(dot(o.Normal, IN.viewDir));
            rim = pow(1-rim, _RimPower);

            //라인 효과
            float lineEffect = pow(frac(IN.worldPos.g * _IncreaseLine - (_Time.y * _LineSpeed)), _LineThickness) * _UseLineEffect;

            //깜빡이는 효과
            float flicker = abs(sin(_Time.y * _FlickerSpeed));
            //0(false)과 1(true)의값을 1과 0으로 변경
            float tempFlickerEffect = abs(-_UseFlickerEffect + 1);
            flicker = (_UseFlickerEffect * flicker) + tempFlickerEffect;

            o.Alpha = (rim+lineEffect) * flicker;
        }

        float4 Lightingnolight(SurfaceOutput s, float lightDir, float atten)
        {
            return float4(0,0,0,s.Alpha);
        }
        ENDCG
    }

    //그림자를 생성하지 않음.
    FallBack "Transparent/Diffuse"
}
