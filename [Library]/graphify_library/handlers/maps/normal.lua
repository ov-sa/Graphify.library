----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: handlers: maps: normal.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Normal Map Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    unpack = unpack,
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

normalMapCache = {
    validNormalTypes = {
        ["world"] = {
            rwData = {((DEFAULT_VS_MODE and AVAILABLE_SHADERS["World"]["VS"]) or AVAILABLE_SHADERS["World"]["No_VS"])["RT_Input_Normal"], 3, 0, false, "world,object"},
            syncRT = true,
            controlNormals = false,
            ambientSupport = true,
            parameters = {
                ["filterColor"] = {DEFAULT_FILTER_COLOR}
            }
        }
    },
    normalMaps = {
        shaders = {},
        textures = {}
    }
}


------------------------------------------------------
--[[ Functions: Generates/Re-Generates Normal Map ]]--
------------------------------------------------------

function generateNormalMap(texture, type, normalMap)

    type = ((type == "object") and "world") or type
    if not texture or not type or not normalMapCache.validNormalTypes[type] or not normalMap or not imports.isElement(normalMap) or (imports.getElementType(normalMap) ~= "texture") or normalMapCache.normalMaps.textures[texture] then return false end

    local textureControlMap, textureNormalMap = imports.getControlMap(texture), getNormalMap(texture)
    local createdNormalMap = textureControlMap or textureNormalMap or false
    if not createdNormalMap then
        createdNormalMap = imports.dxCreateShader(imports.unpack(normalMapCache.validNormalTypes[type].rwData))
        normalMapCache.normalMaps.shaders[createdNormalMap] = {
            texture = texture,
            type = type,
            shaderMaps = {}
        }
        normalMapCache.normalMaps.textures[texture] = createdNormalMap
        if normalMapCache.validNormalTypes[type].syncRT then
            imports.syncRTWithShader(createdNormalMap)
        end
        for i, j in imports.pairs(normalMapCache.validNormalTypes[type].parameters) do
            imports.dxSetShaderValue(createdNormalMap, i, imports.unpack(j))
        end
    end
    normalMapCache.normalMaps.shaders[createdNormalMap].shaderMaps.normal = normalMap
    imports.dxSetShaderValue(createdNormalMap, "enableNormalMap", true)
    imports.dxSetShaderValue(createdNormalMap, "normalTexture", normalMap)
    if not textureControlMap then
        imports.engineApplyShaderToWorldTexture(createdNormalMap, texture)
    end
    return createdNormalMap

end

function regenerateNormalMap(texture, destroyShader, controlReference)

    if not texture then return false end

    local mapDetails = false
    if controlReference then
        if controlReference.shaderMaps then
            mapDetails = controlReference.shaderMaps
        end
    else
        local shaderReference = normalMapCache.normalMaps.textures[texture]
        if shaderReference then
            if destroyShader then
                imports.destroyElement(shaderReference)
            end
            mapDetails = imports.table.clone(normalMapCache.normalMaps.shaders[shaderReference], true)
            normalMapCache.normalMaps.textures[texture] = nil
            normalMapCache.normalMaps.shaders[shaderReference] = nil
        end
    end

    if mapDetails then
        print("REGENERATIN!!!")
        imports.setTimer(function(mapDetails)
            if mapDetails and mapDetails.shaderMaps then
                for i, j in imports.pairs(mapDetails.shaderMaps) do
                    if i == "normal" then
                        generateNormalMap(mapDetails.texture, mapDetails.type, j)
                    elseif i == "bump" then
                        generateBumpMap(mapDetails.texture, mapDetails.type, j)
                    end
                end
            end
        end, 1, 1, controlReference.shaderMaps)
        return true
    end
    return false

end


------------------------------------------
--[[ Event: On Client Element Destroy ]]--
------------------------------------------

imports.addEventHandler("onClientElementDestroy", resourceRoot, function()

    if not isLibraryResourceStopping then
        if normalMapCache.normalMaps.shaders[source] then
            normalMapCache.normalMaps.textures[(normalMapCache.normalMaps.shaders[source].texture)] = nil
            normalMapCache.normalMaps.shaders[source] = nil
        end
    end

end)