----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: handlers: emissive.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Emissive Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    unpack = unpack,
    tocolor = tocolor,
    destroyElement = destroyElement,
    addEventHandler = addEventHandler,
    removeEventHandler = removeEventHandler,
    dxCreateRenderTarget = dxCreateRenderTarget,
    dxCreateShader = dxCreateShader,
    dxSetShaderValue = dxSetShaderValue,
    dxSetRenderTarget = dxSetRenderTarget,
    dxDrawImage = dxDrawImage
}


-------------------
--[[ Variables ]]--
-------------------

emissiveCache = {

    ["__STATE__"] = false,
    ["__BLEND_COLOR__"] = imports.tocolor(204, 153, 130, 80),
    ["__EMISSIVE_CLASS_"] = {
        methods = {
            getLayerSize = function(emissiveLayer)
                if not emissiveLayer or not emissiveCache["__EMISSIVE_CLASS_"].pool.pooledRTs[emissiveLayer] then return false end
                return emissiveCache["__EMISSIVE_CLASS_"].pool.pooledRTs[emissiveLayer].sizeX, emissiveCache["__EMISSIVE_CLASS_"].pool.pooledRTs[emissiveLayer].sizeY
            end,
            applyBrightPass = function(emissiveLayer, layerSizeX, layerSizeY)
                if not emissiveLayer then return false end
                if not layerSizeX or not layerSizeY then
                    layerSizeX, layerSizeY = emissiveCache["__EMISSIVE_CLASS_"].methods.getLayerSize(emissiveLayer)
                end
                local layerRT = emissiveCache["__EMISSIVE_CLASS_"].pool.getFreeRT(layerSizeX, layerSizeY)
                if not layerRT then return false end
                imports.dxSetRenderTarget(layerRT, true)
                imports.dxSetShaderValue(emissiveCache.RT_Bright.shader, "rtTexture", emissiveLayer)
                imports.dxDrawImage(0, 0, layerSizeX, layerSizeY, emissiveCache.RT_Bright.shader)
                return layerRT
            end,
            applyDownSample = function(emissiveLayer)
                if not emissiveLayer then return false end
                local layerSizeX, layerSizeY = emissiveCache["__EMISSIVE_CLASS_"].methods.getLayerSize(emissiveLayer)
                layerSizeX = layerSizeX/2; layerSizeY = layerSizeY/2;
                local layerRT = emissiveCache["__EMISSIVE_CLASS_"].pool.getFreeRT(layerSizeX, layerSizeY)
                if not layerRT then return false end
                imports.dxSetRenderTarget(layerRT)
                imports.dxDrawImage(0, 0, layerSizeX, layerSizeY, emissiveLayer)
                return layerRT
            end,
            applyBlurX = function(emissiveLayer)
                if not emissiveLayer then return false end
                local layerSizeX, layerSizeY = emissiveCache["__EMISSIVE_CLASS_"].methods.getLayerSize(emissiveLayer)
                local layerRT = emissiveCache["__EMISSIVE_CLASS_"].pool.getFreeRT(layerSizeX, layerSizeY)
                if not layerRT then return false end
                imports.dxSetRenderTarget(layerRT, true) 
                imports.dxSetShaderValue(emissiveCache.RT_BlurX.shader, "rtTexture", emissiveLayer)
                imports.dxDrawImage(0, 0, layerSizeX, layerSizeY, emissiveCache.RT_BlurX.shader)
                return layerRT
            end,
            applyBlurY = function(emissiveLayer)
                if not emissiveLayer then return false end
                local layerSizeX, layerSizeY = emissiveCache["__EMISSIVE_CLASS_"].methods.getLayerSize(emissiveLayer)
                local layerRT = emissiveCache["__EMISSIVE_CLASS_"].pool.getFreeRT(layerSizeX, layerSizeY)
                if not layerRT then return false end
                imports.dxSetRenderTarget(layerRT, true) 
                imports.dxSetShaderValue(emissiveCache.RT_BlurY.shader, "rtTexture", emissiveLayer)
                imports.dxDrawImage(0, 0, layerSizeX, layerSizeY, emissiveCache.RT_BlurY.shader)
                return layerRT
            end
        },

        pool = {
            pooledRTs = {},
            resetPool = function()
                for i, j in imports.pairs(emissiveCache["__EMISSIVE_CLASS_"].pool.pooledRTs) do
                    j.isRTUsed = false
                end
            end,
            clearPool = function()
                for i, j in imports.pairs(emissiveCache["__EMISSIVE_CLASS_"].pool.pooledRTs) do
                    imports.destroyElement(i)
                end
                emissiveCache["__EMISSIVE_CLASS_"].pool.pooledRTs = {}
            end,
            getFreeRT = function(sizeX, sizeY)
                for i, j in imports.pairs(emissiveCache["__EMISSIVE_CLASS_"].pool.pooledRTs) do
                    if not j.isRTUsed and (j.sizeX == sizeX) and (j.sizeY == sizeY) then
                        j.isRTUsed = true
                        return i
                    end
                end
                local createdRT = imports.dxCreateRenderTarget(sizeX, sizeY)
                if createdRT then
                    emissiveCache["__EMISSIVE_CLASS_"].pool.pooledRTs[createdRT] = {isRTUsed = true, sizeX = sizeX, sizeY = sizeY}
                end
                return createdRT
            end
        }
    },

    RT_Bright = {
        rwData = {AVAILABLE_SHADERS["Bloom"]["RT_Bright"]},
        parameters = {
            ["rtCuttOff"] = {0.001},
            ["rtPower"] = {0.001}
        }
    },

    RT_Blend = {
        rwData = {AVAILABLE_SHADERS["Bloom"]["RT_Blend"]},
        parameters = {}
    },

    RT_BlurX = {
        rwData = {AVAILABLE_SHADERS["Bloom"]["RT_BlurX"]},
        parameters = {
            ["bloomMultiplier"] = {1.3},
            ["blurMultiplier"] = {3},
            ["viewportSize"] = {CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2]}
        }
    },

    RT_BlurY = {
        rwData = {AVAILABLE_SHADERS["Bloom"]["RT_BlurY"]},
        parameters = {
            ["bloomMultiplier"] = {2.6},
            ["blurMultiplier"] = {5},
            ["viewportSize"] = {CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2]}
        }
    }

}


---------------------------------------------------
--[[ Functions: Creates/Destroys Emissive Mode ]]--
---------------------------------------------------

local function renderEmissiveMode()

    emissiveCache["__EMISSIVE_CLASS_"].pool.resetPool()
    local emissiveLayer = createdRTs.emissiveLayer
    emissiveLayer = emissiveCache["__EMISSIVE_CLASS_"].methods.applyBrightPass(emissiveLayer, CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2])
    emissiveLayer = emissiveCache["__EMISSIVE_CLASS_"].methods.applyDownSample(emissiveLayer)
    emissiveLayer = emissiveCache["__EMISSIVE_CLASS_"].methods.applyDownSample(emissiveLayer)
    emissiveLayer = emissiveCache["__EMISSIVE_CLASS_"].methods.applyBlurX(emissiveLayer)
    emissiveLayer = emissiveCache["__EMISSIVE_CLASS_"].methods.applyBlurY(emissiveLayer)
    imports.dxSetRenderTarget()
    if not emissiveLayer then return false end
    imports.dxSetShaderValue(emissiveCache.RT_Blend.shader, "rtTexture", emissiveLayer)
    imports.dxDrawImage(0, 0, CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2], emissiveCache.RT_Blend.shader, 0, 0, 0, emissiveCache["__BLEND_COLOR__"])
    
end

function createEmissiveMode()

    if emissiveCache["__STATE__"] then return false end

    emissiveCache["__STATE__"] = true
    for i, j in imports.pairs(emissiveCache) do
        if (i ~= "__STATE__") and (i ~= "__BLEND_COLOR__") and (i ~= "__EMISSIVE_CLASS_") then
            j.shader = imports.dxCreateShader(imports.unpack(j.rwData))
            for k, v in imports.pairs(j.parameters) do
                imports.dxSetShaderValue(j.shader, k, imports.unpack(v))
            end
        end
    end
    imports.addEventHandler("onClientHUDRender", root, renderEmissiveMode, false, PRIORITY_LEVEL.Emissive_Render)
    return true

end

function destroyEmissiveMode()

    if not emissiveCache["__STATE__"] then return false end

    imports.removeEventHandler("onClientHUDRender", root, renderEmissiveMode)
    emissiveCache["__EMISSIVE_CLASS_"].pool.clearPool()
    emissiveCache["__STATE__"] = false
    return true

end
