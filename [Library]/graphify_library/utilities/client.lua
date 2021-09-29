  
----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: utilities: client.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Client Sided Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    loadstring = loadstring,
    dxSetShaderValue = dxSetShaderValue
}


-------------------
--[[ Variables ]]--
-------------------

imports.loadstring(exports.beautify_library:fetchImports())()


--------------------------------------
--[[ Function: Syncs RT w/ Shader ]]--
--------------------------------------

function syncRTWithShader(shader)

    if not shader then return false end

    for i, j in imports.pairs(createdRTs) do
        imports.dxSetShaderValue(shader, i, j)
    end
    return true

end