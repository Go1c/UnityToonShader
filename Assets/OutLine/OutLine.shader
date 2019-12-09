//双pass描边
Shader "Custom/OutLine"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo (RGB)", 2D) = "white" { }
        _Glossiness ("Smoothness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0, 1)) = 0.0
        _OutLineColor ("OutLineColor", Color) = (1, 1, 1, 1)
        _OutLineWidth ("OutLineWidth", Range(0, 10)) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200
        
        CGPROGRAM
        
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows
        
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        
        sampler2D _MainTex;
        
        struct Input
        {
            float2 uv_MainTex;
        };
        
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        
        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
        
        pass
        {
            Cull Front
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            half _OutLineWidth;
            half4 _OutLineColor;
            float2 offset;
            float4 vert(float4 position : POSITION, float3 normal:  NORMAL) : SV_POSITION
            {
                float4 clipPosition = UnityObjectToClipPos(position);
                //先转世界再转裁剪
                float3 clipNormal = mul((float3x3)UNITY_MATRIX_VP, mul((float3x3)UNITY_MATRIX_M, normal)); 
                // 除以_ScreenParams.xy 是根据分辨率来自适应描边效果， 
                // clipPosition.w 是防止透视除法后距离相机远导致描边看不到
                // * 2 是因为裁剪空间是[-1,1]之间 总共为2, _OutLineWidth  和像素为1：1
                offset = normalize(clipNormal.xy) / _ScreenParams.xy * _OutLineWidth * clipPosition.w * 2;
                clipPosition.xy += offset;
                return clipPosition;
            }
            
            half4 frag(): SV_Target
            {
                return _OutLineColor;
            }
            ENDCG
            
        }
    }
    FallBack "Diffuse"
}
