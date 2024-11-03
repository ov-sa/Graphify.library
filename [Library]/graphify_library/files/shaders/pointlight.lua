function getPointLightFX()
    return [[
        // Native //
        float4x4 gProjectionMainScene : PROJECTION_MAIN_SCENE;
        float4x4 gViewMainScene : VIEW_MAIN_SCENE;
        int gFogEnable <string renderState="FOGENABLE";>;
        float4 gFogColor <string renderState="FOGCOLOR";>;
        float gFogStart <string renderState="FOGSTART";>;
        float gFogEnd <string renderState="FOGEND";>;
        static const float PI = 3.14159265f;
        int CUSTOMFLAGS <string skipUnusedParameters = "yes";>;
        texture layerRT;
        texture gDepthBuffer : DEPTHBUFFER;


        // Variables //
        float3 lightPosition = 0;
        float lightAttenuation = 1;
        float lightAttenuationPower = 2;
        float2 lightFadeDist = float2(250, 150);
        int lightSubdivUnit = 1;
        float lightTexBlend = 1;
        float2 lightHalfPixel = float2(0.000625, 0.00083);
        float2 lightPixelSize = float2(0.00125, 0.00166);


        // Inputs //
        sampler SamplerDepth = sampler_state {
            Texture = gDepthBuffer;
            AddressU = Clamp;
            AddressV = Clamp;
            MinFilter = Point;
            MagFilter = Point;
            MipFilter = None;
            MaxMipLevel = 0;
            MipMapLodBias = 0;
        };
        sampler SamplerLayer = sampler_state {
            Texture = layerRT;
            AddressU = Mirror;
            AddressV = Mirror;
            MinFilter = Linear;
            MagFilter = Linear;
            MipFilter = None;
            MaxMipLevel = 0;
            MipMapLodBias = 0;
        };
        struct VSInput {
            float3 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
            float4 Diffuse : COLOR0;
        };
        struct PSInput {
            float4 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
            float DistFade : TEXCOORD1;
            float4 ProjCoord : TEXCOORD2;
            float3 WorldPos : TEXCOORD3;
            float4 UvToView : TEXCOORD4;
            float4 Diffuse : COLOR0;
        };


        // Utils //
        float4x4 CreateMatrix(float3 pos, float3 rot) {
            float4x4 eleMatrix = {
                float4(cos(rot.z)*cos(rot.y) - sin(rot.z)*sin(rot.x)*sin(rot.y), cos(rot.y)*sin(rot.z) + cos(rot.z)*sin(rot.x)*sin(rot.y), -cos(rot.x)*sin(rot.y), 0),
                float4(-cos(rot.x)*sin(rot.z), cos(rot.z)*cos(rot.x), sin(rot.x), 0),
                float4(cos(rot.z)*sin(rot.y) + cos(rot.y)*sin(rot.z)*sin(rot.x), sin(rot.z)*sin(rot.y) - cos(rot.z)*cos(rot.y)*sin(rot.x), cos(rot.x)*cos(rot.y), 0),
                float4(pos.x, pos.y, pos.z, 1)
            };
            return eleMatrix;
        }

        float4x4 InverseMatrix(float4x4 input) {
            #define minor(a,b,c) determinant(float3x3(input.a, input.b, input.c))
            float4x4 cofactors = float4x4(
                minor(_22_23_24, _32_33_34, _42_43_44), 
                -minor(_21_23_24, _31_33_34, _41_43_44),
                minor(_21_22_24, _31_32_34, _41_42_44),
                -minor(_21_22_23, _31_32_33, _41_42_43),
                -minor(_12_13_14, _32_33_34, _42_43_44),
                minor(_11_13_14, _31_33_34, _41_43_44),
                -minor(_11_12_14, _31_32_34, _41_42_44),
                minor(_11_12_13, _31_32_33, _41_42_43),
                minor(_12_13_14, _22_23_24, _42_43_44),
                -minor(_11_13_14, _21_23_24, _41_43_44),
                minor(_11_12_14, _21_22_24, _41_42_44),
                -minor(_11_12_13, _21_22_23, _41_42_43),
                -minor(_12_13_14, _22_23_24, _32_33_34),
                minor(_11_13_14, _21_23_24, _31_33_34),
                -minor(_11_12_14, _21_22_24, _31_32_34),
                minor(_11_12_13, _21_22_23, _31_32_33)
            );
            #undef minor
            return transpose(cofactors)/determinant(input);
        }

        float FetchDepthBufferValue(float2 uv) {
            float4 texel = tex2D(SamplerDepth, uv);
            #if IS_DEPTHBUFFER_RAWZ
                float3 rawval = floor(255.0*texel.arg + 0.5);
                float3 valueScaler = float3(0.996093809371817670572857294849, 0.0038909914428586627756752238080039, 1.5199185323666651467481343000015e-5);
                return dot(rawval, valueScaler/255.0);
            #else
                return texel.r;
            #endif
        }

        float Linearize(float posZ) { return gProjectionMainScene[3][2]/(posZ - gProjectionMainScene[2][2]); }
        float InvLinearize(float posZ) { return (gProjectionMainScene[3][2]/posZ) + gProjectionMainScene[2][2]; }
        float3 GetPositionFromDepth(float2 coords, float4 uvToView) { return float3(coords.x*uvToView.x + uvToView.z, (1 - coords.y)*uvToView.y + uvToView.w, 1.0)*Linearize(FetchDepthBufferValue(coords.xy)); }
        float3 GetPositionFromDepthMatrix(float2 coords, float4x4 g_matInvProjection) {
            float4 vProjectedPos = float4(coords.x*2 - 1, (1 - coords.y)*2 - 1, FetchDepthBufferValue(coords), 1.0f);
            float4 vPositionVS = mul(vProjectedPos, g_matInvProjection);  
            return vPositionVS.xyz/vPositionVS.w;  
        }

        float3 getSphereVertexPosition(float3 inPosition, float3 scale) {
            float3 outPosition;
            outPosition.z = cos(2*inPosition.x*PI)*0.5;
            outPosition.x = sin(2*inPosition.x*PI)*0.5;
            outPosition.xz *= cos(inPosition.y*PI);
            outPosition.y = sin(inPosition.y*PI)*0.5;
            return outPosition*scale;
        }

        bool GetZEnable() {
            float4x4 sViewInverse = InverseMatrix(gViewMainScene);
            if ((length(sViewInverse[3].xyz - lightPosition) - lightAttenuation*2) < 0) return false;
            else return true;
        }

        int GetCullMode() {
            if (lightSubdivUnit >= 2) {
                float4x4 sViewInverse = InverseMatrix(gViewMainScene);
                if ((length(sViewInverse[3].xyz - lightPosition) - lightAttenuation*1.5) < 0) return 3;
                else return 2;
            }
            else return 2;
        }


        // Handlers //
        PSInput VSHandler_1(VSInput VS) {
            PSInput PS = (PSInput)0;
            VS.Position.xyz = float3(- 0.5 + VS.TexCoord.xy, 0);
            if (lightSubdivUnit >= 2) {
                float sphRadius = 1/cos(radians(180/lightSubdivUnit));
                float3 scaleNorm = normalize(lightAttenuation*sphRadius);
                float3 resultPos = getSphereVertexPosition(VS.Position.xyz, scaleNorm);
                VS.Position.xyz = resultPos*length(2*lightAttenuation*sphRadius);
            }
            else VS.Position.xy *= lightAttenuation*2.5;
            VS.TexCoord.x = 1 - VS.TexCoord.x;
            float4x4 sWorld = CreateMatrix(lightPosition, 0);
            float nearClip = - gProjectionMainScene[3][2]/gProjectionMainScene[2][2];
            float farClip = gProjectionMainScene[3][2]/(1 - gProjectionMainScene[2][2]);
            float4x4 sViewInverse = InverseMatrix(gViewMainScene);
            float4x4 sProjection = gProjectionMainScene;
            float objDist = distance(sViewInverse[3].xyz, lightPosition) + (lightAttenuation*0.5);
            float farPlaneAlt = max(farClip, objDist);
            sProjection[2].z = farPlaneAlt/(farPlaneAlt - nearClip);
            sProjection[3].z =  - sProjection[2].z*nearClip;
            float4 wPos = mul(float4(VS.Position, 1), sWorld);
            float4 vPos = 0;
            float4x4 sWorldView = mul(sWorld, gViewMainScene);
            if (lightSubdivUnit >= 2) vPos = mul(wPos, gViewMainScene);
            else vPos = float4(VS.Position.xyz + sWorldView[3].xyz, 1);
            PS.Position = mul(vPos, gProjectionMainScene);
            if (lightSubdivUnit < 2) {
                float depthBias = max(0, InvLinearize(vPos.z) - InvLinearize(vPos.z - 2*lightAttenuation));
                PS.Position.z -= depthBias*PS.Position.w;
            }
            float DistFromCam = vPos.z/vPos.w;
            float2 DistFade = float2(max(0.3, min(lightFadeDist.x, farClip) - lightAttenuation*0.5), max(0, min(lightFadeDist.y, gFogStart) - lightAttenuation*0.5));
            PS.DistFade = saturate((DistFromCam - DistFade.x)/(DistFade.y - DistFade.x));
            PS.TexCoord = VS.TexCoord;
            PS.Diffuse = VS.Diffuse;
            float projectedX = (0.5*(PS.Position.w + PS.Position.x));
            float projectedY = (0.5*(PS.Position.w - PS.Position.y));
            PS.ProjCoord.xyz = float3(projectedX, projectedY, PS.Position.w);
            PS.ProjCoord.w = dot(sViewInverse[2].xyz, lightPosition - sViewInverse[3].xyz) + 2*lightAttenuation;
            float2 uvToViewADD = - 1/float2(gProjectionMainScene[0][0], gProjectionMainScene[1][1]);	
            float2 uvToViewMUL = -2.0*uvToViewADD.xy;
            PS.UvToView = float4(uvToViewMUL, uvToViewADD);
            return PS;
        }

        PSInput VSHandler_2(VSInput VS) {
            PSInput PS = (PSInput)0;
            VS.Position.xyz = float3(- 0.5 + VS.TexCoord.xy, 0);
            VS.Position.xy *= lightAttenuation*2.5;
            VS.TexCoord.x = 1 - VS.TexCoord.x;
            float4x4 sWorld = CreateMatrix(lightPosition, 0);
            float4x4 sWorldView = mul(sWorld, gViewMainScene);
            float4 vPos = float4(VS.Position.xyz + sWorldView[3].xyz, 1);
            PS.WorldPos = VS.Position.xyz + sWorld[3].xyz;	
            PS.Position = mul(float4(vPos.xyz, 1), gProjectionMainScene);
            float nearClip = - gProjectionMainScene[3][2]/gProjectionMainScene[2][2];
            float farClip = (gProjectionMainScene[3][2]/(1 - gProjectionMainScene[2][2]));
            float4x4 sViewInverse = InverseMatrix(gViewMainScene);
            float DistFromCam = vPos.z/vPos.w;
            float2 DistFade = float2(max(0.3, min(lightFadeDist.x, farClip) - lightAttenuation*0.5), max(0, min(lightFadeDist.y, gFogStart) - lightAttenuation*0.5));
            PS.DistFade = saturate((DistFromCam - DistFade.x)/(DistFade.y - DistFade.x));
            PS.TexCoord = VS.TexCoord;
            PS.Diffuse = VS.Diffuse;
            return PS;
        }

        float4 PSHandler_1(PSInput PS) : COLOR0 {
            float2 TexProj = PS.ProjCoord.xy/PS.ProjCoord.z;
            TexProj += lightHalfPixel.xy;
            float bufferValue = FetchDepthBufferValue(TexProj);
            float linearDepth = Linearize(bufferValue);
            if (bufferValue > 0.99999f) return 0;
            if ((linearDepth - PS.ProjCoord.w) > 0) return 0;
            float4x4 sViewInverse = InverseMatrix(gViewMainScene);
            float3 viewPos = GetPositionFromDepth(TexProj.xy, PS.UvToView);
            float3 worldPos = mul(float4(viewPos.xyz, 1),  sViewInverse).xyz;
            float fDistance = distance(lightPosition, worldPos);
            float fAttenuation = 1 - saturate(fDistance/lightAttenuation);
            fAttenuation = pow(fAttenuation, lightAttenuationPower);
            float4 texColor = tex2D(SamplerLayer, TexProj.xy);
            texColor.rgb = texColor.rgb*lightTexBlend + (1 - lightTexBlend);
            texColor.rgb *= texColor.a;
            float4 finalColor = texColor*PS.Diffuse;
            finalColor.rgb *= saturate(fAttenuation);
            finalColor.a *= saturate(PS.DistFade);
            return finalColor;
        }

        float4 PSHandler_2(PSInput PS) : COLOR0 {
            float fDistance = distance(lightPosition, PS.WorldPos);
            float fAttenuation = 1 - saturate(fDistance/lightAttenuation);
            fAttenuation = pow(fAttenuation, lightAttenuationPower);
            float4 finalColor = PS.Diffuse;
            finalColor.rgb *= saturate(fAttenuation);
            finalColor.a *= saturate(PS.DistFade);
            return finalColor;
        }


        // Techniques //
        technique PointLight_1 {
            pass P0 {
                ZEnable = GetZEnable();
                ZFunc = LessEqual;
                ZWriteEnable = false;
                CullMode = GetCullMode();
                ShadeMode = Gouraud;
                AlphaBlendEnable = true;
                SrcBlend = SrcAlpha;
                DestBlend = One;
                AlphaTestEnable = true;
                AlphaRef = 1;
                AlphaFunc = GreaterEqual;
                Lighting = false;
                FogEnable = false;
                VertexShader = compile vs_3_0 VSHandler_1();
                PixelShader = compile ps_3_0 PSHandler_1();
            }
        }

        technique PointLight_2 {
            pass P0 {
                ZEnable = true;
                ZFunc = LessEqual;
                ZWriteEnable = false;
                CullMode = 2;
                ShadeMode = Gouraud;
                AlphaBlendEnable = true;
                SrcBlend = SrcAlpha;
                DestBlend = One;
                AlphaTestEnable = true;
                AlphaRef = 1;
                AlphaFunc = GreaterEqual;
                Lighting = false;
                FogEnable = false;
                VertexShader = compile vs_2_0 VSHandler_2();
                PixelShader = compile ps_2_0 PSHandler_2();
            }
        }

        technique fallback {
            pass P0 {}
        }
    ]]
end