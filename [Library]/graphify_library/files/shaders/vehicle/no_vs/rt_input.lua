----------------------------------------------------------------
--[[ Resource: Graphify Library
     Shaders: vehicle: no_vs: rt_input.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Vehicle's RT Inputter ]]--
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
    category = AVAILABLE_SHADERS["Vehicle"]["No_VS"],
    reference = "RT_Input",
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
texture colorLayer <string renderTarget = "yes";>;
texture normalLayer <string renderTarget = "yes";>;
texture emissiveLayer <string renderTarget = "yes";>;


/*-----------------
-->> Variables <<--
-------------------*/

bool filterOverlayMode;
float4 filterColor;

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


/*----------------
-->> Handlers <<--
------------------*/

Pixel PixelShaderFunction(PSInput PS) {
    Pixel output;	

    float4 inputTexel = tex2D(inputSampler1, PS.TexCoord.xy);

    float4 worldColor = inputTexel*PS.Diffuse;
    if (gStage1ColorOp == 14) {
        worldColor.rgb = worldColor.rgb*(1 - gTextureFactor.a) + inputTexel.rgb*gTextureFactor.a;
    }
    if (gStage1ColorOp == 25) {
        worldColor.rgb += inputTexel.rgb*gTextureFactor.r;
    }
    if (gMaterialSpecPower != 0) {
        worldColor.rgb += PS.Diffuse.rgb;
    }
    float4 outputColor = worldColor;
    if (filterOverlayMode) {
        worldColor += filterColor;
    } else {
        worldColor *= filterColor;
    }
    worldColor.a = inputTexel.a;
    output.World = saturate(worldColor);
    output.Color.rgb = outputColor.rgb*0.85 + 0.15;
    output.Color.a = inputTexel.a*PS.Diffuse.a;
    output.Emissive.rgb = 0;
    output.Emissive.a = 1;
    output.Normal = float4(0, 0, 0, 1);
    return output;
}


/*------------------
-->> Techniques <<--
--------------------*/

technique vehicle_rtInput {
    pass P0 {
        CullMode = ((gMaterialDiffuse.a < 0.9) && (gBlendFactor.a == 0)) ? 1 : gCullMode;
        ZWriteEnable = (gMaterialDiffuse.a < 0.9) ? 0 : gZWriteEnable;
        SRGBWriteEnable = false;
        PixelShader = compile ps_3_0 PixelShaderFunction();
    }
}

technique fallback {
    pass P0 {}
}
]]