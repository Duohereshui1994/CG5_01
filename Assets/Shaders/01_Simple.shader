Shader "Unlit/01_Simple"
{
    properties
    {
        _Color ("Color", Color) = (1,0,0,1)
    }
    Subshader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _Color;

            float4 vert(float4 v : POSITION) : SV_POSITION
            {
                float4 o;
                o = UnityObjectToClipPos(v);
                return o;
            }
            fixed4 frag(float4 i : SV_POSITION) : SV_Target
            {
                fixed4 o = _Color;
                return o;
            }
            ENDCG
        }
    }
}