----------------------------------------------------------------
--[[ Resource: Graphify Library
     Shaders: utilities: tex_clear.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Texture Clearer ]]--
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
    category = "Utilities",
    reference = "Tex_Clear",
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

AVAILABLE_SHADERS[shaderConfig.category][shaderConfig.reference] = [[
/*---------------
-->> Imports <<--
-----------------*/

]]..shaderConfig.dependencyData..[[


/*----------------
-->> Handlers <<--
------------------*/

float4 PixelShaderFunction() : COLOR0 {
    return 0;
}


/*------------------
-->> Techniques <<--
--------------------*/

technique utilities_texClear {
    pass P0 {
        AlphaBlendEnable = TRUE;
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

technique fallback {
    pass P0 {}
}
]]