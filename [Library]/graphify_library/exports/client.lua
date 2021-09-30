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
    disableNormals = disableNormals,
    dxSetShaderValue = dxSetShaderValue
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