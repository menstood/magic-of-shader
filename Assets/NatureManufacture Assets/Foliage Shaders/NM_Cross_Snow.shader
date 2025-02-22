Shader "NatureManufacture/URP/Foliage/Cross Snow"
{
    Properties
    {
        _AlphaCutoff("Alpha Cutoff", Float) = 0.5
        [NoScaleOffset]_BaseColorMap("Base Map", 2D) = "white" {}
        _TilingOffset("Tiling and Offset", Vector) = (1, 1, 0, 0)
        _HealthyColor("Healthy Color", Color) = (1, 1, 1, 0)
        _DryColor("Dry Color", Color) = (0.8196079, 0.8196079, 0.8196079, 0)
        _ColorNoiseSpread("Color Noise Spread", Float) = 2
        [Normal][NoScaleOffset]_NormalMap("Normal Map", 2D) = "bump" {}
        _NormalScale("Normal Scale", Range(0, 8)) = 1
        _AORemapMax("AO Remap Max", Range(0, 1)) = 1
        _SmoothnessRemapMax("Smoothness Remap Max", Range(0, 1)) = 1
        _Specular("Specular", Range(0, 1)) = 0.3
        _Snow_Amount("Snow Amount", Range(0, 2)) = 0
        _SnowBaseColor("Snow Base Color", Color) = (1, 1, 1, 0)
        [NoScaleOffset]_SnowMaskA("Snow Mask(A)", 2D) = "black" {}
        _SnowMaskTreshold("Snow Mask Treshold", Range(0.1, 6)) = 4
        [ToggleUI]_InvertSnowMask("Invert Snow Mask", Float) = 0
        [NoScaleOffset]_SnowBaseColorMap("Snow Base Map", 2D) = "white" {}
        _SnowTilingOffset("Snow Tiling Offset", Vector) = (1, 1, 0, 0)
        _SnowBlendHardness("Snow Blend Hardness", Range(0, 8)) = 1
        _SnowAORemapMax("Snow AO Remap Max", Range(0, 1)) = 1
        _SnowSmoothnessRemapMax("Snow Smoothness Remap Max", Range(0, 1)) = 1
        _SnowSpecular("Snow Specular", Range(0, 1)) = 0.3
        _Stiffness("Wind Stiffness", Float) = 1
        _InitialBend("Wind Initial Bend", Float) = 0
        _Drag("Wind Drag", Float) = 1
        _HeightDrag("Wind Drag Height Offset", Float) = 0
        _NewNormal("Mesh Normal Multiply", Vector) = (0, 0, 0, 0)
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="AlphaTest"
            "DisableBatching"="LODFading"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        AlphaToMask On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        #define _SPECULAR_SETUP 1
        #define USE_UNITY_CROSSFADE 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 VertexColor;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        float _Stiffness;
        float _InitialBend;
        float _Drag;
        float _HeightDrag;
        float4 _NewNormal;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        float4x4 WIND_SETTINGS_Points;
        float4 WIND_SETTINGS_Points_Radius;
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        float WIND_SETTINGS_GustWorldScale;
        float WIND_SETTINGS_GustScale;
        float WIND_SETTINGS_GustSpeed;
        float WIND_SETTINGS_Turbulence;
        float WIND_SETTINGS_ShiverNoiseScale;
        float WIND_SETTINGS_FlexNoiseScale;
        float4 WIND_SETTINGS_WorldDirectionAndSpeed;
        TEXTURE2D(WIND_SETTINGS_TexGust);
        SAMPLER(samplerWIND_SETTINGS_TexGust);
        float4 WIND_SETTINGS_TexGust_TexelSize;
        TEXTURE2D(WIND_SETTINGS_TexNoise);
        SAMPLER(samplerWIND_SETTINGS_TexNoise);
        float4 WIND_SETTINGS_TexNoise_TexelSize;
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Length_float4(float4 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float
        {
        };
        
        void SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(float4x4 Matrix4_cb72bb33b7a84dfda97778a514f9b60f, float3 Vector3_90379ebf40aa468b8362f8d265f4f234, float4 Vector4_159bb4232f82428893101734a03e2a1e, Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float IN, out float4 WindPoint_1)
        {
        float3 _Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3 = Vector3_90379ebf40aa468b8362f8d265f4f234;
        float4x4 _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4 = Matrix4_cb72bb33b7a84dfda97778a514f9b60f;
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].r);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].g);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].b);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].a);
        float3 _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4.xyz), _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3);
        float3 _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3);
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[0];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[1];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[2];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[3];
        float _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float;
        Unity_Length_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float);
        float4 _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4 = Vector4_159bb4232f82428893101734a03e2a1e;
        float _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[0];
        float _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[1];
        float _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[2];
        float _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[3];
        float _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float;
        Unity_Divide_float(_Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float, _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float);
        float _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float;
        Unity_Clamp_float(_Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float, 0, 1, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float);
        float _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float;
        Unity_Lerp_float(_Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float, 0, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float);
        float3 _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3, (_Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float.xxx), _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3);
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[0];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[1];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[2];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_A_4_Float = 0;
        float4 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4;
        float3 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3;
        float2 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2;
        Unity_Combine_float(_Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2);
        float3 _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4.xyz), _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3);
        float3 _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3);
        float _Split_8bbd5052350846968bf312362efd9f01_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[0];
        float _Split_8bbd5052350846968bf312362efd9f01_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[1];
        float _Split_8bbd5052350846968bf312362efd9f01_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[2];
        float _Split_8bbd5052350846968bf312362efd9f01_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[3];
        float _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float;
        Unity_Length_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float);
        float _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float;
        Unity_Divide_float(_Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float, _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float);
        float _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float;
        Unity_Clamp_float(_Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float, 0, 1, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float);
        float _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float;
        Unity_Lerp_float(_Split_8bbd5052350846968bf312362efd9f01_A_4_Float, 0, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float);
        float3 _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3, (_Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float.xxx), _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3);
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[0];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[1];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[2];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_A_4_Float = 0;
        float4 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4;
        float3 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3;
        float2 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2;
        Unity_Combine_float(_Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2);
        float4 _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4;
        Unity_Add_float4(_Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4);
        float3 _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4.xyz), _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3);
        float3 _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3);
        float _Split_fa21a8022f944854903e06c07c6f079c_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[0];
        float _Split_fa21a8022f944854903e06c07c6f079c_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[1];
        float _Split_fa21a8022f944854903e06c07c6f079c_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[2];
        float _Split_fa21a8022f944854903e06c07c6f079c_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[3];
        float _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float;
        Unity_Length_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float);
        float _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float;
        Unity_Divide_float(_Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float, _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float);
        float _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float;
        Unity_Clamp_float(_Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float, 0, 1, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float);
        float _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float;
        Unity_Lerp_float(_Split_fa21a8022f944854903e06c07c6f079c_A_4_Float, 0, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float);
        float3 _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3, (_Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float.xxx), _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3);
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[0];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[1];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[2];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_A_4_Float = 0;
        float4 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4;
        float3 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3;
        float2 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2;
        Unity_Combine_float(_Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2);
        float4 _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4;
        Unity_Add_float4(_Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4);
        float3 _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4.xyz), _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3);
        float3 _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3);
        float _Split_1bfec6763d4b458398e36937b4114c29_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[0];
        float _Split_1bfec6763d4b458398e36937b4114c29_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[1];
        float _Split_1bfec6763d4b458398e36937b4114c29_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[2];
        float _Split_1bfec6763d4b458398e36937b4114c29_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[3];
        float _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float;
        Unity_Length_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float);
        float _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float;
        Unity_Divide_float(_Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float, _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float);
        float _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float;
        Unity_Clamp_float(_Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float, 0, 1, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float);
        float _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float;
        Unity_Lerp_float(_Split_1bfec6763d4b458398e36937b4114c29_A_4_Float, 0, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float);
        float3 _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3, (_Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float.xxx), _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3);
        float _Split_e22879e6c4574322ab21f6261a21bced_R_1_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[0];
        float _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[1];
        float _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[2];
        float _Split_e22879e6c4574322ab21f6261a21bced_A_4_Float = 0;
        float4 _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4;
        float3 _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3;
        float2 _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2;
        Unity_Combine_float(_Split_e22879e6c4574322ab21f6261a21bced_R_1_Float, _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float, _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3, _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2);
        float4 _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        Unity_Add_float4(_Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4);
        WindPoint_1 = _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float
        {
        };
        
        void SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(float3 Vector3_604F121F, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7F78DDD2, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float Vector1_5EFF6B1A, Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float IN, out float3 direction_1, out float strength_2)
        {
        float4 _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[0];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[1];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[2];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_A_4_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[3];
        float4 _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4;
        float3 _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3;
        float2 _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2;
        Unity_Combine_float(_Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float, 0, _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4, _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2);
        float3 _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3;
        Unity_Normalize_float3(_Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3);
        float4 _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_R_1_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[0];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_G_2_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[1];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_B_3_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[2];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[3];
        float3 _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, (_Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float.xxx), _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3);
        float _Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float = Vector1_9365F438;
        float _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float, 0, _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean);
        UnityTexture2D _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D = Texture2D_A3874DB9;
        float3 _Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3 = float3(1, 0, 0);
        float _Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float.xxx), _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3);
        float _Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float = Vector1_5EFF6B1A;
        float3 _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3);
        float3 _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3;
        Unity_Subtract_float3(_Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3, _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3, _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3);
        float _Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float = Vector1_6803B355;
        float3 _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3, (_Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float.xxx), _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3);
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[0];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_G_2_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[1];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[2];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_A_4_Float = 0;
        float4 _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4;
        float3 _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3;
        float2 _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2;
        Unity_Combine_float(_Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float, _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float, 0, 0, _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4, _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3, _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2);
          float4 _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.tex, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.samplerstate, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.GetTransformedUV(_Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_G_6_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_B_7_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_A_8_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.a;
        float _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float;
        Unity_Branch_float(_Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean, _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float, 0, _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float);
        float _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float;
        Unity_Power_float(_Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float, 2, _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float);
        float _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float = Vector1_F53C4B89;
        float _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float;
        Unity_Multiply_float_float(_Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float, _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float, _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float);
        float3 _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float.xxx), _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3);
        float _Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3, (_Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float.xxx), _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3);
        float3 _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3, _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3, _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3);
        float4 _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_e719665c40324e89a536d165d0427a68_R_1_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[0];
        float _Split_e719665c40324e89a536d165d0427a68_G_2_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[1];
        float _Split_e719665c40324e89a536d165d0427a68_B_3_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[2];
        float _Split_e719665c40324e89a536d165d0427a68_A_4_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[3];
        float _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Split_e719665c40324e89a536d165d0427a68_A_4_Float, 0, _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean);
        float _Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float = Vector1_2EC6D670;
        float _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float, 0, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean);
        float _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean;
        Unity_Or_float(_Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean, _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean);
        UnityTexture2D _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D = Texture2D_5BAC276D;
        float3 _Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Split_e719665c40324e89a536d165d0427a68_A_4_Float.xxx), _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3);
        float3 _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3);
        float3 _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3;
        Unity_Subtract_float3(_Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3, _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3, _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3);
        float _Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float = Vector1_B4470F9B;
        float3 _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3, (_Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float.xxx), _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3);
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[0];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_G_2_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[1];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[2];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_A_4_Float = 0;
        float4 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4;
        float3 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3;
        float2 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2;
        Unity_Combine_float(_Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float, _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float, 0, 0, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2);
          float4 _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.tex, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.samplerstate, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.GetTransformedUV(_Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_A_8_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.a;
        float4 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4;
        float3 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3;
        float2 _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2;
        Unity_Combine_float(_SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float, 0, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2);
        float3 _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3;
        Unity_Add_float3(_Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3);
        float3 _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3;
        Unity_Branch_float3(_Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean, _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3, float3(0, 0, 0), _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3);
        float _Property_9946d066804cc584a96830f8d35269cc_Out_0_Float = Vector1_2EC6D670;
        float3 _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3, (_Property_9946d066804cc584a96830f8d35269cc_Out_0_Float.xxx), _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3);
        float3 _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3;
        Unity_Add_float3(_Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3, _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3, _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3);
        float _Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float = Vector1_A2C4B4F4;
        float3 _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3, (_Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float.xxx), _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3);
        float _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float;
        Unity_Length_float3(_Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3, _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float);
        float _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float = Vector1_7F78DDD2;
        float _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float;
        Unity_Add_float(_Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float, _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float, _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float);
        float _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        Unity_Multiply_float_float(_Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float, 0.001, _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float);
        direction_1 = _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        strength_2 = _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Comparison_NotEqual_float(float A, float B, out float Out)
        {
            Out = A != B ? 1 : 0;
        }
        
        struct Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float
        {
        float3 WorldSpaceNormal;
        float4 VertexColor;
        };
        
        void SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(float Vector1_BCB03E1A, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7EE0F94A, float Boolean_527CB26E, float Vector1_DE1BF63A, float Vector1_7F78DDD2, float3 Vector3_DE8CC74D, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float4x4 Matrix4_0617b0bd42fc46ff90b1d55303a5477f, float4 Vector4_b44806ec67ca461fbcdf009dc6092cc3, Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float IN, out float3 vertex_1, out float3 normal_2)
        {
        float4 _Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3;
        _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3 = TransformObjectToWorld((_Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4.xyz).xyz);
        float _Distance_63631313b11e497cab6af82887a71903_Out_2_Float;
        Unity_Distance_float3(_Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3, float3(0, 0, 0), _Distance_63631313b11e497cab6af82887a71903_Out_2_Float);
        float _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_63631313b11e497cab6af82887a71903_Out_2_Float, 0.001, _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean);
        float3 _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3 = Vector3_C30D997B;
        float4 _Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3;
        _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3 = TransformObjectToWorld((_Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4.xyz).xyz);
        float _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float;
        Unity_Distance_float3(_Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, float3(0, 0, 0), _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float);
        float _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float, 1, _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean);
        float3 _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean, float3(5, 5, 5), _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3);
        float3 _Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3;
        _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3 = TransformObjectToWorld(_Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3.xyz);
        float _Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean = Boolean_527CB26E;
        float _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float = Vector1_7EE0F94A;
        float _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, 0, _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean);
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_R_1_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[0];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[1];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_B_3_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[2];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_A_4_Float = 0;
        float _Split_7a634ef857769683b2100876a36535a2_R_1_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[0];
        float _Split_7a634ef857769683b2100876a36535a2_G_2_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[1];
        float _Split_7a634ef857769683b2100876a36535a2_B_3_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[2];
        float _Split_7a634ef857769683b2100876a36535a2_A_4_Float = 0;
        float _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float;
        Unity_Subtract_float(_Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float, _Split_7a634ef857769683b2100876a36535a2_G_2_Float, _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float);
        float _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean;
        Unity_Comparison_Less_float(_Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float, _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean);
        float _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean;
        Unity_And_float(_Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean, _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean);
        float _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float = Vector1_A2C4B4F4;
        float _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float;
        Unity_Branch_float(_And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean, 1E-05, _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float);
        float _Split_43013162a81fc4889a1944f2a2b75f66_R_1_Float = IN.VertexColor[0];
        float _Split_43013162a81fc4889a1944f2a2b75f66_G_2_Float = IN.VertexColor[1];
        float _Split_43013162a81fc4889a1944f2a2b75f66_B_3_Float = IN.VertexColor[2];
        float _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float = IN.VertexColor[3];
        float _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float;
        Unity_Multiply_float_float(_Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float);
        float _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float;
        Unity_Branch_float(_Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float);
        float _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float = Vector1_7F78DDD2;
        UnityTexture2D _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D = Texture2D_5BAC276D;
        UnityTexture2D _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D = Texture2D_A3874DB9;
        float4 _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float;
        Unity_Length_float4(_Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float);
        float _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float, 0, _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean);
        float4 _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4;
        Unity_Branch_float4(_Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean, _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, float4(0, 0, 1, 1), _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4);
        float4x4 _Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4 = Matrix4_0617b0bd42fc46ff90b1d55303a5477f;
        float4 _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4 = Vector4_b44806ec67ca461fbcdf009dc6092cc3;
        Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float _WindNMPoints_a2cb25cd23df4791acc49df936a795bc;
        float4 _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4;
        SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(_Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4, SHADERGRAPH_OBJECT_POSITION, _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4);
        float4 _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4;
        Unity_Add_float4(_Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4);
        float _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float = Vector1_B4470F9B;
        float _Property_6b508d48a081548385021b27896c0622_Out_0_Float = Vector1_2EC6D670;
        float _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float = Vector1_9365F438;
        float _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float = Vector1_F53C4B89;
        float _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float = Vector1_6803B355;
        float _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float = Vector1_BCB03E1A;
        Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba;
        float3 _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3;
        float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float;
        SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float, _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float, _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D, _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4, _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float, _Property_6b508d48a081548385021b27896c0622_Out_0_Float, _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float, _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float, _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float, _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float);
        float3 _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3;
        Unity_CrossProduct_float(float3 (0, 1, 0), _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3);
        float _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean;
        Unity_Comparison_Equal_float((_CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3).x, 0, _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean);
        float3 _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean, float3(1E-06, 1E-06, 1E-06), _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3, _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3);
        float3 _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3;
        Unity_Normalize_float3(_Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3, _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3);
        float3 _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3);
        float _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float;
        Unity_DotProduct_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3, _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float);
        float3 _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, (_DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float.xxx), _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3);
        float3 _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3;
        Unity_Add_float3(_Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3);
        float3 _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3);
        float _Distance_702b068f612c7289a99272879da274ed_Out_2_Float;
        Unity_Distance_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Distance_702b068f612c7289a99272879da274ed_Out_2_Float);
        float _Property_f5c255b0f666358291012b78132d6593_Out_0_Float = Vector1_DE1BF63A;
        float _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float;
        Unity_Divide_float(_Distance_702b068f612c7289a99272879da274ed_Out_2_Float, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float);
        float _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float;
        Unity_Absolute_float(_Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float, _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float);
        float _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float = 1E-07;
        float _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float;
        Unity_Maximum_float(_Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float, _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float, _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float);
        float _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float;
        Unity_Divide_float(1, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float);
        float _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float;
        Unity_Power_float(_Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float);
        float _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float;
        Unity_Multiply_float_float(_WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float, _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float);
        float _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float;
        Unity_Cosine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float);
        float3 _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, (_Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float.xxx), _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3);
        float3 _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3;
        Unity_CrossProduct_float(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3);
        float _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float;
        Unity_Sine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float);
        float3 _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3;
        Unity_Multiply_float3_float3(_CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3, (_Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float.xxx), _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3);
        float3 _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3;
        Unity_Add_float3(_Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3, _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3);
        float3 _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3;
        Unity_Add_float3(_Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3, _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3);
        float3 _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3;
        _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3 = TransformWorldToObject(_Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3.xyz);
        float3 _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean, _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3, _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3, _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3);
        float3 _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3 = Vector3_DE8CC74D;
        float _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float;
        Unity_Length_float3(_Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float);
        float _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean;
        Unity_Comparison_NotEqual_float(_Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float, 0, _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean);
        float3 _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpaceNormal, _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3);
        float3 _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3, IN.WorldSpaceNormal, _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3);
        vertex_1 = _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        normal_2 = _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, float3(1E-07, 1E-07, 1E-07), _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3);
            float _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float = _Drag;
            float _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float = _HeightDrag;
            float _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float = _Stiffness;
            float _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float = _InitialBend;
            float4 _Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4 = _NewNormal;
            UnityTexture2D _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            UnityTexture2D _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            float4 _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            float _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float = WIND_SETTINGS_FlexNoiseScale;
            float _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float = WIND_SETTINGS_Turbulence;
            float _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float = WIND_SETTINGS_GustSpeed;
            float _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float = WIND_SETTINGS_GustScale;
            float _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            float4x4 _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4 = WIND_SETTINGS_Points;
            float4 _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4 = WIND_SETTINGS_Points_Radius;
            Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.WorldSpaceNormal = IN.WorldSpaceNormal;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.VertexColor = IN.VertexColor;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3;
            SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(IN.TimeParameters.x, _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3, _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float, _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float, 0, _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float, _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float, (_Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4.xyz), _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D, _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D, _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4, _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float, _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float, _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float, _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float, _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float, _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4, _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3);
            description.Position = _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[0];
            float _Split_23e0470490bacd83973312a833450913_G_2_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[1];
            float _Split_23e0470490bacd83973312a833450913_B_3_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[2];
            float _Split_23e0470490bacd83973312a833450913_A_4_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_R_1_Float, _Split_23e0470490bacd83973312a833450913_G_2_Float);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_B_3_Float, _Split_23e0470490bacd83973312a833450913_A_4_Float);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2) );
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.a;
            float4 _Property_0457e5435408618697b5c5387038cff3_Out_0_Vector4 = _DryColor;
            float4 _Property_b618307b57ad3380b3914a2093b7f159_Out_0_Vector4 = _HealthyColor;
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_A_4_Float = 0;
            float2 _Vector2_a6e9136948d4528182e57d0748ed446b_Out_0_Vector2 = float2(_Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1_Float, _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3_Float);
            float _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0_Float = _ColorNoiseSpread;
            float _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float(_Vector2_a6e9136948d4528182e57d0748ed446b_Out_0_Vector2, _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0_Float, _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2_Float);
            float4 _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3_Vector4;
            Unity_Lerp_float4(_Property_0457e5435408618697b5c5387038cff3_Out_0_Vector4, _Property_b618307b57ad3380b3914a2093b7f159_Out_0_Vector4, (_SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2_Float.xxxx), _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3_Vector4);
            float4 _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4, _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3_Vector4, _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2_Vector4);
            UnityTexture2D _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_SnowBaseColorMap);
            float4 _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4 = _SnowTilingOffset;
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_R_1_Float = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4[0];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2_Float = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4[1];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_B_3_Float = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4[2];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4_Float = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4[3];
            float2 _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0_Vector2 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_R_1_Float, _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2_Float);
            float2 _Vector2_f1756f1084099581aefb8f7868e45176_Out_0_Vector2 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_B_3_Float, _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4_Float);
            float2 _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0_Vector2, _Vector2_f1756f1084099581aefb8f7868e45176_Out_0_Vector2, _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3_Vector2);
            float4 _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0_Texture2D.tex, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0_Texture2D.samplerstate, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3_Vector2) );
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_R_4_Float = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4.r;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_G_5_Float = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4.g;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_B_6_Float = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4.b;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_A_7_Float = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4.a;
            float4 _Property_6fad1bea7f828d879b30d1995855944c_Out_0_Vector4 = _SnowBaseColor;
            float4 _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4, _Property_6fad1bea7f828d879b30d1995855944c_Out_0_Vector4, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2_Vector4);
            float _Property_7dfafd311568c28ea4498c71c218169e_Out_0_Float = _Snow_Amount;
            UnityTexture2D _Property_850aded96259f88b9f084f496dd42683_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_850aded96259f88b9f084f496dd42683_Out_0_Texture2D.tex, _Property_850aded96259f88b9f084f496dd42683_Out_0_Texture2D.samplerstate, _Property_850aded96259f88b9f084f496dd42683_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2) );
            _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4);
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_R_4_Float = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.r;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_G_5_Float = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.g;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_B_6_Float = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.b;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_A_7_Float = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.a;
            float _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0_Float = _NormalScale;
            float3 _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2_Vector3;
            Unity_NormalStrength_float((_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.xyz), _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0_Float, _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2_Vector3);
            float _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0_Float = _SnowBlendHardness;
            float3 _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2_Vector3;
            Unity_NormalStrength_float(_NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2_Vector3, _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0_Float, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2_Vector3);
            float3 _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3;
            Unity_NormalBlend_float(IN.WorldSpaceNormal, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2_Vector3, _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3);
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_R_1_Float = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3[0];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2_Float = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3[1];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_B_3_Float = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3[2];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_A_4_Float = 0;
            float _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2_Float;
            Unity_Multiply_float_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0_Float, _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2_Float, _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2_Float);
            float _Clamp_55159c695da3ec84995296ffa5245953_Out_3_Float;
            Unity_Clamp_float(_Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2_Float, 0, 1, _Clamp_55159c695da3ec84995296ffa5245953_Out_3_Float);
            float _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1_Float;
            Unity_Saturate_float(_Clamp_55159c695da3ec84995296ffa5245953_Out_3_Float, _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1_Float);
            float _Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0_Boolean = _InvertSnowMask;
            UnityTexture2D _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_SnowMaskA);
            float4 _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0_Texture2D.tex, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0_Texture2D.samplerstate, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3_Vector2) );
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_R_4_Float = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4.r;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_G_5_Float = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4.g;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_B_6_Float = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4.b;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7_Float = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4.a;
            float _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1_Float;
            Unity_OneMinus_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7_Float, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1_Float);
            float _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3_Float;
            Unity_Branch_float(_Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0_Boolean, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1_Float, _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7_Float, _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3_Float);
            float _Property_53155f8b6e17528993532384c69b45cf_Out_0_Float = _SnowMaskTreshold;
            float _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2_Float;
            Unity_Multiply_float_float(_Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3_Float, _Property_53155f8b6e17528993532384c69b45cf_Out_0_Float, _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2_Float);
            float _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3_Float;
            Unity_Clamp_float(_Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2_Float, 0, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3_Float);
            float _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3_Float;
            Unity_Lerp_float(_Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1_Float, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3_Float, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3_Float);
            float _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1_Float;
            Unity_Absolute_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7_Float, _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1_Float);
            float _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3_Float;
            Unity_Clamp_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0_Float, 0.1, 2, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3_Float);
            float _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2_Float;
            Unity_Divide_float(_Property_53155f8b6e17528993532384c69b45cf_Out_0_Float, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3_Float, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2_Float);
            float _Power_a92be574722606868c966ca3ced4bc87_Out_2_Float;
            Unity_Power_float(_Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1_Float, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2_Float, _Power_a92be574722606868c966ca3ced4bc87_Out_2_Float);
            float _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3_Float;
            Unity_Lerp_float(0, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3_Float, _Power_a92be574722606868c966ca3ced4bc87_Out_2_Float, _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3_Float);
            float4 _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2_Vector4, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2_Vector4, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3_Float.xxxx), _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3_Vector4);
            float _Property_bd0a717ae2b0db8baa627b9a8a9761b4_Out_0_Float = _Specular;
            float4 _Multiply_6c203806d37b7d8caaa5dfc2bdab732b_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2_Vector4, (_Property_bd0a717ae2b0db8baa627b9a8a9761b4_Out_0_Float.xxxx), _Multiply_6c203806d37b7d8caaa5dfc2bdab732b_Out_2_Vector4);
            float _Property_cda2dc52405412819df8bf027152ca03_Out_0_Float = _SnowSpecular;
            float4 _Multiply_5c6f5408a112138082ef2da475dc428b_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2_Vector4, (_Property_cda2dc52405412819df8bf027152ca03_Out_0_Float.xxxx), _Multiply_5c6f5408a112138082ef2da475dc428b_Out_2_Vector4);
            float4 _Lerp_e576a35987d3bb8dbade05cc44570778_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_6c203806d37b7d8caaa5dfc2bdab732b_Out_2_Vector4, _Multiply_5c6f5408a112138082ef2da475dc428b_Out_2_Vector4, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3_Float.xxxx), _Lerp_e576a35987d3bb8dbade05cc44570778_Out_3_Vector4);
            float _Property_1fe791220a37bc80925a480d2b0ad9ba_Out_0_Float = _SmoothnessRemapMax;
            float _Property_befeeb45ab2fa1858b297164b55c2e30_Out_0_Float = _AORemapMax;
            float4 _Combine_d5268fe722e31e8fb563616026809f3c_RGBA_4_Vector4;
            float3 _Combine_d5268fe722e31e8fb563616026809f3c_RGB_5_Vector3;
            float2 _Combine_d5268fe722e31e8fb563616026809f3c_RG_6_Vector2;
            Unity_Combine_float(_Property_1fe791220a37bc80925a480d2b0ad9ba_Out_0_Float, _Property_befeeb45ab2fa1858b297164b55c2e30_Out_0_Float, 0, 0, _Combine_d5268fe722e31e8fb563616026809f3c_RGBA_4_Vector4, _Combine_d5268fe722e31e8fb563616026809f3c_RGB_5_Vector3, _Combine_d5268fe722e31e8fb563616026809f3c_RG_6_Vector2);
            float _Property_5eeb66aeb3f6bc80a354c81de11cc782_Out_0_Float = _SnowSmoothnessRemapMax;
            float _Property_90bbe7b170b6f982afddd3a1a17a7419_Out_0_Float = _SnowAORemapMax;
            float4 _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGBA_4_Vector4;
            float3 _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGB_5_Vector3;
            float2 _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RG_6_Vector2;
            Unity_Combine_float(_Property_5eeb66aeb3f6bc80a354c81de11cc782_Out_0_Float, _Property_90bbe7b170b6f982afddd3a1a17a7419_Out_0_Float, 0, 0, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGBA_4_Vector4, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGB_5_Vector3, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RG_6_Vector2);
            float3 _Lerp_382c19f948614f82b955834c26134f08_Out_3_Vector3;
            Unity_Lerp_float3(_Combine_d5268fe722e31e8fb563616026809f3c_RGB_5_Vector3, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGB_5_Vector3, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3_Float.xxx), _Lerp_382c19f948614f82b955834c26134f08_Out_3_Vector3);
            float _Split_c892f60129203a858bd6cb863f3a99bc_R_1_Float = _Lerp_382c19f948614f82b955834c26134f08_Out_3_Vector3[0];
            float _Split_c892f60129203a858bd6cb863f3a99bc_G_2_Float = _Lerp_382c19f948614f82b955834c26134f08_Out_3_Vector3[1];
            float _Split_c892f60129203a858bd6cb863f3a99bc_B_3_Float = _Lerp_382c19f948614f82b955834c26134f08_Out_3_Vector3[2];
            float _Split_c892f60129203a858bd6cb863f3a99bc_A_4_Float = 0;
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float = _AlphaCutoff;
            surface.BaseColor = (_Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3_Vector4.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Specular = (_Lerp_e576a35987d3bb8dbade05cc44570778_Out_3_Vector4.xyz);
            surface.Smoothness = _Split_c892f60129203a858bd6cb863f3a99bc_R_1_Float;
            surface.Occlusion = _Split_c892f60129203a858bd6cb863f3a99bc_G_2_Float;
            surface.Alpha = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.VertexColor =                                input.color;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        #define _SPECULAR_SETUP 1
        #define USE_UNITY_CROSSFADE 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 VertexColor;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        float _Stiffness;
        float _InitialBend;
        float _Drag;
        float _HeightDrag;
        float4 _NewNormal;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        float4x4 WIND_SETTINGS_Points;
        float4 WIND_SETTINGS_Points_Radius;
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        float WIND_SETTINGS_GustWorldScale;
        float WIND_SETTINGS_GustScale;
        float WIND_SETTINGS_GustSpeed;
        float WIND_SETTINGS_Turbulence;
        float WIND_SETTINGS_ShiverNoiseScale;
        float WIND_SETTINGS_FlexNoiseScale;
        float4 WIND_SETTINGS_WorldDirectionAndSpeed;
        TEXTURE2D(WIND_SETTINGS_TexGust);
        SAMPLER(samplerWIND_SETTINGS_TexGust);
        float4 WIND_SETTINGS_TexGust_TexelSize;
        TEXTURE2D(WIND_SETTINGS_TexNoise);
        SAMPLER(samplerWIND_SETTINGS_TexNoise);
        float4 WIND_SETTINGS_TexNoise_TexelSize;
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Length_float4(float4 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float
        {
        };
        
        void SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(float4x4 Matrix4_cb72bb33b7a84dfda97778a514f9b60f, float3 Vector3_90379ebf40aa468b8362f8d265f4f234, float4 Vector4_159bb4232f82428893101734a03e2a1e, Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float IN, out float4 WindPoint_1)
        {
        float3 _Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3 = Vector3_90379ebf40aa468b8362f8d265f4f234;
        float4x4 _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4 = Matrix4_cb72bb33b7a84dfda97778a514f9b60f;
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].r);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].g);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].b);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].a);
        float3 _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4.xyz), _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3);
        float3 _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3);
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[0];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[1];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[2];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[3];
        float _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float;
        Unity_Length_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float);
        float4 _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4 = Vector4_159bb4232f82428893101734a03e2a1e;
        float _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[0];
        float _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[1];
        float _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[2];
        float _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[3];
        float _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float;
        Unity_Divide_float(_Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float, _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float);
        float _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float;
        Unity_Clamp_float(_Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float, 0, 1, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float);
        float _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float;
        Unity_Lerp_float(_Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float, 0, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float);
        float3 _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3, (_Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float.xxx), _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3);
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[0];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[1];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[2];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_A_4_Float = 0;
        float4 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4;
        float3 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3;
        float2 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2;
        Unity_Combine_float(_Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2);
        float3 _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4.xyz), _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3);
        float3 _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3);
        float _Split_8bbd5052350846968bf312362efd9f01_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[0];
        float _Split_8bbd5052350846968bf312362efd9f01_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[1];
        float _Split_8bbd5052350846968bf312362efd9f01_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[2];
        float _Split_8bbd5052350846968bf312362efd9f01_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[3];
        float _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float;
        Unity_Length_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float);
        float _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float;
        Unity_Divide_float(_Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float, _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float);
        float _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float;
        Unity_Clamp_float(_Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float, 0, 1, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float);
        float _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float;
        Unity_Lerp_float(_Split_8bbd5052350846968bf312362efd9f01_A_4_Float, 0, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float);
        float3 _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3, (_Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float.xxx), _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3);
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[0];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[1];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[2];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_A_4_Float = 0;
        float4 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4;
        float3 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3;
        float2 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2;
        Unity_Combine_float(_Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2);
        float4 _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4;
        Unity_Add_float4(_Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4);
        float3 _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4.xyz), _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3);
        float3 _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3);
        float _Split_fa21a8022f944854903e06c07c6f079c_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[0];
        float _Split_fa21a8022f944854903e06c07c6f079c_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[1];
        float _Split_fa21a8022f944854903e06c07c6f079c_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[2];
        float _Split_fa21a8022f944854903e06c07c6f079c_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[3];
        float _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float;
        Unity_Length_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float);
        float _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float;
        Unity_Divide_float(_Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float, _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float);
        float _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float;
        Unity_Clamp_float(_Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float, 0, 1, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float);
        float _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float;
        Unity_Lerp_float(_Split_fa21a8022f944854903e06c07c6f079c_A_4_Float, 0, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float);
        float3 _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3, (_Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float.xxx), _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3);
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[0];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[1];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[2];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_A_4_Float = 0;
        float4 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4;
        float3 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3;
        float2 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2;
        Unity_Combine_float(_Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2);
        float4 _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4;
        Unity_Add_float4(_Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4);
        float3 _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4.xyz), _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3);
        float3 _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3);
        float _Split_1bfec6763d4b458398e36937b4114c29_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[0];
        float _Split_1bfec6763d4b458398e36937b4114c29_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[1];
        float _Split_1bfec6763d4b458398e36937b4114c29_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[2];
        float _Split_1bfec6763d4b458398e36937b4114c29_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[3];
        float _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float;
        Unity_Length_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float);
        float _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float;
        Unity_Divide_float(_Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float, _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float);
        float _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float;
        Unity_Clamp_float(_Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float, 0, 1, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float);
        float _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float;
        Unity_Lerp_float(_Split_1bfec6763d4b458398e36937b4114c29_A_4_Float, 0, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float);
        float3 _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3, (_Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float.xxx), _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3);
        float _Split_e22879e6c4574322ab21f6261a21bced_R_1_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[0];
        float _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[1];
        float _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[2];
        float _Split_e22879e6c4574322ab21f6261a21bced_A_4_Float = 0;
        float4 _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4;
        float3 _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3;
        float2 _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2;
        Unity_Combine_float(_Split_e22879e6c4574322ab21f6261a21bced_R_1_Float, _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float, _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3, _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2);
        float4 _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        Unity_Add_float4(_Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4);
        WindPoint_1 = _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float
        {
        };
        
        void SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(float3 Vector3_604F121F, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7F78DDD2, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float Vector1_5EFF6B1A, Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float IN, out float3 direction_1, out float strength_2)
        {
        float4 _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[0];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[1];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[2];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_A_4_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[3];
        float4 _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4;
        float3 _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3;
        float2 _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2;
        Unity_Combine_float(_Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float, 0, _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4, _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2);
        float3 _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3;
        Unity_Normalize_float3(_Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3);
        float4 _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_R_1_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[0];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_G_2_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[1];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_B_3_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[2];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[3];
        float3 _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, (_Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float.xxx), _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3);
        float _Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float = Vector1_9365F438;
        float _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float, 0, _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean);
        UnityTexture2D _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D = Texture2D_A3874DB9;
        float3 _Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3 = float3(1, 0, 0);
        float _Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float.xxx), _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3);
        float _Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float = Vector1_5EFF6B1A;
        float3 _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3);
        float3 _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3;
        Unity_Subtract_float3(_Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3, _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3, _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3);
        float _Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float = Vector1_6803B355;
        float3 _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3, (_Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float.xxx), _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3);
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[0];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_G_2_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[1];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[2];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_A_4_Float = 0;
        float4 _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4;
        float3 _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3;
        float2 _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2;
        Unity_Combine_float(_Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float, _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float, 0, 0, _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4, _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3, _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2);
          float4 _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.tex, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.samplerstate, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.GetTransformedUV(_Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_G_6_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_B_7_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_A_8_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.a;
        float _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float;
        Unity_Branch_float(_Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean, _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float, 0, _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float);
        float _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float;
        Unity_Power_float(_Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float, 2, _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float);
        float _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float = Vector1_F53C4B89;
        float _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float;
        Unity_Multiply_float_float(_Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float, _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float, _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float);
        float3 _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float.xxx), _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3);
        float _Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3, (_Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float.xxx), _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3);
        float3 _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3, _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3, _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3);
        float4 _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_e719665c40324e89a536d165d0427a68_R_1_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[0];
        float _Split_e719665c40324e89a536d165d0427a68_G_2_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[1];
        float _Split_e719665c40324e89a536d165d0427a68_B_3_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[2];
        float _Split_e719665c40324e89a536d165d0427a68_A_4_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[3];
        float _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Split_e719665c40324e89a536d165d0427a68_A_4_Float, 0, _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean);
        float _Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float = Vector1_2EC6D670;
        float _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float, 0, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean);
        float _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean;
        Unity_Or_float(_Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean, _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean);
        UnityTexture2D _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D = Texture2D_5BAC276D;
        float3 _Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Split_e719665c40324e89a536d165d0427a68_A_4_Float.xxx), _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3);
        float3 _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3);
        float3 _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3;
        Unity_Subtract_float3(_Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3, _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3, _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3);
        float _Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float = Vector1_B4470F9B;
        float3 _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3, (_Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float.xxx), _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3);
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[0];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_G_2_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[1];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[2];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_A_4_Float = 0;
        float4 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4;
        float3 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3;
        float2 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2;
        Unity_Combine_float(_Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float, _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float, 0, 0, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2);
          float4 _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.tex, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.samplerstate, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.GetTransformedUV(_Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_A_8_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.a;
        float4 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4;
        float3 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3;
        float2 _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2;
        Unity_Combine_float(_SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float, 0, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2);
        float3 _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3;
        Unity_Add_float3(_Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3);
        float3 _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3;
        Unity_Branch_float3(_Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean, _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3, float3(0, 0, 0), _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3);
        float _Property_9946d066804cc584a96830f8d35269cc_Out_0_Float = Vector1_2EC6D670;
        float3 _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3, (_Property_9946d066804cc584a96830f8d35269cc_Out_0_Float.xxx), _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3);
        float3 _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3;
        Unity_Add_float3(_Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3, _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3, _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3);
        float _Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float = Vector1_A2C4B4F4;
        float3 _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3, (_Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float.xxx), _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3);
        float _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float;
        Unity_Length_float3(_Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3, _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float);
        float _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float = Vector1_7F78DDD2;
        float _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float;
        Unity_Add_float(_Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float, _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float, _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float);
        float _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        Unity_Multiply_float_float(_Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float, 0.001, _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float);
        direction_1 = _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        strength_2 = _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Comparison_NotEqual_float(float A, float B, out float Out)
        {
            Out = A != B ? 1 : 0;
        }
        
        struct Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float
        {
        float3 WorldSpaceNormal;
        float4 VertexColor;
        };
        
        void SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(float Vector1_BCB03E1A, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7EE0F94A, float Boolean_527CB26E, float Vector1_DE1BF63A, float Vector1_7F78DDD2, float3 Vector3_DE8CC74D, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float4x4 Matrix4_0617b0bd42fc46ff90b1d55303a5477f, float4 Vector4_b44806ec67ca461fbcdf009dc6092cc3, Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float IN, out float3 vertex_1, out float3 normal_2)
        {
        float4 _Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3;
        _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3 = TransformObjectToWorld((_Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4.xyz).xyz);
        float _Distance_63631313b11e497cab6af82887a71903_Out_2_Float;
        Unity_Distance_float3(_Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3, float3(0, 0, 0), _Distance_63631313b11e497cab6af82887a71903_Out_2_Float);
        float _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_63631313b11e497cab6af82887a71903_Out_2_Float, 0.001, _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean);
        float3 _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3 = Vector3_C30D997B;
        float4 _Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3;
        _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3 = TransformObjectToWorld((_Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4.xyz).xyz);
        float _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float;
        Unity_Distance_float3(_Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, float3(0, 0, 0), _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float);
        float _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float, 1, _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean);
        float3 _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean, float3(5, 5, 5), _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3);
        float3 _Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3;
        _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3 = TransformObjectToWorld(_Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3.xyz);
        float _Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean = Boolean_527CB26E;
        float _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float = Vector1_7EE0F94A;
        float _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, 0, _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean);
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_R_1_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[0];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[1];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_B_3_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[2];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_A_4_Float = 0;
        float _Split_7a634ef857769683b2100876a36535a2_R_1_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[0];
        float _Split_7a634ef857769683b2100876a36535a2_G_2_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[1];
        float _Split_7a634ef857769683b2100876a36535a2_B_3_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[2];
        float _Split_7a634ef857769683b2100876a36535a2_A_4_Float = 0;
        float _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float;
        Unity_Subtract_float(_Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float, _Split_7a634ef857769683b2100876a36535a2_G_2_Float, _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float);
        float _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean;
        Unity_Comparison_Less_float(_Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float, _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean);
        float _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean;
        Unity_And_float(_Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean, _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean);
        float _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float = Vector1_A2C4B4F4;
        float _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float;
        Unity_Branch_float(_And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean, 1E-05, _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float);
        float _Split_43013162a81fc4889a1944f2a2b75f66_R_1_Float = IN.VertexColor[0];
        float _Split_43013162a81fc4889a1944f2a2b75f66_G_2_Float = IN.VertexColor[1];
        float _Split_43013162a81fc4889a1944f2a2b75f66_B_3_Float = IN.VertexColor[2];
        float _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float = IN.VertexColor[3];
        float _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float;
        Unity_Multiply_float_float(_Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float);
        float _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float;
        Unity_Branch_float(_Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float);
        float _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float = Vector1_7F78DDD2;
        UnityTexture2D _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D = Texture2D_5BAC276D;
        UnityTexture2D _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D = Texture2D_A3874DB9;
        float4 _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float;
        Unity_Length_float4(_Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float);
        float _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float, 0, _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean);
        float4 _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4;
        Unity_Branch_float4(_Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean, _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, float4(0, 0, 1, 1), _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4);
        float4x4 _Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4 = Matrix4_0617b0bd42fc46ff90b1d55303a5477f;
        float4 _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4 = Vector4_b44806ec67ca461fbcdf009dc6092cc3;
        Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float _WindNMPoints_a2cb25cd23df4791acc49df936a795bc;
        float4 _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4;
        SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(_Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4, SHADERGRAPH_OBJECT_POSITION, _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4);
        float4 _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4;
        Unity_Add_float4(_Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4);
        float _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float = Vector1_B4470F9B;
        float _Property_6b508d48a081548385021b27896c0622_Out_0_Float = Vector1_2EC6D670;
        float _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float = Vector1_9365F438;
        float _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float = Vector1_F53C4B89;
        float _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float = Vector1_6803B355;
        float _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float = Vector1_BCB03E1A;
        Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba;
        float3 _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3;
        float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float;
        SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float, _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float, _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D, _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4, _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float, _Property_6b508d48a081548385021b27896c0622_Out_0_Float, _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float, _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float, _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float, _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float);
        float3 _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3;
        Unity_CrossProduct_float(float3 (0, 1, 0), _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3);
        float _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean;
        Unity_Comparison_Equal_float((_CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3).x, 0, _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean);
        float3 _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean, float3(1E-06, 1E-06, 1E-06), _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3, _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3);
        float3 _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3;
        Unity_Normalize_float3(_Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3, _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3);
        float3 _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3);
        float _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float;
        Unity_DotProduct_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3, _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float);
        float3 _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, (_DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float.xxx), _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3);
        float3 _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3;
        Unity_Add_float3(_Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3);
        float3 _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3);
        float _Distance_702b068f612c7289a99272879da274ed_Out_2_Float;
        Unity_Distance_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Distance_702b068f612c7289a99272879da274ed_Out_2_Float);
        float _Property_f5c255b0f666358291012b78132d6593_Out_0_Float = Vector1_DE1BF63A;
        float _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float;
        Unity_Divide_float(_Distance_702b068f612c7289a99272879da274ed_Out_2_Float, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float);
        float _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float;
        Unity_Absolute_float(_Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float, _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float);
        float _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float = 1E-07;
        float _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float;
        Unity_Maximum_float(_Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float, _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float, _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float);
        float _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float;
        Unity_Divide_float(1, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float);
        float _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float;
        Unity_Power_float(_Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float);
        float _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float;
        Unity_Multiply_float_float(_WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float, _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float);
        float _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float;
        Unity_Cosine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float);
        float3 _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, (_Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float.xxx), _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3);
        float3 _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3;
        Unity_CrossProduct_float(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3);
        float _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float;
        Unity_Sine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float);
        float3 _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3;
        Unity_Multiply_float3_float3(_CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3, (_Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float.xxx), _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3);
        float3 _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3;
        Unity_Add_float3(_Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3, _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3);
        float3 _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3;
        Unity_Add_float3(_Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3, _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3);
        float3 _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3;
        _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3 = TransformWorldToObject(_Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3.xyz);
        float3 _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean, _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3, _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3, _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3);
        float3 _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3 = Vector3_DE8CC74D;
        float _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float;
        Unity_Length_float3(_Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float);
        float _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean;
        Unity_Comparison_NotEqual_float(_Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float, 0, _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean);
        float3 _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpaceNormal, _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3);
        float3 _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3, IN.WorldSpaceNormal, _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3);
        vertex_1 = _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        normal_2 = _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, float3(1E-07, 1E-07, 1E-07), _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3);
            float _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float = _Drag;
            float _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float = _HeightDrag;
            float _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float = _Stiffness;
            float _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float = _InitialBend;
            float4 _Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4 = _NewNormal;
            UnityTexture2D _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            UnityTexture2D _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            float4 _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            float _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float = WIND_SETTINGS_FlexNoiseScale;
            float _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float = WIND_SETTINGS_Turbulence;
            float _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float = WIND_SETTINGS_GustSpeed;
            float _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float = WIND_SETTINGS_GustScale;
            float _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            float4x4 _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4 = WIND_SETTINGS_Points;
            float4 _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4 = WIND_SETTINGS_Points_Radius;
            Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.WorldSpaceNormal = IN.WorldSpaceNormal;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.VertexColor = IN.VertexColor;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3;
            SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(IN.TimeParameters.x, _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3, _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float, _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float, 0, _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float, _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float, (_Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4.xyz), _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D, _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D, _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4, _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float, _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float, _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float, _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float, _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float, _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4, _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3);
            description.Position = _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[0];
            float _Split_23e0470490bacd83973312a833450913_G_2_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[1];
            float _Split_23e0470490bacd83973312a833450913_B_3_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[2];
            float _Split_23e0470490bacd83973312a833450913_A_4_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_R_1_Float, _Split_23e0470490bacd83973312a833450913_G_2_Float);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_B_3_Float, _Split_23e0470490bacd83973312a833450913_A_4_Float);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2) );
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.a;
            float4 _Property_0457e5435408618697b5c5387038cff3_Out_0_Vector4 = _DryColor;
            float4 _Property_b618307b57ad3380b3914a2093b7f159_Out_0_Vector4 = _HealthyColor;
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_A_4_Float = 0;
            float2 _Vector2_a6e9136948d4528182e57d0748ed446b_Out_0_Vector2 = float2(_Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1_Float, _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3_Float);
            float _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0_Float = _ColorNoiseSpread;
            float _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float(_Vector2_a6e9136948d4528182e57d0748ed446b_Out_0_Vector2, _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0_Float, _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2_Float);
            float4 _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3_Vector4;
            Unity_Lerp_float4(_Property_0457e5435408618697b5c5387038cff3_Out_0_Vector4, _Property_b618307b57ad3380b3914a2093b7f159_Out_0_Vector4, (_SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2_Float.xxxx), _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3_Vector4);
            float4 _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4, _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3_Vector4, _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2_Vector4);
            UnityTexture2D _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_SnowBaseColorMap);
            float4 _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4 = _SnowTilingOffset;
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_R_1_Float = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4[0];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2_Float = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4[1];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_B_3_Float = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4[2];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4_Float = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4[3];
            float2 _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0_Vector2 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_R_1_Float, _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2_Float);
            float2 _Vector2_f1756f1084099581aefb8f7868e45176_Out_0_Vector2 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_B_3_Float, _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4_Float);
            float2 _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0_Vector2, _Vector2_f1756f1084099581aefb8f7868e45176_Out_0_Vector2, _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3_Vector2);
            float4 _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0_Texture2D.tex, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0_Texture2D.samplerstate, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3_Vector2) );
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_R_4_Float = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4.r;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_G_5_Float = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4.g;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_B_6_Float = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4.b;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_A_7_Float = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4.a;
            float4 _Property_6fad1bea7f828d879b30d1995855944c_Out_0_Vector4 = _SnowBaseColor;
            float4 _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4, _Property_6fad1bea7f828d879b30d1995855944c_Out_0_Vector4, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2_Vector4);
            float _Property_7dfafd311568c28ea4498c71c218169e_Out_0_Float = _Snow_Amount;
            UnityTexture2D _Property_850aded96259f88b9f084f496dd42683_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_850aded96259f88b9f084f496dd42683_Out_0_Texture2D.tex, _Property_850aded96259f88b9f084f496dd42683_Out_0_Texture2D.samplerstate, _Property_850aded96259f88b9f084f496dd42683_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2) );
            _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4);
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_R_4_Float = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.r;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_G_5_Float = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.g;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_B_6_Float = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.b;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_A_7_Float = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.a;
            float _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0_Float = _NormalScale;
            float3 _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2_Vector3;
            Unity_NormalStrength_float((_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.xyz), _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0_Float, _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2_Vector3);
            float _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0_Float = _SnowBlendHardness;
            float3 _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2_Vector3;
            Unity_NormalStrength_float(_NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2_Vector3, _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0_Float, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2_Vector3);
            float3 _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3;
            Unity_NormalBlend_float(IN.WorldSpaceNormal, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2_Vector3, _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3);
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_R_1_Float = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3[0];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2_Float = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3[1];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_B_3_Float = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3[2];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_A_4_Float = 0;
            float _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2_Float;
            Unity_Multiply_float_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0_Float, _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2_Float, _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2_Float);
            float _Clamp_55159c695da3ec84995296ffa5245953_Out_3_Float;
            Unity_Clamp_float(_Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2_Float, 0, 1, _Clamp_55159c695da3ec84995296ffa5245953_Out_3_Float);
            float _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1_Float;
            Unity_Saturate_float(_Clamp_55159c695da3ec84995296ffa5245953_Out_3_Float, _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1_Float);
            float _Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0_Boolean = _InvertSnowMask;
            UnityTexture2D _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_SnowMaskA);
            float4 _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0_Texture2D.tex, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0_Texture2D.samplerstate, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3_Vector2) );
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_R_4_Float = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4.r;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_G_5_Float = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4.g;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_B_6_Float = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4.b;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7_Float = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4.a;
            float _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1_Float;
            Unity_OneMinus_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7_Float, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1_Float);
            float _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3_Float;
            Unity_Branch_float(_Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0_Boolean, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1_Float, _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7_Float, _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3_Float);
            float _Property_53155f8b6e17528993532384c69b45cf_Out_0_Float = _SnowMaskTreshold;
            float _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2_Float;
            Unity_Multiply_float_float(_Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3_Float, _Property_53155f8b6e17528993532384c69b45cf_Out_0_Float, _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2_Float);
            float _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3_Float;
            Unity_Clamp_float(_Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2_Float, 0, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3_Float);
            float _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3_Float;
            Unity_Lerp_float(_Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1_Float, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3_Float, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3_Float);
            float _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1_Float;
            Unity_Absolute_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7_Float, _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1_Float);
            float _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3_Float;
            Unity_Clamp_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0_Float, 0.1, 2, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3_Float);
            float _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2_Float;
            Unity_Divide_float(_Property_53155f8b6e17528993532384c69b45cf_Out_0_Float, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3_Float, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2_Float);
            float _Power_a92be574722606868c966ca3ced4bc87_Out_2_Float;
            Unity_Power_float(_Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1_Float, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2_Float, _Power_a92be574722606868c966ca3ced4bc87_Out_2_Float);
            float _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3_Float;
            Unity_Lerp_float(0, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3_Float, _Power_a92be574722606868c966ca3ced4bc87_Out_2_Float, _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3_Float);
            float4 _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2_Vector4, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2_Vector4, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3_Float.xxxx), _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3_Vector4);
            float _Property_bd0a717ae2b0db8baa627b9a8a9761b4_Out_0_Float = _Specular;
            float4 _Multiply_6c203806d37b7d8caaa5dfc2bdab732b_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2_Vector4, (_Property_bd0a717ae2b0db8baa627b9a8a9761b4_Out_0_Float.xxxx), _Multiply_6c203806d37b7d8caaa5dfc2bdab732b_Out_2_Vector4);
            float _Property_cda2dc52405412819df8bf027152ca03_Out_0_Float = _SnowSpecular;
            float4 _Multiply_5c6f5408a112138082ef2da475dc428b_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2_Vector4, (_Property_cda2dc52405412819df8bf027152ca03_Out_0_Float.xxxx), _Multiply_5c6f5408a112138082ef2da475dc428b_Out_2_Vector4);
            float4 _Lerp_e576a35987d3bb8dbade05cc44570778_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_6c203806d37b7d8caaa5dfc2bdab732b_Out_2_Vector4, _Multiply_5c6f5408a112138082ef2da475dc428b_Out_2_Vector4, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3_Float.xxxx), _Lerp_e576a35987d3bb8dbade05cc44570778_Out_3_Vector4);
            float _Property_1fe791220a37bc80925a480d2b0ad9ba_Out_0_Float = _SmoothnessRemapMax;
            float _Property_befeeb45ab2fa1858b297164b55c2e30_Out_0_Float = _AORemapMax;
            float4 _Combine_d5268fe722e31e8fb563616026809f3c_RGBA_4_Vector4;
            float3 _Combine_d5268fe722e31e8fb563616026809f3c_RGB_5_Vector3;
            float2 _Combine_d5268fe722e31e8fb563616026809f3c_RG_6_Vector2;
            Unity_Combine_float(_Property_1fe791220a37bc80925a480d2b0ad9ba_Out_0_Float, _Property_befeeb45ab2fa1858b297164b55c2e30_Out_0_Float, 0, 0, _Combine_d5268fe722e31e8fb563616026809f3c_RGBA_4_Vector4, _Combine_d5268fe722e31e8fb563616026809f3c_RGB_5_Vector3, _Combine_d5268fe722e31e8fb563616026809f3c_RG_6_Vector2);
            float _Property_5eeb66aeb3f6bc80a354c81de11cc782_Out_0_Float = _SnowSmoothnessRemapMax;
            float _Property_90bbe7b170b6f982afddd3a1a17a7419_Out_0_Float = _SnowAORemapMax;
            float4 _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGBA_4_Vector4;
            float3 _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGB_5_Vector3;
            float2 _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RG_6_Vector2;
            Unity_Combine_float(_Property_5eeb66aeb3f6bc80a354c81de11cc782_Out_0_Float, _Property_90bbe7b170b6f982afddd3a1a17a7419_Out_0_Float, 0, 0, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGBA_4_Vector4, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGB_5_Vector3, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RG_6_Vector2);
            float3 _Lerp_382c19f948614f82b955834c26134f08_Out_3_Vector3;
            Unity_Lerp_float3(_Combine_d5268fe722e31e8fb563616026809f3c_RGB_5_Vector3, _Combine_1fdd4fbb12c6ad80b9149224d4a716f7_RGB_5_Vector3, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3_Float.xxx), _Lerp_382c19f948614f82b955834c26134f08_Out_3_Vector3);
            float _Split_c892f60129203a858bd6cb863f3a99bc_R_1_Float = _Lerp_382c19f948614f82b955834c26134f08_Out_3_Vector3[0];
            float _Split_c892f60129203a858bd6cb863f3a99bc_G_2_Float = _Lerp_382c19f948614f82b955834c26134f08_Out_3_Vector3[1];
            float _Split_c892f60129203a858bd6cb863f3a99bc_B_3_Float = _Lerp_382c19f948614f82b955834c26134f08_Out_3_Vector3[2];
            float _Split_c892f60129203a858bd6cb863f3a99bc_A_4_Float = 0;
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float = _AlphaCutoff;
            surface.BaseColor = (_Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3_Vector4.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Specular = (_Lerp_e576a35987d3bb8dbade05cc44570778_Out_3_Vector4.xyz);
            surface.Smoothness = _Split_c892f60129203a858bd6cb863f3a99bc_R_1_Float;
            surface.Occlusion = _Split_c892f60129203a858bd6cb863f3a99bc_G_2_Float;
            surface.Alpha = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.VertexColor =                                input.color;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        #define USE_UNITY_CROSSFADE 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 VertexColor;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        float _Stiffness;
        float _InitialBend;
        float _Drag;
        float _HeightDrag;
        float4 _NewNormal;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        float4x4 WIND_SETTINGS_Points;
        float4 WIND_SETTINGS_Points_Radius;
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        float WIND_SETTINGS_GustWorldScale;
        float WIND_SETTINGS_GustScale;
        float WIND_SETTINGS_GustSpeed;
        float WIND_SETTINGS_Turbulence;
        float WIND_SETTINGS_ShiverNoiseScale;
        float WIND_SETTINGS_FlexNoiseScale;
        float4 WIND_SETTINGS_WorldDirectionAndSpeed;
        TEXTURE2D(WIND_SETTINGS_TexGust);
        SAMPLER(samplerWIND_SETTINGS_TexGust);
        float4 WIND_SETTINGS_TexGust_TexelSize;
        TEXTURE2D(WIND_SETTINGS_TexNoise);
        SAMPLER(samplerWIND_SETTINGS_TexNoise);
        float4 WIND_SETTINGS_TexNoise_TexelSize;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Length_float4(float4 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float
        {
        };
        
        void SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(float4x4 Matrix4_cb72bb33b7a84dfda97778a514f9b60f, float3 Vector3_90379ebf40aa468b8362f8d265f4f234, float4 Vector4_159bb4232f82428893101734a03e2a1e, Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float IN, out float4 WindPoint_1)
        {
        float3 _Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3 = Vector3_90379ebf40aa468b8362f8d265f4f234;
        float4x4 _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4 = Matrix4_cb72bb33b7a84dfda97778a514f9b60f;
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].r);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].g);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].b);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].a);
        float3 _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4.xyz), _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3);
        float3 _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3);
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[0];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[1];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[2];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[3];
        float _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float;
        Unity_Length_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float);
        float4 _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4 = Vector4_159bb4232f82428893101734a03e2a1e;
        float _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[0];
        float _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[1];
        float _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[2];
        float _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[3];
        float _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float;
        Unity_Divide_float(_Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float, _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float);
        float _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float;
        Unity_Clamp_float(_Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float, 0, 1, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float);
        float _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float;
        Unity_Lerp_float(_Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float, 0, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float);
        float3 _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3, (_Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float.xxx), _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3);
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[0];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[1];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[2];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_A_4_Float = 0;
        float4 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4;
        float3 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3;
        float2 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2;
        Unity_Combine_float(_Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2);
        float3 _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4.xyz), _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3);
        float3 _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3);
        float _Split_8bbd5052350846968bf312362efd9f01_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[0];
        float _Split_8bbd5052350846968bf312362efd9f01_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[1];
        float _Split_8bbd5052350846968bf312362efd9f01_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[2];
        float _Split_8bbd5052350846968bf312362efd9f01_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[3];
        float _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float;
        Unity_Length_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float);
        float _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float;
        Unity_Divide_float(_Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float, _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float);
        float _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float;
        Unity_Clamp_float(_Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float, 0, 1, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float);
        float _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float;
        Unity_Lerp_float(_Split_8bbd5052350846968bf312362efd9f01_A_4_Float, 0, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float);
        float3 _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3, (_Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float.xxx), _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3);
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[0];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[1];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[2];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_A_4_Float = 0;
        float4 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4;
        float3 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3;
        float2 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2;
        Unity_Combine_float(_Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2);
        float4 _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4;
        Unity_Add_float4(_Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4);
        float3 _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4.xyz), _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3);
        float3 _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3);
        float _Split_fa21a8022f944854903e06c07c6f079c_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[0];
        float _Split_fa21a8022f944854903e06c07c6f079c_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[1];
        float _Split_fa21a8022f944854903e06c07c6f079c_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[2];
        float _Split_fa21a8022f944854903e06c07c6f079c_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[3];
        float _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float;
        Unity_Length_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float);
        float _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float;
        Unity_Divide_float(_Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float, _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float);
        float _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float;
        Unity_Clamp_float(_Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float, 0, 1, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float);
        float _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float;
        Unity_Lerp_float(_Split_fa21a8022f944854903e06c07c6f079c_A_4_Float, 0, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float);
        float3 _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3, (_Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float.xxx), _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3);
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[0];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[1];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[2];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_A_4_Float = 0;
        float4 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4;
        float3 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3;
        float2 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2;
        Unity_Combine_float(_Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2);
        float4 _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4;
        Unity_Add_float4(_Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4);
        float3 _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4.xyz), _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3);
        float3 _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3);
        float _Split_1bfec6763d4b458398e36937b4114c29_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[0];
        float _Split_1bfec6763d4b458398e36937b4114c29_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[1];
        float _Split_1bfec6763d4b458398e36937b4114c29_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[2];
        float _Split_1bfec6763d4b458398e36937b4114c29_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[3];
        float _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float;
        Unity_Length_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float);
        float _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float;
        Unity_Divide_float(_Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float, _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float);
        float _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float;
        Unity_Clamp_float(_Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float, 0, 1, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float);
        float _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float;
        Unity_Lerp_float(_Split_1bfec6763d4b458398e36937b4114c29_A_4_Float, 0, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float);
        float3 _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3, (_Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float.xxx), _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3);
        float _Split_e22879e6c4574322ab21f6261a21bced_R_1_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[0];
        float _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[1];
        float _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[2];
        float _Split_e22879e6c4574322ab21f6261a21bced_A_4_Float = 0;
        float4 _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4;
        float3 _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3;
        float2 _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2;
        Unity_Combine_float(_Split_e22879e6c4574322ab21f6261a21bced_R_1_Float, _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float, _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3, _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2);
        float4 _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        Unity_Add_float4(_Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4);
        WindPoint_1 = _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float
        {
        };
        
        void SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(float3 Vector3_604F121F, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7F78DDD2, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float Vector1_5EFF6B1A, Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float IN, out float3 direction_1, out float strength_2)
        {
        float4 _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[0];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[1];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[2];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_A_4_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[3];
        float4 _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4;
        float3 _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3;
        float2 _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2;
        Unity_Combine_float(_Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float, 0, _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4, _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2);
        float3 _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3;
        Unity_Normalize_float3(_Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3);
        float4 _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_R_1_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[0];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_G_2_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[1];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_B_3_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[2];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[3];
        float3 _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, (_Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float.xxx), _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3);
        float _Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float = Vector1_9365F438;
        float _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float, 0, _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean);
        UnityTexture2D _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D = Texture2D_A3874DB9;
        float3 _Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3 = float3(1, 0, 0);
        float _Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float.xxx), _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3);
        float _Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float = Vector1_5EFF6B1A;
        float3 _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3);
        float3 _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3;
        Unity_Subtract_float3(_Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3, _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3, _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3);
        float _Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float = Vector1_6803B355;
        float3 _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3, (_Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float.xxx), _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3);
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[0];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_G_2_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[1];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[2];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_A_4_Float = 0;
        float4 _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4;
        float3 _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3;
        float2 _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2;
        Unity_Combine_float(_Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float, _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float, 0, 0, _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4, _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3, _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2);
          float4 _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.tex, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.samplerstate, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.GetTransformedUV(_Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_G_6_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_B_7_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_A_8_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.a;
        float _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float;
        Unity_Branch_float(_Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean, _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float, 0, _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float);
        float _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float;
        Unity_Power_float(_Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float, 2, _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float);
        float _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float = Vector1_F53C4B89;
        float _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float;
        Unity_Multiply_float_float(_Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float, _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float, _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float);
        float3 _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float.xxx), _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3);
        float _Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3, (_Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float.xxx), _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3);
        float3 _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3, _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3, _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3);
        float4 _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_e719665c40324e89a536d165d0427a68_R_1_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[0];
        float _Split_e719665c40324e89a536d165d0427a68_G_2_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[1];
        float _Split_e719665c40324e89a536d165d0427a68_B_3_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[2];
        float _Split_e719665c40324e89a536d165d0427a68_A_4_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[3];
        float _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Split_e719665c40324e89a536d165d0427a68_A_4_Float, 0, _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean);
        float _Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float = Vector1_2EC6D670;
        float _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float, 0, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean);
        float _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean;
        Unity_Or_float(_Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean, _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean);
        UnityTexture2D _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D = Texture2D_5BAC276D;
        float3 _Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Split_e719665c40324e89a536d165d0427a68_A_4_Float.xxx), _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3);
        float3 _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3);
        float3 _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3;
        Unity_Subtract_float3(_Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3, _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3, _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3);
        float _Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float = Vector1_B4470F9B;
        float3 _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3, (_Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float.xxx), _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3);
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[0];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_G_2_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[1];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[2];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_A_4_Float = 0;
        float4 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4;
        float3 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3;
        float2 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2;
        Unity_Combine_float(_Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float, _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float, 0, 0, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2);
          float4 _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.tex, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.samplerstate, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.GetTransformedUV(_Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_A_8_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.a;
        float4 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4;
        float3 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3;
        float2 _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2;
        Unity_Combine_float(_SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float, 0, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2);
        float3 _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3;
        Unity_Add_float3(_Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3);
        float3 _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3;
        Unity_Branch_float3(_Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean, _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3, float3(0, 0, 0), _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3);
        float _Property_9946d066804cc584a96830f8d35269cc_Out_0_Float = Vector1_2EC6D670;
        float3 _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3, (_Property_9946d066804cc584a96830f8d35269cc_Out_0_Float.xxx), _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3);
        float3 _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3;
        Unity_Add_float3(_Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3, _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3, _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3);
        float _Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float = Vector1_A2C4B4F4;
        float3 _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3, (_Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float.xxx), _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3);
        float _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float;
        Unity_Length_float3(_Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3, _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float);
        float _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float = Vector1_7F78DDD2;
        float _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float;
        Unity_Add_float(_Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float, _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float, _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float);
        float _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        Unity_Multiply_float_float(_Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float, 0.001, _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float);
        direction_1 = _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        strength_2 = _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Comparison_NotEqual_float(float A, float B, out float Out)
        {
            Out = A != B ? 1 : 0;
        }
        
        struct Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float
        {
        float3 WorldSpaceNormal;
        float4 VertexColor;
        };
        
        void SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(float Vector1_BCB03E1A, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7EE0F94A, float Boolean_527CB26E, float Vector1_DE1BF63A, float Vector1_7F78DDD2, float3 Vector3_DE8CC74D, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float4x4 Matrix4_0617b0bd42fc46ff90b1d55303a5477f, float4 Vector4_b44806ec67ca461fbcdf009dc6092cc3, Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float IN, out float3 vertex_1, out float3 normal_2)
        {
        float4 _Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3;
        _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3 = TransformObjectToWorld((_Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4.xyz).xyz);
        float _Distance_63631313b11e497cab6af82887a71903_Out_2_Float;
        Unity_Distance_float3(_Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3, float3(0, 0, 0), _Distance_63631313b11e497cab6af82887a71903_Out_2_Float);
        float _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_63631313b11e497cab6af82887a71903_Out_2_Float, 0.001, _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean);
        float3 _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3 = Vector3_C30D997B;
        float4 _Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3;
        _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3 = TransformObjectToWorld((_Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4.xyz).xyz);
        float _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float;
        Unity_Distance_float3(_Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, float3(0, 0, 0), _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float);
        float _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float, 1, _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean);
        float3 _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean, float3(5, 5, 5), _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3);
        float3 _Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3;
        _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3 = TransformObjectToWorld(_Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3.xyz);
        float _Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean = Boolean_527CB26E;
        float _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float = Vector1_7EE0F94A;
        float _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, 0, _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean);
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_R_1_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[0];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[1];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_B_3_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[2];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_A_4_Float = 0;
        float _Split_7a634ef857769683b2100876a36535a2_R_1_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[0];
        float _Split_7a634ef857769683b2100876a36535a2_G_2_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[1];
        float _Split_7a634ef857769683b2100876a36535a2_B_3_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[2];
        float _Split_7a634ef857769683b2100876a36535a2_A_4_Float = 0;
        float _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float;
        Unity_Subtract_float(_Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float, _Split_7a634ef857769683b2100876a36535a2_G_2_Float, _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float);
        float _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean;
        Unity_Comparison_Less_float(_Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float, _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean);
        float _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean;
        Unity_And_float(_Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean, _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean);
        float _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float = Vector1_A2C4B4F4;
        float _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float;
        Unity_Branch_float(_And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean, 1E-05, _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float);
        float _Split_43013162a81fc4889a1944f2a2b75f66_R_1_Float = IN.VertexColor[0];
        float _Split_43013162a81fc4889a1944f2a2b75f66_G_2_Float = IN.VertexColor[1];
        float _Split_43013162a81fc4889a1944f2a2b75f66_B_3_Float = IN.VertexColor[2];
        float _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float = IN.VertexColor[3];
        float _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float;
        Unity_Multiply_float_float(_Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float);
        float _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float;
        Unity_Branch_float(_Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float);
        float _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float = Vector1_7F78DDD2;
        UnityTexture2D _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D = Texture2D_5BAC276D;
        UnityTexture2D _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D = Texture2D_A3874DB9;
        float4 _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float;
        Unity_Length_float4(_Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float);
        float _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float, 0, _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean);
        float4 _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4;
        Unity_Branch_float4(_Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean, _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, float4(0, 0, 1, 1), _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4);
        float4x4 _Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4 = Matrix4_0617b0bd42fc46ff90b1d55303a5477f;
        float4 _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4 = Vector4_b44806ec67ca461fbcdf009dc6092cc3;
        Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float _WindNMPoints_a2cb25cd23df4791acc49df936a795bc;
        float4 _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4;
        SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(_Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4, SHADERGRAPH_OBJECT_POSITION, _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4);
        float4 _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4;
        Unity_Add_float4(_Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4);
        float _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float = Vector1_B4470F9B;
        float _Property_6b508d48a081548385021b27896c0622_Out_0_Float = Vector1_2EC6D670;
        float _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float = Vector1_9365F438;
        float _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float = Vector1_F53C4B89;
        float _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float = Vector1_6803B355;
        float _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float = Vector1_BCB03E1A;
        Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba;
        float3 _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3;
        float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float;
        SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float, _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float, _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D, _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4, _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float, _Property_6b508d48a081548385021b27896c0622_Out_0_Float, _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float, _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float, _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float, _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float);
        float3 _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3;
        Unity_CrossProduct_float(float3 (0, 1, 0), _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3);
        float _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean;
        Unity_Comparison_Equal_float((_CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3).x, 0, _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean);
        float3 _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean, float3(1E-06, 1E-06, 1E-06), _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3, _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3);
        float3 _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3;
        Unity_Normalize_float3(_Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3, _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3);
        float3 _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3);
        float _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float;
        Unity_DotProduct_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3, _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float);
        float3 _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, (_DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float.xxx), _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3);
        float3 _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3;
        Unity_Add_float3(_Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3);
        float3 _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3);
        float _Distance_702b068f612c7289a99272879da274ed_Out_2_Float;
        Unity_Distance_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Distance_702b068f612c7289a99272879da274ed_Out_2_Float);
        float _Property_f5c255b0f666358291012b78132d6593_Out_0_Float = Vector1_DE1BF63A;
        float _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float;
        Unity_Divide_float(_Distance_702b068f612c7289a99272879da274ed_Out_2_Float, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float);
        float _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float;
        Unity_Absolute_float(_Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float, _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float);
        float _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float = 1E-07;
        float _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float;
        Unity_Maximum_float(_Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float, _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float, _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float);
        float _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float;
        Unity_Divide_float(1, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float);
        float _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float;
        Unity_Power_float(_Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float);
        float _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float;
        Unity_Multiply_float_float(_WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float, _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float);
        float _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float;
        Unity_Cosine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float);
        float3 _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, (_Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float.xxx), _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3);
        float3 _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3;
        Unity_CrossProduct_float(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3);
        float _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float;
        Unity_Sine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float);
        float3 _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3;
        Unity_Multiply_float3_float3(_CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3, (_Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float.xxx), _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3);
        float3 _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3;
        Unity_Add_float3(_Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3, _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3);
        float3 _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3;
        Unity_Add_float3(_Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3, _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3);
        float3 _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3;
        _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3 = TransformWorldToObject(_Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3.xyz);
        float3 _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean, _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3, _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3, _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3);
        float3 _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3 = Vector3_DE8CC74D;
        float _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float;
        Unity_Length_float3(_Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float);
        float _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean;
        Unity_Comparison_NotEqual_float(_Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float, 0, _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean);
        float3 _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpaceNormal, _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3);
        float3 _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3, IN.WorldSpaceNormal, _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3);
        vertex_1 = _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        normal_2 = _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, float3(1E-07, 1E-07, 1E-07), _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3);
            float _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float = _Drag;
            float _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float = _HeightDrag;
            float _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float = _Stiffness;
            float _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float = _InitialBend;
            float4 _Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4 = _NewNormal;
            UnityTexture2D _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            UnityTexture2D _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            float4 _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            float _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float = WIND_SETTINGS_FlexNoiseScale;
            float _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float = WIND_SETTINGS_Turbulence;
            float _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float = WIND_SETTINGS_GustSpeed;
            float _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float = WIND_SETTINGS_GustScale;
            float _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            float4x4 _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4 = WIND_SETTINGS_Points;
            float4 _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4 = WIND_SETTINGS_Points_Radius;
            Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.WorldSpaceNormal = IN.WorldSpaceNormal;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.VertexColor = IN.VertexColor;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3;
            SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(IN.TimeParameters.x, _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3, _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float, _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float, 0, _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float, _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float, (_Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4.xyz), _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D, _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D, _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4, _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float, _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float, _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float, _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float, _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float, _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4, _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3);
            description.Position = _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[0];
            float _Split_23e0470490bacd83973312a833450913_G_2_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[1];
            float _Split_23e0470490bacd83973312a833450913_B_3_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[2];
            float _Split_23e0470490bacd83973312a833450913_A_4_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_R_1_Float, _Split_23e0470490bacd83973312a833450913_G_2_Float);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_B_3_Float, _Split_23e0470490bacd83973312a833450913_A_4_Float);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2) );
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.a;
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float = _AlphaCutoff;
            surface.Alpha = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.VertexColor =                                input.color;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "MotionVectors"
            Tags
            {
                "LightMode" = "MotionVectors"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask RG
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.5
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_MOTION_VECTORS
        #define _ALPHATEST_ON 1
        #define USE_UNITY_CROSSFADE 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 ObjectSpacePosition;
             float4 VertexColor;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        float _Stiffness;
        float _InitialBend;
        float _Drag;
        float _HeightDrag;
        float4 _NewNormal;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        float4x4 WIND_SETTINGS_Points;
        float4 WIND_SETTINGS_Points_Radius;
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        float WIND_SETTINGS_GustWorldScale;
        float WIND_SETTINGS_GustScale;
        float WIND_SETTINGS_GustSpeed;
        float WIND_SETTINGS_Turbulence;
        float WIND_SETTINGS_ShiverNoiseScale;
        float WIND_SETTINGS_FlexNoiseScale;
        float4 WIND_SETTINGS_WorldDirectionAndSpeed;
        TEXTURE2D(WIND_SETTINGS_TexGust);
        SAMPLER(samplerWIND_SETTINGS_TexGust);
        float4 WIND_SETTINGS_TexGust_TexelSize;
        TEXTURE2D(WIND_SETTINGS_TexNoise);
        SAMPLER(samplerWIND_SETTINGS_TexNoise);
        float4 WIND_SETTINGS_TexNoise_TexelSize;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Length_float4(float4 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float
        {
        };
        
        void SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(float4x4 Matrix4_cb72bb33b7a84dfda97778a514f9b60f, float3 Vector3_90379ebf40aa468b8362f8d265f4f234, float4 Vector4_159bb4232f82428893101734a03e2a1e, Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float IN, out float4 WindPoint_1)
        {
        float3 _Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3 = Vector3_90379ebf40aa468b8362f8d265f4f234;
        float4x4 _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4 = Matrix4_cb72bb33b7a84dfda97778a514f9b60f;
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].r);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].g);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].b);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].a);
        float3 _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4.xyz), _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3);
        float3 _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3);
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[0];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[1];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[2];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[3];
        float _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float;
        Unity_Length_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float);
        float4 _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4 = Vector4_159bb4232f82428893101734a03e2a1e;
        float _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[0];
        float _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[1];
        float _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[2];
        float _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[3];
        float _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float;
        Unity_Divide_float(_Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float, _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float);
        float _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float;
        Unity_Clamp_float(_Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float, 0, 1, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float);
        float _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float;
        Unity_Lerp_float(_Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float, 0, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float);
        float3 _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3, (_Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float.xxx), _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3);
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[0];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[1];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[2];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_A_4_Float = 0;
        float4 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4;
        float3 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3;
        float2 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2;
        Unity_Combine_float(_Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2);
        float3 _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4.xyz), _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3);
        float3 _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3);
        float _Split_8bbd5052350846968bf312362efd9f01_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[0];
        float _Split_8bbd5052350846968bf312362efd9f01_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[1];
        float _Split_8bbd5052350846968bf312362efd9f01_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[2];
        float _Split_8bbd5052350846968bf312362efd9f01_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[3];
        float _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float;
        Unity_Length_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float);
        float _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float;
        Unity_Divide_float(_Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float, _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float);
        float _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float;
        Unity_Clamp_float(_Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float, 0, 1, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float);
        float _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float;
        Unity_Lerp_float(_Split_8bbd5052350846968bf312362efd9f01_A_4_Float, 0, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float);
        float3 _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3, (_Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float.xxx), _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3);
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[0];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[1];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[2];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_A_4_Float = 0;
        float4 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4;
        float3 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3;
        float2 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2;
        Unity_Combine_float(_Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2);
        float4 _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4;
        Unity_Add_float4(_Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4);
        float3 _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4.xyz), _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3);
        float3 _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3);
        float _Split_fa21a8022f944854903e06c07c6f079c_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[0];
        float _Split_fa21a8022f944854903e06c07c6f079c_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[1];
        float _Split_fa21a8022f944854903e06c07c6f079c_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[2];
        float _Split_fa21a8022f944854903e06c07c6f079c_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[3];
        float _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float;
        Unity_Length_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float);
        float _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float;
        Unity_Divide_float(_Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float, _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float);
        float _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float;
        Unity_Clamp_float(_Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float, 0, 1, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float);
        float _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float;
        Unity_Lerp_float(_Split_fa21a8022f944854903e06c07c6f079c_A_4_Float, 0, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float);
        float3 _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3, (_Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float.xxx), _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3);
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[0];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[1];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[2];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_A_4_Float = 0;
        float4 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4;
        float3 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3;
        float2 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2;
        Unity_Combine_float(_Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2);
        float4 _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4;
        Unity_Add_float4(_Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4);
        float3 _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4.xyz), _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3);
        float3 _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3);
        float _Split_1bfec6763d4b458398e36937b4114c29_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[0];
        float _Split_1bfec6763d4b458398e36937b4114c29_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[1];
        float _Split_1bfec6763d4b458398e36937b4114c29_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[2];
        float _Split_1bfec6763d4b458398e36937b4114c29_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[3];
        float _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float;
        Unity_Length_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float);
        float _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float;
        Unity_Divide_float(_Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float, _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float);
        float _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float;
        Unity_Clamp_float(_Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float, 0, 1, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float);
        float _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float;
        Unity_Lerp_float(_Split_1bfec6763d4b458398e36937b4114c29_A_4_Float, 0, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float);
        float3 _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3, (_Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float.xxx), _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3);
        float _Split_e22879e6c4574322ab21f6261a21bced_R_1_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[0];
        float _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[1];
        float _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[2];
        float _Split_e22879e6c4574322ab21f6261a21bced_A_4_Float = 0;
        float4 _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4;
        float3 _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3;
        float2 _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2;
        Unity_Combine_float(_Split_e22879e6c4574322ab21f6261a21bced_R_1_Float, _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float, _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3, _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2);
        float4 _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        Unity_Add_float4(_Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4);
        WindPoint_1 = _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float
        {
        };
        
        void SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(float3 Vector3_604F121F, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7F78DDD2, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float Vector1_5EFF6B1A, Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float IN, out float3 direction_1, out float strength_2)
        {
        float4 _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[0];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[1];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[2];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_A_4_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[3];
        float4 _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4;
        float3 _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3;
        float2 _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2;
        Unity_Combine_float(_Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float, 0, _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4, _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2);
        float3 _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3;
        Unity_Normalize_float3(_Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3);
        float4 _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_R_1_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[0];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_G_2_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[1];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_B_3_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[2];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[3];
        float3 _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, (_Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float.xxx), _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3);
        float _Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float = Vector1_9365F438;
        float _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float, 0, _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean);
        UnityTexture2D _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D = Texture2D_A3874DB9;
        float3 _Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3 = float3(1, 0, 0);
        float _Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float.xxx), _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3);
        float _Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float = Vector1_5EFF6B1A;
        float3 _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3);
        float3 _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3;
        Unity_Subtract_float3(_Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3, _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3, _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3);
        float _Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float = Vector1_6803B355;
        float3 _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3, (_Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float.xxx), _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3);
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[0];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_G_2_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[1];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[2];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_A_4_Float = 0;
        float4 _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4;
        float3 _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3;
        float2 _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2;
        Unity_Combine_float(_Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float, _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float, 0, 0, _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4, _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3, _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2);
          float4 _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.tex, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.samplerstate, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.GetTransformedUV(_Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_G_6_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_B_7_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_A_8_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.a;
        float _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float;
        Unity_Branch_float(_Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean, _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float, 0, _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float);
        float _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float;
        Unity_Power_float(_Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float, 2, _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float);
        float _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float = Vector1_F53C4B89;
        float _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float;
        Unity_Multiply_float_float(_Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float, _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float, _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float);
        float3 _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float.xxx), _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3);
        float _Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3, (_Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float.xxx), _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3);
        float3 _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3, _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3, _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3);
        float4 _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_e719665c40324e89a536d165d0427a68_R_1_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[0];
        float _Split_e719665c40324e89a536d165d0427a68_G_2_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[1];
        float _Split_e719665c40324e89a536d165d0427a68_B_3_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[2];
        float _Split_e719665c40324e89a536d165d0427a68_A_4_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[3];
        float _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Split_e719665c40324e89a536d165d0427a68_A_4_Float, 0, _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean);
        float _Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float = Vector1_2EC6D670;
        float _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float, 0, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean);
        float _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean;
        Unity_Or_float(_Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean, _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean);
        UnityTexture2D _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D = Texture2D_5BAC276D;
        float3 _Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Split_e719665c40324e89a536d165d0427a68_A_4_Float.xxx), _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3);
        float3 _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3);
        float3 _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3;
        Unity_Subtract_float3(_Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3, _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3, _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3);
        float _Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float = Vector1_B4470F9B;
        float3 _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3, (_Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float.xxx), _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3);
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[0];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_G_2_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[1];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[2];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_A_4_Float = 0;
        float4 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4;
        float3 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3;
        float2 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2;
        Unity_Combine_float(_Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float, _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float, 0, 0, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2);
          float4 _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.tex, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.samplerstate, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.GetTransformedUV(_Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_A_8_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.a;
        float4 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4;
        float3 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3;
        float2 _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2;
        Unity_Combine_float(_SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float, 0, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2);
        float3 _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3;
        Unity_Add_float3(_Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3);
        float3 _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3;
        Unity_Branch_float3(_Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean, _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3, float3(0, 0, 0), _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3);
        float _Property_9946d066804cc584a96830f8d35269cc_Out_0_Float = Vector1_2EC6D670;
        float3 _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3, (_Property_9946d066804cc584a96830f8d35269cc_Out_0_Float.xxx), _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3);
        float3 _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3;
        Unity_Add_float3(_Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3, _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3, _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3);
        float _Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float = Vector1_A2C4B4F4;
        float3 _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3, (_Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float.xxx), _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3);
        float _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float;
        Unity_Length_float3(_Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3, _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float);
        float _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float = Vector1_7F78DDD2;
        float _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float;
        Unity_Add_float(_Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float, _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float, _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float);
        float _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        Unity_Multiply_float_float(_Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float, 0.001, _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float);
        direction_1 = _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        strength_2 = _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Comparison_NotEqual_float(float A, float B, out float Out)
        {
            Out = A != B ? 1 : 0;
        }
        
        struct Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float
        {
        float3 WorldSpaceNormal;
        float4 VertexColor;
        };
        
        void SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(float Vector1_BCB03E1A, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7EE0F94A, float Boolean_527CB26E, float Vector1_DE1BF63A, float Vector1_7F78DDD2, float3 Vector3_DE8CC74D, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float4x4 Matrix4_0617b0bd42fc46ff90b1d55303a5477f, float4 Vector4_b44806ec67ca461fbcdf009dc6092cc3, Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float IN, out float3 vertex_1, out float3 normal_2)
        {
        float4 _Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3;
        _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3 = TransformObjectToWorld((_Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4.xyz).xyz);
        float _Distance_63631313b11e497cab6af82887a71903_Out_2_Float;
        Unity_Distance_float3(_Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3, float3(0, 0, 0), _Distance_63631313b11e497cab6af82887a71903_Out_2_Float);
        float _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_63631313b11e497cab6af82887a71903_Out_2_Float, 0.001, _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean);
        float3 _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3 = Vector3_C30D997B;
        float4 _Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3;
        _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3 = TransformObjectToWorld((_Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4.xyz).xyz);
        float _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float;
        Unity_Distance_float3(_Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, float3(0, 0, 0), _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float);
        float _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float, 1, _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean);
        float3 _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean, float3(5, 5, 5), _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3);
        float3 _Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3;
        _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3 = TransformObjectToWorld(_Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3.xyz);
        float _Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean = Boolean_527CB26E;
        float _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float = Vector1_7EE0F94A;
        float _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, 0, _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean);
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_R_1_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[0];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[1];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_B_3_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[2];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_A_4_Float = 0;
        float _Split_7a634ef857769683b2100876a36535a2_R_1_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[0];
        float _Split_7a634ef857769683b2100876a36535a2_G_2_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[1];
        float _Split_7a634ef857769683b2100876a36535a2_B_3_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[2];
        float _Split_7a634ef857769683b2100876a36535a2_A_4_Float = 0;
        float _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float;
        Unity_Subtract_float(_Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float, _Split_7a634ef857769683b2100876a36535a2_G_2_Float, _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float);
        float _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean;
        Unity_Comparison_Less_float(_Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float, _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean);
        float _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean;
        Unity_And_float(_Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean, _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean);
        float _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float = Vector1_A2C4B4F4;
        float _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float;
        Unity_Branch_float(_And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean, 1E-05, _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float);
        float _Split_43013162a81fc4889a1944f2a2b75f66_R_1_Float = IN.VertexColor[0];
        float _Split_43013162a81fc4889a1944f2a2b75f66_G_2_Float = IN.VertexColor[1];
        float _Split_43013162a81fc4889a1944f2a2b75f66_B_3_Float = IN.VertexColor[2];
        float _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float = IN.VertexColor[3];
        float _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float;
        Unity_Multiply_float_float(_Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float);
        float _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float;
        Unity_Branch_float(_Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float);
        float _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float = Vector1_7F78DDD2;
        UnityTexture2D _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D = Texture2D_5BAC276D;
        UnityTexture2D _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D = Texture2D_A3874DB9;
        float4 _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float;
        Unity_Length_float4(_Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float);
        float _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float, 0, _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean);
        float4 _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4;
        Unity_Branch_float4(_Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean, _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, float4(0, 0, 1, 1), _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4);
        float4x4 _Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4 = Matrix4_0617b0bd42fc46ff90b1d55303a5477f;
        float4 _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4 = Vector4_b44806ec67ca461fbcdf009dc6092cc3;
        Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float _WindNMPoints_a2cb25cd23df4791acc49df936a795bc;
        float4 _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4;
        SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(_Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4, SHADERGRAPH_OBJECT_POSITION, _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4);
        float4 _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4;
        Unity_Add_float4(_Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4);
        float _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float = Vector1_B4470F9B;
        float _Property_6b508d48a081548385021b27896c0622_Out_0_Float = Vector1_2EC6D670;
        float _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float = Vector1_9365F438;
        float _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float = Vector1_F53C4B89;
        float _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float = Vector1_6803B355;
        float _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float = Vector1_BCB03E1A;
        Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba;
        float3 _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3;
        float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float;
        SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float, _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float, _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D, _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4, _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float, _Property_6b508d48a081548385021b27896c0622_Out_0_Float, _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float, _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float, _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float, _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float);
        float3 _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3;
        Unity_CrossProduct_float(float3 (0, 1, 0), _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3);
        float _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean;
        Unity_Comparison_Equal_float((_CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3).x, 0, _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean);
        float3 _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean, float3(1E-06, 1E-06, 1E-06), _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3, _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3);
        float3 _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3;
        Unity_Normalize_float3(_Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3, _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3);
        float3 _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3);
        float _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float;
        Unity_DotProduct_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3, _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float);
        float3 _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, (_DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float.xxx), _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3);
        float3 _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3;
        Unity_Add_float3(_Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3);
        float3 _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3);
        float _Distance_702b068f612c7289a99272879da274ed_Out_2_Float;
        Unity_Distance_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Distance_702b068f612c7289a99272879da274ed_Out_2_Float);
        float _Property_f5c255b0f666358291012b78132d6593_Out_0_Float = Vector1_DE1BF63A;
        float _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float;
        Unity_Divide_float(_Distance_702b068f612c7289a99272879da274ed_Out_2_Float, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float);
        float _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float;
        Unity_Absolute_float(_Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float, _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float);
        float _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float = 1E-07;
        float _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float;
        Unity_Maximum_float(_Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float, _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float, _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float);
        float _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float;
        Unity_Divide_float(1, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float);
        float _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float;
        Unity_Power_float(_Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float);
        float _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float;
        Unity_Multiply_float_float(_WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float, _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float);
        float _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float;
        Unity_Cosine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float);
        float3 _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, (_Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float.xxx), _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3);
        float3 _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3;
        Unity_CrossProduct_float(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3);
        float _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float;
        Unity_Sine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float);
        float3 _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3;
        Unity_Multiply_float3_float3(_CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3, (_Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float.xxx), _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3);
        float3 _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3;
        Unity_Add_float3(_Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3, _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3);
        float3 _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3;
        Unity_Add_float3(_Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3, _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3);
        float3 _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3;
        _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3 = TransformWorldToObject(_Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3.xyz);
        float3 _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean, _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3, _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3, _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3);
        float3 _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3 = Vector3_DE8CC74D;
        float _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float;
        Unity_Length_float3(_Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float);
        float _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean;
        Unity_Comparison_NotEqual_float(_Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float, 0, _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean);
        float3 _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpaceNormal, _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3);
        float3 _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3, IN.WorldSpaceNormal, _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3);
        vertex_1 = _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        normal_2 = _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, float3(1E-07, 1E-07, 1E-07), _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3);
            float _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float = _Drag;
            float _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float = _HeightDrag;
            float _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float = _Stiffness;
            float _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float = _InitialBend;
            float4 _Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4 = _NewNormal;
            UnityTexture2D _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            UnityTexture2D _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            float4 _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            float _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float = WIND_SETTINGS_FlexNoiseScale;
            float _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float = WIND_SETTINGS_Turbulence;
            float _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float = WIND_SETTINGS_GustSpeed;
            float _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float = WIND_SETTINGS_GustScale;
            float _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            float4x4 _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4 = WIND_SETTINGS_Points;
            float4 _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4 = WIND_SETTINGS_Points_Radius;
            Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.WorldSpaceNormal = IN.WorldSpaceNormal;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.VertexColor = IN.VertexColor;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3;
            SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(IN.TimeParameters.x, _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3, _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float, _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float, 0, _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float, _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float, (_Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4.xyz), _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D, _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D, _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4, _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float, _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float, _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float, _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float, _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float, _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4, _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3);
            description.Position = _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[0];
            float _Split_23e0470490bacd83973312a833450913_G_2_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[1];
            float _Split_23e0470490bacd83973312a833450913_B_3_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[2];
            float _Split_23e0470490bacd83973312a833450913_A_4_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_R_1_Float, _Split_23e0470490bacd83973312a833450913_G_2_Float);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_B_3_Float, _Split_23e0470490bacd83973312a833450913_A_4_Float);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2) );
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.a;
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float = _AlphaCutoff;
            surface.Alpha = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpacePosition =                        input.positionOS;
            output.VertexColor =                                input.color;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/MotionVectorPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask R
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define _ALPHATEST_ON 1
        #define USE_UNITY_CROSSFADE 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 VertexColor;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        float _Stiffness;
        float _InitialBend;
        float _Drag;
        float _HeightDrag;
        float4 _NewNormal;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        float4x4 WIND_SETTINGS_Points;
        float4 WIND_SETTINGS_Points_Radius;
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        float WIND_SETTINGS_GustWorldScale;
        float WIND_SETTINGS_GustScale;
        float WIND_SETTINGS_GustSpeed;
        float WIND_SETTINGS_Turbulence;
        float WIND_SETTINGS_ShiverNoiseScale;
        float WIND_SETTINGS_FlexNoiseScale;
        float4 WIND_SETTINGS_WorldDirectionAndSpeed;
        TEXTURE2D(WIND_SETTINGS_TexGust);
        SAMPLER(samplerWIND_SETTINGS_TexGust);
        float4 WIND_SETTINGS_TexGust_TexelSize;
        TEXTURE2D(WIND_SETTINGS_TexNoise);
        SAMPLER(samplerWIND_SETTINGS_TexNoise);
        float4 WIND_SETTINGS_TexNoise_TexelSize;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Length_float4(float4 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float
        {
        };
        
        void SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(float4x4 Matrix4_cb72bb33b7a84dfda97778a514f9b60f, float3 Vector3_90379ebf40aa468b8362f8d265f4f234, float4 Vector4_159bb4232f82428893101734a03e2a1e, Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float IN, out float4 WindPoint_1)
        {
        float3 _Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3 = Vector3_90379ebf40aa468b8362f8d265f4f234;
        float4x4 _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4 = Matrix4_cb72bb33b7a84dfda97778a514f9b60f;
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].r);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].g);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].b);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].a);
        float3 _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4.xyz), _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3);
        float3 _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3);
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[0];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[1];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[2];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[3];
        float _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float;
        Unity_Length_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float);
        float4 _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4 = Vector4_159bb4232f82428893101734a03e2a1e;
        float _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[0];
        float _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[1];
        float _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[2];
        float _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[3];
        float _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float;
        Unity_Divide_float(_Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float, _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float);
        float _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float;
        Unity_Clamp_float(_Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float, 0, 1, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float);
        float _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float;
        Unity_Lerp_float(_Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float, 0, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float);
        float3 _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3, (_Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float.xxx), _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3);
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[0];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[1];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[2];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_A_4_Float = 0;
        float4 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4;
        float3 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3;
        float2 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2;
        Unity_Combine_float(_Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2);
        float3 _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4.xyz), _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3);
        float3 _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3);
        float _Split_8bbd5052350846968bf312362efd9f01_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[0];
        float _Split_8bbd5052350846968bf312362efd9f01_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[1];
        float _Split_8bbd5052350846968bf312362efd9f01_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[2];
        float _Split_8bbd5052350846968bf312362efd9f01_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[3];
        float _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float;
        Unity_Length_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float);
        float _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float;
        Unity_Divide_float(_Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float, _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float);
        float _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float;
        Unity_Clamp_float(_Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float, 0, 1, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float);
        float _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float;
        Unity_Lerp_float(_Split_8bbd5052350846968bf312362efd9f01_A_4_Float, 0, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float);
        float3 _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3, (_Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float.xxx), _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3);
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[0];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[1];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[2];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_A_4_Float = 0;
        float4 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4;
        float3 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3;
        float2 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2;
        Unity_Combine_float(_Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2);
        float4 _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4;
        Unity_Add_float4(_Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4);
        float3 _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4.xyz), _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3);
        float3 _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3);
        float _Split_fa21a8022f944854903e06c07c6f079c_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[0];
        float _Split_fa21a8022f944854903e06c07c6f079c_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[1];
        float _Split_fa21a8022f944854903e06c07c6f079c_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[2];
        float _Split_fa21a8022f944854903e06c07c6f079c_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[3];
        float _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float;
        Unity_Length_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float);
        float _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float;
        Unity_Divide_float(_Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float, _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float);
        float _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float;
        Unity_Clamp_float(_Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float, 0, 1, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float);
        float _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float;
        Unity_Lerp_float(_Split_fa21a8022f944854903e06c07c6f079c_A_4_Float, 0, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float);
        float3 _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3, (_Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float.xxx), _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3);
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[0];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[1];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[2];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_A_4_Float = 0;
        float4 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4;
        float3 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3;
        float2 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2;
        Unity_Combine_float(_Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2);
        float4 _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4;
        Unity_Add_float4(_Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4);
        float3 _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4.xyz), _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3);
        float3 _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3);
        float _Split_1bfec6763d4b458398e36937b4114c29_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[0];
        float _Split_1bfec6763d4b458398e36937b4114c29_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[1];
        float _Split_1bfec6763d4b458398e36937b4114c29_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[2];
        float _Split_1bfec6763d4b458398e36937b4114c29_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[3];
        float _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float;
        Unity_Length_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float);
        float _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float;
        Unity_Divide_float(_Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float, _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float);
        float _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float;
        Unity_Clamp_float(_Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float, 0, 1, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float);
        float _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float;
        Unity_Lerp_float(_Split_1bfec6763d4b458398e36937b4114c29_A_4_Float, 0, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float);
        float3 _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3, (_Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float.xxx), _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3);
        float _Split_e22879e6c4574322ab21f6261a21bced_R_1_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[0];
        float _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[1];
        float _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[2];
        float _Split_e22879e6c4574322ab21f6261a21bced_A_4_Float = 0;
        float4 _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4;
        float3 _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3;
        float2 _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2;
        Unity_Combine_float(_Split_e22879e6c4574322ab21f6261a21bced_R_1_Float, _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float, _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3, _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2);
        float4 _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        Unity_Add_float4(_Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4);
        WindPoint_1 = _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float
        {
        };
        
        void SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(float3 Vector3_604F121F, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7F78DDD2, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float Vector1_5EFF6B1A, Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float IN, out float3 direction_1, out float strength_2)
        {
        float4 _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[0];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[1];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[2];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_A_4_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[3];
        float4 _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4;
        float3 _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3;
        float2 _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2;
        Unity_Combine_float(_Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float, 0, _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4, _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2);
        float3 _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3;
        Unity_Normalize_float3(_Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3);
        float4 _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_R_1_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[0];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_G_2_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[1];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_B_3_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[2];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[3];
        float3 _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, (_Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float.xxx), _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3);
        float _Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float = Vector1_9365F438;
        float _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float, 0, _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean);
        UnityTexture2D _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D = Texture2D_A3874DB9;
        float3 _Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3 = float3(1, 0, 0);
        float _Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float.xxx), _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3);
        float _Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float = Vector1_5EFF6B1A;
        float3 _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3);
        float3 _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3;
        Unity_Subtract_float3(_Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3, _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3, _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3);
        float _Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float = Vector1_6803B355;
        float3 _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3, (_Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float.xxx), _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3);
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[0];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_G_2_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[1];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[2];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_A_4_Float = 0;
        float4 _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4;
        float3 _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3;
        float2 _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2;
        Unity_Combine_float(_Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float, _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float, 0, 0, _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4, _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3, _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2);
          float4 _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.tex, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.samplerstate, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.GetTransformedUV(_Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_G_6_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_B_7_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_A_8_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.a;
        float _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float;
        Unity_Branch_float(_Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean, _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float, 0, _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float);
        float _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float;
        Unity_Power_float(_Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float, 2, _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float);
        float _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float = Vector1_F53C4B89;
        float _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float;
        Unity_Multiply_float_float(_Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float, _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float, _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float);
        float3 _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float.xxx), _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3);
        float _Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3, (_Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float.xxx), _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3);
        float3 _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3, _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3, _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3);
        float4 _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_e719665c40324e89a536d165d0427a68_R_1_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[0];
        float _Split_e719665c40324e89a536d165d0427a68_G_2_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[1];
        float _Split_e719665c40324e89a536d165d0427a68_B_3_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[2];
        float _Split_e719665c40324e89a536d165d0427a68_A_4_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[3];
        float _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Split_e719665c40324e89a536d165d0427a68_A_4_Float, 0, _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean);
        float _Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float = Vector1_2EC6D670;
        float _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float, 0, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean);
        float _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean;
        Unity_Or_float(_Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean, _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean);
        UnityTexture2D _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D = Texture2D_5BAC276D;
        float3 _Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Split_e719665c40324e89a536d165d0427a68_A_4_Float.xxx), _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3);
        float3 _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3);
        float3 _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3;
        Unity_Subtract_float3(_Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3, _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3, _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3);
        float _Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float = Vector1_B4470F9B;
        float3 _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3, (_Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float.xxx), _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3);
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[0];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_G_2_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[1];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[2];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_A_4_Float = 0;
        float4 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4;
        float3 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3;
        float2 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2;
        Unity_Combine_float(_Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float, _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float, 0, 0, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2);
          float4 _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.tex, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.samplerstate, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.GetTransformedUV(_Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_A_8_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.a;
        float4 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4;
        float3 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3;
        float2 _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2;
        Unity_Combine_float(_SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float, 0, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2);
        float3 _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3;
        Unity_Add_float3(_Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3);
        float3 _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3;
        Unity_Branch_float3(_Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean, _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3, float3(0, 0, 0), _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3);
        float _Property_9946d066804cc584a96830f8d35269cc_Out_0_Float = Vector1_2EC6D670;
        float3 _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3, (_Property_9946d066804cc584a96830f8d35269cc_Out_0_Float.xxx), _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3);
        float3 _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3;
        Unity_Add_float3(_Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3, _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3, _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3);
        float _Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float = Vector1_A2C4B4F4;
        float3 _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3, (_Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float.xxx), _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3);
        float _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float;
        Unity_Length_float3(_Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3, _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float);
        float _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float = Vector1_7F78DDD2;
        float _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float;
        Unity_Add_float(_Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float, _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float, _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float);
        float _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        Unity_Multiply_float_float(_Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float, 0.001, _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float);
        direction_1 = _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        strength_2 = _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Comparison_NotEqual_float(float A, float B, out float Out)
        {
            Out = A != B ? 1 : 0;
        }
        
        struct Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float
        {
        float3 WorldSpaceNormal;
        float4 VertexColor;
        };
        
        void SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(float Vector1_BCB03E1A, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7EE0F94A, float Boolean_527CB26E, float Vector1_DE1BF63A, float Vector1_7F78DDD2, float3 Vector3_DE8CC74D, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float4x4 Matrix4_0617b0bd42fc46ff90b1d55303a5477f, float4 Vector4_b44806ec67ca461fbcdf009dc6092cc3, Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float IN, out float3 vertex_1, out float3 normal_2)
        {
        float4 _Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3;
        _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3 = TransformObjectToWorld((_Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4.xyz).xyz);
        float _Distance_63631313b11e497cab6af82887a71903_Out_2_Float;
        Unity_Distance_float3(_Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3, float3(0, 0, 0), _Distance_63631313b11e497cab6af82887a71903_Out_2_Float);
        float _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_63631313b11e497cab6af82887a71903_Out_2_Float, 0.001, _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean);
        float3 _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3 = Vector3_C30D997B;
        float4 _Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3;
        _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3 = TransformObjectToWorld((_Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4.xyz).xyz);
        float _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float;
        Unity_Distance_float3(_Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, float3(0, 0, 0), _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float);
        float _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float, 1, _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean);
        float3 _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean, float3(5, 5, 5), _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3);
        float3 _Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3;
        _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3 = TransformObjectToWorld(_Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3.xyz);
        float _Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean = Boolean_527CB26E;
        float _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float = Vector1_7EE0F94A;
        float _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, 0, _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean);
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_R_1_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[0];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[1];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_B_3_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[2];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_A_4_Float = 0;
        float _Split_7a634ef857769683b2100876a36535a2_R_1_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[0];
        float _Split_7a634ef857769683b2100876a36535a2_G_2_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[1];
        float _Split_7a634ef857769683b2100876a36535a2_B_3_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[2];
        float _Split_7a634ef857769683b2100876a36535a2_A_4_Float = 0;
        float _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float;
        Unity_Subtract_float(_Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float, _Split_7a634ef857769683b2100876a36535a2_G_2_Float, _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float);
        float _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean;
        Unity_Comparison_Less_float(_Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float, _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean);
        float _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean;
        Unity_And_float(_Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean, _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean);
        float _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float = Vector1_A2C4B4F4;
        float _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float;
        Unity_Branch_float(_And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean, 1E-05, _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float);
        float _Split_43013162a81fc4889a1944f2a2b75f66_R_1_Float = IN.VertexColor[0];
        float _Split_43013162a81fc4889a1944f2a2b75f66_G_2_Float = IN.VertexColor[1];
        float _Split_43013162a81fc4889a1944f2a2b75f66_B_3_Float = IN.VertexColor[2];
        float _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float = IN.VertexColor[3];
        float _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float;
        Unity_Multiply_float_float(_Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float);
        float _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float;
        Unity_Branch_float(_Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float);
        float _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float = Vector1_7F78DDD2;
        UnityTexture2D _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D = Texture2D_5BAC276D;
        UnityTexture2D _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D = Texture2D_A3874DB9;
        float4 _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float;
        Unity_Length_float4(_Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float);
        float _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float, 0, _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean);
        float4 _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4;
        Unity_Branch_float4(_Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean, _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, float4(0, 0, 1, 1), _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4);
        float4x4 _Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4 = Matrix4_0617b0bd42fc46ff90b1d55303a5477f;
        float4 _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4 = Vector4_b44806ec67ca461fbcdf009dc6092cc3;
        Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float _WindNMPoints_a2cb25cd23df4791acc49df936a795bc;
        float4 _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4;
        SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(_Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4, SHADERGRAPH_OBJECT_POSITION, _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4);
        float4 _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4;
        Unity_Add_float4(_Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4);
        float _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float = Vector1_B4470F9B;
        float _Property_6b508d48a081548385021b27896c0622_Out_0_Float = Vector1_2EC6D670;
        float _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float = Vector1_9365F438;
        float _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float = Vector1_F53C4B89;
        float _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float = Vector1_6803B355;
        float _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float = Vector1_BCB03E1A;
        Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba;
        float3 _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3;
        float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float;
        SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float, _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float, _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D, _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4, _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float, _Property_6b508d48a081548385021b27896c0622_Out_0_Float, _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float, _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float, _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float, _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float);
        float3 _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3;
        Unity_CrossProduct_float(float3 (0, 1, 0), _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3);
        float _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean;
        Unity_Comparison_Equal_float((_CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3).x, 0, _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean);
        float3 _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean, float3(1E-06, 1E-06, 1E-06), _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3, _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3);
        float3 _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3;
        Unity_Normalize_float3(_Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3, _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3);
        float3 _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3);
        float _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float;
        Unity_DotProduct_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3, _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float);
        float3 _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, (_DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float.xxx), _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3);
        float3 _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3;
        Unity_Add_float3(_Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3);
        float3 _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3);
        float _Distance_702b068f612c7289a99272879da274ed_Out_2_Float;
        Unity_Distance_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Distance_702b068f612c7289a99272879da274ed_Out_2_Float);
        float _Property_f5c255b0f666358291012b78132d6593_Out_0_Float = Vector1_DE1BF63A;
        float _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float;
        Unity_Divide_float(_Distance_702b068f612c7289a99272879da274ed_Out_2_Float, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float);
        float _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float;
        Unity_Absolute_float(_Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float, _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float);
        float _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float = 1E-07;
        float _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float;
        Unity_Maximum_float(_Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float, _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float, _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float);
        float _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float;
        Unity_Divide_float(1, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float);
        float _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float;
        Unity_Power_float(_Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float);
        float _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float;
        Unity_Multiply_float_float(_WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float, _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float);
        float _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float;
        Unity_Cosine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float);
        float3 _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, (_Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float.xxx), _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3);
        float3 _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3;
        Unity_CrossProduct_float(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3);
        float _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float;
        Unity_Sine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float);
        float3 _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3;
        Unity_Multiply_float3_float3(_CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3, (_Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float.xxx), _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3);
        float3 _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3;
        Unity_Add_float3(_Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3, _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3);
        float3 _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3;
        Unity_Add_float3(_Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3, _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3);
        float3 _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3;
        _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3 = TransformWorldToObject(_Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3.xyz);
        float3 _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean, _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3, _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3, _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3);
        float3 _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3 = Vector3_DE8CC74D;
        float _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float;
        Unity_Length_float3(_Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float);
        float _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean;
        Unity_Comparison_NotEqual_float(_Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float, 0, _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean);
        float3 _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpaceNormal, _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3);
        float3 _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3, IN.WorldSpaceNormal, _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3);
        vertex_1 = _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        normal_2 = _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, float3(1E-07, 1E-07, 1E-07), _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3);
            float _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float = _Drag;
            float _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float = _HeightDrag;
            float _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float = _Stiffness;
            float _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float = _InitialBend;
            float4 _Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4 = _NewNormal;
            UnityTexture2D _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            UnityTexture2D _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            float4 _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            float _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float = WIND_SETTINGS_FlexNoiseScale;
            float _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float = WIND_SETTINGS_Turbulence;
            float _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float = WIND_SETTINGS_GustSpeed;
            float _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float = WIND_SETTINGS_GustScale;
            float _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            float4x4 _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4 = WIND_SETTINGS_Points;
            float4 _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4 = WIND_SETTINGS_Points_Radius;
            Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.WorldSpaceNormal = IN.WorldSpaceNormal;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.VertexColor = IN.VertexColor;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3;
            SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(IN.TimeParameters.x, _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3, _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float, _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float, 0, _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float, _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float, (_Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4.xyz), _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D, _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D, _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4, _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float, _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float, _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float, _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float, _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float, _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4, _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3);
            description.Position = _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[0];
            float _Split_23e0470490bacd83973312a833450913_G_2_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[1];
            float _Split_23e0470490bacd83973312a833450913_B_3_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[2];
            float _Split_23e0470490bacd83973312a833450913_A_4_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_R_1_Float, _Split_23e0470490bacd83973312a833450913_G_2_Float);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_B_3_Float, _Split_23e0470490bacd83973312a833450913_A_4_Float);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2) );
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.a;
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float = _AlphaCutoff;
            surface.Alpha = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.VertexColor =                                input.color;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_COLOR
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        #define USE_UNITY_CROSSFADE 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 VertexColor;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float3 normalWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        float _Stiffness;
        float _InitialBend;
        float _Drag;
        float _HeightDrag;
        float4 _NewNormal;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        float4x4 WIND_SETTINGS_Points;
        float4 WIND_SETTINGS_Points_Radius;
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        float WIND_SETTINGS_GustWorldScale;
        float WIND_SETTINGS_GustScale;
        float WIND_SETTINGS_GustSpeed;
        float WIND_SETTINGS_Turbulence;
        float WIND_SETTINGS_ShiverNoiseScale;
        float WIND_SETTINGS_FlexNoiseScale;
        float4 WIND_SETTINGS_WorldDirectionAndSpeed;
        TEXTURE2D(WIND_SETTINGS_TexGust);
        SAMPLER(samplerWIND_SETTINGS_TexGust);
        float4 WIND_SETTINGS_TexGust_TexelSize;
        TEXTURE2D(WIND_SETTINGS_TexNoise);
        SAMPLER(samplerWIND_SETTINGS_TexNoise);
        float4 WIND_SETTINGS_TexNoise_TexelSize;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Length_float4(float4 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float
        {
        };
        
        void SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(float4x4 Matrix4_cb72bb33b7a84dfda97778a514f9b60f, float3 Vector3_90379ebf40aa468b8362f8d265f4f234, float4 Vector4_159bb4232f82428893101734a03e2a1e, Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float IN, out float4 WindPoint_1)
        {
        float3 _Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3 = Vector3_90379ebf40aa468b8362f8d265f4f234;
        float4x4 _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4 = Matrix4_cb72bb33b7a84dfda97778a514f9b60f;
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].r);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].g);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].b);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].a);
        float3 _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4.xyz), _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3);
        float3 _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3);
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[0];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[1];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[2];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[3];
        float _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float;
        Unity_Length_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float);
        float4 _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4 = Vector4_159bb4232f82428893101734a03e2a1e;
        float _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[0];
        float _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[1];
        float _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[2];
        float _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[3];
        float _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float;
        Unity_Divide_float(_Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float, _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float);
        float _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float;
        Unity_Clamp_float(_Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float, 0, 1, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float);
        float _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float;
        Unity_Lerp_float(_Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float, 0, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float);
        float3 _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3, (_Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float.xxx), _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3);
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[0];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[1];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[2];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_A_4_Float = 0;
        float4 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4;
        float3 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3;
        float2 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2;
        Unity_Combine_float(_Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2);
        float3 _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4.xyz), _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3);
        float3 _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3);
        float _Split_8bbd5052350846968bf312362efd9f01_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[0];
        float _Split_8bbd5052350846968bf312362efd9f01_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[1];
        float _Split_8bbd5052350846968bf312362efd9f01_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[2];
        float _Split_8bbd5052350846968bf312362efd9f01_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[3];
        float _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float;
        Unity_Length_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float);
        float _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float;
        Unity_Divide_float(_Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float, _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float);
        float _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float;
        Unity_Clamp_float(_Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float, 0, 1, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float);
        float _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float;
        Unity_Lerp_float(_Split_8bbd5052350846968bf312362efd9f01_A_4_Float, 0, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float);
        float3 _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3, (_Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float.xxx), _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3);
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[0];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[1];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[2];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_A_4_Float = 0;
        float4 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4;
        float3 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3;
        float2 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2;
        Unity_Combine_float(_Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2);
        float4 _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4;
        Unity_Add_float4(_Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4);
        float3 _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4.xyz), _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3);
        float3 _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3);
        float _Split_fa21a8022f944854903e06c07c6f079c_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[0];
        float _Split_fa21a8022f944854903e06c07c6f079c_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[1];
        float _Split_fa21a8022f944854903e06c07c6f079c_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[2];
        float _Split_fa21a8022f944854903e06c07c6f079c_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[3];
        float _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float;
        Unity_Length_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float);
        float _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float;
        Unity_Divide_float(_Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float, _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float);
        float _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float;
        Unity_Clamp_float(_Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float, 0, 1, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float);
        float _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float;
        Unity_Lerp_float(_Split_fa21a8022f944854903e06c07c6f079c_A_4_Float, 0, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float);
        float3 _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3, (_Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float.xxx), _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3);
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[0];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[1];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[2];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_A_4_Float = 0;
        float4 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4;
        float3 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3;
        float2 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2;
        Unity_Combine_float(_Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2);
        float4 _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4;
        Unity_Add_float4(_Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4);
        float3 _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4.xyz), _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3);
        float3 _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3);
        float _Split_1bfec6763d4b458398e36937b4114c29_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[0];
        float _Split_1bfec6763d4b458398e36937b4114c29_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[1];
        float _Split_1bfec6763d4b458398e36937b4114c29_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[2];
        float _Split_1bfec6763d4b458398e36937b4114c29_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[3];
        float _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float;
        Unity_Length_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float);
        float _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float;
        Unity_Divide_float(_Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float, _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float);
        float _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float;
        Unity_Clamp_float(_Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float, 0, 1, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float);
        float _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float;
        Unity_Lerp_float(_Split_1bfec6763d4b458398e36937b4114c29_A_4_Float, 0, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float);
        float3 _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3, (_Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float.xxx), _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3);
        float _Split_e22879e6c4574322ab21f6261a21bced_R_1_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[0];
        float _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[1];
        float _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[2];
        float _Split_e22879e6c4574322ab21f6261a21bced_A_4_Float = 0;
        float4 _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4;
        float3 _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3;
        float2 _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2;
        Unity_Combine_float(_Split_e22879e6c4574322ab21f6261a21bced_R_1_Float, _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float, _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3, _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2);
        float4 _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        Unity_Add_float4(_Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4);
        WindPoint_1 = _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float
        {
        };
        
        void SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(float3 Vector3_604F121F, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7F78DDD2, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float Vector1_5EFF6B1A, Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float IN, out float3 direction_1, out float strength_2)
        {
        float4 _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[0];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[1];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[2];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_A_4_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[3];
        float4 _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4;
        float3 _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3;
        float2 _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2;
        Unity_Combine_float(_Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float, 0, _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4, _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2);
        float3 _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3;
        Unity_Normalize_float3(_Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3);
        float4 _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_R_1_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[0];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_G_2_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[1];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_B_3_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[2];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[3];
        float3 _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, (_Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float.xxx), _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3);
        float _Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float = Vector1_9365F438;
        float _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float, 0, _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean);
        UnityTexture2D _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D = Texture2D_A3874DB9;
        float3 _Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3 = float3(1, 0, 0);
        float _Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float.xxx), _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3);
        float _Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float = Vector1_5EFF6B1A;
        float3 _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3);
        float3 _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3;
        Unity_Subtract_float3(_Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3, _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3, _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3);
        float _Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float = Vector1_6803B355;
        float3 _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3, (_Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float.xxx), _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3);
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[0];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_G_2_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[1];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[2];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_A_4_Float = 0;
        float4 _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4;
        float3 _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3;
        float2 _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2;
        Unity_Combine_float(_Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float, _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float, 0, 0, _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4, _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3, _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2);
          float4 _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.tex, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.samplerstate, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.GetTransformedUV(_Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_G_6_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_B_7_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_A_8_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.a;
        float _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float;
        Unity_Branch_float(_Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean, _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float, 0, _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float);
        float _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float;
        Unity_Power_float(_Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float, 2, _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float);
        float _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float = Vector1_F53C4B89;
        float _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float;
        Unity_Multiply_float_float(_Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float, _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float, _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float);
        float3 _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float.xxx), _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3);
        float _Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3, (_Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float.xxx), _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3);
        float3 _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3, _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3, _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3);
        float4 _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_e719665c40324e89a536d165d0427a68_R_1_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[0];
        float _Split_e719665c40324e89a536d165d0427a68_G_2_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[1];
        float _Split_e719665c40324e89a536d165d0427a68_B_3_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[2];
        float _Split_e719665c40324e89a536d165d0427a68_A_4_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[3];
        float _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Split_e719665c40324e89a536d165d0427a68_A_4_Float, 0, _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean);
        float _Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float = Vector1_2EC6D670;
        float _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float, 0, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean);
        float _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean;
        Unity_Or_float(_Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean, _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean);
        UnityTexture2D _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D = Texture2D_5BAC276D;
        float3 _Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Split_e719665c40324e89a536d165d0427a68_A_4_Float.xxx), _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3);
        float3 _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3);
        float3 _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3;
        Unity_Subtract_float3(_Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3, _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3, _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3);
        float _Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float = Vector1_B4470F9B;
        float3 _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3, (_Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float.xxx), _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3);
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[0];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_G_2_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[1];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[2];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_A_4_Float = 0;
        float4 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4;
        float3 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3;
        float2 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2;
        Unity_Combine_float(_Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float, _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float, 0, 0, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2);
          float4 _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.tex, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.samplerstate, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.GetTransformedUV(_Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_A_8_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.a;
        float4 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4;
        float3 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3;
        float2 _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2;
        Unity_Combine_float(_SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float, 0, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2);
        float3 _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3;
        Unity_Add_float3(_Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3);
        float3 _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3;
        Unity_Branch_float3(_Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean, _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3, float3(0, 0, 0), _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3);
        float _Property_9946d066804cc584a96830f8d35269cc_Out_0_Float = Vector1_2EC6D670;
        float3 _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3, (_Property_9946d066804cc584a96830f8d35269cc_Out_0_Float.xxx), _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3);
        float3 _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3;
        Unity_Add_float3(_Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3, _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3, _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3);
        float _Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float = Vector1_A2C4B4F4;
        float3 _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3, (_Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float.xxx), _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3);
        float _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float;
        Unity_Length_float3(_Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3, _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float);
        float _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float = Vector1_7F78DDD2;
        float _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float;
        Unity_Add_float(_Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float, _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float, _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float);
        float _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        Unity_Multiply_float_float(_Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float, 0.001, _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float);
        direction_1 = _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        strength_2 = _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Comparison_NotEqual_float(float A, float B, out float Out)
        {
            Out = A != B ? 1 : 0;
        }
        
        struct Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float
        {
        float3 WorldSpaceNormal;
        float4 VertexColor;
        };
        
        void SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(float Vector1_BCB03E1A, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7EE0F94A, float Boolean_527CB26E, float Vector1_DE1BF63A, float Vector1_7F78DDD2, float3 Vector3_DE8CC74D, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float4x4 Matrix4_0617b0bd42fc46ff90b1d55303a5477f, float4 Vector4_b44806ec67ca461fbcdf009dc6092cc3, Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float IN, out float3 vertex_1, out float3 normal_2)
        {
        float4 _Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3;
        _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3 = TransformObjectToWorld((_Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4.xyz).xyz);
        float _Distance_63631313b11e497cab6af82887a71903_Out_2_Float;
        Unity_Distance_float3(_Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3, float3(0, 0, 0), _Distance_63631313b11e497cab6af82887a71903_Out_2_Float);
        float _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_63631313b11e497cab6af82887a71903_Out_2_Float, 0.001, _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean);
        float3 _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3 = Vector3_C30D997B;
        float4 _Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3;
        _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3 = TransformObjectToWorld((_Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4.xyz).xyz);
        float _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float;
        Unity_Distance_float3(_Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, float3(0, 0, 0), _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float);
        float _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float, 1, _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean);
        float3 _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean, float3(5, 5, 5), _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3);
        float3 _Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3;
        _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3 = TransformObjectToWorld(_Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3.xyz);
        float _Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean = Boolean_527CB26E;
        float _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float = Vector1_7EE0F94A;
        float _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, 0, _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean);
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_R_1_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[0];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[1];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_B_3_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[2];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_A_4_Float = 0;
        float _Split_7a634ef857769683b2100876a36535a2_R_1_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[0];
        float _Split_7a634ef857769683b2100876a36535a2_G_2_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[1];
        float _Split_7a634ef857769683b2100876a36535a2_B_3_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[2];
        float _Split_7a634ef857769683b2100876a36535a2_A_4_Float = 0;
        float _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float;
        Unity_Subtract_float(_Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float, _Split_7a634ef857769683b2100876a36535a2_G_2_Float, _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float);
        float _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean;
        Unity_Comparison_Less_float(_Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float, _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean);
        float _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean;
        Unity_And_float(_Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean, _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean);
        float _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float = Vector1_A2C4B4F4;
        float _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float;
        Unity_Branch_float(_And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean, 1E-05, _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float);
        float _Split_43013162a81fc4889a1944f2a2b75f66_R_1_Float = IN.VertexColor[0];
        float _Split_43013162a81fc4889a1944f2a2b75f66_G_2_Float = IN.VertexColor[1];
        float _Split_43013162a81fc4889a1944f2a2b75f66_B_3_Float = IN.VertexColor[2];
        float _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float = IN.VertexColor[3];
        float _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float;
        Unity_Multiply_float_float(_Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float);
        float _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float;
        Unity_Branch_float(_Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float);
        float _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float = Vector1_7F78DDD2;
        UnityTexture2D _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D = Texture2D_5BAC276D;
        UnityTexture2D _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D = Texture2D_A3874DB9;
        float4 _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float;
        Unity_Length_float4(_Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float);
        float _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float, 0, _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean);
        float4 _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4;
        Unity_Branch_float4(_Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean, _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, float4(0, 0, 1, 1), _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4);
        float4x4 _Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4 = Matrix4_0617b0bd42fc46ff90b1d55303a5477f;
        float4 _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4 = Vector4_b44806ec67ca461fbcdf009dc6092cc3;
        Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float _WindNMPoints_a2cb25cd23df4791acc49df936a795bc;
        float4 _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4;
        SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(_Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4, SHADERGRAPH_OBJECT_POSITION, _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4);
        float4 _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4;
        Unity_Add_float4(_Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4);
        float _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float = Vector1_B4470F9B;
        float _Property_6b508d48a081548385021b27896c0622_Out_0_Float = Vector1_2EC6D670;
        float _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float = Vector1_9365F438;
        float _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float = Vector1_F53C4B89;
        float _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float = Vector1_6803B355;
        float _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float = Vector1_BCB03E1A;
        Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba;
        float3 _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3;
        float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float;
        SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float, _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float, _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D, _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4, _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float, _Property_6b508d48a081548385021b27896c0622_Out_0_Float, _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float, _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float, _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float, _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float);
        float3 _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3;
        Unity_CrossProduct_float(float3 (0, 1, 0), _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3);
        float _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean;
        Unity_Comparison_Equal_float((_CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3).x, 0, _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean);
        float3 _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean, float3(1E-06, 1E-06, 1E-06), _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3, _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3);
        float3 _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3;
        Unity_Normalize_float3(_Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3, _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3);
        float3 _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3);
        float _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float;
        Unity_DotProduct_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3, _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float);
        float3 _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, (_DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float.xxx), _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3);
        float3 _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3;
        Unity_Add_float3(_Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3);
        float3 _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3);
        float _Distance_702b068f612c7289a99272879da274ed_Out_2_Float;
        Unity_Distance_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Distance_702b068f612c7289a99272879da274ed_Out_2_Float);
        float _Property_f5c255b0f666358291012b78132d6593_Out_0_Float = Vector1_DE1BF63A;
        float _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float;
        Unity_Divide_float(_Distance_702b068f612c7289a99272879da274ed_Out_2_Float, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float);
        float _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float;
        Unity_Absolute_float(_Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float, _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float);
        float _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float = 1E-07;
        float _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float;
        Unity_Maximum_float(_Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float, _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float, _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float);
        float _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float;
        Unity_Divide_float(1, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float);
        float _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float;
        Unity_Power_float(_Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float);
        float _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float;
        Unity_Multiply_float_float(_WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float, _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float);
        float _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float;
        Unity_Cosine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float);
        float3 _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, (_Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float.xxx), _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3);
        float3 _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3;
        Unity_CrossProduct_float(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3);
        float _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float;
        Unity_Sine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float);
        float3 _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3;
        Unity_Multiply_float3_float3(_CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3, (_Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float.xxx), _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3);
        float3 _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3;
        Unity_Add_float3(_Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3, _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3);
        float3 _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3;
        Unity_Add_float3(_Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3, _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3);
        float3 _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3;
        _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3 = TransformWorldToObject(_Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3.xyz);
        float3 _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean, _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3, _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3, _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3);
        float3 _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3 = Vector3_DE8CC74D;
        float _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float;
        Unity_Length_float3(_Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float);
        float _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean;
        Unity_Comparison_NotEqual_float(_Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float, 0, _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean);
        float3 _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpaceNormal, _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3);
        float3 _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3, IN.WorldSpaceNormal, _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3);
        vertex_1 = _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        normal_2 = _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, float3(1E-07, 1E-07, 1E-07), _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3);
            float _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float = _Drag;
            float _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float = _HeightDrag;
            float _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float = _Stiffness;
            float _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float = _InitialBend;
            float4 _Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4 = _NewNormal;
            UnityTexture2D _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            UnityTexture2D _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            float4 _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            float _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float = WIND_SETTINGS_FlexNoiseScale;
            float _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float = WIND_SETTINGS_Turbulence;
            float _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float = WIND_SETTINGS_GustSpeed;
            float _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float = WIND_SETTINGS_GustScale;
            float _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            float4x4 _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4 = WIND_SETTINGS_Points;
            float4 _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4 = WIND_SETTINGS_Points_Radius;
            Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.WorldSpaceNormal = IN.WorldSpaceNormal;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.VertexColor = IN.VertexColor;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3;
            SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(IN.TimeParameters.x, _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3, _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float, _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float, 0, _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float, _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float, (_Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4.xyz), _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D, _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D, _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4, _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float, _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float, _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float, _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float, _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float, _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4, _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3);
            description.Position = _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[0];
            float _Split_23e0470490bacd83973312a833450913_G_2_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[1];
            float _Split_23e0470490bacd83973312a833450913_B_3_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[2];
            float _Split_23e0470490bacd83973312a833450913_A_4_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_R_1_Float, _Split_23e0470490bacd83973312a833450913_G_2_Float);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_B_3_Float, _Split_23e0470490bacd83973312a833450913_A_4_Float);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2) );
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.a;
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float = _AlphaCutoff;
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.VertexColor =                                input.color;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 VertexColor;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
             float3 positionWS : INTERP3;
             float3 normalWS : INTERP4;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        float _Stiffness;
        float _InitialBend;
        float _Drag;
        float _HeightDrag;
        float4 _NewNormal;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        float4x4 WIND_SETTINGS_Points;
        float4 WIND_SETTINGS_Points_Radius;
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        float WIND_SETTINGS_GustWorldScale;
        float WIND_SETTINGS_GustScale;
        float WIND_SETTINGS_GustSpeed;
        float WIND_SETTINGS_Turbulence;
        float WIND_SETTINGS_ShiverNoiseScale;
        float WIND_SETTINGS_FlexNoiseScale;
        float4 WIND_SETTINGS_WorldDirectionAndSpeed;
        TEXTURE2D(WIND_SETTINGS_TexGust);
        SAMPLER(samplerWIND_SETTINGS_TexGust);
        float4 WIND_SETTINGS_TexGust_TexelSize;
        TEXTURE2D(WIND_SETTINGS_TexNoise);
        SAMPLER(samplerWIND_SETTINGS_TexNoise);
        float4 WIND_SETTINGS_TexNoise_TexelSize;
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Length_float4(float4 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float
        {
        };
        
        void SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(float4x4 Matrix4_cb72bb33b7a84dfda97778a514f9b60f, float3 Vector3_90379ebf40aa468b8362f8d265f4f234, float4 Vector4_159bb4232f82428893101734a03e2a1e, Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float IN, out float4 WindPoint_1)
        {
        float3 _Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3 = Vector3_90379ebf40aa468b8362f8d265f4f234;
        float4x4 _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4 = Matrix4_cb72bb33b7a84dfda97778a514f9b60f;
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].r);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].g);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].b);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].a);
        float3 _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4.xyz), _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3);
        float3 _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3);
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[0];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[1];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[2];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[3];
        float _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float;
        Unity_Length_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float);
        float4 _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4 = Vector4_159bb4232f82428893101734a03e2a1e;
        float _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[0];
        float _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[1];
        float _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[2];
        float _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[3];
        float _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float;
        Unity_Divide_float(_Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float, _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float);
        float _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float;
        Unity_Clamp_float(_Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float, 0, 1, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float);
        float _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float;
        Unity_Lerp_float(_Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float, 0, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float);
        float3 _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3, (_Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float.xxx), _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3);
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[0];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[1];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[2];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_A_4_Float = 0;
        float4 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4;
        float3 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3;
        float2 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2;
        Unity_Combine_float(_Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2);
        float3 _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4.xyz), _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3);
        float3 _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3);
        float _Split_8bbd5052350846968bf312362efd9f01_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[0];
        float _Split_8bbd5052350846968bf312362efd9f01_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[1];
        float _Split_8bbd5052350846968bf312362efd9f01_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[2];
        float _Split_8bbd5052350846968bf312362efd9f01_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[3];
        float _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float;
        Unity_Length_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float);
        float _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float;
        Unity_Divide_float(_Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float, _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float);
        float _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float;
        Unity_Clamp_float(_Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float, 0, 1, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float);
        float _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float;
        Unity_Lerp_float(_Split_8bbd5052350846968bf312362efd9f01_A_4_Float, 0, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float);
        float3 _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3, (_Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float.xxx), _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3);
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[0];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[1];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[2];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_A_4_Float = 0;
        float4 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4;
        float3 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3;
        float2 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2;
        Unity_Combine_float(_Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2);
        float4 _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4;
        Unity_Add_float4(_Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4);
        float3 _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4.xyz), _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3);
        float3 _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3);
        float _Split_fa21a8022f944854903e06c07c6f079c_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[0];
        float _Split_fa21a8022f944854903e06c07c6f079c_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[1];
        float _Split_fa21a8022f944854903e06c07c6f079c_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[2];
        float _Split_fa21a8022f944854903e06c07c6f079c_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[3];
        float _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float;
        Unity_Length_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float);
        float _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float;
        Unity_Divide_float(_Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float, _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float);
        float _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float;
        Unity_Clamp_float(_Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float, 0, 1, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float);
        float _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float;
        Unity_Lerp_float(_Split_fa21a8022f944854903e06c07c6f079c_A_4_Float, 0, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float);
        float3 _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3, (_Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float.xxx), _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3);
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[0];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[1];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[2];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_A_4_Float = 0;
        float4 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4;
        float3 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3;
        float2 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2;
        Unity_Combine_float(_Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2);
        float4 _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4;
        Unity_Add_float4(_Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4);
        float3 _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4.xyz), _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3);
        float3 _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3);
        float _Split_1bfec6763d4b458398e36937b4114c29_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[0];
        float _Split_1bfec6763d4b458398e36937b4114c29_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[1];
        float _Split_1bfec6763d4b458398e36937b4114c29_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[2];
        float _Split_1bfec6763d4b458398e36937b4114c29_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[3];
        float _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float;
        Unity_Length_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float);
        float _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float;
        Unity_Divide_float(_Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float, _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float);
        float _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float;
        Unity_Clamp_float(_Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float, 0, 1, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float);
        float _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float;
        Unity_Lerp_float(_Split_1bfec6763d4b458398e36937b4114c29_A_4_Float, 0, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float);
        float3 _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3, (_Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float.xxx), _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3);
        float _Split_e22879e6c4574322ab21f6261a21bced_R_1_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[0];
        float _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[1];
        float _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[2];
        float _Split_e22879e6c4574322ab21f6261a21bced_A_4_Float = 0;
        float4 _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4;
        float3 _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3;
        float2 _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2;
        Unity_Combine_float(_Split_e22879e6c4574322ab21f6261a21bced_R_1_Float, _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float, _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3, _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2);
        float4 _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        Unity_Add_float4(_Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4);
        WindPoint_1 = _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float
        {
        };
        
        void SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(float3 Vector3_604F121F, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7F78DDD2, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float Vector1_5EFF6B1A, Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float IN, out float3 direction_1, out float strength_2)
        {
        float4 _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[0];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[1];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[2];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_A_4_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[3];
        float4 _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4;
        float3 _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3;
        float2 _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2;
        Unity_Combine_float(_Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float, 0, _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4, _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2);
        float3 _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3;
        Unity_Normalize_float3(_Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3);
        float4 _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_R_1_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[0];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_G_2_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[1];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_B_3_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[2];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[3];
        float3 _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, (_Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float.xxx), _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3);
        float _Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float = Vector1_9365F438;
        float _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float, 0, _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean);
        UnityTexture2D _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D = Texture2D_A3874DB9;
        float3 _Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3 = float3(1, 0, 0);
        float _Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float.xxx), _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3);
        float _Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float = Vector1_5EFF6B1A;
        float3 _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3);
        float3 _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3;
        Unity_Subtract_float3(_Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3, _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3, _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3);
        float _Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float = Vector1_6803B355;
        float3 _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3, (_Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float.xxx), _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3);
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[0];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_G_2_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[1];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[2];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_A_4_Float = 0;
        float4 _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4;
        float3 _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3;
        float2 _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2;
        Unity_Combine_float(_Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float, _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float, 0, 0, _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4, _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3, _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2);
          float4 _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.tex, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.samplerstate, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.GetTransformedUV(_Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_G_6_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_B_7_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_A_8_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.a;
        float _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float;
        Unity_Branch_float(_Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean, _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float, 0, _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float);
        float _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float;
        Unity_Power_float(_Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float, 2, _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float);
        float _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float = Vector1_F53C4B89;
        float _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float;
        Unity_Multiply_float_float(_Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float, _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float, _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float);
        float3 _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float.xxx), _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3);
        float _Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3, (_Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float.xxx), _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3);
        float3 _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3, _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3, _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3);
        float4 _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_e719665c40324e89a536d165d0427a68_R_1_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[0];
        float _Split_e719665c40324e89a536d165d0427a68_G_2_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[1];
        float _Split_e719665c40324e89a536d165d0427a68_B_3_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[2];
        float _Split_e719665c40324e89a536d165d0427a68_A_4_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[3];
        float _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Split_e719665c40324e89a536d165d0427a68_A_4_Float, 0, _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean);
        float _Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float = Vector1_2EC6D670;
        float _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float, 0, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean);
        float _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean;
        Unity_Or_float(_Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean, _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean);
        UnityTexture2D _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D = Texture2D_5BAC276D;
        float3 _Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Split_e719665c40324e89a536d165d0427a68_A_4_Float.xxx), _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3);
        float3 _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3);
        float3 _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3;
        Unity_Subtract_float3(_Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3, _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3, _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3);
        float _Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float = Vector1_B4470F9B;
        float3 _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3, (_Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float.xxx), _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3);
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[0];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_G_2_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[1];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[2];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_A_4_Float = 0;
        float4 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4;
        float3 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3;
        float2 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2;
        Unity_Combine_float(_Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float, _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float, 0, 0, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2);
          float4 _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.tex, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.samplerstate, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.GetTransformedUV(_Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_A_8_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.a;
        float4 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4;
        float3 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3;
        float2 _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2;
        Unity_Combine_float(_SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float, 0, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2);
        float3 _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3;
        Unity_Add_float3(_Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3);
        float3 _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3;
        Unity_Branch_float3(_Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean, _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3, float3(0, 0, 0), _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3);
        float _Property_9946d066804cc584a96830f8d35269cc_Out_0_Float = Vector1_2EC6D670;
        float3 _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3, (_Property_9946d066804cc584a96830f8d35269cc_Out_0_Float.xxx), _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3);
        float3 _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3;
        Unity_Add_float3(_Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3, _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3, _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3);
        float _Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float = Vector1_A2C4B4F4;
        float3 _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3, (_Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float.xxx), _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3);
        float _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float;
        Unity_Length_float3(_Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3, _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float);
        float _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float = Vector1_7F78DDD2;
        float _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float;
        Unity_Add_float(_Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float, _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float, _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float);
        float _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        Unity_Multiply_float_float(_Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float, 0.001, _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float);
        direction_1 = _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        strength_2 = _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Comparison_NotEqual_float(float A, float B, out float Out)
        {
            Out = A != B ? 1 : 0;
        }
        
        struct Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float
        {
        float3 WorldSpaceNormal;
        float4 VertexColor;
        };
        
        void SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(float Vector1_BCB03E1A, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7EE0F94A, float Boolean_527CB26E, float Vector1_DE1BF63A, float Vector1_7F78DDD2, float3 Vector3_DE8CC74D, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float4x4 Matrix4_0617b0bd42fc46ff90b1d55303a5477f, float4 Vector4_b44806ec67ca461fbcdf009dc6092cc3, Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float IN, out float3 vertex_1, out float3 normal_2)
        {
        float4 _Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3;
        _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3 = TransformObjectToWorld((_Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4.xyz).xyz);
        float _Distance_63631313b11e497cab6af82887a71903_Out_2_Float;
        Unity_Distance_float3(_Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3, float3(0, 0, 0), _Distance_63631313b11e497cab6af82887a71903_Out_2_Float);
        float _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_63631313b11e497cab6af82887a71903_Out_2_Float, 0.001, _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean);
        float3 _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3 = Vector3_C30D997B;
        float4 _Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3;
        _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3 = TransformObjectToWorld((_Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4.xyz).xyz);
        float _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float;
        Unity_Distance_float3(_Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, float3(0, 0, 0), _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float);
        float _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float, 1, _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean);
        float3 _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean, float3(5, 5, 5), _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3);
        float3 _Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3;
        _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3 = TransformObjectToWorld(_Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3.xyz);
        float _Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean = Boolean_527CB26E;
        float _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float = Vector1_7EE0F94A;
        float _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, 0, _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean);
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_R_1_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[0];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[1];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_B_3_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[2];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_A_4_Float = 0;
        float _Split_7a634ef857769683b2100876a36535a2_R_1_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[0];
        float _Split_7a634ef857769683b2100876a36535a2_G_2_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[1];
        float _Split_7a634ef857769683b2100876a36535a2_B_3_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[2];
        float _Split_7a634ef857769683b2100876a36535a2_A_4_Float = 0;
        float _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float;
        Unity_Subtract_float(_Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float, _Split_7a634ef857769683b2100876a36535a2_G_2_Float, _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float);
        float _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean;
        Unity_Comparison_Less_float(_Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float, _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean);
        float _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean;
        Unity_And_float(_Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean, _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean);
        float _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float = Vector1_A2C4B4F4;
        float _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float;
        Unity_Branch_float(_And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean, 1E-05, _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float);
        float _Split_43013162a81fc4889a1944f2a2b75f66_R_1_Float = IN.VertexColor[0];
        float _Split_43013162a81fc4889a1944f2a2b75f66_G_2_Float = IN.VertexColor[1];
        float _Split_43013162a81fc4889a1944f2a2b75f66_B_3_Float = IN.VertexColor[2];
        float _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float = IN.VertexColor[3];
        float _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float;
        Unity_Multiply_float_float(_Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float);
        float _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float;
        Unity_Branch_float(_Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float);
        float _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float = Vector1_7F78DDD2;
        UnityTexture2D _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D = Texture2D_5BAC276D;
        UnityTexture2D _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D = Texture2D_A3874DB9;
        float4 _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float;
        Unity_Length_float4(_Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float);
        float _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float, 0, _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean);
        float4 _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4;
        Unity_Branch_float4(_Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean, _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, float4(0, 0, 1, 1), _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4);
        float4x4 _Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4 = Matrix4_0617b0bd42fc46ff90b1d55303a5477f;
        float4 _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4 = Vector4_b44806ec67ca461fbcdf009dc6092cc3;
        Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float _WindNMPoints_a2cb25cd23df4791acc49df936a795bc;
        float4 _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4;
        SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(_Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4, SHADERGRAPH_OBJECT_POSITION, _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4);
        float4 _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4;
        Unity_Add_float4(_Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4);
        float _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float = Vector1_B4470F9B;
        float _Property_6b508d48a081548385021b27896c0622_Out_0_Float = Vector1_2EC6D670;
        float _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float = Vector1_9365F438;
        float _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float = Vector1_F53C4B89;
        float _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float = Vector1_6803B355;
        float _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float = Vector1_BCB03E1A;
        Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba;
        float3 _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3;
        float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float;
        SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float, _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float, _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D, _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4, _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float, _Property_6b508d48a081548385021b27896c0622_Out_0_Float, _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float, _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float, _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float, _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float);
        float3 _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3;
        Unity_CrossProduct_float(float3 (0, 1, 0), _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3);
        float _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean;
        Unity_Comparison_Equal_float((_CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3).x, 0, _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean);
        float3 _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean, float3(1E-06, 1E-06, 1E-06), _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3, _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3);
        float3 _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3;
        Unity_Normalize_float3(_Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3, _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3);
        float3 _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3);
        float _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float;
        Unity_DotProduct_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3, _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float);
        float3 _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, (_DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float.xxx), _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3);
        float3 _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3;
        Unity_Add_float3(_Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3);
        float3 _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3);
        float _Distance_702b068f612c7289a99272879da274ed_Out_2_Float;
        Unity_Distance_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Distance_702b068f612c7289a99272879da274ed_Out_2_Float);
        float _Property_f5c255b0f666358291012b78132d6593_Out_0_Float = Vector1_DE1BF63A;
        float _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float;
        Unity_Divide_float(_Distance_702b068f612c7289a99272879da274ed_Out_2_Float, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float);
        float _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float;
        Unity_Absolute_float(_Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float, _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float);
        float _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float = 1E-07;
        float _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float;
        Unity_Maximum_float(_Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float, _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float, _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float);
        float _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float;
        Unity_Divide_float(1, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float);
        float _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float;
        Unity_Power_float(_Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float);
        float _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float;
        Unity_Multiply_float_float(_WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float, _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float);
        float _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float;
        Unity_Cosine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float);
        float3 _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, (_Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float.xxx), _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3);
        float3 _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3;
        Unity_CrossProduct_float(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3);
        float _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float;
        Unity_Sine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float);
        float3 _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3;
        Unity_Multiply_float3_float3(_CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3, (_Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float.xxx), _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3);
        float3 _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3;
        Unity_Add_float3(_Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3, _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3);
        float3 _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3;
        Unity_Add_float3(_Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3, _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3);
        float3 _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3;
        _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3 = TransformWorldToObject(_Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3.xyz);
        float3 _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean, _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3, _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3, _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3);
        float3 _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3 = Vector3_DE8CC74D;
        float _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float;
        Unity_Length_float3(_Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float);
        float _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean;
        Unity_Comparison_NotEqual_float(_Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float, 0, _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean);
        float3 _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpaceNormal, _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3);
        float3 _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3, IN.WorldSpaceNormal, _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3);
        vertex_1 = _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        normal_2 = _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, float3(1E-07, 1E-07, 1E-07), _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3);
            float _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float = _Drag;
            float _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float = _HeightDrag;
            float _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float = _Stiffness;
            float _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float = _InitialBend;
            float4 _Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4 = _NewNormal;
            UnityTexture2D _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            UnityTexture2D _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            float4 _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            float _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float = WIND_SETTINGS_FlexNoiseScale;
            float _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float = WIND_SETTINGS_Turbulence;
            float _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float = WIND_SETTINGS_GustSpeed;
            float _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float = WIND_SETTINGS_GustScale;
            float _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            float4x4 _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4 = WIND_SETTINGS_Points;
            float4 _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4 = WIND_SETTINGS_Points_Radius;
            Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.WorldSpaceNormal = IN.WorldSpaceNormal;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.VertexColor = IN.VertexColor;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3;
            SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(IN.TimeParameters.x, _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3, _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float, _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float, 0, _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float, _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float, (_Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4.xyz), _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D, _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D, _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4, _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float, _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float, _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float, _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float, _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float, _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4, _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3);
            description.Position = _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[0];
            float _Split_23e0470490bacd83973312a833450913_G_2_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[1];
            float _Split_23e0470490bacd83973312a833450913_B_3_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[2];
            float _Split_23e0470490bacd83973312a833450913_A_4_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_R_1_Float, _Split_23e0470490bacd83973312a833450913_G_2_Float);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_B_3_Float, _Split_23e0470490bacd83973312a833450913_A_4_Float);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2) );
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.a;
            float4 _Property_0457e5435408618697b5c5387038cff3_Out_0_Vector4 = _DryColor;
            float4 _Property_b618307b57ad3380b3914a2093b7f159_Out_0_Vector4 = _HealthyColor;
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_A_4_Float = 0;
            float2 _Vector2_a6e9136948d4528182e57d0748ed446b_Out_0_Vector2 = float2(_Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1_Float, _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3_Float);
            float _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0_Float = _ColorNoiseSpread;
            float _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float(_Vector2_a6e9136948d4528182e57d0748ed446b_Out_0_Vector2, _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0_Float, _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2_Float);
            float4 _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3_Vector4;
            Unity_Lerp_float4(_Property_0457e5435408618697b5c5387038cff3_Out_0_Vector4, _Property_b618307b57ad3380b3914a2093b7f159_Out_0_Vector4, (_SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2_Float.xxxx), _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3_Vector4);
            float4 _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4, _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3_Vector4, _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2_Vector4);
            UnityTexture2D _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_SnowBaseColorMap);
            float4 _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4 = _SnowTilingOffset;
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_R_1_Float = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4[0];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2_Float = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4[1];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_B_3_Float = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4[2];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4_Float = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4[3];
            float2 _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0_Vector2 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_R_1_Float, _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2_Float);
            float2 _Vector2_f1756f1084099581aefb8f7868e45176_Out_0_Vector2 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_B_3_Float, _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4_Float);
            float2 _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0_Vector2, _Vector2_f1756f1084099581aefb8f7868e45176_Out_0_Vector2, _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3_Vector2);
            float4 _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0_Texture2D.tex, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0_Texture2D.samplerstate, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3_Vector2) );
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_R_4_Float = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4.r;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_G_5_Float = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4.g;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_B_6_Float = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4.b;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_A_7_Float = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4.a;
            float4 _Property_6fad1bea7f828d879b30d1995855944c_Out_0_Vector4 = _SnowBaseColor;
            float4 _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4, _Property_6fad1bea7f828d879b30d1995855944c_Out_0_Vector4, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2_Vector4);
            float _Property_7dfafd311568c28ea4498c71c218169e_Out_0_Float = _Snow_Amount;
            UnityTexture2D _Property_850aded96259f88b9f084f496dd42683_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_850aded96259f88b9f084f496dd42683_Out_0_Texture2D.tex, _Property_850aded96259f88b9f084f496dd42683_Out_0_Texture2D.samplerstate, _Property_850aded96259f88b9f084f496dd42683_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2) );
            _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4);
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_R_4_Float = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.r;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_G_5_Float = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.g;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_B_6_Float = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.b;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_A_7_Float = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.a;
            float _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0_Float = _NormalScale;
            float3 _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2_Vector3;
            Unity_NormalStrength_float((_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.xyz), _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0_Float, _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2_Vector3);
            float _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0_Float = _SnowBlendHardness;
            float3 _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2_Vector3;
            Unity_NormalStrength_float(_NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2_Vector3, _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0_Float, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2_Vector3);
            float3 _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3;
            Unity_NormalBlend_float(IN.WorldSpaceNormal, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2_Vector3, _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3);
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_R_1_Float = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3[0];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2_Float = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3[1];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_B_3_Float = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3[2];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_A_4_Float = 0;
            float _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2_Float;
            Unity_Multiply_float_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0_Float, _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2_Float, _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2_Float);
            float _Clamp_55159c695da3ec84995296ffa5245953_Out_3_Float;
            Unity_Clamp_float(_Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2_Float, 0, 1, _Clamp_55159c695da3ec84995296ffa5245953_Out_3_Float);
            float _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1_Float;
            Unity_Saturate_float(_Clamp_55159c695da3ec84995296ffa5245953_Out_3_Float, _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1_Float);
            float _Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0_Boolean = _InvertSnowMask;
            UnityTexture2D _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_SnowMaskA);
            float4 _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0_Texture2D.tex, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0_Texture2D.samplerstate, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3_Vector2) );
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_R_4_Float = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4.r;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_G_5_Float = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4.g;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_B_6_Float = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4.b;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7_Float = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4.a;
            float _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1_Float;
            Unity_OneMinus_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7_Float, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1_Float);
            float _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3_Float;
            Unity_Branch_float(_Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0_Boolean, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1_Float, _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7_Float, _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3_Float);
            float _Property_53155f8b6e17528993532384c69b45cf_Out_0_Float = _SnowMaskTreshold;
            float _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2_Float;
            Unity_Multiply_float_float(_Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3_Float, _Property_53155f8b6e17528993532384c69b45cf_Out_0_Float, _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2_Float);
            float _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3_Float;
            Unity_Clamp_float(_Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2_Float, 0, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3_Float);
            float _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3_Float;
            Unity_Lerp_float(_Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1_Float, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3_Float, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3_Float);
            float _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1_Float;
            Unity_Absolute_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7_Float, _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1_Float);
            float _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3_Float;
            Unity_Clamp_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0_Float, 0.1, 2, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3_Float);
            float _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2_Float;
            Unity_Divide_float(_Property_53155f8b6e17528993532384c69b45cf_Out_0_Float, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3_Float, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2_Float);
            float _Power_a92be574722606868c966ca3ced4bc87_Out_2_Float;
            Unity_Power_float(_Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1_Float, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2_Float, _Power_a92be574722606868c966ca3ced4bc87_Out_2_Float);
            float _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3_Float;
            Unity_Lerp_float(0, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3_Float, _Power_a92be574722606868c966ca3ced4bc87_Out_2_Float, _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3_Float);
            float4 _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2_Vector4, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2_Vector4, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3_Float.xxxx), _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3_Vector4);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float = _AlphaCutoff;
            surface.BaseColor = (_Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3_Vector4.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.VertexColor =                                input.color;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 VertexColor;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        float _Stiffness;
        float _InitialBend;
        float _Drag;
        float _HeightDrag;
        float4 _NewNormal;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        float4x4 WIND_SETTINGS_Points;
        float4 WIND_SETTINGS_Points_Radius;
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        float WIND_SETTINGS_GustWorldScale;
        float WIND_SETTINGS_GustScale;
        float WIND_SETTINGS_GustSpeed;
        float WIND_SETTINGS_Turbulence;
        float WIND_SETTINGS_ShiverNoiseScale;
        float WIND_SETTINGS_FlexNoiseScale;
        float4 WIND_SETTINGS_WorldDirectionAndSpeed;
        TEXTURE2D(WIND_SETTINGS_TexGust);
        SAMPLER(samplerWIND_SETTINGS_TexGust);
        float4 WIND_SETTINGS_TexGust_TexelSize;
        TEXTURE2D(WIND_SETTINGS_TexNoise);
        SAMPLER(samplerWIND_SETTINGS_TexNoise);
        float4 WIND_SETTINGS_TexNoise_TexelSize;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Length_float4(float4 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float
        {
        };
        
        void SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(float4x4 Matrix4_cb72bb33b7a84dfda97778a514f9b60f, float3 Vector3_90379ebf40aa468b8362f8d265f4f234, float4 Vector4_159bb4232f82428893101734a03e2a1e, Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float IN, out float4 WindPoint_1)
        {
        float3 _Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3 = Vector3_90379ebf40aa468b8362f8d265f4f234;
        float4x4 _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4 = Matrix4_cb72bb33b7a84dfda97778a514f9b60f;
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].r);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].g);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].b);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].a);
        float3 _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4.xyz), _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3);
        float3 _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3);
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[0];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[1];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[2];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[3];
        float _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float;
        Unity_Length_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float);
        float4 _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4 = Vector4_159bb4232f82428893101734a03e2a1e;
        float _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[0];
        float _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[1];
        float _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[2];
        float _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[3];
        float _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float;
        Unity_Divide_float(_Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float, _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float);
        float _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float;
        Unity_Clamp_float(_Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float, 0, 1, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float);
        float _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float;
        Unity_Lerp_float(_Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float, 0, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float);
        float3 _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3, (_Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float.xxx), _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3);
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[0];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[1];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[2];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_A_4_Float = 0;
        float4 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4;
        float3 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3;
        float2 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2;
        Unity_Combine_float(_Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2);
        float3 _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4.xyz), _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3);
        float3 _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3);
        float _Split_8bbd5052350846968bf312362efd9f01_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[0];
        float _Split_8bbd5052350846968bf312362efd9f01_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[1];
        float _Split_8bbd5052350846968bf312362efd9f01_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[2];
        float _Split_8bbd5052350846968bf312362efd9f01_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[3];
        float _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float;
        Unity_Length_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float);
        float _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float;
        Unity_Divide_float(_Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float, _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float);
        float _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float;
        Unity_Clamp_float(_Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float, 0, 1, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float);
        float _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float;
        Unity_Lerp_float(_Split_8bbd5052350846968bf312362efd9f01_A_4_Float, 0, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float);
        float3 _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3, (_Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float.xxx), _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3);
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[0];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[1];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[2];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_A_4_Float = 0;
        float4 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4;
        float3 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3;
        float2 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2;
        Unity_Combine_float(_Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2);
        float4 _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4;
        Unity_Add_float4(_Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4);
        float3 _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4.xyz), _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3);
        float3 _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3);
        float _Split_fa21a8022f944854903e06c07c6f079c_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[0];
        float _Split_fa21a8022f944854903e06c07c6f079c_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[1];
        float _Split_fa21a8022f944854903e06c07c6f079c_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[2];
        float _Split_fa21a8022f944854903e06c07c6f079c_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[3];
        float _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float;
        Unity_Length_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float);
        float _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float;
        Unity_Divide_float(_Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float, _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float);
        float _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float;
        Unity_Clamp_float(_Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float, 0, 1, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float);
        float _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float;
        Unity_Lerp_float(_Split_fa21a8022f944854903e06c07c6f079c_A_4_Float, 0, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float);
        float3 _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3, (_Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float.xxx), _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3);
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[0];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[1];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[2];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_A_4_Float = 0;
        float4 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4;
        float3 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3;
        float2 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2;
        Unity_Combine_float(_Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2);
        float4 _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4;
        Unity_Add_float4(_Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4);
        float3 _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4.xyz), _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3);
        float3 _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3);
        float _Split_1bfec6763d4b458398e36937b4114c29_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[0];
        float _Split_1bfec6763d4b458398e36937b4114c29_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[1];
        float _Split_1bfec6763d4b458398e36937b4114c29_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[2];
        float _Split_1bfec6763d4b458398e36937b4114c29_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[3];
        float _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float;
        Unity_Length_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float);
        float _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float;
        Unity_Divide_float(_Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float, _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float);
        float _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float;
        Unity_Clamp_float(_Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float, 0, 1, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float);
        float _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float;
        Unity_Lerp_float(_Split_1bfec6763d4b458398e36937b4114c29_A_4_Float, 0, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float);
        float3 _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3, (_Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float.xxx), _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3);
        float _Split_e22879e6c4574322ab21f6261a21bced_R_1_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[0];
        float _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[1];
        float _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[2];
        float _Split_e22879e6c4574322ab21f6261a21bced_A_4_Float = 0;
        float4 _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4;
        float3 _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3;
        float2 _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2;
        Unity_Combine_float(_Split_e22879e6c4574322ab21f6261a21bced_R_1_Float, _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float, _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3, _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2);
        float4 _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        Unity_Add_float4(_Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4);
        WindPoint_1 = _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float
        {
        };
        
        void SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(float3 Vector3_604F121F, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7F78DDD2, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float Vector1_5EFF6B1A, Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float IN, out float3 direction_1, out float strength_2)
        {
        float4 _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[0];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[1];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[2];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_A_4_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[3];
        float4 _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4;
        float3 _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3;
        float2 _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2;
        Unity_Combine_float(_Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float, 0, _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4, _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2);
        float3 _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3;
        Unity_Normalize_float3(_Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3);
        float4 _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_R_1_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[0];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_G_2_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[1];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_B_3_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[2];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[3];
        float3 _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, (_Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float.xxx), _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3);
        float _Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float = Vector1_9365F438;
        float _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float, 0, _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean);
        UnityTexture2D _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D = Texture2D_A3874DB9;
        float3 _Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3 = float3(1, 0, 0);
        float _Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float.xxx), _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3);
        float _Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float = Vector1_5EFF6B1A;
        float3 _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3);
        float3 _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3;
        Unity_Subtract_float3(_Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3, _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3, _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3);
        float _Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float = Vector1_6803B355;
        float3 _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3, (_Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float.xxx), _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3);
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[0];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_G_2_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[1];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[2];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_A_4_Float = 0;
        float4 _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4;
        float3 _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3;
        float2 _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2;
        Unity_Combine_float(_Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float, _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float, 0, 0, _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4, _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3, _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2);
          float4 _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.tex, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.samplerstate, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.GetTransformedUV(_Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_G_6_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_B_7_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_A_8_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.a;
        float _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float;
        Unity_Branch_float(_Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean, _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float, 0, _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float);
        float _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float;
        Unity_Power_float(_Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float, 2, _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float);
        float _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float = Vector1_F53C4B89;
        float _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float;
        Unity_Multiply_float_float(_Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float, _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float, _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float);
        float3 _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float.xxx), _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3);
        float _Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3, (_Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float.xxx), _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3);
        float3 _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3, _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3, _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3);
        float4 _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_e719665c40324e89a536d165d0427a68_R_1_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[0];
        float _Split_e719665c40324e89a536d165d0427a68_G_2_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[1];
        float _Split_e719665c40324e89a536d165d0427a68_B_3_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[2];
        float _Split_e719665c40324e89a536d165d0427a68_A_4_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[3];
        float _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Split_e719665c40324e89a536d165d0427a68_A_4_Float, 0, _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean);
        float _Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float = Vector1_2EC6D670;
        float _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float, 0, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean);
        float _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean;
        Unity_Or_float(_Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean, _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean);
        UnityTexture2D _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D = Texture2D_5BAC276D;
        float3 _Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Split_e719665c40324e89a536d165d0427a68_A_4_Float.xxx), _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3);
        float3 _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3);
        float3 _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3;
        Unity_Subtract_float3(_Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3, _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3, _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3);
        float _Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float = Vector1_B4470F9B;
        float3 _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3, (_Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float.xxx), _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3);
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[0];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_G_2_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[1];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[2];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_A_4_Float = 0;
        float4 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4;
        float3 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3;
        float2 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2;
        Unity_Combine_float(_Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float, _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float, 0, 0, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2);
          float4 _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.tex, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.samplerstate, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.GetTransformedUV(_Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_A_8_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.a;
        float4 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4;
        float3 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3;
        float2 _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2;
        Unity_Combine_float(_SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float, 0, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2);
        float3 _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3;
        Unity_Add_float3(_Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3);
        float3 _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3;
        Unity_Branch_float3(_Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean, _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3, float3(0, 0, 0), _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3);
        float _Property_9946d066804cc584a96830f8d35269cc_Out_0_Float = Vector1_2EC6D670;
        float3 _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3, (_Property_9946d066804cc584a96830f8d35269cc_Out_0_Float.xxx), _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3);
        float3 _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3;
        Unity_Add_float3(_Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3, _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3, _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3);
        float _Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float = Vector1_A2C4B4F4;
        float3 _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3, (_Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float.xxx), _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3);
        float _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float;
        Unity_Length_float3(_Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3, _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float);
        float _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float = Vector1_7F78DDD2;
        float _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float;
        Unity_Add_float(_Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float, _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float, _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float);
        float _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        Unity_Multiply_float_float(_Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float, 0.001, _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float);
        direction_1 = _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        strength_2 = _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Comparison_NotEqual_float(float A, float B, out float Out)
        {
            Out = A != B ? 1 : 0;
        }
        
        struct Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float
        {
        float3 WorldSpaceNormal;
        float4 VertexColor;
        };
        
        void SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(float Vector1_BCB03E1A, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7EE0F94A, float Boolean_527CB26E, float Vector1_DE1BF63A, float Vector1_7F78DDD2, float3 Vector3_DE8CC74D, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float4x4 Matrix4_0617b0bd42fc46ff90b1d55303a5477f, float4 Vector4_b44806ec67ca461fbcdf009dc6092cc3, Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float IN, out float3 vertex_1, out float3 normal_2)
        {
        float4 _Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3;
        _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3 = TransformObjectToWorld((_Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4.xyz).xyz);
        float _Distance_63631313b11e497cab6af82887a71903_Out_2_Float;
        Unity_Distance_float3(_Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3, float3(0, 0, 0), _Distance_63631313b11e497cab6af82887a71903_Out_2_Float);
        float _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_63631313b11e497cab6af82887a71903_Out_2_Float, 0.001, _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean);
        float3 _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3 = Vector3_C30D997B;
        float4 _Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3;
        _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3 = TransformObjectToWorld((_Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4.xyz).xyz);
        float _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float;
        Unity_Distance_float3(_Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, float3(0, 0, 0), _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float);
        float _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float, 1, _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean);
        float3 _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean, float3(5, 5, 5), _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3);
        float3 _Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3;
        _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3 = TransformObjectToWorld(_Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3.xyz);
        float _Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean = Boolean_527CB26E;
        float _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float = Vector1_7EE0F94A;
        float _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, 0, _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean);
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_R_1_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[0];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[1];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_B_3_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[2];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_A_4_Float = 0;
        float _Split_7a634ef857769683b2100876a36535a2_R_1_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[0];
        float _Split_7a634ef857769683b2100876a36535a2_G_2_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[1];
        float _Split_7a634ef857769683b2100876a36535a2_B_3_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[2];
        float _Split_7a634ef857769683b2100876a36535a2_A_4_Float = 0;
        float _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float;
        Unity_Subtract_float(_Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float, _Split_7a634ef857769683b2100876a36535a2_G_2_Float, _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float);
        float _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean;
        Unity_Comparison_Less_float(_Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float, _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean);
        float _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean;
        Unity_And_float(_Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean, _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean);
        float _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float = Vector1_A2C4B4F4;
        float _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float;
        Unity_Branch_float(_And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean, 1E-05, _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float);
        float _Split_43013162a81fc4889a1944f2a2b75f66_R_1_Float = IN.VertexColor[0];
        float _Split_43013162a81fc4889a1944f2a2b75f66_G_2_Float = IN.VertexColor[1];
        float _Split_43013162a81fc4889a1944f2a2b75f66_B_3_Float = IN.VertexColor[2];
        float _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float = IN.VertexColor[3];
        float _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float;
        Unity_Multiply_float_float(_Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float);
        float _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float;
        Unity_Branch_float(_Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float);
        float _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float = Vector1_7F78DDD2;
        UnityTexture2D _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D = Texture2D_5BAC276D;
        UnityTexture2D _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D = Texture2D_A3874DB9;
        float4 _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float;
        Unity_Length_float4(_Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float);
        float _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float, 0, _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean);
        float4 _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4;
        Unity_Branch_float4(_Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean, _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, float4(0, 0, 1, 1), _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4);
        float4x4 _Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4 = Matrix4_0617b0bd42fc46ff90b1d55303a5477f;
        float4 _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4 = Vector4_b44806ec67ca461fbcdf009dc6092cc3;
        Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float _WindNMPoints_a2cb25cd23df4791acc49df936a795bc;
        float4 _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4;
        SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(_Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4, SHADERGRAPH_OBJECT_POSITION, _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4);
        float4 _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4;
        Unity_Add_float4(_Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4);
        float _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float = Vector1_B4470F9B;
        float _Property_6b508d48a081548385021b27896c0622_Out_0_Float = Vector1_2EC6D670;
        float _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float = Vector1_9365F438;
        float _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float = Vector1_F53C4B89;
        float _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float = Vector1_6803B355;
        float _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float = Vector1_BCB03E1A;
        Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba;
        float3 _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3;
        float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float;
        SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float, _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float, _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D, _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4, _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float, _Property_6b508d48a081548385021b27896c0622_Out_0_Float, _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float, _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float, _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float, _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float);
        float3 _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3;
        Unity_CrossProduct_float(float3 (0, 1, 0), _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3);
        float _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean;
        Unity_Comparison_Equal_float((_CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3).x, 0, _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean);
        float3 _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean, float3(1E-06, 1E-06, 1E-06), _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3, _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3);
        float3 _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3;
        Unity_Normalize_float3(_Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3, _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3);
        float3 _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3);
        float _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float;
        Unity_DotProduct_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3, _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float);
        float3 _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, (_DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float.xxx), _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3);
        float3 _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3;
        Unity_Add_float3(_Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3);
        float3 _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3);
        float _Distance_702b068f612c7289a99272879da274ed_Out_2_Float;
        Unity_Distance_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Distance_702b068f612c7289a99272879da274ed_Out_2_Float);
        float _Property_f5c255b0f666358291012b78132d6593_Out_0_Float = Vector1_DE1BF63A;
        float _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float;
        Unity_Divide_float(_Distance_702b068f612c7289a99272879da274ed_Out_2_Float, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float);
        float _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float;
        Unity_Absolute_float(_Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float, _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float);
        float _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float = 1E-07;
        float _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float;
        Unity_Maximum_float(_Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float, _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float, _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float);
        float _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float;
        Unity_Divide_float(1, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float);
        float _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float;
        Unity_Power_float(_Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float);
        float _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float;
        Unity_Multiply_float_float(_WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float, _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float);
        float _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float;
        Unity_Cosine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float);
        float3 _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, (_Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float.xxx), _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3);
        float3 _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3;
        Unity_CrossProduct_float(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3);
        float _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float;
        Unity_Sine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float);
        float3 _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3;
        Unity_Multiply_float3_float3(_CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3, (_Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float.xxx), _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3);
        float3 _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3;
        Unity_Add_float3(_Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3, _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3);
        float3 _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3;
        Unity_Add_float3(_Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3, _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3);
        float3 _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3;
        _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3 = TransformWorldToObject(_Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3.xyz);
        float3 _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean, _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3, _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3, _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3);
        float3 _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3 = Vector3_DE8CC74D;
        float _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float;
        Unity_Length_float3(_Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float);
        float _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean;
        Unity_Comparison_NotEqual_float(_Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float, 0, _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean);
        float3 _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpaceNormal, _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3);
        float3 _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3, IN.WorldSpaceNormal, _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3);
        vertex_1 = _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        normal_2 = _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, float3(1E-07, 1E-07, 1E-07), _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3);
            float _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float = _Drag;
            float _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float = _HeightDrag;
            float _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float = _Stiffness;
            float _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float = _InitialBend;
            float4 _Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4 = _NewNormal;
            UnityTexture2D _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            UnityTexture2D _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            float4 _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            float _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float = WIND_SETTINGS_FlexNoiseScale;
            float _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float = WIND_SETTINGS_Turbulence;
            float _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float = WIND_SETTINGS_GustSpeed;
            float _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float = WIND_SETTINGS_GustScale;
            float _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            float4x4 _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4 = WIND_SETTINGS_Points;
            float4 _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4 = WIND_SETTINGS_Points_Radius;
            Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.WorldSpaceNormal = IN.WorldSpaceNormal;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.VertexColor = IN.VertexColor;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3;
            SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(IN.TimeParameters.x, _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3, _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float, _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float, 0, _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float, _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float, (_Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4.xyz), _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D, _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D, _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4, _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float, _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float, _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float, _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float, _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float, _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4, _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3);
            description.Position = _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[0];
            float _Split_23e0470490bacd83973312a833450913_G_2_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[1];
            float _Split_23e0470490bacd83973312a833450913_B_3_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[2];
            float _Split_23e0470490bacd83973312a833450913_A_4_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_R_1_Float, _Split_23e0470490bacd83973312a833450913_G_2_Float);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_B_3_Float, _Split_23e0470490bacd83973312a833450913_A_4_Float);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2) );
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.a;
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float = _AlphaCutoff;
            surface.Alpha = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.VertexColor =                                input.color;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 VertexColor;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        float _Stiffness;
        float _InitialBend;
        float _Drag;
        float _HeightDrag;
        float4 _NewNormal;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        float4x4 WIND_SETTINGS_Points;
        float4 WIND_SETTINGS_Points_Radius;
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        float WIND_SETTINGS_GustWorldScale;
        float WIND_SETTINGS_GustScale;
        float WIND_SETTINGS_GustSpeed;
        float WIND_SETTINGS_Turbulence;
        float WIND_SETTINGS_ShiverNoiseScale;
        float WIND_SETTINGS_FlexNoiseScale;
        float4 WIND_SETTINGS_WorldDirectionAndSpeed;
        TEXTURE2D(WIND_SETTINGS_TexGust);
        SAMPLER(samplerWIND_SETTINGS_TexGust);
        float4 WIND_SETTINGS_TexGust_TexelSize;
        TEXTURE2D(WIND_SETTINGS_TexNoise);
        SAMPLER(samplerWIND_SETTINGS_TexNoise);
        float4 WIND_SETTINGS_TexNoise_TexelSize;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Length_float4(float4 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float
        {
        };
        
        void SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(float4x4 Matrix4_cb72bb33b7a84dfda97778a514f9b60f, float3 Vector3_90379ebf40aa468b8362f8d265f4f234, float4 Vector4_159bb4232f82428893101734a03e2a1e, Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float IN, out float4 WindPoint_1)
        {
        float3 _Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3 = Vector3_90379ebf40aa468b8362f8d265f4f234;
        float4x4 _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4 = Matrix4_cb72bb33b7a84dfda97778a514f9b60f;
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].r);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].g);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].b);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].a);
        float3 _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4.xyz), _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3);
        float3 _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3);
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[0];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[1];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[2];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[3];
        float _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float;
        Unity_Length_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float);
        float4 _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4 = Vector4_159bb4232f82428893101734a03e2a1e;
        float _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[0];
        float _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[1];
        float _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[2];
        float _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[3];
        float _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float;
        Unity_Divide_float(_Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float, _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float);
        float _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float;
        Unity_Clamp_float(_Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float, 0, 1, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float);
        float _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float;
        Unity_Lerp_float(_Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float, 0, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float);
        float3 _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3, (_Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float.xxx), _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3);
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[0];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[1];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[2];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_A_4_Float = 0;
        float4 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4;
        float3 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3;
        float2 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2;
        Unity_Combine_float(_Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2);
        float3 _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4.xyz), _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3);
        float3 _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3);
        float _Split_8bbd5052350846968bf312362efd9f01_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[0];
        float _Split_8bbd5052350846968bf312362efd9f01_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[1];
        float _Split_8bbd5052350846968bf312362efd9f01_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[2];
        float _Split_8bbd5052350846968bf312362efd9f01_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[3];
        float _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float;
        Unity_Length_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float);
        float _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float;
        Unity_Divide_float(_Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float, _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float);
        float _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float;
        Unity_Clamp_float(_Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float, 0, 1, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float);
        float _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float;
        Unity_Lerp_float(_Split_8bbd5052350846968bf312362efd9f01_A_4_Float, 0, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float);
        float3 _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3, (_Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float.xxx), _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3);
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[0];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[1];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[2];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_A_4_Float = 0;
        float4 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4;
        float3 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3;
        float2 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2;
        Unity_Combine_float(_Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2);
        float4 _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4;
        Unity_Add_float4(_Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4);
        float3 _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4.xyz), _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3);
        float3 _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3);
        float _Split_fa21a8022f944854903e06c07c6f079c_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[0];
        float _Split_fa21a8022f944854903e06c07c6f079c_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[1];
        float _Split_fa21a8022f944854903e06c07c6f079c_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[2];
        float _Split_fa21a8022f944854903e06c07c6f079c_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[3];
        float _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float;
        Unity_Length_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float);
        float _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float;
        Unity_Divide_float(_Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float, _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float);
        float _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float;
        Unity_Clamp_float(_Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float, 0, 1, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float);
        float _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float;
        Unity_Lerp_float(_Split_fa21a8022f944854903e06c07c6f079c_A_4_Float, 0, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float);
        float3 _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3, (_Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float.xxx), _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3);
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[0];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[1];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[2];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_A_4_Float = 0;
        float4 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4;
        float3 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3;
        float2 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2;
        Unity_Combine_float(_Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2);
        float4 _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4;
        Unity_Add_float4(_Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4);
        float3 _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4.xyz), _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3);
        float3 _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3);
        float _Split_1bfec6763d4b458398e36937b4114c29_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[0];
        float _Split_1bfec6763d4b458398e36937b4114c29_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[1];
        float _Split_1bfec6763d4b458398e36937b4114c29_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[2];
        float _Split_1bfec6763d4b458398e36937b4114c29_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[3];
        float _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float;
        Unity_Length_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float);
        float _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float;
        Unity_Divide_float(_Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float, _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float);
        float _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float;
        Unity_Clamp_float(_Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float, 0, 1, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float);
        float _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float;
        Unity_Lerp_float(_Split_1bfec6763d4b458398e36937b4114c29_A_4_Float, 0, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float);
        float3 _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3, (_Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float.xxx), _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3);
        float _Split_e22879e6c4574322ab21f6261a21bced_R_1_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[0];
        float _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[1];
        float _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[2];
        float _Split_e22879e6c4574322ab21f6261a21bced_A_4_Float = 0;
        float4 _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4;
        float3 _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3;
        float2 _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2;
        Unity_Combine_float(_Split_e22879e6c4574322ab21f6261a21bced_R_1_Float, _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float, _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3, _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2);
        float4 _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        Unity_Add_float4(_Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4);
        WindPoint_1 = _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float
        {
        };
        
        void SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(float3 Vector3_604F121F, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7F78DDD2, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float Vector1_5EFF6B1A, Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float IN, out float3 direction_1, out float strength_2)
        {
        float4 _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[0];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[1];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[2];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_A_4_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[3];
        float4 _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4;
        float3 _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3;
        float2 _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2;
        Unity_Combine_float(_Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float, 0, _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4, _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2);
        float3 _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3;
        Unity_Normalize_float3(_Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3);
        float4 _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_R_1_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[0];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_G_2_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[1];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_B_3_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[2];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[3];
        float3 _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, (_Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float.xxx), _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3);
        float _Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float = Vector1_9365F438;
        float _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float, 0, _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean);
        UnityTexture2D _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D = Texture2D_A3874DB9;
        float3 _Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3 = float3(1, 0, 0);
        float _Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float.xxx), _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3);
        float _Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float = Vector1_5EFF6B1A;
        float3 _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3);
        float3 _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3;
        Unity_Subtract_float3(_Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3, _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3, _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3);
        float _Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float = Vector1_6803B355;
        float3 _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3, (_Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float.xxx), _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3);
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[0];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_G_2_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[1];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[2];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_A_4_Float = 0;
        float4 _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4;
        float3 _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3;
        float2 _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2;
        Unity_Combine_float(_Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float, _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float, 0, 0, _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4, _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3, _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2);
          float4 _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.tex, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.samplerstate, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.GetTransformedUV(_Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_G_6_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_B_7_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_A_8_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.a;
        float _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float;
        Unity_Branch_float(_Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean, _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float, 0, _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float);
        float _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float;
        Unity_Power_float(_Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float, 2, _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float);
        float _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float = Vector1_F53C4B89;
        float _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float;
        Unity_Multiply_float_float(_Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float, _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float, _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float);
        float3 _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float.xxx), _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3);
        float _Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3, (_Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float.xxx), _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3);
        float3 _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3, _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3, _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3);
        float4 _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_e719665c40324e89a536d165d0427a68_R_1_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[0];
        float _Split_e719665c40324e89a536d165d0427a68_G_2_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[1];
        float _Split_e719665c40324e89a536d165d0427a68_B_3_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[2];
        float _Split_e719665c40324e89a536d165d0427a68_A_4_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[3];
        float _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Split_e719665c40324e89a536d165d0427a68_A_4_Float, 0, _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean);
        float _Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float = Vector1_2EC6D670;
        float _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float, 0, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean);
        float _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean;
        Unity_Or_float(_Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean, _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean);
        UnityTexture2D _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D = Texture2D_5BAC276D;
        float3 _Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Split_e719665c40324e89a536d165d0427a68_A_4_Float.xxx), _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3);
        float3 _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3);
        float3 _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3;
        Unity_Subtract_float3(_Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3, _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3, _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3);
        float _Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float = Vector1_B4470F9B;
        float3 _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3, (_Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float.xxx), _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3);
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[0];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_G_2_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[1];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[2];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_A_4_Float = 0;
        float4 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4;
        float3 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3;
        float2 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2;
        Unity_Combine_float(_Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float, _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float, 0, 0, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2);
          float4 _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.tex, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.samplerstate, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.GetTransformedUV(_Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_A_8_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.a;
        float4 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4;
        float3 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3;
        float2 _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2;
        Unity_Combine_float(_SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float, 0, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2);
        float3 _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3;
        Unity_Add_float3(_Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3);
        float3 _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3;
        Unity_Branch_float3(_Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean, _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3, float3(0, 0, 0), _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3);
        float _Property_9946d066804cc584a96830f8d35269cc_Out_0_Float = Vector1_2EC6D670;
        float3 _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3, (_Property_9946d066804cc584a96830f8d35269cc_Out_0_Float.xxx), _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3);
        float3 _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3;
        Unity_Add_float3(_Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3, _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3, _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3);
        float _Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float = Vector1_A2C4B4F4;
        float3 _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3, (_Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float.xxx), _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3);
        float _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float;
        Unity_Length_float3(_Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3, _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float);
        float _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float = Vector1_7F78DDD2;
        float _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float;
        Unity_Add_float(_Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float, _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float, _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float);
        float _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        Unity_Multiply_float_float(_Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float, 0.001, _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float);
        direction_1 = _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        strength_2 = _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Comparison_NotEqual_float(float A, float B, out float Out)
        {
            Out = A != B ? 1 : 0;
        }
        
        struct Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float
        {
        float3 WorldSpaceNormal;
        float4 VertexColor;
        };
        
        void SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(float Vector1_BCB03E1A, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7EE0F94A, float Boolean_527CB26E, float Vector1_DE1BF63A, float Vector1_7F78DDD2, float3 Vector3_DE8CC74D, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float4x4 Matrix4_0617b0bd42fc46ff90b1d55303a5477f, float4 Vector4_b44806ec67ca461fbcdf009dc6092cc3, Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float IN, out float3 vertex_1, out float3 normal_2)
        {
        float4 _Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3;
        _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3 = TransformObjectToWorld((_Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4.xyz).xyz);
        float _Distance_63631313b11e497cab6af82887a71903_Out_2_Float;
        Unity_Distance_float3(_Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3, float3(0, 0, 0), _Distance_63631313b11e497cab6af82887a71903_Out_2_Float);
        float _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_63631313b11e497cab6af82887a71903_Out_2_Float, 0.001, _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean);
        float3 _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3 = Vector3_C30D997B;
        float4 _Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3;
        _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3 = TransformObjectToWorld((_Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4.xyz).xyz);
        float _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float;
        Unity_Distance_float3(_Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, float3(0, 0, 0), _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float);
        float _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float, 1, _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean);
        float3 _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean, float3(5, 5, 5), _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3);
        float3 _Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3;
        _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3 = TransformObjectToWorld(_Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3.xyz);
        float _Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean = Boolean_527CB26E;
        float _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float = Vector1_7EE0F94A;
        float _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, 0, _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean);
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_R_1_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[0];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[1];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_B_3_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[2];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_A_4_Float = 0;
        float _Split_7a634ef857769683b2100876a36535a2_R_1_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[0];
        float _Split_7a634ef857769683b2100876a36535a2_G_2_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[1];
        float _Split_7a634ef857769683b2100876a36535a2_B_3_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[2];
        float _Split_7a634ef857769683b2100876a36535a2_A_4_Float = 0;
        float _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float;
        Unity_Subtract_float(_Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float, _Split_7a634ef857769683b2100876a36535a2_G_2_Float, _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float);
        float _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean;
        Unity_Comparison_Less_float(_Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float, _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean);
        float _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean;
        Unity_And_float(_Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean, _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean);
        float _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float = Vector1_A2C4B4F4;
        float _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float;
        Unity_Branch_float(_And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean, 1E-05, _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float);
        float _Split_43013162a81fc4889a1944f2a2b75f66_R_1_Float = IN.VertexColor[0];
        float _Split_43013162a81fc4889a1944f2a2b75f66_G_2_Float = IN.VertexColor[1];
        float _Split_43013162a81fc4889a1944f2a2b75f66_B_3_Float = IN.VertexColor[2];
        float _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float = IN.VertexColor[3];
        float _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float;
        Unity_Multiply_float_float(_Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float);
        float _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float;
        Unity_Branch_float(_Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float);
        float _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float = Vector1_7F78DDD2;
        UnityTexture2D _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D = Texture2D_5BAC276D;
        UnityTexture2D _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D = Texture2D_A3874DB9;
        float4 _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float;
        Unity_Length_float4(_Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float);
        float _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float, 0, _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean);
        float4 _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4;
        Unity_Branch_float4(_Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean, _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, float4(0, 0, 1, 1), _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4);
        float4x4 _Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4 = Matrix4_0617b0bd42fc46ff90b1d55303a5477f;
        float4 _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4 = Vector4_b44806ec67ca461fbcdf009dc6092cc3;
        Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float _WindNMPoints_a2cb25cd23df4791acc49df936a795bc;
        float4 _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4;
        SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(_Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4, SHADERGRAPH_OBJECT_POSITION, _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4);
        float4 _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4;
        Unity_Add_float4(_Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4);
        float _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float = Vector1_B4470F9B;
        float _Property_6b508d48a081548385021b27896c0622_Out_0_Float = Vector1_2EC6D670;
        float _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float = Vector1_9365F438;
        float _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float = Vector1_F53C4B89;
        float _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float = Vector1_6803B355;
        float _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float = Vector1_BCB03E1A;
        Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba;
        float3 _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3;
        float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float;
        SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float, _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float, _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D, _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4, _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float, _Property_6b508d48a081548385021b27896c0622_Out_0_Float, _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float, _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float, _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float, _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float);
        float3 _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3;
        Unity_CrossProduct_float(float3 (0, 1, 0), _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3);
        float _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean;
        Unity_Comparison_Equal_float((_CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3).x, 0, _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean);
        float3 _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean, float3(1E-06, 1E-06, 1E-06), _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3, _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3);
        float3 _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3;
        Unity_Normalize_float3(_Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3, _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3);
        float3 _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3);
        float _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float;
        Unity_DotProduct_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3, _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float);
        float3 _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, (_DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float.xxx), _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3);
        float3 _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3;
        Unity_Add_float3(_Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3);
        float3 _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3);
        float _Distance_702b068f612c7289a99272879da274ed_Out_2_Float;
        Unity_Distance_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Distance_702b068f612c7289a99272879da274ed_Out_2_Float);
        float _Property_f5c255b0f666358291012b78132d6593_Out_0_Float = Vector1_DE1BF63A;
        float _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float;
        Unity_Divide_float(_Distance_702b068f612c7289a99272879da274ed_Out_2_Float, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float);
        float _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float;
        Unity_Absolute_float(_Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float, _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float);
        float _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float = 1E-07;
        float _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float;
        Unity_Maximum_float(_Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float, _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float, _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float);
        float _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float;
        Unity_Divide_float(1, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float);
        float _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float;
        Unity_Power_float(_Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float);
        float _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float;
        Unity_Multiply_float_float(_WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float, _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float);
        float _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float;
        Unity_Cosine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float);
        float3 _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, (_Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float.xxx), _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3);
        float3 _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3;
        Unity_CrossProduct_float(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3);
        float _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float;
        Unity_Sine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float);
        float3 _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3;
        Unity_Multiply_float3_float3(_CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3, (_Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float.xxx), _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3);
        float3 _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3;
        Unity_Add_float3(_Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3, _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3);
        float3 _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3;
        Unity_Add_float3(_Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3, _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3);
        float3 _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3;
        _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3 = TransformWorldToObject(_Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3.xyz);
        float3 _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean, _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3, _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3, _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3);
        float3 _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3 = Vector3_DE8CC74D;
        float _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float;
        Unity_Length_float3(_Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float);
        float _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean;
        Unity_Comparison_NotEqual_float(_Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float, 0, _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean);
        float3 _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpaceNormal, _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3);
        float3 _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3, IN.WorldSpaceNormal, _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3);
        vertex_1 = _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        normal_2 = _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, float3(1E-07, 1E-07, 1E-07), _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3);
            float _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float = _Drag;
            float _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float = _HeightDrag;
            float _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float = _Stiffness;
            float _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float = _InitialBend;
            float4 _Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4 = _NewNormal;
            UnityTexture2D _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            UnityTexture2D _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            float4 _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            float _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float = WIND_SETTINGS_FlexNoiseScale;
            float _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float = WIND_SETTINGS_Turbulence;
            float _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float = WIND_SETTINGS_GustSpeed;
            float _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float = WIND_SETTINGS_GustScale;
            float _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            float4x4 _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4 = WIND_SETTINGS_Points;
            float4 _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4 = WIND_SETTINGS_Points_Radius;
            Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.WorldSpaceNormal = IN.WorldSpaceNormal;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.VertexColor = IN.VertexColor;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3;
            SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(IN.TimeParameters.x, _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3, _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float, _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float, 0, _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float, _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float, (_Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4.xyz), _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D, _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D, _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4, _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float, _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float, _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float, _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float, _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float, _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4, _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3);
            description.Position = _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[0];
            float _Split_23e0470490bacd83973312a833450913_G_2_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[1];
            float _Split_23e0470490bacd83973312a833450913_B_3_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[2];
            float _Split_23e0470490bacd83973312a833450913_A_4_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_R_1_Float, _Split_23e0470490bacd83973312a833450913_G_2_Float);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_B_3_Float, _Split_23e0470490bacd83973312a833450913_A_4_Float);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2) );
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.a;
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float = _AlphaCutoff;
            surface.Alpha = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.VertexColor =                                input.color;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 VertexColor;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
             float3 normalWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaCutoff;
        float4 _BaseColorMap_TexelSize;
        float4 _TilingOffset;
        float4 _HealthyColor;
        float4 _DryColor;
        float _ColorNoiseSpread;
        float4 _NormalMap_TexelSize;
        float _NormalScale;
        float _AORemapMax;
        float _SmoothnessRemapMax;
        float _Specular;
        float _Snow_Amount;
        float4 _SnowBaseColor;
        float4 _SnowMaskA_TexelSize;
        float _SnowMaskTreshold;
        float _InvertSnowMask;
        float4 _SnowBaseColorMap_TexelSize;
        float4 _SnowTilingOffset;
        float _SnowBlendHardness;
        float _SnowAORemapMax;
        float _SnowSmoothnessRemapMax;
        float _SnowSpecular;
        float _Stiffness;
        float _InitialBend;
        float _Drag;
        float _HeightDrag;
        float4 _NewNormal;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        float4x4 WIND_SETTINGS_Points;
        float4 WIND_SETTINGS_Points_Radius;
        TEXTURE2D(_BaseColorMap);
        SAMPLER(sampler_BaseColorMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_SnowMaskA);
        SAMPLER(sampler_SnowMaskA);
        TEXTURE2D(_SnowBaseColorMap);
        SAMPLER(sampler_SnowBaseColorMap);
        float WIND_SETTINGS_GustWorldScale;
        float WIND_SETTINGS_GustScale;
        float WIND_SETTINGS_GustSpeed;
        float WIND_SETTINGS_Turbulence;
        float WIND_SETTINGS_ShiverNoiseScale;
        float WIND_SETTINGS_FlexNoiseScale;
        float4 WIND_SETTINGS_WorldDirectionAndSpeed;
        TEXTURE2D(WIND_SETTINGS_TexGust);
        SAMPLER(samplerWIND_SETTINGS_TexGust);
        float4 WIND_SETTINGS_TexGust_TexelSize;
        TEXTURE2D(WIND_SETTINGS_TexNoise);
        SAMPLER(samplerWIND_SETTINGS_TexNoise);
        float4 WIND_SETTINGS_TexNoise_TexelSize;
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Length_float4(float4 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float
        {
        };
        
        void SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(float4x4 Matrix4_cb72bb33b7a84dfda97778a514f9b60f, float3 Vector3_90379ebf40aa468b8362f8d265f4f234, float4 Vector4_159bb4232f82428893101734a03e2a1e, Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float IN, out float4 WindPoint_1)
        {
        float3 _Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3 = Vector3_90379ebf40aa468b8362f8d265f4f234;
        float4x4 _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4 = Matrix4_cb72bb33b7a84dfda97778a514f9b60f;
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].r, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].r);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].g, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].g);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].b, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].b);
        float4 _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4 = float4(_Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[0].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[1].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[2].a, _Property_0ccfce542b5a45ac9b2982fe9b0a6f94_Out_0_Matrix4[3].a);
        float3 _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4.xyz), _Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3);
        float3 _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3);
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[0];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[1];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[2];
        float _Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M0_1_Vector4[3];
        float _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float;
        Unity_Length_float3(_Subtract_95daedfd69f34cb1bdd7e1efcdaa8440_Out_2_Vector3, _Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float);
        float4 _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4 = Vector4_159bb4232f82428893101734a03e2a1e;
        float _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[0];
        float _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[1];
        float _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[2];
        float _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float = _Property_95860f949fd1491fa36d8d177961e858_Out_0_Vector4[3];
        float _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float;
        Unity_Divide_float(_Length_dbcd47a2d3574d29bd8b12b1cdb0745a_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_R_1_Float, _Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float);
        float _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float;
        Unity_Clamp_float(_Divide_19f232d35a834d09895353590c5a8b5a_Out_2_Float, 0, 1, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float);
        float _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float;
        Unity_Lerp_float(_Split_d6e088f9ab90466583adc22ea79eb8cc_A_4_Float, 0, _Clamp_de1c41c0ba3341a2911a314981cf7a7a_Out_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float);
        float3 _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_bb19d5a0fb6544769cde736c8f2bcf83_Out_1_Vector3, (_Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float.xxx), _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3);
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[0];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[1];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float = _Multiply_d943bd948d9a4a6caab75f7761fc1c8d_Out_2_Vector3[2];
        float _Split_ef99a48850fe4f8f8e30e870c5e2ee09_A_4_Float = 0;
        float4 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4;
        float3 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3;
        float2 _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2;
        Unity_Combine_float(_Split_ef99a48850fe4f8f8e30e870c5e2ee09_R_1_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_G_2_Float, _Split_ef99a48850fe4f8f8e30e870c5e2ee09_B_3_Float, _Lerp_c895c7b6e0e94a65924bfc68c604c69e_Out_3_Float, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGB_5_Vector3, _Combine_d5dcc6adcb9e470599060ef2ff7859e6_RG_6_Vector2);
        float3 _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4.xyz), _Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3);
        float3 _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3);
        float _Split_8bbd5052350846968bf312362efd9f01_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[0];
        float _Split_8bbd5052350846968bf312362efd9f01_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[1];
        float _Split_8bbd5052350846968bf312362efd9f01_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[2];
        float _Split_8bbd5052350846968bf312362efd9f01_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M1_2_Vector4[3];
        float _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float;
        Unity_Length_float3(_Subtract_7197b65dd3b4425fb005b453c221c47d_Out_2_Vector3, _Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float);
        float _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float;
        Unity_Divide_float(_Length_25176aaf1e3847cb98d4410ff636b560_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_G_2_Float, _Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float);
        float _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float;
        Unity_Clamp_float(_Divide_d22ef2f383f94e6cbb0ec05ab2af98d0_Out_2_Float, 0, 1, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float);
        float _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float;
        Unity_Lerp_float(_Split_8bbd5052350846968bf312362efd9f01_A_4_Float, 0, _Clamp_ec5be35d1db54279a9e0dcdc65ab5420_Out_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float);
        float3 _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_c1cb58821e4547dcbdff92ca338be8b9_Out_1_Vector3, (_Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float.xxx), _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3);
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[0];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[1];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float = _Multiply_7bd4a79d1b37484996b73b3702618628_Out_2_Vector3[2];
        float _Split_ab8841795f594d3a90b87ac9fcc98d38_A_4_Float = 0;
        float4 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4;
        float3 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3;
        float2 _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2;
        Unity_Combine_float(_Split_ab8841795f594d3a90b87ac9fcc98d38_R_1_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_G_2_Float, _Split_ab8841795f594d3a90b87ac9fcc98d38_B_3_Float, _Lerp_8e9751e8ad6842b3a85b84b5b568aa94_Out_3_Float, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGB_5_Vector3, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RG_6_Vector2);
        float4 _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4;
        Unity_Add_float4(_Combine_d5dcc6adcb9e470599060ef2ff7859e6_RGBA_4_Vector4, _Combine_2c29d82626064a91a7c4bd08cce14cc9_RGBA_4_Vector4, _Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4);
        float3 _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4.xyz), _Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3);
        float3 _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3);
        float _Split_fa21a8022f944854903e06c07c6f079c_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[0];
        float _Split_fa21a8022f944854903e06c07c6f079c_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[1];
        float _Split_fa21a8022f944854903e06c07c6f079c_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[2];
        float _Split_fa21a8022f944854903e06c07c6f079c_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M2_3_Vector4[3];
        float _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float;
        Unity_Length_float3(_Subtract_f38c175f40644157a8c113a8fd7c038c_Out_2_Vector3, _Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float);
        float _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float;
        Unity_Divide_float(_Length_882dfabd3bce4dbebba98f988f897026_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_B_3_Float, _Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float);
        float _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float;
        Unity_Clamp_float(_Divide_997deb354f774bf5b27a9320f16d1a2f_Out_2_Float, 0, 1, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float);
        float _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float;
        Unity_Lerp_float(_Split_fa21a8022f944854903e06c07c6f079c_A_4_Float, 0, _Clamp_616aa25ccc4b4508957dfe01132d62f5_Out_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float);
        float3 _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_3e728f603e4844f0ada691bd863000b2_Out_1_Vector3, (_Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float.xxx), _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3);
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[0];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[1];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float = _Multiply_0399d775d57741a6b1308fce50cf7216_Out_2_Vector3[2];
        float _Split_6b9b5ad9f14a49b9bc49c718430617a8_A_4_Float = 0;
        float4 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4;
        float3 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3;
        float2 _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2;
        Unity_Combine_float(_Split_6b9b5ad9f14a49b9bc49c718430617a8_R_1_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_G_2_Float, _Split_6b9b5ad9f14a49b9bc49c718430617a8_B_3_Float, _Lerp_5d383299b2154039a2583aeed4883a88_Out_3_Float, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGB_5_Vector3, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RG_6_Vector2);
        float4 _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4;
        Unity_Add_float4(_Add_d1b72dc7a2294f8a86c0f5ae8ed9831b_Out_2_Vector4, _Combine_ef684d29a4b74f918ca38fa0cf6bea4d_RGBA_4_Vector4, _Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4);
        float3 _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3;
        Unity_Subtract_float3(_Property_8921fe8497db4536a36227f7cadb23db_Out_0_Vector3, (_MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4.xyz), _Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3);
        float3 _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3);
        float _Split_1bfec6763d4b458398e36937b4114c29_R_1_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[0];
        float _Split_1bfec6763d4b458398e36937b4114c29_G_2_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[1];
        float _Split_1bfec6763d4b458398e36937b4114c29_B_3_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[2];
        float _Split_1bfec6763d4b458398e36937b4114c29_A_4_Float = _MatrixSplit_09b25987ae114376bd1deca21c911b24_M3_4_Vector4[3];
        float _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float;
        Unity_Length_float3(_Subtract_59668fc0d64640d3926a84feeb6cc7d1_Out_2_Vector3, _Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float);
        float _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float;
        Unity_Divide_float(_Length_8a37c2eaad554eeb885a33813fcb99c7_Out_1_Float, _Split_3d7febba13614fefa50d13642a1d3f97_A_4_Float, _Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float);
        float _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float;
        Unity_Clamp_float(_Divide_1c33f266d32a43d69818e21acd21cc3f_Out_2_Float, 0, 1, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float);
        float _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float;
        Unity_Lerp_float(_Split_1bfec6763d4b458398e36937b4114c29_A_4_Float, 0, _Clamp_5ea5d4daacbb48b8a052eb0b94a0a46e_Out_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float);
        float3 _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_fb80659c0b1d4ba2b93a9c269e0cc737_Out_1_Vector3, (_Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float.xxx), _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3);
        float _Split_e22879e6c4574322ab21f6261a21bced_R_1_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[0];
        float _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[1];
        float _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float = _Multiply_67f2ec6d64334332906d5c564d5bb7c5_Out_2_Vector3[2];
        float _Split_e22879e6c4574322ab21f6261a21bced_A_4_Float = 0;
        float4 _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4;
        float3 _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3;
        float2 _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2;
        Unity_Combine_float(_Split_e22879e6c4574322ab21f6261a21bced_R_1_Float, _Split_e22879e6c4574322ab21f6261a21bced_G_2_Float, _Split_e22879e6c4574322ab21f6261a21bced_B_3_Float, _Lerp_b26221cb41884c75acf850b4f66b414b_Out_3_Float, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGB_5_Vector3, _Combine_872906644fc84c8c8286733edba75045_RG_6_Vector2);
        float4 _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        Unity_Add_float4(_Add_e88334a2c6bf40e197a79d333645fdb2_Out_2_Vector4, _Combine_872906644fc84c8c8286733edba75045_RGBA_4_Vector4, _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4);
        WindPoint_1 = _Add_710af6873aa744f6838904f22ad657e2_Out_2_Vector4;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float
        {
        };
        
        void SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(float3 Vector3_604F121F, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7F78DDD2, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float Vector1_5EFF6B1A, Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float IN, out float3 direction_1, out float strength_2)
        {
        float4 _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[0];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[1];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[2];
        float _Split_f4f701329abd45808bbd6b61ce26dcc8_A_4_Float = _Property_8eece987bcee5a8681353e05121e2390_Out_0_Vector4[3];
        float4 _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4;
        float3 _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3;
        float2 _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2;
        Unity_Combine_float(_Split_f4f701329abd45808bbd6b61ce26dcc8_R_1_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_G_2_Float, _Split_f4f701329abd45808bbd6b61ce26dcc8_B_3_Float, 0, _Combine_39060d5de038a58eb7462ba953e69739_RGBA_4_Vector4, _Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Combine_39060d5de038a58eb7462ba953e69739_RG_6_Vector2);
        float3 _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3;
        Unity_Normalize_float3(_Combine_39060d5de038a58eb7462ba953e69739_RGB_5_Vector3, _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3);
        float4 _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_R_1_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[0];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_G_2_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[1];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_B_3_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[2];
        float _Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float = _Property_2c43c4b554974085ab95cddc7214c1e2_Out_0_Vector4[3];
        float3 _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, (_Split_aeb4c57f09db718e9e14c3afd38465ae_A_4_Float.xxx), _Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3);
        float _Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float = Vector1_9365F438;
        float _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_72aef364136bb683b08145ce7a1b59a1_Out_0_Float, 0, _Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean);
        UnityTexture2D _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D = Texture2D_A3874DB9;
        float3 _Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3 = float3(1, 0, 0);
        float _Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Property_e53ae21dcf87e286b67de750a59275e7_Out_0_Float.xxx), _Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3);
        float _Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float = Vector1_5EFF6B1A;
        float3 _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_ea451e1902009f82a8b8044a4344575e_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3);
        float3 _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3;
        Unity_Subtract_float3(_Property_f0ff7954720d018395b7da89e2e2d761_Out_0_Vector3, _Multiply_ae858d83e1cea885a9aa0a01a1eef954_Out_2_Vector3, _Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3);
        float _Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float = Vector1_6803B355;
        float3 _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b8786cc4ca501c8ba745007b3c25c479_Out_2_Vector3, (_Property_7f2599afa6fc5b8394c8fb0389031122_Out_0_Float.xxx), _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3);
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[0];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_G_2_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[1];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float = _Multiply_4cc0cd205c36b88aa0411aa274ed6066_Out_2_Vector3[2];
        float _Split_f4466ebe24e7fa838f5735fb1210a3dd_A_4_Float = 0;
        float4 _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4;
        float3 _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3;
        float2 _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2;
        Unity_Combine_float(_Split_f4466ebe24e7fa838f5735fb1210a3dd_R_1_Float, _Split_f4466ebe24e7fa838f5735fb1210a3dd_B_3_Float, 0, 0, _Combine_0ac20ec517f076829f01b70d67c5af02_RGBA_4_Vector4, _Combine_0ac20ec517f076829f01b70d67c5af02_RGB_5_Vector3, _Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2);
          float4 _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.tex, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.samplerstate, _Property_acc8b35c6330408c905387353b2a48e7_Out_0_Texture2D.GetTransformedUV(_Combine_0ac20ec517f076829f01b70d67c5af02_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_G_6_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_B_7_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_A_8_Float = _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_RGBA_0_Vector4.a;
        float _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float;
        Unity_Branch_float(_Comparison_30e6d1ed5d13ea88ac1c717b4cf7f8b6_Out_2_Boolean, _SampleTexture2DLOD_230c200055ef6a87bc7e6561e4cc94a8_R_5_Float, 0, _Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float);
        float _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float;
        Unity_Power_float(_Branch_710124ae92f9d88bbca57ab4e6ca8632_Out_3_Float, 2, _Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float);
        float _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float = Vector1_F53C4B89;
        float _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float;
        Unity_Multiply_float_float(_Power_62722ebbb5d5b18cb4e41bb5612b4f78_Out_2_Float, _Property_9592cd5ab3f8628d995c1b79e8b0e51d_Out_0_Float, _Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float);
        float3 _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Multiply_a0cee471fa6b3f81a23110085b9f7901_Out_2_Float.xxx), _Normalize_a38510e5fae5478f897b4be58ae18930_Out_1_Vector3, _Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3);
        float _Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float = Vector1_9365F438;
        float3 _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_dbea21b5e949338ba29fe217546785bd_Out_2_Vector3, (_Property_7be270a4cb312f8ebbfba142f454b30d_Out_0_Float.xxx), _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3);
        float3 _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_43c9dfe8713d4584b24b33530801a1b9_Out_2_Vector3, _Multiply_57f8f9285ea3698a9db9febf3bb09729_Out_2_Vector3, _Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3);
        float4 _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Split_e719665c40324e89a536d165d0427a68_R_1_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[0];
        float _Split_e719665c40324e89a536d165d0427a68_G_2_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[1];
        float _Split_e719665c40324e89a536d165d0427a68_B_3_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[2];
        float _Split_e719665c40324e89a536d165d0427a68_A_4_Float = _Property_d76b4059b7077987b51af415dfa9bf4a_Out_0_Vector4[3];
        float _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Split_e719665c40324e89a536d165d0427a68_A_4_Float, 0, _Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean);
        float _Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float = Vector1_2EC6D670;
        float _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_295a45d224dd35829c1fc35a5ac74847_Out_0_Float, 0, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean);
        float _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean;
        Unity_Or_float(_Comparison_0e3f11398ddedf898ab9dfc4afb01674_Out_2_Boolean, _Comparison_d11455e909bf08898f06c88542bc8c3c_Out_2_Boolean, _Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean);
        UnityTexture2D _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D = Texture2D_5BAC276D;
        float3 _Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Vector3_a72856f64732461f9c308d03c9df6e06_Out_0_Vector3, (_Split_e719665c40324e89a536d165d0427a68_A_4_Float.xxx), _Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3);
        float3 _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_aabee1c217095b809f71af0c1a159e17_Out_2_Vector3, (_Property_bad047c8692ad38e91118ad73dfde8a1_Out_0_Float.xxx), _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3);
        float3 _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3;
        Unity_Subtract_float3(_Property_c82f40aba4b7f08db9a97aaccbe0e096_Out_0_Vector3, _Multiply_dc69447dd485178f8993dfedd03528df_Out_2_Vector3, _Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3);
        float _Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float = Vector1_B4470F9B;
        float3 _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_994d0a10f1b53f89a06319a456a703cb_Out_2_Vector3, (_Property_1ab0df57959c6986a0602bb0abfeaf58_Out_0_Float.xxx), _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3);
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[0];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_G_2_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[1];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float = _Multiply_9653c173603c7f88bb186f1bf4699302_Out_2_Vector3[2];
        float _Split_5ff678fef0fb61889da2a8288f7e7d15_A_4_Float = 0;
        float4 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4;
        float3 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3;
        float2 _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2;
        Unity_Combine_float(_Split_5ff678fef0fb61889da2a8288f7e7d15_R_1_Float, _Split_5ff678fef0fb61889da2a8288f7e7d15_B_3_Float, 0, 0, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGBA_4_Vector4, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RGB_5_Vector3, _Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2);
          float4 _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.tex, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.samplerstate, _Property_0c5a125604df6a8c882ffd08d9ab1eb1_Out_0_Texture2D.GetTransformedUV(_Combine_c6371d3dd2e6e588b17d15becfd9f41f_RG_6_Vector2), 3);
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_A_8_Float = _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_RGBA_0_Vector4.a;
        float4 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4;
        float3 _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3;
        float2 _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2;
        Unity_Combine_float(_SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_R_5_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_G_6_Float, _SampleTexture2DLOD_f9da942482343b84b60697d06f23721c_B_7_Float, 0, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGBA_4_Vector4, _Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, _Combine_3136fa3d24c46087969f5a3828ccbb98_RG_6_Vector2);
        float3 _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3;
        Unity_Add_float3(_Combine_3136fa3d24c46087969f5a3828ccbb98_RGB_5_Vector3, float3(-0.5, -0.5, -0.5), _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3);
        float3 _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3;
        Unity_Branch_float3(_Or_4341a0900c08ad87bd6a2225f3fa0566_Out_2_Boolean, _Add_ef7a0ab366477c878fbb735a918f7344_Out_2_Vector3, float3(0, 0, 0), _Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3);
        float _Property_9946d066804cc584a96830f8d35269cc_Out_0_Float = Vector1_2EC6D670;
        float3 _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Branch_740c68545077da8f8307f27b8c42ae4a_Out_3_Vector3, (_Property_9946d066804cc584a96830f8d35269cc_Out_0_Float.xxx), _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3);
        float3 _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3;
        Unity_Add_float3(_Add_02d5dc0d629dcd8f97caf80b6afb884c_Out_2_Vector3, _Multiply_96523fbe5cf67789a958918945aae4af_Out_2_Vector3, _Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3);
        float _Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float = Vector1_A2C4B4F4;
        float3 _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Add_36ab0a2baacbf685bfc47193bdd9ede0_Out_2_Vector3, (_Property_4ffb3356bdb9c78c815a6e7da47e7a34_Out_0_Float.xxx), _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3);
        float _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float;
        Unity_Length_float3(_Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3, _Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float);
        float _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float = Vector1_7F78DDD2;
        float _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float;
        Unity_Add_float(_Length_5a5f71c3d2510f898359c583d75db21b_Out_1_Float, _Property_51d6736452f5938caf6f83cdfc7df682_Out_0_Float, _Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float);
        float _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        Unity_Multiply_float_float(_Add_8b1ff99f4209848e94b032b984c39e3d_Out_2_Float, 0.001, _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float);
        direction_1 = _Multiply_5c06c9a8640ee88fa0516a7a341a0ea9_Out_2_Vector3;
        strength_2 = _Multiply_5a6d4212aae61b828d149e491e799600_Out_2_Float;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Comparison_NotEqual_float(float A, float B, out float Out)
        {
            Out = A != B ? 1 : 0;
        }
        
        struct Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float
        {
        float3 WorldSpaceNormal;
        float4 VertexColor;
        };
        
        void SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(float Vector1_BCB03E1A, float3 Vector3_C30D997B, float Vector1_A2C4B4F4, float Vector1_7EE0F94A, float Boolean_527CB26E, float Vector1_DE1BF63A, float Vector1_7F78DDD2, float3 Vector3_DE8CC74D, UnityTexture2D Texture2D_5BAC276D, UnityTexture2D Texture2D_A3874DB9, float4 Vector4_EBFF8CDE, float Vector1_B4470F9B, float Vector1_2EC6D670, float Vector1_9365F438, float Vector1_F53C4B89, float Vector1_6803B355, float4x4 Matrix4_0617b0bd42fc46ff90b1d55303a5477f, float4 Vector4_b44806ec67ca461fbcdf009dc6092cc3, Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float IN, out float3 vertex_1, out float3 normal_2)
        {
        float4 _Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3;
        _Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3 = TransformObjectToWorld((_Vector4_c313b0597c39438bb9a6bb83c46531a3_Out_0_Vector4.xyz).xyz);
        float _Distance_63631313b11e497cab6af82887a71903_Out_2_Float;
        Unity_Distance_float3(_Transform_75daaac96b6847df8f9cc10319e80ab2_Out_1_Vector3, float3(0, 0, 0), _Distance_63631313b11e497cab6af82887a71903_Out_2_Float);
        float _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_63631313b11e497cab6af82887a71903_Out_2_Float, 0.001, _Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean);
        float3 _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3 = Vector3_C30D997B;
        float4 _Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4 = float4(0, 0, 0, 1);
        float3 _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3;
        _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3 = TransformObjectToWorld((_Vector4_d213eb2790b34988809a251ff9c74c6b_Out_0_Vector4.xyz).xyz);
        float _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float;
        Unity_Distance_float3(_Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, float3(0, 0, 0), _Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float);
        float _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean;
        Unity_Comparison_Less_float(_Distance_1c61c2848b134e8a89dc80c4a957783f_Out_2_Float, 1, _Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean);
        float3 _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_f303132939384d919c59d7e0a2a9482a_Out_2_Boolean, float3(5, 5, 5), _Transform_4acbe76287b06c88a7e8fd7bf234e885_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3);
        float3 _Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3 = Vector3_C30D997B;
        float3 _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3;
        _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3 = TransformObjectToWorld(_Property_4a88ff8e6e6b2b84bb2818cf73a0af30_Out_0_Vector3.xyz);
        float _Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean = Boolean_527CB26E;
        float _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float = Vector1_7EE0F94A;
        float _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, 0, _Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean);
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_R_1_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[0];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[1];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_B_3_Float = _Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3[2];
        float _Split_05e55a8c1b8cf88f93cbafc67103b677_A_4_Float = 0;
        float _Split_7a634ef857769683b2100876a36535a2_R_1_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[0];
        float _Split_7a634ef857769683b2100876a36535a2_G_2_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[1];
        float _Split_7a634ef857769683b2100876a36535a2_B_3_Float = _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3[2];
        float _Split_7a634ef857769683b2100876a36535a2_A_4_Float = 0;
        float _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float;
        Unity_Subtract_float(_Split_05e55a8c1b8cf88f93cbafc67103b677_G_2_Float, _Split_7a634ef857769683b2100876a36535a2_G_2_Float, _Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float);
        float _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean;
        Unity_Comparison_Less_float(_Subtract_1a45a2cfb2029a85a28951578a3fde32_Out_2_Float, _Property_d2b118dbe85e878e9fec6b0b9baa39c4_Out_0_Float, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean);
        float _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean;
        Unity_And_float(_Comparison_5cee8efb01c62783a5e7b747d356c826_Out_2_Boolean, _Comparison_010cc8a451c9dc83967dac44b371c4df_Out_2_Boolean, _And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean);
        float _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float = Vector1_A2C4B4F4;
        float _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float;
        Unity_Branch_float(_And_555aa962b30d6f8fa39e7b48a39aed28_Out_2_Boolean, 1E-05, _Property_e5e59fcc565a8b80ac239ba87d1bcf74_Out_0_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float);
        float _Split_43013162a81fc4889a1944f2a2b75f66_R_1_Float = IN.VertexColor[0];
        float _Split_43013162a81fc4889a1944f2a2b75f66_G_2_Float = IN.VertexColor[1];
        float _Split_43013162a81fc4889a1944f2a2b75f66_B_3_Float = IN.VertexColor[2];
        float _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float = IN.VertexColor[3];
        float _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float;
        Unity_Multiply_float_float(_Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Split_43013162a81fc4889a1944f2a2b75f66_A_4_Float, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float);
        float _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float;
        Unity_Branch_float(_Property_dfda12e25f42bd808e65c99db447e176_Out_0_Boolean, _Multiply_9c96a1fd35427788a3d19f08eaffffef_Out_2_Float, _Branch_24dc0e5d7442ff84b33e0e63f143d905_Out_3_Float, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float);
        float _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float = Vector1_7F78DDD2;
        UnityTexture2D _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D = Texture2D_5BAC276D;
        UnityTexture2D _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D = Texture2D_A3874DB9;
        float4 _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4 = Vector4_EBFF8CDE;
        float _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float;
        Unity_Length_float4(_Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, _Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float);
        float _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Length_2deb60e58108481bbea09c2abd4f6360_Out_1_Float, 0, _Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean);
        float4 _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4;
        Unity_Branch_float4(_Comparison_e709f727d2ea465cb4118f3949b53fe3_Out_2_Boolean, _Property_deadd39786d94cb381d4d15213801177_Out_0_Vector4, float4(0, 0, 1, 1), _Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4);
        float4x4 _Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4 = Matrix4_0617b0bd42fc46ff90b1d55303a5477f;
        float4 _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4 = Vector4_b44806ec67ca461fbcdf009dc6092cc3;
        Bindings_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float _WindNMPoints_a2cb25cd23df4791acc49df936a795bc;
        float4 _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4;
        SG_WindNMPoints_920a3602244f68a4599f846c02f0a9c5_float(_Property_cb03cb298f0a47d4ae24d85f3c47db75_Out_0_Matrix4, SHADERGRAPH_OBJECT_POSITION, _Property_844e35a56a864617b521872c1cee398d_Out_0_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4);
        float4 _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4;
        Unity_Add_float4(_Branch_2e6bb4148fd446a993140d85024ed2fd_Out_3_Vector4, _WindNMPoints_a2cb25cd23df4791acc49df936a795bc_WindPoint_1_Vector4, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4);
        float _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float = Vector1_B4470F9B;
        float _Property_6b508d48a081548385021b27896c0622_Out_0_Float = Vector1_2EC6D670;
        float _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float = Vector1_9365F438;
        float _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float = Vector1_F53C4B89;
        float _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float = Vector1_6803B355;
        float _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float = Vector1_BCB03E1A;
        Bindings_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba;
        float3 _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3;
        float _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float;
        SG_WindNMCalculateNoShiver_eb6e21ce3f0928341b88e73dd9c62c10_float(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Branch_61b7d28e5f7d2981b63f0054ac12d71a_Out_3_Float, _Property_eaab26f57a13988a8a813ad0813c8570_Out_0_Float, _Property_0f02225ebee993849ea6be48328c0958_Out_0_Texture2D, _Property_fce16cc7b4fcf48097b94eb2d5f1b596_Out_0_Texture2D, _Add_a113107313614631a97405d9184f98a3_Out_2_Vector4, _Property_02c51f4c8a859f8f88433b435d4452f6_Out_0_Float, _Property_6b508d48a081548385021b27896c0622_Out_0_Float, _Property_d73fed4fb3c7b58d892364765a30498b_Out_0_Float, _Property_c3101a1b656cac858bfa11dbe7ebd268_Out_0_Float, _Property_c82c2ac458938d86bcc1aae3a58cc1dc_Out_0_Float, _Property_3f5330d8bec7c681ab9563aad03c7b89_Out_0_Float, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float);
        float3 _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3;
        Unity_CrossProduct_float(float3 (0, 1, 0), _WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_direction_1_Vector3, _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3);
        float _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean;
        Unity_Comparison_Equal_float((_CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3).x, 0, _Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean);
        float3 _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_5d396e98300c4552830ea915069fed2c_Out_2_Boolean, float3(1E-06, 1E-06, 1E-06), _CrossProduct_968274de232ac28180b15962e0cd7d4b_Out_2_Vector3, _Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3);
        float3 _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3;
        Unity_Normalize_float3(_Branch_0c9fa566a12947f2933cfaf6c994c646_Out_3_Vector3, _Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3);
        float3 _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3);
        float _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float;
        Unity_DotProduct_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_669f1473ae7e6e8595e30c93528623a2_Out_2_Vector3, _DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float);
        float3 _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, (_DotProduct_4ef6847a2d36df8cac2bf956cc3d32e0_Out_2_Float.xxx), _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3);
        float3 _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3;
        Unity_Add_float3(_Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Multiply_cde444a0de597b8282b544296776bd35_Out_2_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3);
        float3 _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3;
        Unity_Subtract_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3);
        float _Distance_702b068f612c7289a99272879da274ed_Out_2_Float;
        Unity_Distance_float3(_Transform_d324a56361d94f80935dd05df051490e_Out_1_Vector3, _Branch_5a1f8cde43c349699ace94eaebd101a4_Out_3_Vector3, _Distance_702b068f612c7289a99272879da274ed_Out_2_Float);
        float _Property_f5c255b0f666358291012b78132d6593_Out_0_Float = Vector1_DE1BF63A;
        float _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float;
        Unity_Divide_float(_Distance_702b068f612c7289a99272879da274ed_Out_2_Float, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float);
        float _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float;
        Unity_Absolute_float(_Divide_86ba32ec2efb64888f1b432782289403_Out_2_Float, _Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float);
        float _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float = 1E-07;
        float _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float;
        Unity_Maximum_float(_Absolute_b490a8463d40078e9f49eb1f255aba57_Out_1_Float, _Float_96534b09fc72da8da7bad6ebdb2b01ab_Out_0_Float, _Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float);
        float _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float;
        Unity_Divide_float(1, _Property_f5c255b0f666358291012b78132d6593_Out_0_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float);
        float _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float;
        Unity_Power_float(_Maximum_433c7134dae10d83ad9da03f0d30c4a0_Out_2_Float, _Divide_c45d79d6b2beea8293614db9809045fa_Out_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float);
        float _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float;
        Unity_Multiply_float_float(_WindNMCalculateNoShiver_ed5866aa196e188893da1307437132ba_strength_2_Float, _Power_aae331b5fcc0168da1590dbbc62504a4_Out_2_Float, _Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float);
        float _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float;
        Unity_Cosine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float);
        float3 _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, (_Cosine_210f67c5c8fb6c8aa417007f6255e22d_Out_1_Float.xxx), _Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3);
        float3 _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3;
        Unity_CrossProduct_float(_Normalize_9fd167d60aa1d1809fce8233690a3c5c_Out_1_Vector3, _Subtract_b285d42464e22a80adba2a34d1e89a02_Out_2_Vector3, _CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3);
        float _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float;
        Unity_Sine_float(_Multiply_13e65c7c3e1e8282bd06a4e2746f709f_Out_2_Float, _Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float);
        float3 _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3;
        Unity_Multiply_float3_float3(_CrossProduct_f5f50ca0805f7080b7fd20844a78afc1_Out_2_Vector3, (_Sine_419aece79cb6a485a9c3dec0b5b09f8c_Out_1_Float.xxx), _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3);
        float3 _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3;
        Unity_Add_float3(_Multiply_2f6dc881c414ee89a8fbbf0a5e0014eb_Out_2_Vector3, _Multiply_df4686bd34ab88839180248e49a9f266_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3);
        float3 _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3;
        Unity_Add_float3(_Add_148ed50f060f2a859e921addaad435fd_Out_2_Vector3, _Add_c14d4bcfa1ccf486a133715f088d8cf7_Out_2_Vector3, _Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3);
        float3 _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3;
        _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3 = TransformWorldToObject(_Add_d48375b91f961f89b468b522221fb6ee_Out_2_Vector3.xyz);
        float3 _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_33904aafc3c14044ae1f2e36a4314ede_Out_2_Boolean, _Property_81eb9f94925849acbb5edc41609b1281_Out_0_Vector3, _Transform_224c24cf5953f18a87e2088380250252_Out_1_Vector3, _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3);
        float3 _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3 = Vector3_DE8CC74D;
        float _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float;
        Unity_Length_float3(_Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float);
        float _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean;
        Unity_Comparison_NotEqual_float(_Length_8fac716cbfa5b983ba3cf14312642ac5_Out_1_Float, 0, _Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean);
        float3 _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpaceNormal, _Property_c5f622c3918154808caa04a0cff875eb_Out_0_Vector3, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3);
        float3 _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_17ad34828cc8b986ac7beaf8f6f2b799_Out_2_Boolean, _Multiply_d5e536621795b68bbc95bb5cc341dfcf_Out_2_Vector3, IN.WorldSpaceNormal, _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3);
        vertex_1 = _Branch_743061b5be8e40a2a6a4a883383944ff_Out_3_Vector3;
        normal_2 = _Branch_e504c7d39baa3084852f5cd5fd3d9d94_Out_3_Vector3;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, float3(1E-07, 1E-07, 1E-07), _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3);
            float _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float = _Drag;
            float _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float = _HeightDrag;
            float _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float = _Stiffness;
            float _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float = _InitialBend;
            float4 _Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4 = _NewNormal;
            UnityTexture2D _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexNoise);
            UnityTexture2D _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(WIND_SETTINGS_TexGust);
            float4 _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4 = WIND_SETTINGS_WorldDirectionAndSpeed;
            float _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float = WIND_SETTINGS_FlexNoiseScale;
            float _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float = WIND_SETTINGS_Turbulence;
            float _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float = WIND_SETTINGS_GustSpeed;
            float _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float = WIND_SETTINGS_GustScale;
            float _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float = WIND_SETTINGS_GustWorldScale;
            float4x4 _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4 = WIND_SETTINGS_Points;
            float4 _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4 = WIND_SETTINGS_Points_Radius;
            Bindings_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.WorldSpaceNormal = IN.WorldSpaceNormal;
            _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce.VertexColor = IN.VertexColor;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            float3 _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3;
            SG_WindNMNoShiver_76b4d01171ac5564a83e72b2b046c0cf_float(IN.TimeParameters.x, _Add_f075a68d91eb45cf874ab4b8f1c0340d_Out_2_Vector3, _Property_3132eefeb5764881932acfe7cbbe43da_Out_0_Float, _Property_2fca2e74fca4e687b1dad5ca1dd01861_Out_0_Float, 0, _Property_c0641e3128dbfd8e8d8ab64e62a8e4dc_Out_0_Float, _Property_fb0fa6c3ab523d8189451c5b3d455074_Out_0_Float, (_Property_508c45c7ee31508d964c733b4d4748c4_Out_0_Vector4.xyz), _Property_4bb644f07fc1a88da005b4e20d70df99_Out_0_Texture2D, _Property_8305506c728c518a8f6cb5fc1efd99d8_Out_0_Texture2D, _Property_0f275fcb6057598ba324ce01eb0e05a4_Out_0_Vector4, _Property_88543158168b67838e88464a9c3ca5a0_Out_0_Float, _Property_af9c1d6ece569186acc43591263766dd_Out_0_Float, _Property_05dafb868b119e83a7cc83a7c6b960b7_Out_0_Float, _Property_9113b88568228b82b637c2b643cbf304_Out_0_Float, _Property_6c4a13e818b3fc80912f3cfde59a9ef1_Out_0_Float, _Property_03c0eb046789422eb25c8a92ceedd1fb_Out_0_Matrix4, _Property_ecbbbcf3ac354f519d0dbe1f71260be1_Out_0_Vector4, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3, _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_normal_2_Vector3);
            description.Position = _WindNMNoShiver_a324687cfe7d928c85fd943c365362ce_vertex_1_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColorMap);
            float4 _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4 = _TilingOffset;
            float _Split_23e0470490bacd83973312a833450913_R_1_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[0];
            float _Split_23e0470490bacd83973312a833450913_G_2_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[1];
            float _Split_23e0470490bacd83973312a833450913_B_3_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[2];
            float _Split_23e0470490bacd83973312a833450913_A_4_Float = _Property_8cc279b5e4536382a4fa841bf310b313_Out_0_Vector4[3];
            float2 _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_R_1_Float, _Split_23e0470490bacd83973312a833450913_G_2_Float);
            float2 _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2 = float2(_Split_23e0470490bacd83973312a833450913_B_3_Float, _Split_23e0470490bacd83973312a833450913_A_4_Float);
            float2 _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0de387e4cfa4ed8c9fa77e9588b40255_Out_0_Vector2, _Vector2_2354257036e6768bae09698305a9fb6e_Out_0_Vector2, _TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2);
            float4 _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.tex, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.samplerstate, _Property_28e5c5ca28dcd6869854e318bc013ef2_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2) );
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_R_4_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.r;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_G_5_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.g;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_B_6_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.b;
            float _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4.a;
            float4 _Property_0457e5435408618697b5c5387038cff3_Out_0_Vector4 = _DryColor;
            float4 _Property_b618307b57ad3380b3914a2093b7f159_Out_0_Vector4 = _HealthyColor;
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_81389cebf3b81c8d9f0ae054eef08ad1_A_4_Float = 0;
            float2 _Vector2_a6e9136948d4528182e57d0748ed446b_Out_0_Vector2 = float2(_Split_81389cebf3b81c8d9f0ae054eef08ad1_R_1_Float, _Split_81389cebf3b81c8d9f0ae054eef08ad1_B_3_Float);
            float _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0_Float = _ColorNoiseSpread;
            float _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float(_Vector2_a6e9136948d4528182e57d0748ed446b_Out_0_Vector2, _Property_63bba8fdb472568e80aa771e766d9e3e_Out_0_Float, _SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2_Float);
            float4 _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3_Vector4;
            Unity_Lerp_float4(_Property_0457e5435408618697b5c5387038cff3_Out_0_Vector4, _Property_b618307b57ad3380b3914a2093b7f159_Out_0_Vector4, (_SimpleNoise_8a2d62a9f80ab1879c416f6e431ff156_Out_2_Float.xxxx), _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3_Vector4);
            float4 _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_RGBA_0_Vector4, _Lerp_a67ad91996e62b82994289da25b5b44d_Out_3_Vector4, _Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2_Vector4);
            UnityTexture2D _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_SnowBaseColorMap);
            float4 _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4 = _SnowTilingOffset;
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_R_1_Float = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4[0];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2_Float = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4[1];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_B_3_Float = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4[2];
            float _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4_Float = _Property_4474e372eb076f8685f8ceefcf6ef8f5_Out_0_Vector4[3];
            float2 _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0_Vector2 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_R_1_Float, _Split_14e6723bd1904e8f96ff12fc464e9a72_G_2_Float);
            float2 _Vector2_f1756f1084099581aefb8f7868e45176_Out_0_Vector2 = float2(_Split_14e6723bd1904e8f96ff12fc464e9a72_B_3_Float, _Split_14e6723bd1904e8f96ff12fc464e9a72_A_4_Float);
            float2 _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_0d6e09e1cfc78a8fa3ee1886df99a259_Out_0_Vector2, _Vector2_f1756f1084099581aefb8f7868e45176_Out_0_Vector2, _TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3_Vector2);
            float4 _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0_Texture2D.tex, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0_Texture2D.samplerstate, _Property_4614e5a8ff22ba8ca469e56d846fe385_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3_Vector2) );
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_R_4_Float = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4.r;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_G_5_Float = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4.g;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_B_6_Float = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4.b;
            float _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_A_7_Float = _SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4.a;
            float4 _Property_6fad1bea7f828d879b30d1995855944c_Out_0_Vector4 = _SnowBaseColor;
            float4 _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f0b0c797d3d94687a778e96a694306d3_RGBA_0_Vector4, _Property_6fad1bea7f828d879b30d1995855944c_Out_0_Vector4, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2_Vector4);
            float _Property_7dfafd311568c28ea4498c71c218169e_Out_0_Float = _Snow_Amount;
            UnityTexture2D _Property_850aded96259f88b9f084f496dd42683_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_850aded96259f88b9f084f496dd42683_Out_0_Texture2D.tex, _Property_850aded96259f88b9f084f496dd42683_Out_0_Texture2D.samplerstate, _Property_850aded96259f88b9f084f496dd42683_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_630f6042dacc1f82832d16add7c24cd3_Out_3_Vector2) );
            _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4);
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_R_4_Float = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.r;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_G_5_Float = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.g;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_B_6_Float = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.b;
            float _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_A_7_Float = _SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.a;
            float _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0_Float = _NormalScale;
            float3 _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2_Vector3;
            Unity_NormalStrength_float((_SampleTexture2D_30be3162d458908ea611f8eb8821e00a_RGBA_0_Vector4.xyz), _Property_55e60d1aa21dd88d9df2ec1010b62a93_Out_0_Float, _NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2_Vector3);
            float _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0_Float = _SnowBlendHardness;
            float3 _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2_Vector3;
            Unity_NormalStrength_float(_NormalStrength_7c57e8a8e204f58e9e9e1b94e40076a3_Out_2_Vector3, _Property_a363ba3b9273ab868cd715de1da71fa7_Out_0_Float, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2_Vector3);
            float3 _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3;
            Unity_NormalBlend_float(IN.WorldSpaceNormal, _NormalStrength_0497263cd421a88c9038508a005b2a9f_Out_2_Vector3, _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3);
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_R_1_Float = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3[0];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2_Float = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3[1];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_B_3_Float = _NormalBlend_76f54eeaac4571899759c13924d022e3_Out_2_Vector3[2];
            float _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_A_4_Float = 0;
            float _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2_Float;
            Unity_Multiply_float_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0_Float, _Split_7e1f1ae3b4baed8f8fd08ae6f7ff7945_G_2_Float, _Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2_Float);
            float _Clamp_55159c695da3ec84995296ffa5245953_Out_3_Float;
            Unity_Clamp_float(_Multiply_c7fc597f48108d88a613f92afe5cb253_Out_2_Float, 0, 1, _Clamp_55159c695da3ec84995296ffa5245953_Out_3_Float);
            float _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1_Float;
            Unity_Saturate_float(_Clamp_55159c695da3ec84995296ffa5245953_Out_3_Float, _Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1_Float);
            float _Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0_Boolean = _InvertSnowMask;
            UnityTexture2D _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_SnowMaskA);
            float4 _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0_Texture2D.tex, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0_Texture2D.samplerstate, _Property_4dfc46b157228d8e8d2d8dcf43d6773a_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_db88fe78e6489a859b6acb53cd98f6c5_Out_3_Vector2) );
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_R_4_Float = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4.r;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_G_5_Float = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4.g;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_B_6_Float = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4.b;
            float _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7_Float = _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_RGBA_0_Vector4.a;
            float _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1_Float;
            Unity_OneMinus_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7_Float, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1_Float);
            float _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3_Float;
            Unity_Branch_float(_Property_4d26f6b6fa7bb380b3c7b3fd6bf9f06d_Out_0_Boolean, _OneMinus_1b8f6a39aaa4c087bca8b637d76e0382_Out_1_Float, _SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7_Float, _Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3_Float);
            float _Property_53155f8b6e17528993532384c69b45cf_Out_0_Float = _SnowMaskTreshold;
            float _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2_Float;
            Unity_Multiply_float_float(_Branch_265dea70ef25dd8ca64d01bf91f69bef_Out_3_Float, _Property_53155f8b6e17528993532384c69b45cf_Out_0_Float, _Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2_Float);
            float _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3_Float;
            Unity_Clamp_float(_Multiply_7c23e0e725920e8590fa3c0232d546ac_Out_2_Float, 0, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3_Float);
            float _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3_Float;
            Unity_Lerp_float(_Saturate_89485b0cc7bb62878e5f005f1352e3c3_Out_1_Float, 1, _Clamp_f66c58a9dbeb7b84a381cb438aceaab1_Out_3_Float, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3_Float);
            float _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1_Float;
            Unity_Absolute_float(_SampleTexture2D_b120d08b5652ba83935ba3cb891d8935_A_7_Float, _Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1_Float);
            float _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3_Float;
            Unity_Clamp_float(_Property_7dfafd311568c28ea4498c71c218169e_Out_0_Float, 0.1, 2, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3_Float);
            float _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2_Float;
            Unity_Divide_float(_Property_53155f8b6e17528993532384c69b45cf_Out_0_Float, _Clamp_6288c5ac6b1d408fa1ca45acf7a232d3_Out_3_Float, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2_Float);
            float _Power_a92be574722606868c966ca3ced4bc87_Out_2_Float;
            Unity_Power_float(_Absolute_bb7561a615c2058e8f1ce4cfea4f8926_Out_1_Float, _Divide_c1beaf5b64e09f87a42fff4efea9aaac_Out_2_Float, _Power_a92be574722606868c966ca3ced4bc87_Out_2_Float);
            float _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3_Float;
            Unity_Lerp_float(0, _Lerp_2f643edf305b7d809ad5c3eee0ab724a_Out_3_Float, _Power_a92be574722606868c966ca3ced4bc87_Out_2_Float, _Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3_Float);
            float4 _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_2a5a6b7f712e578090699be9a9de5b63_Out_2_Vector4, _Multiply_825768ebffaa4e8bb346ffdd8066f679_Out_2_Vector4, (_Lerp_6f1ab1aa1f10c88eb36468d32bc87af4_Out_3_Float.xxxx), _Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3_Vector4);
            float _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float = _AlphaCutoff;
            surface.BaseColor = (_Lerp_86ea92c4d999e18bb6d2f24db9c6cd57_Out_3_Vector4.xyz);
            surface.Alpha = _SampleTexture2D_ede9f1f2fa30c984b3faeb8d64316a3b_A_7_Float;
            surface.AlphaClipThreshold = _Property_e061df8ff6536c88a5c285f610e9e304_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.VertexColor =                                input.color;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}