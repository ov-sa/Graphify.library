----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: handlers: normalMap.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Normal-Map Handler ]]--
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


-----------------------------------------------------------
--[[ Functions: Generates/Re-Generates Normal/Bump-Map ]]--
-----------------------------------------------------------

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

function regenerateNormalMap(texture, destroyMap)

    if not texture then return false end

    local textureReference = normalMapCache.normalMaps.textures[texture]
    if textureReference then
        local normalDetails = imports.table.clone(normalMapCache.normalMaps.shaders[textureReference], false)
        if destroyMap then
            imports.destroyElement(textureReference)
        end
        normalMapCache.normalMaps.textures[texture] = nil
        normalMapCache.normalMaps.shaders[textureReference] = nil
        imports.setTimer(function()
            generateNormalMap(normalDetails.texture, normalDetails.type, normalDetails.normalMap)
        end, 1, 1)
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
            if not controlMapCache.controlMaps.shaders[source] then
                normalMapCache.normalMaps.textures[(normalMapCache.normalMaps.shaders[source].texture)] = nil
                normalMapCache.normalMaps.shaders[source] = nil
            end
        end
    end

end)