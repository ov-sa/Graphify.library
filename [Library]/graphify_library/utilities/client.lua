  
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
    ipairs = ipairs,
    loadstring = loadstring,
    addEventHandler = addEventHandler,
    dxSetShaderValue = dxSetShaderValue,
    engineApplyShaderToWorldTexture = engineApplyShaderToWorldTexture,
    engineRemoveShaderFromWorldTexture = engineRemoveShaderFromWorldTexture
}


-------------------
--[[ Variables ]]--
-------------------

imports.loadstring(exports.beautify_library:fetchImports())()


---------------------------------
--[[ Event: On Resource Stop ]]--
---------------------------------

isLibraryResourceStopping = false
imports.addEventHandler("onClientResourceStop", root, function()
    if source == resource then
        isLibraryResourceStopping = true
    end
end)


--------------------------------------
--[[ Function: Syncs RT w/ Shader ]]--
--------------------------------------

function syncRTWithShader(shader)

    if not isGraphifySupported or not shader then return false end

    for i, j in imports.pairs(createdRTs) do
        imports.dxSetShaderValue(shader, i, j)
    end
    return true

end


------------------------------------
--[[ Function: Disables Normals ]]--
------------------------------------

function disableNormals(state)

    if not isGraphifySupported then return false end

    for i, j in imports.pairs(createdShaders) do
        if j.shader and j.controlNormals then
            imports.dxSetShaderValue(j.shader, "disableNormals", state)
        end
    end
	return true

end


----------------------------------------------
--[[ Function: Sets Shader's Texture List ]]--
----------------------------------------------

function setShaderTextureList(shader, list, state)

    if not isGraphifySupported or not shader or not list or (state ~= true and state ~= false) then return false end

    local setterFunction = (state and imports.engineApplyShaderToWorldTexture) or imports.engineRemoveShaderFromWorldTexture
    for i, j in imports.ipairs(list) do
        setterFunction(shader, j)
    end
    return true

end