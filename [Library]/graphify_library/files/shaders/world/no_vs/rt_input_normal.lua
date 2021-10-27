----------------------------------------------------------------
--[[ Resource: Graphify Library
     Shaders: world: no_vs: rt_input_normal.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: World's RT Normal Inputter ]]--
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
    reference = "RT_Input_Normal",
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
texture colorLayer <string renderTarget = "yes";>;
texture normalLayer <string renderTarget = "yes";>;
texture emissiveLayer <string renderTarget = "yes";>;


/*-----------------
-->> Variables <<--
-------------------*/

bool enableFilterOverlay = false;
float4 filterColor;
texture normalTexture;
float bumpContrast = 0.5;
float bumpBrightness = 0.5;

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

sampler inputSampler = sampler_state {
    Texture = (gTexture0);
};

sampler normalSampler = sampler_state {
    Texture = (normalTexture);
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
};


/*----------------
-->> Handlers <<--
------------------*/

Pixel PixelShaderFunction(PSInput PS) {
    Pixel output;
	
    float4 inputTexel = tex2D(inputSampler, PS.TexCoord);
    float4 bumpTexel = tex2D(normalSampler, PS.TexCoord);

    float bumpAverage = (inputTexel.r + inputTexel.g + inputTexel.b)/3.0f;
    bumpTexel.r = bumpAverage;
    bumpTexel.g = bumpAverage;
    bumpTexel.b = bumpAverage;
    bumpTexel.rgb = ((bumpTexel.rgb - 0.5f) * max(bumpContrast, 0)) + 0.5f;
    bumpTexel.rgb += bumpBrightness;
    inputTexel.rgb *= bumpTexel.rgb;

    float4 worldColor = inputTexel*PS.Diffuse;
    if (enableFilterOverlay) {
        worldColor += filterColor;
    } else {
        worldColor *= filterColor;
    }
    worldColor.a = inputTexel.a;
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

technique world_rtInputNormal {
    pass P0 {
        SRGBWriteEnable = false;
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

technique fallback {
    pass P0 {}
}
]]