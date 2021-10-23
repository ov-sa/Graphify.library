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
    getElementType = getElementType,
    destroyElement = destroyElement,
    addEventHandler = addEventHandler,
    syncRTWithShader = syncRTWithShader,
    getControlMap = getControlMap,
    dxCreateShader = dxCreateShader,
    dxSetShaderValue = dxSetShaderValue,
    engineApplyShaderToWorldTexture = engineApplyShaderToWorldTexture,
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
                ["filterColor"] = {DEFAULT_FILTER_COLOR}
            }
        }
    },
    bumpMaps = {
        shaders = {},
        textures = {}
    }
}


--------------------------------------
--[[ Function: Generates Bump-Map ]]--
--------------------------------------

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
        for i, j in imports.pairs(bumpMapCache.validBumpTypes[type].parameters) do
            imports.dxSetShaderValue(createdBumpMap, i, imports.unpack(j))
        end
    end
    imports.dxSetShaderValue(createdBumpMap, "bumpTexture", bumpElement)
    bumpMapCache.bumpMaps.shaders[createdBumpMap] = {
        texture = texture,
        bumpElement = bumpElement,
        type = type
    }
    if not textureControlMap then
        imports.engineApplyShaderToWorldTexture(createdBumpMap, texture)
    end
    return createdBumpMap

end


------------------------------------------
--[[ Event: On Client Element Destroy ]]--
------------------------------------------

imports.addEventHandler("onClientElementDestroy", resourceRoot, function()

    if not isLibraryResourceStopping then
        if bumpMapCache.bumpMaps[source] then
            bumpMapCache.bumpMaps.textures[(bumpMapCache.bumpMaps.shaders[source].texture)] = nil
            bumpMapCache.bumpMaps.shaders[source] = nil
        end
    end

end)