----------------------------------------------------------------
--[[ Resource: Graphify Library
     Shaders: world: no_vs: rt_input_ref.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: World's RT Ref Inputter ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    fetchFileData = fetchFileData
}


-------------------
--[[ Variables ]]--
-------------------

local shaderConfig = {
    category = AVAILABLE_SHADERS["World"]["No_VS"],
    reference = "RT_Input_Ref",
    dependencies = {},
    dependencyData = AVAILABLE_SHADERS["Utilities"]["MTA_Helper"]
}

for i, j in imports.pairs(shaderConfig.dependencies) do
    local fileData = imports.fetchFileData(j)
    if fileData then
        shaderConfig.dependencyData = shaderConfig.dependencyData.."\n"..fileData
    end
end


----------------
--[[ Shader ]]--
----------------

shaderConfig.category[shaderConfig.reference] = [[
/*---------------
-->> Imports <<--
-----------------*/

]]..shaderConfig.dependencyData..[[
float4 gBlendFactor <string renderState="BLENDFACTOR";>;
int gZWriteEnable <string renderState="ZWRITEENABLE";>;
int gCullMode <string renderState="CULLMODE";>;
int gStage1ColorOp <string stageState="1,COLOROP";>;
float4 gTextureFactor <string renderState="TEXTUREFACTOR";>;
int gStage0TextureTransformFlags <string stageState="0,TEXTURETRANSFORMFLAGS";>;
float4x4 gTransformTexture0 <string transformState="TEXTURE0";>;
float4x4 gTransformTexture1 <string transformState="TEXTURE1";>;
texture colorLayer <string renderTarget = "yes";>;
texture normalLayer <string renderTarget = "yes";>;
texture emissiveLayer <string renderTarget = "yes";>;


/*-----------------
-->> Variables <<--
-------------------*/

struct Pixel {
    float4 World : COLOR0;
    float4 Color : COLOR1;
    float4 Normal : COLOR2;
    float4 Emissive : COLOR3;
};

struct PSInput {
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
}; 


/*----------------
-->> Samplers <<--
------------------*/

sampler inputSampler1 = sampler_state {
    Texture = (gTexture0);
};

sampler inputSampler2 = sampler_state {
    Texture = (gTexture1);
};


/*----------------
-->> Handlers <<--
------------------*/

Pixel PixelShaderFunction(PSInput PS) {
    Pixel output;

    float4 inputTexel = tex2D(inputSampler1, PS.TexCoord);

    float4 worldColor = inputTexel*PS.Diffuse;
    if (gStage1ColorOp == 25) {
        worldColor.rgb += inputTexel.rgb*gTextureFactor.r;
    }
    output.World = saturate(worldColor);
    output.Color.rgb = inputTexel.rgb;
    output.Color.a = inputTexel.a*PS.Diffuse.a;
    output.Emissive.rgb = 0;
    output.Emissive.a = 1;
    output.Normal = float4(0, 0, 0, 1);
    return output;
}


/*------------------
-->> Techniques <<--
--------------------*/

technique world_rtInputRef {
    pass P0 {
        SRGBWriteEnable = false;
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

technique fallback {
    pass P0 {}
}
]]