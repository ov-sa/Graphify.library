----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: handlers: controlmap.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Control-Map Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    ipairs = ipairs,
    unpack = unpack,
    tonumber = tonumber,
    isElement = isElement,
    getElementType = getElementType,
    destroyElement = destroyElement,
    addEventHandler = addEventHandler,
    syncRTWithShader = syncRTWithShader,
    dxCreateShader = dxCreateShader,
    dxSetShaderValue = dxSetShaderValue,
    engineApplyShaderToWorldTexture = engineApplyShaderToWorldTexture,
    math = {
        max = math.max
    }
}


-------------------
--[[ Variables ]]--
-------------------

controlMapCache = {
    validControlTypes = {
        ["world"] = {
            rwData = {AVAILABLE_SHADERS["World"]["RT_Input_ControlMap"], 3, 0, false, "world,object"},
            syncRT = true,
            controlNormals = true,
            ambientSupport = true,
            parameters = {
                ["anisotropy"] = {1}
            }
        }
    },
    validControls = {"red", "green", "blue"},
    controlMaps = {}
}


-----------------------------------------
--[[ Function: Generates Control-Map ]]--
-----------------------------------------

function generateControlMap(texture, type, controls)

    type = ((type == "object") and "world") or type
    if not texture or not type or not controlMapCache.validControlTypes[type] or not controls then return false end

    for i, j in imports.ipairs(controlMapCache.validControls) do
        if not controls[j] or not controls[j].texture or not imports.isElement(controls[j].texture) or (imports.getElementType(controls[j].texture) ~= "texture") then
            return false
        else
            controls[j].scale = imports.math.max(0, imports.tonumber(controls[j].scale) or 1)
        end
    end

    local createdControlMap = imports.dxCreateShader(imports.unpack(controlMapCache.validControlTypes[type].rwData))
    if controlMapCache.validControlTypes[type].syncRT then
        imports.syncRTWithShader(createdControlMap)
    end
    for i, j in imports.ipairs(controlMapCache.validControls) do
        imports.dxSetShaderValue(createdControlMap, j.."ControlScale", controls[j].scale)
        imports.dxSetShaderValue(createdControlMap, j.."ControlTexture", controls[j].texture)
    end
    for i, j in imports.pairs(controlMapCache.validControlTypes[type].parameters) do
        imports.dxSetShaderValue(createdControlMap, i, imports.unpack(j))
    end
    controlMapCache.controlMaps[createdControlMap] = {
        texture = texture,
        controls = controls,
        type = type
    }
    imports.engineApplyShaderToWorldTexture(createdControlMap, texture)
    return createdControlMap

end


------------------------------------------
--[[ Event: On Client Element Destroy ]]--
------------------------------------------

imports.addEventHandler("onClientElementDestroy", resourceRoot, function()

    if not isLibraryResourceStopping then
        if controlMapCache.controlMaps[source] then
            controlMapCache.controlMaps[source] = nil
        end
    end

end)
