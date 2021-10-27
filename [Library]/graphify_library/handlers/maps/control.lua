----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: handlers: maps: control.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Control Map Handler ]]--
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
    regenerateNormalMap = regenerateNormalMap,
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
            rwData = {((DEFAULT_VS_MODE and AVAILABLE_SHADERS["World"]["VS"]) or AVAILABLE_SHADERS["World"]["No_VS"])["RT_Input_ControlMap"], 3, 0, false, "world,object"},
            syncRT = true,
            controlNormals = (DEFAULT_VS_MODE and true) or false,
            ambientSupport = true,
            parameters = {
                ["anisotropy"] = {1},
                ["filterColor"] = {DEFAULT_FILTER_COLOR}
            }
        }
    },
    validControls = {"red", "green", "blue"},
    controlMaps = {
        shaders = {},
        textures = {}
    }
}


-----------------------------------------
--[[ Function: Generates Control Map ]]--
-----------------------------------------

function generateControlMap(texture, type, shaderControls)

    type = ((type == "object") and "world") or type
    if not texture or not type or not controlMapCache.validControlTypes[type] or not shaderControls or controlMapCache.controlMaps.textures[texture] then return false end

    for i, j in imports.ipairs(controlMapCache.validControls) do
        if not shaderControls[j] or not shaderControls[j].texture or not imports.isElement(shaderControls[j].texture) or (imports.getElementType(shaderControls[j].texture) ~= "texture") then
            return false
        else
            shaderControls[j].scale = imports.math.max(0, imports.tonumber(shaderControls[j].scale) or 1)
        end
    end

    imports.regenerateNormalMap(texture, nil, true)
    local createdControlMap = imports.dxCreateShader(imports.unpack(controlMapCache.validControlTypes[type].rwData))
    if controlMapCache.validControlTypes[type].syncRT then
        imports.syncRTWithShader(createdControlMap)
    end
    for i, j in imports.ipairs(controlMapCache.validControls) do
        imports.dxSetShaderValue(createdControlMap, j.."ControlScale", shaderControls[j].scale)
        imports.dxSetShaderValue(createdControlMap, j.."ControlTexture", shaderControls[j].texture)
    end
    for i, j in imports.pairs(controlMapCache.validControlTypes[type].parameters) do
        imports.dxSetShaderValue(createdControlMap, i, imports.unpack(j))
    end
    controlMapCache.controlMaps.shaders[createdControlMap] = {
        texture = texture,
        type = type,
        shaderMaps = {},
        shaderControls = shaderControls
    }
    controlMapCache.controlMaps.textures[texture] = createdControlMap
    imports.engineApplyShaderToWorldTexture(createdControlMap, texture)
    return createdControlMap

end


------------------------------------------
--[[ Event: On Client Element Destroy ]]--
------------------------------------------

imports.addEventHandler("onClientElementDestroy", resourceRoot, function()

    if not isLibraryResourceStopping then
        if controlMapCache.controlMaps.shaders[source] then
            if not controlMapCache.controlMaps.shaders[source].skipPropagation then
                imports.regenerateNormalMap(nil, controlMapCache.controlMaps.shaders[source])
            end
            controlMapCache.controlMaps.textures[(controlMapCache.controlMaps.shaders[source].texture)] = nil
            controlMapCache.controlMaps.shaders[source] = nil
        end
    end

end)
