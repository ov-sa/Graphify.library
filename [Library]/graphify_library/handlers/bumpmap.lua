----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: handlers: bumpmap.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Bump-Map Handler ]]--
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
    getControlMap = getControlMap,
    dxCreateShader = dxCreateShader,
    dxSetShaderValue = dxSetShaderValue,
    engineApplyShaderToWorldTexture = engineApplyShaderToWorldTexture,
    table = {
        clone = table.clone
    }
}


-------------------
--[[ Variables ]]--
-------------------

bumpMapCache = {
    validBumpTypes = {
        ["world"] = {
            rwData = {((DEFAULT_VS_MODE and AVAILABLE_SHADERS["World"]["VS"]["Bump"]["RT_Input"]) or AVAILABLE_SHADERS["World"]["No_VS"]["Bump"]["RT_Input"]), 3, 0, false, "world,object"},
            syncRT = true,
            controlNormals = (DEFAULT_VS_MODE and true) or false,
            ambientSupport = true,
            parameters = {
                ["enableBump"] = {true},
                ["filterColor"] = {DEFAULT_FILTER_COLOR}
            }
        }
    },
    bumpMaps = {
        shaders = {},
        textures = {}
    }
}


-------------------------------------------------
--[[ FunctionS: Generates/Refreshes Bump-Map ]]--
-------------------------------------------------

function generateBumpMap(texture, type, bumpElement)

    type = ((type == "object") and "world") or type
    if not texture or not type or not bumpMapCache.validBumpTypes[type] or not bumpElement or not imports.isElement(bumpElement) or (imports.getElementType(bumpElement) ~= "texture") or bumpMapCache.bumpMaps.textures[texture] then return false end

    local createdBumpMap = false
    local textureControlMap = imports.getControlMap(texture)
    if textureControlMap then
        createdBumpMap = textureControlMap
    else
        createdBumpMap = imports.dxCreateShader(imports.unpack(bumpMapCache.validBumpTypes[type].rwData))
        if bumpMapCache.validBumpTypes[type].syncRT then
            imports.syncRTWithShader(createdBumpMap)
        end
    end
    for i, j in imports.pairs(bumpMapCache.validBumpTypes[type].parameters) do
        imports.dxSetShaderValue(createdBumpMap, i, imports.unpack(j))
    end
    imports.dxSetShaderValue(createdBumpMap, "bumpTexture", bumpElement)
    bumpMapCache.bumpMaps.shaders[createdBumpMap] = {
        texture = texture,
        bumpElement = bumpElement,
        type = type
    }
    bumpMapCache.bumpMaps.textures[texture] = createdBumpMap
    if not textureControlMap then
        imports.engineApplyShaderToWorldTexture(createdBumpMap, texture)
    end
    return createdBumpMap

end

function refreshBumpMap(texture)

    if not texture then return false end

    local textureReference = bumpMapCache.bumpMaps.textures[texture]
    if textureReference then
        local bumpDetails = imports.table.clone(bumpMapCache.bumpMaps.shaders[textureReference], false)
        bumpMapCache.bumpMaps.textures[texture] = nil
        bumpMapCache.bumpMaps.shaders[textureReference] = nil
        imports.setTimer(function()
            generateBumpMap(bumpDetails.texture, bumpDetails.type, bumpDetails.bumpElement)
        end, 1, 1)
    end
    return false

end


------------------------------------------
--[[ Event: On Client Element Destroy ]]--
------------------------------------------

imports.addEventHandler("onClientElementDestroy", resourceRoot, function()

    if not isLibraryResourceStopping then
        if bumpMapCache.bumpMaps.shaders[source] then
            if not controlMapCache.controlMaps.shaders[source] then
                bumpMapCache.bumpMaps.textures[(bumpMapCache.bumpMaps.shaders[source].texture)] = nil
                bumpMapCache.bumpMaps.shaders[source] = nil
            end
        end
    end

end)