----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: handlers: bumpMap.lua
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
    unpack = unpack,
    isElement = isElement,
    getElementType = getElementType,
    syncRTWithShader = syncRTWithShader,
    getControlMap = getControlMap,
    dxCreateShader = dxCreateShader,
    dxSetShaderValue = dxSetShaderValue,
    engineApplyShaderToWorldTexture = engineApplyShaderToWorldTexture,
    table = {
        clone = table.clone
    }
}


--------------------------------------
--[[ Function: Generates Bump-Map ]]--
--------------------------------------

function generateBumpMap(texture, type, bumpElement)

    type = ((type == "object") and "world") or type
    if not texture or not type or not normalMapCache.validNormalTypes[type] or not bumpElement or not imports.isElement(bumpElement) or (imports.getElementType(bumpElement) ~= "texture") or normalMapCache.normalMaps.textures[texture] then return false end

    local createdNormalMap = false
    local textureControlMap = imports.getControlMap(texture)
    if textureControlMap then
        createdNormalMap = textureControlMap
    else
        createdNormalMap = imports.dxCreateShader(imports.unpack(normalMapCache.validNormalTypes[type].rwData))
        if normalMapCache.validNormalTypes[type].syncRT then
            imports.syncRTWithShader(createdNormalMap)
        end
    end
    for i, j in imports.pairs(normalMapCache.validNormalTypes[type].parameters) do
        imports.dxSetShaderValue(createdNormalMap, i, imports.unpack(j))
    end
    imports.dxSetShaderValue(createdNormalMap, "enableBumpMap", true)
    imports.dxSetShaderValue(createdNormalMap, "bumpTexture", bumpElement)
    normalMapCache.normalMaps.shaders[createdNormalMap] = {
        texture = texture,
        type = type,
        shaderMaps = {
            bumpElement = bumpElement
        }
    }
    normalMapCache.normalMaps.textures[texture] = createdNormalMap
    if not textureControlMap then
        imports.engineApplyShaderToWorldTexture(createdNormalMap, texture)
    end
    return createdNormalMap

end