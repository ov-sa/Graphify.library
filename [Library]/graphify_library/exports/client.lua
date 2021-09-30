----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: exports: client.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Client Sided Exports ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    tonumber = tonumber,
    destroyElement = destroyElement,
    disableNormals = disableNormals,
    dxSetShaderValue = dxSetShaderValue,
    engineApplyShaderToWorldTexture = engineApplyShaderToWorldTexture,
    engineRemoveShaderFromWorldTexture = engineRemoveShaderFromWorldTexture
}


---------------------------------------
--[[ Function: Retrieves Layer RTs ]]--
---------------------------------------

function getLayerRTs()

    if isGraphifySupported then 
        return createdRTs
    end
    return false

end


--------------------------------------------------
--[[ Function: Sets Normal Generation's State ]]--
--------------------------------------------------

function setNormalGenerationState(...)

    if isGraphifySupported then
        return imports.disableNormals(...)
    end
    return false

end


--------------------------------------------
--[[ Function: Sets Ambience Multiplier ]]--
--------------------------------------------

function setAmbienceMutiplier(multiplier)

    if isGraphifySupported then
        multiplier = imports.tonumber(multiplier) or false
        for i, j in imports.pairs(createdShaders) do
            if (i ~= "__SORT_ORDER__") and j.ambientSupport then
                imports.dxSetShaderValue(j.shader, "ambienceMultiplier", multiplier)
            end
        end
        return true
    end
    return false

end


-------------------------------------------------
--[[ Functions: Sets/Retrieves Emissive Mode ]]--
-------------------------------------------------

function setEmissiveMode(state)

    if isGraphifySupported then
        if state == true then
            return createEmissiveMode()
        elseif state == false then
            return destroyEmissiveMode()
        end
    end
    return false

end

function getEmissiveMode()

    if isGraphifySupported then
        return emissiveCache["__STATE__"]
    end
    return false

end


-------------------------------------------------
--[[ Function: Sets Texture's Emissive State ]]--
-------------------------------------------------

function setTextureEmissive(texture, type, state)

    if isGraphifySupported and texture and type and ((state == true) or (state == false)) then
        local emissiveShader = false
        if (type == "world") or (type == "object") then
            emissiveShader = createdShaders["world_RT_Input_Emissive"].shader
        end
        if emissiveShader then
            local setterFunction = (state and imports.engineApplyShaderToWorldTexture) or imports.engineRemoveShaderFromWorldTexture
            setterFunction(shader, texture)
        end
    end
    return false

end


-------------------------------------------------
--[[ Functions: Creates/Destroys Control-Map ]]--
-------------------------------------------------

function destroyControlMap(shader)

    if isGraphifySupported and controlMapCache.controlMaps[shader] then
        imports.destroyElement(shader)
    end
    return true

end

