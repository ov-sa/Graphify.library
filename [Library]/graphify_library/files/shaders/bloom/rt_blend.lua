----------------------------------------------------------------
--[[ Resource: Graphify Library
     Shaders: bloom: rt_blend.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Bloom's RT Blender ]]--
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
    reference = "RT_Blend",
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


/*-----------------
-->> Variables <<--
-------------------*/

texture rtTexture;


/*------------------
-->> Techniques <<--
--------------------*/

technique bloom_rtBlend {
    pass P0 {
        SrcBlend = SRCALPHA;
        DestBlend = ONE;
        Texture[0] = rtTexture;
    }
}

technique fallback {
    pass P0 {}
}
]]