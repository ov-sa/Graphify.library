----------------------------------------------------------------
--[[ Resource: Graphify Library
     Shaders: world: no_vs: rt_input_controlmap.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: World's RT Control-Map Inputter ]]--
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
    reference = "RT_Input_ControlMap",
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
int gCapsMaxAnisotropy <string deviceCaps="MaxAnisotropy";>;
texture colorLayer <string renderTarget = "yes";>;
texture normalLayer <string renderTarget = "yes";>;
texture emissiveLayer <string renderTarget = "yes";>;
// #define GENERATE_NORMALS


/*-----------------
-->> Variables <<--
-------------------*/

bool disableNormals = false;
bool filterOverlayMode;
float4 filterColor;
float anisotropy = 1;
float redControlScale = 1;
float greenControlScale = 1;
float blueControlScale = 1;
texture redControlTexture;
texture greenControlTexture;
texture blueControlTexture;

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

sampler controlSampler = sampler_state {
    Texture = (gTexture0);
    MipFilter = Linear;
    MaxAnisotropy = gCapsMaxAnisotropy*anisotropy;
    MinFilter = Anisotropic;
};

sampler redControlSampler = sampler_state { 
    Texture = (redControlTexture);
    MipFilter = Linear;
    MaxAnisotropy = gCapsMaxAnisotropy*anisotropy;
    MinFilter = Anisotropic;
};

sampler greenControlSampler = sampler_state { 
    Texture = (greenControlTexture);
    MipFilter = Linear;
    MaxAnisotropy = gCapsMaxAnisotropy*anisotropy;
    MinFilter = Anisotropic;
};

sampler blueControlSampler = sampler_state { 
    Texture = (blueControlTexture);
    MipFilter = Linear;
    MaxAnisotropy = gCapsMaxAnisotropy*anisotropy;
    MinFilter = Anisotropic;
}; 


/*----------------
-->> Handlers <<--
------------------*/

Pixel PixelShaderFunction(PSInput PS) {
    Pixel output;

    float4 controlTexel = tex2D(controlSampler, PS.TexCoord);
    float4 redTexel = tex2D(redControlSampler, PS.TexCoord*redControlScale);
    float4 greenTexel = tex2D(greenControlSampler, PS.TexCoord*greenControlScale);
    float4 blueTexel = tex2D(blueControlSampler, PS.TexCoord*blueControlScale);

    float4 sampledControlTexel = lerp(controlTexel, redTexel, controlTexel.r);
    sampledControlTexel = lerp(controlTexel, redTexel, controlTexel.r);
    sampledControlTexel = lerp(controlTexel, redTexel, controlTexel.r);
    sampledControlTexel = lerp(sampledControlTexel, greenTexel, controlTexel.g);
    sampledControlTexel = lerp(sampledControlTexel, greenTexel, controlTexel.g);
    sampledControlTexel = lerp(sampledControlTexel, greenTexel, controlTexel.g);
    sampledControlTexel = lerp(sampledControlTexel, blueTexel, controlTexel.b);
    sampledControlTexel = lerp(sampledControlTexel, blueTexel, controlTexel.b);
    sampledControlTexel = lerp(sampledControlTexel, blueTexel, controlTexel.b);
    sampledControlTexel.rgb = sampledControlTexel.rgb/3;

    float4 worldColor = sampledControlTexel;
    if (filterOverlayMode) {
        worldColor += filterColor;
    } else {
        worldColor *= filterColor;
    }
    worldColor.a = controlTexel.a;
    output.World = saturate(worldColor);
    output.Color.rgb = sampledControlTexel.rgb;
    output.Color.a = sampledControlTexel.a*PS.Diffuse.a;
    output.Emissive.rgb = 0;
    output.Emissive.a = 1;
    output.Normal = float4(0, 0, 0, 1);
    return output;
}


/*------------------
-->> Techniques <<--
--------------------*/

technique world_rtInputControlMap {
    pass P0 {
        SRGBWriteEnable = false;
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

technique fallback {
    pass P0 {}
}
]]