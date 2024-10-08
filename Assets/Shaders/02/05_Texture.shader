Shader "Unlit/05_Texture"
{
/* 	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float2 titling =  _MainTex_ST.xy;
				float2 offset =  _MainTex_ST.zw;
				fixed4 col = tex2D(_MainTex, i.uv * titling + offset);
				return col;
			}
			ENDCG
		}
	} */

	Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1,1,1,1)
		_SpecularPower ("Specular Power", Range(0.1, 100)) = 40
		_SpecularIntensity ("Specular Intensity", Range(0, 2)) = 1
		_AmbientIntensity ("Ambient Intensity", Range(0, 1)) = 0.2
		_DiffuseIntensity ("Diffuse Intensity", Range(0, 2)) = 1.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _Color;
            float4 _MainTex_ST;

			float _SpecularPower;
			float _SpecularIntensity;
			float _AmbientIntensity;
			float _DiffuseIntensity;


            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD1;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Phong 光照计算
                float3 normal = normalize(i.normal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
                float3 reflectDir = reflect(-lightDir, normal);

                //float3 ambient = 0.1 * _LightColor0.rgb;
                //float3 diffuse = max(dot(normal, lightDir), 0.0) * _LightColor0.rgb;
                //float3 specular = pow(max(dot(reflectDir, viewDir), 0.0), 20.0) * _LightColor0.rgb;
				float3 ambient = _AmbientIntensity * _LightColor0.rgb;
				float3 diffuse = max(dot(normal, lightDir), 0.0) * _LightColor0.rgb * _DiffuseIntensity;
				float3 specular = pow(max(dot(reflectDir, viewDir), 0.0), _SpecularPower) * _LightColor0.rgb * _SpecularIntensity;


                // 纹理采样
                fixed4 texColor = tex2D(_MainTex, i.uv);

                // 最终颜色：Phong 反射光照 + 纹理颜色
                fixed4 finalColor = texColor * _Color; // 基础纹理颜色
                finalColor.rgb *= ambient + diffuse + specular; // 结合光照
                return finalColor;
            }
            ENDCG
        }
    }
}