----------------------------------------------------------------
--[[ Resource: Graphify Library
     Shaders: sky: rt_input.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Sky's RT Inputter ]]--
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
    category = AVAILABLE_SHADERS["Sky"],
    reference = "RT_Input",
    dependencies = {},
    dependencyData = ""
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

texture skyControlMap;
texture skyControlTexture;
float4 transparentTexel = float4(0, 0, 0, 0);


/*----------------
-->> Samplers <<--
------------------*/

sampler controlSampler = sampler_state {
    Texture = (skyControlMap);
};

sampler skyControlSampler = sampler_state { 
    Texture = (skyControlTexture);
};


/*----------------
-->> Handlers <<--
------------------*/

float4 PixelShaderFunction(float2 TexCoord : TEXCOORD0) : COLOR0 {
    float4 controlTexel = tex2D(controlSampler, TexCoord);
    controlTexel.r = 1;
    float4 skyTexel = tex2D(skyControlSampler, TexCoord);
    float4 sampledControlTexel = lerp(skyTexel, controlTexel, controlTexel.a);
    sampledControlTexel = lerp(sampledControlTexel, transparentTexel, controlTexel.a);
    return sampledControlTexel;
} 


/*------------------
-->> Techniques <<--
--------------------*/

technique sky_rtInput {
    pass P0 {
        AlphaBlendEnable = true;
        SrcBlend = SrcAlpha;
        DestBlend = InvSrcAlpha;
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

technique fallback {
    pass P0 {}
}
]]