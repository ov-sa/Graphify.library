----------------------------------------------------------------
--[[ Resource: Graphify Library
     Shaders: bloom: rt_bright.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Bloom's RT Brighter ]]--
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
    category = "Bloom",
    reference = "RT_Bright",
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

AVAILABLE_SHADERS[shaderConfig.category][shaderConfig.reference] = [[
/*---------------
-->> Imports <<--
-----------------*/

]]..shaderConfig.dependencyData..[[


/*-----------------
-->> Variables <<--
-------------------*/

texture rtTexture;
float rtCuttOff = 0.2;
float rtPower = 1;

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
	float4 inputTexel = tex2D(brightSampler, PS.TexCoord);

    float lum = (inputTexel.r + inputTexel.g + inputTexel.b)/3;
    float adj = saturate(lum - rtCuttOff)/(1.01 - rtCuttOff);
    inputTexel = inputTexel*adj;
    inputTexel = pow(inputTexel, rtPower);
    inputTexel = inputTexel;
	inputTexel.a = 1;
	return inputTexel;
}


/*------------------
-->> Techniques <<--
--------------------*/

technique bloom_rtBright {
    pass P0 {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

technique fallback {
    pass P0 {}
}
]]