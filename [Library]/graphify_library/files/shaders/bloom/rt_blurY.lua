----------------------------------------------------------------
--[[ Resource: Graphify Library
     Shaders: bloom: rt_blurY.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Bloom's RT Y-Blurrer ]]--
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
    category = AVAILABLE_SHADERS["Bloom"],
    reference = "RT_BlurY",
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


/*-----------------
-->> Variables <<--
-------------------*/

texture rtTexture;
float bloomMultiplier = 1;
float blurMultiplier = 1;
float2 viewportSize = float2(800, 600);
static const float Kernel[13] = {-6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6};
static const float Weights[13] = {0.002216, 0.008764, 0.026995, 0.064759, 0.120985, 0.176033, 0.199471, 0.176033, 0.120985, 0.064759, 0.026995, 0.008764, 0.002216};

struct VSInput {
    float3 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

struct PSInput {
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord: TEXCOORD0;
};


/*----------------
-->> Samplers <<--
------------------*/

sampler blurSampler = sampler_state {
    Texture = (rtTexture);
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Mirror;
    AddressV = Mirror;
};


/*----------------
-->> Handlers <<--
------------------*/

PSInput VertexShaderFunction(VSInput VS) {
    PSInput PS = (PSInput)0;

    PS.Position = MTACalcScreenPosition(VS.Position);
    PS.Diffuse = VS.Diffuse;
    PS.TexCoord = VS.TexCoord;
    return PS;
}

float4 PixelShaderFunction(PSInput PS) : COLOR0 {
    float4 inputTexel = 0;

    float2 rtColor;
    rtColor.x = PS.TexCoord.x;
    for(int i = 0; i < 13; ++i) {
        rtColor.y = PS.TexCoord.y + ((blurMultiplier*Kernel[i])/viewportSize.y);
        inputTexel += tex2D(blurSampler, rtColor.xy)*Weights[i]*bloomMultiplier;
    }
    inputTexel = inputTexel*PS.Diffuse;
    inputTexel.a = 1;
    return inputTexel;
}


/*------------------
-->> Techniques <<--
--------------------*/

technique bloom_rtBlurY {
    pass P0 {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

technique fallback {
    pass P0 {}
}
]]