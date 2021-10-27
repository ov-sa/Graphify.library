----------------------------------------------------------------
--[[ Resource: Graphify Library
     Shaders: world: no_vs: rt_input_grass.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: World's RT Grass Inputter ]]--
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
    reference = "RT_Input_Grass",
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
int gStage1ColorOp <string stageState="1,COLOROP";>;
float4 gTextureFactor <string renderState="TEXTUREFACTOR";>;
texture colorLayer <string renderTarget = "yes";>;
texture emissiveLayer <string renderTarget = "yes";>;


/*-----------------
-->> Variables <<--
-------------------*/

float4 filterColor;

struct Pixel {
    float4 World : COLOR0;
    float4 Color : COLOR1;
    float4 Emissive : COLOR2;
};

struct PSInput {
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};


/*----------------
-->> Samplers <<--
------------------*/

sampler inputSampler = sampler_state {
    Texture = (gTexture0);
};


/*----------------
-->> Handlers <<--
------------------*/

Pixel PixelShaderFunction(PSInput PS) {
    Pixel output;

    float4 inputTexel = tex2D(inputSampler, PS.TexCoord);
    inputTexel = inputTexel*PS.Diffuse;
    if (gStage1ColorOp == 4) {
        inputTexel *= gTextureFactor;
    }

    float4 worldColor = inputTexel*PS.Diffuse;
    if (gStage1ColorOp == 4) {
        worldColor *= gTextureFactor;
    }
    if (enableFilterOverlay) {
        worldColor += filterColor;
    } else {
        worldColor *= filterColor;
    }
    worldColor.a = inputTexel.a;
    output.World = worldColor; 
    output.Color = inputTexel; 
    output.Emissive.rgb = 0;
    output.Emissive.a = 1;
    return output;
}


/*------------------
-->> Techniques <<--
--------------------*/

technique world_rtInputGrass {
    pass P0 {
        ZWriteEnable = false;
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

technique fallback {
    pass P0 {}
}
]]