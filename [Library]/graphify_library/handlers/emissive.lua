----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: handlers: emissive.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Emissive Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    unpack = unpack,
    addEventHandler = addEventHandler,
    removeEventHandler = removeEventHandler,
    dxCreateShader = dxCreateShader,
    dxSetShaderValue = dxSetShaderValue
}


-------------------
--[[ Variables ]]--
-------------------

emissiveCache = {

    ["__STATE__"] = false,

    RT_Blend = {
        rwData = {AVAILABLE_SHADERS["Bloom"]["RT_Blend"]},
        parameters = {}
    },

    RT_BlurX = {
        rwData = {AVAILABLE_SHADERS["Bloom"]["RT_BlurX"]},
        parameters = {
            ["viewportSize"] = {CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2]}
        }
    },

    RT_BlurY = {
        rwData = {AVAILABLE_SHADERS["Bloom"]["RT_BlurY"]},
        parameters = {
            ["viewportSize"] = {CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2]}
        }
    },

    RT_Bright = {
        rwData = {AVAILABLE_SHADERS["Bloom"]["RT_Bright"]},
        parameters = {}
    }

}


-----------------------------------------
--[[ Function: Renders Emissive Mode ]]--
-----------------------------------------

local function renderEmissiveMode()

    outputChatBox("rendering emissive...")

end


---------------------------------------------------
--[[ Functions: Creates/Destroys Emissive Mode ]]--
---------------------------------------------------

function createEmissiveMode()

    if emissiveCache["__STATE__"] then return false end

    emissiveCache["__STATE__"] = true
    for i, j in imports.pairs(emissiveCache) do
        if i ~= "__STATE__" then
            j.shader = imports.dxCreateShader(imports.unpack(j.rwData))
            for k, v in imports.pairs(j.parameters) do
                imports.dxSetShaderValue(j.shader, k, imports.unpack(v))
            end
        end
    end
    imports.addEventHandler("onClientHUDRender", root, renderEmissiveMode)
    return true

end

function destroyEmissiveMode()

    if not emissiveCache["__STATE__"] then return false end

    imports.removeEventHandler("onClientHUDRender", root, renderEmissiveMode)
    emissiveCache["__STATE__"] = false
    return true

end
