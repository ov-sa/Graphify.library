function getInvisibleFX()
    return [[
        // Inputs //
        struct PSInput {
            float4 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
            float4 Diffuse : COLOR0;
        };


        // Handlers //
        float4 PSHandler(PSInput PS) : COLOR0 {
            return 0;
        }


        // Techniques //
        technique Invisible {
            pass P0 {
                AlphaBlendEnable = true;
                PixelShader = compile ps_2_0 PSHandler();
            }
        }

        technique fallback {
            pass P0 {}
        }
    ]]
end