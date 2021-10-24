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
    setTimer = setTimer,
    getElementType = getElementType,
    destroyElement = destroyElement,
    addEventHandler = addEventHandler,
    syncRTWithShader = syncRTWithShader,
    getBumpMap = getBumpMap,
    generateBumpMap = generateBumpMap,
    dxCreateShader = dxCreateShader,
    dxSetShaderValue = dxSetShaderValue,
    engineApplyShaderToWorldTexture = engineApplyShaderToWorldTexture,
    table = {
        clone = table.clone
    },
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
--[[ Function: Generates Control-Map ]]--
-----------------------------------------

function generateControlMap(texture, type, controls)

    type = ((type == "object") and "world") or type
    if not texture or not type or not controlMapCache.validControlTypes[type] or not controls or controlMapCache.controlMaps.textures[texture] then return false end

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
    controlMapCache.controlMaps.shaders[createdControlMap] = {
        texture = texture,
        controls = controls,
        type = type
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
            local textureBumpMap = imports.getBumpMap(controlMapCache.controlMaps.shaders[source].texture)
            if textureBumpMap then
                local clonedBumpDetails = imports.table.clone(bumpMapCache.bumpMaps.shaders[source], false)
                bumpMapCache.bumpMaps.textures[(bumpMapCache.bumpMaps.shaders[source].texture)] = nil
                bumpMapCache.bumpMaps.shaders[source] = nil
                imports.setTimer(function()
                    imports.generateBumpMap(clonedBumpDetails.texture, clonedBumpDetails.type, clonedBumpDetails.bumpElement)
                end, 1, 1)
            end
            controlMapCache.controlMaps.textures[(controlMapCache.controlMaps.shaders[source].texture)] = nil
            controlMapCache.controlMaps.shaders[source] = nil
        end
    end

end)
