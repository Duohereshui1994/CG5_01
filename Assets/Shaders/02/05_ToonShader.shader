Shader "Unlit/05_ToonShader"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Cutoff ("Light Threshold", Range(0.0, 1.0)) = 0.5
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineWidth ("Outline Width", Range(0.005, 0.03)) = 0.02
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        // パス 1: トゥーンシェーディング
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _Color;
            float _Cutoff;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float NdotL = dot(i.normal, lightDir);

                // トゥーンライトの計算: 明るさの段階を2段階に分ける
                float toonShade = step(_Cutoff, NdotL);

                // テクスチャと色を適用
                fixed4 texColor = tex2D(_MainTex, i.uv);
                fixed4 finalColor = texColor * _Color * toonShade;

                return finalColor;
            }
            ENDCG
        }

        // パス 2: 輪郭線の描画
        Pass
        {
            Name "Outline"
            Tags { "LightMode" = "Always" }
            Cull Front
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float _OutlineWidth;
            float4 _OutlineColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 color : COLOR;
            };

            v2f vert(appdata v)
            {
                // 頂点を法線方向に押し出すことでアウトラインを生成
                v2f o;
                float3 norm = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                float4 pos = v.vertex;
                pos.xyz += norm * _OutlineWidth;
                o.pos = UnityObjectToClipPos(pos);
                o.color = _OutlineColor;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
