function getLayerFX()
    return [[
        // Native //
        float layerBrightness = 1;
        bool isAlphaEnabled = true;
        texture gTexture0 <string textureState="0,Texture";>;
        texture layerRT <string renderTarget = "yes";>;


        // Inputs //
        struct PSInput {
            float4 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
            float4 Diffuse : COLOR0;
        };
        struct Pixel {
            float4 World : COLOR0;
            float4 Color : COLOR1;
        };
        sampler baseSampler = sampler_state {
            Texture = gTexture0;
        };


        // Handlers //
        Pixel PSHandler(PSInput PS) {
            Pixel Output;
            float4 inputTexel = tex2D(baseSampler, PS.TexCoord);
            Output.World = float4(0, 0, 0, 0.00615);
            //Output.Color.rgb = inputTexel.rgb*length(inputTexel.rgb)*layerBrightness;
            Output.Color.rgb = inputTexel.rgb*layerBrightness;
            if (isAlphaEnabled) Output.Color.a = inputTexel.a;
            else Output.Color.a = 1;
            return Output;
        }


        // Techniques //
        technique Shader_Layer {
            pass P0 {
                PixelShader = compile ps_2_0 PSHandler();
            }
        }

        technique fallback {
            pass P0 {}
        }
    ]]
end