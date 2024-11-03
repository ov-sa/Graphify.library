function getZBufferFX()
    return [[
        // Native //
        float2 fViewportSize = float2(800, 600);
        float2 fViewportScale = 1;
        float2 fViewportPos = 0;
        int gCapsMaxAnisotropy <string deviceCaps="MaxAnisotropy";>;
        int CUSTOMFLAGS <string skipUnusedParameters = "yes";>;
        texture gDepthBuffer : DEPTHBUFFER;


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
        struct VSInput {
            float3 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
        };
        struct PSInput {
            float4 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
        };
        struct Pixel {
            float4 World : COLOR0;
            float Depth : DEPTH;      
        };


        // Utils //
        float4x4 makeTranslation(float3 trans) {
            return float4x4(
                1,  0,  0,  0,
                0,  1,  0,  0,
                0,  0,  1,  0,
                trans.x, trans.y, trans.z, 1
            );
        }

        float4x4 createImageProjectionMatrix(float2 viewportPos, float2 viewportSize, float2 viewportScale, float adjustZFactor, float nearPlane, float farPlane) {
            float Q = farPlane/(farPlane - nearPlane);
            float rcpSizeX = 2.0f/viewportSize.x;
            float rcpSizeY = -2.0f/viewportSize.y;
            rcpSizeX *= adjustZFactor;
            rcpSizeY *= adjustZFactor;
            float viewportPosX = 2*viewportPos.x;
            float viewportPosY = 2*viewportPos.y;
            float4x4 sProjection = {
                float4(rcpSizeX*viewportScale.x, 0, 0,  0), float4(0, rcpSizeY*viewportScale.y, 0, 0), float4(viewportPosX, -viewportPosY, Q, 1),
                float4((-viewportSize.x/2.0f - 0.5f)*rcpSizeX,(-viewportSize.y/2.0f - 0.5f)*rcpSizeY, -Q*nearPlane, 0)
            };
            return sProjection;
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


        // Handlers //
        PSInput VSHandler(VSInput VS){
            PSInput PS = (PSInput)0;
            VS.Position.xyz = float3(VS.TexCoord, 0);
            VS.Position.xy *= fViewportSize;
            float4x4 sProjection = createImageProjectionMatrix(fViewportPos, fViewportSize, fViewportScale, 1000, 100, 10000);
            float4 viewPos = mul(float4(VS.Position.xyz, 1), makeTranslation(float3(0,0, 1000)));
            PS.Position = mul(viewPos, sProjection);
            PS.TexCoord = VS.TexCoord;
            return PS;
        }

        Pixel PSHandler(PSInput PS){
            Pixel output;
            output.World = 0;
            output.Depth = FetchDepthBufferValue(PS.TexCoord);
            return output;
        }


        // Techniques //
        technique ZBuffer {
            pass P0 {
                ZEnable = true;
                ZFunc = LessEqual;
                ZWriteEnable = true;
                CullMode = 1;
                ShadeMode = Gouraud;
                AlphaBlendEnable = true;
                SrcBlend = SrcAlpha;
                DestBlend = InvSrcAlpha;
                AlphaTestEnable = false;
                AlphaRef = 1;
                AlphaFunc = GreaterEqual;
                Lighting = false;
                FogEnable = false;
                VertexShader = compile vs_3_0 VSHandler();
                PixelShader = compile ps_3_0 PSHandler();
            }
        } 

        technique fallback {
            pass P0 {}
        }
    ]]
end