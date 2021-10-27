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
    if not texture or not type or not normalMapCache.validNormalTypes[type] or not normalMap or not imports.isElement(normalMap) or (imports.getElementType(normalMap) ~= "texture") then return false end

    local createdNormalMap, shaderReference = false, false
    local texControlMap, texControlReference = imports.getControlMap(texture)
    local texNormalMap, texNormalReference = imports.getNormalMap(texture)
    if texControlMap then
        createdNormalMap, shaderReference = texControlMap, texControlReference
    elseif texNormalMap then
        createdNormalMap, shaderReference = texNormalMap, texNormalReference
    end
    if not createdNormalMap then
        createdNormalMap = imports.dxCreateShader(imports.unpack(normalMapCache.validNormalTypes[type].rwData))
        normalMapCache.normalMaps.shaders[createdNormalMap] = {
            texture = texture,
            type = type,
            shaderMaps = {}
        }
        normalMapCache.normalMaps.textures[texture] = createdNormalMap
        shaderReference = normalMapCache.normalMaps.shaders[createdNormalMap]
        if normalMapCache.validNormalTypes[type].syncRT then
            imports.syncRTWithShader(createdNormalMap)
        end
        for i, j in imports.pairs(normalMapCache.validNormalTypes[type].parameters) do
            imports.dxSetShaderValue(createdNormalMap, i, imports.unpack(j))
        end
        imports.engineApplyShaderToWorldTexture(createdNormalMap, texture)
    end
    shaderReference.shaderMaps.normal = normalMap
    imports.dxSetShaderValue(createdNormalMap, "enableNormalMap", true)
    imports.dxSetShaderValue(createdNormalMap, "normalTexture", normalMap)
    return createdNormalMap

end

function regenerateNormalMap(texture, shaderReference, destroyShader)

    if not texture and not shaderReference then return false end

    local mapDetails = false
    if shaderReference then
        if shaderReference.shaderMaps then
            mapDetails = shaderReference.shaderMaps
        end
    else
        shaderReference = normalMapCache.normalMaps.textures[texture]
        if shaderReference then
            mapDetails = imports.table.clone(normalMapCache.normalMaps.shaders[shaderReference], true)
            if destroyShader then
                imports.destroyElement(shaderReference)
            end
            normalMapCache.normalMaps.textures[texture] = nil
            normalMapCache.normalMaps.shaders[shaderReference] = nil
        end
    end

    if mapDetails then
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
        end, 1, 1, mapDetails)
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