----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: exports: client.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Client Sided Exports ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    tonumber = tonumber,
    isElement = isElement,
    getElementType = getElementType,
    destroyElement = destroyElement,
    unpackColor = unpackColor,
    disableNormals = disableNormals,
    validateNormalMap = validateNormalMap,
    dxSetShaderValue = dxSetShaderValue,
    engineApplyShaderToWorldTexture = engineApplyShaderToWorldTexture,
    engineRemoveShaderFromWorldTexture = engineRemoveShaderFromWorldTexture,
    math = {
        min = math.min,
        max = math.max
    }
}


---------------------------------------
--[[ Function: Retrieves Layer RTs ]]--
---------------------------------------

function getLayerRTs()

    if isGraphifySupported then 
        return createdRTs
    end
    return false

end


------------------------------------------
--[[ Function: Sets Sky-Map's Texture ]]--
------------------------------------------

function setSkyMapTexture(textureElement)

    if isGraphifySupported and textureElement and imports.isElement(textureElement) and (imports.getElementType(textureElement) == "texture") then
        return imports.dxSetShaderValue(createdShaders.sky_RT_Input_Transform.shader, "skyMapTexture", textureElement)
    end
    return false

end


-----------------------------------------------------
--[[ Functions: Sets Filter's Overlay Mode/Color ]]--
-----------------------------------------------------

function setFilterOverlayMode(state)

    if isGraphifySupported then
        if (state == true) or (state == false) then
            for i, j in imports.pairs(createdShaders) do
                if (i ~= "__SORT_ORDER__") and j.ambientSupport then
                    imports.dxSetShaderValue(j.shader, "enableFilterOverlay", state)
                end
            end
            return true
        end
    end
    return false

end

function setFilterColor(color)

    if isGraphifySupported and (#color >= 4) then
        local isColorValidated = true
        for i = 1, 4, 1 do
            color[i] = imports.tonumber(color[i])
            if not color[i] then
                isColorValidated = false
                break
            else
                color[i] = imports.math.max(-255, imports.math.min(255, color[i]))/255
            end
        end
        if isColorValidated then
            for i, j in imports.pairs(createdShaders) do
                if (i ~= "__SORT_ORDER__") and j.ambientSupport then
                    imports.dxSetShaderValue(j.shader, "filterColor", imports.unpackColor(color))
                end
            end
            return true
        end
    end
    return false

end


------------------------------------------------------------
--[[ Functions: Retrieves/Sets Normal-Gen/Emissive Mode ]]--
------------------------------------------------------------

function setNormalGenMode(...)

    if isGraphifySupported then
        return imports.disableNormals(...)
    end
    return false

end

function getEmissiveMode()

    if isGraphifySupported then
        return emissiveMapCache.state
    end
    return false

end

function setEmissiveMode(state)

    if isGraphifySupported then
        if state == true then
            return createEmissiveMode()
        elseif state == false then
            return destroyEmissiveMode()
        end
    end
    return false

end


-------------------------------------------------------
--[[ Function: Sets Texture's Clear/Emissive State ]]--
-------------------------------------------------------

function setTextureClearState(texture, state, targetElement)

    if isGraphifySupported and texture and ((state == true) or (state == false)) then
        targetElement = (targetElement and imports.isElement(targetElement)) or nil
        local setterFunction = (state and imports.engineApplyShaderToWorldTexture) or imports.engineRemoveShaderFromWorldTexture
        return setterFunction(createdShaders.texClear.shader, texture, targetElement)
    end
    return false

end

function setTextureEmissiveState(texture, type, state, targetElement)

    if isGraphifySupported and texture and type and ((state == true) or (state == false)) then
        type = ((type == "object") and "world") or type
        local emissiveShader = emissiveMapCache.validEmissiveTypes[type]
        if emissiveShader then
            targetElement = (targetElement and imports.isElement(targetElement)) or nil
            local setterFunction = (state and imports.engineApplyShaderToWorldTexture) or imports.engineRemoveShaderFromWorldTexture
            return setterFunction(emissiveShader.shader, texture, targetElement)
        end
    end
    return false

end


----------------------------------------------------------
--[[ Functions: Retrieves/Creates/Destroys Normal-Map ]]--
----------------------------------------------------------

function getNormalMap(texture)

    if isGraphifySupported and texture and normalMapCache.normalMaps.textures[texture] then
        return normalMapCache.normalMaps.textures[texture]
    end
    return false

end

function createNormalMap(...)

    return generateNormalMap(...)

end

function destroyNormalMap(shader)

    if isGraphifySupported then
        local shaderReference = false
        if normalMapCache.normalMaps.shaders[shader] then
            normalMapCache.normalMaps.shaders[shader].shaderMaps.normal = nil
            if not imports.validateNormalMap(shader) then
                shaderReference = shader
            end
        elseif controlMapCache.controlMaps.shaders[shader] then
            shaderReference = shader
        end
        if shaderReference then
            imports.dxSetShaderValue(shaderReference, "enableNormalMap", false)
            imports.dxSetShaderValue(shaderReference, "normalTexture", nil)
        end
        return true
    end
    return false

end


----------------------------------------------
--[[ Functions: Creates/Destroys Bump-Map ]]--
----------------------------------------------

function createBumpMap(...)

    return generateBumpMap(...)

end

function destroyBumpMap(shader)

    if isGraphifySupported then
        local shaderReference = false
        if normalMapCache.normalMaps.shaders[shader] then
            normalMapCache.normalMaps.shaders[shader].shaderMaps.bump = nil
            if not imports.validateNormalMap(shader) then
                shaderReference = shader
            end
        elseif controlMapCache.controlMaps.shaders[shader] then
            shaderReference = shader
        end
        if shaderReference then
            imports.dxSetShaderValue(shaderReference, "enableBumpMap", false)
            imports.dxSetShaderValue(shaderReference, "bumpTexture", nil)
        end
        return true
    end
    return false

end


-----------------------------------------------------------
--[[ Functions: Retrieves/Creates/Destroys Control-Map ]]--
-----------------------------------------------------------

function getControlMap(texture)

    if isGraphifySupported and texture and controlMapCache.controlMaps.textures[texture] then
        return controlMapCache.controlMaps.textures[texture]
    end
    return false

end

function createControlMap(...)

    return generateControlMap(...)

end

function destroyControlMap(shader)

    if isGraphifySupported and controlMapCache.controlMaps.shaders[shader] then
        return imports.destroyElement(shader)
    end
    return true

end