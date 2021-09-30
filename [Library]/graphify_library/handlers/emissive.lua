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

emissiveMapCache = {

    state = false,
    blend_color = imports.tocolor(204, 153, 130, 80),
    validEmissiveTypes = {
        ["world"] = createdShaders["world_RT_Input_Emissive"]
    },
    validEmissivePasses = {
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
    },
    class = {
        methods = {
            getLayerSize = function(emissiveLayer)
                if not emissiveLayer or not emissiveMapCache.class.pool.pooledRTs[emissiveLayer] then return false end
                return emissiveMapCache.class.pool.pooledRTs[emissiveLayer].sizeX, emissiveMapCache.class.pool.pooledRTs[emissiveLayer].sizeY
            end,
            applyBrightPass = function(emissiveLayer, layerSizeX, layerSizeY)
                if not emissiveLayer then return false end
                if not layerSizeX or not layerSizeY then
                    layerSizeX, layerSizeY = emissiveMapCache.class.methods.getLayerSize(emissiveLayer)
                end
                local layerRT = emissiveMapCache.class.pool.getFreeRT(layerSizeX, layerSizeY)
                if not layerRT then return false end
                imports.dxSetRenderTarget(layerRT, true)
                imports.dxSetShaderValue(emissiveMapCache.validEmissivePasses.RT_Bright.shader, "rtTexture", emissiveLayer)
                imports.dxDrawImage(0, 0, layerSizeX, layerSizeY, emissiveMapCache.validEmissivePasses.RT_Bright.shader)
                return layerRT
            end,
            applyDownSample = function(emissiveLayer)
                if not emissiveLayer then return false end
                local layerSizeX, layerSizeY = emissiveMapCache.class.methods.getLayerSize(emissiveLayer)
                layerSizeX = layerSizeX/2; layerSizeY = layerSizeY/2;
                local layerRT = emissiveMapCache.class.pool.getFreeRT(layerSizeX, layerSizeY)
                if not layerRT then return false end
                imports.dxSetRenderTarget(layerRT)
                imports.dxDrawImage(0, 0, layerSizeX, layerSizeY, emissiveLayer)
                return layerRT
            end,
            applyBlurX = function(emissiveLayer)
                if not emissiveLayer then return false end
                local layerSizeX, layerSizeY = emissiveMapCache.class.methods.getLayerSize(emissiveLayer)
                local layerRT = emissiveMapCache.class.pool.getFreeRT(layerSizeX, layerSizeY)
                if not layerRT then return false end
                imports.dxSetRenderTarget(layerRT, true) 
                imports.dxSetShaderValue(emissiveMapCache.validEmissivePasses.RT_BlurX.shader, "rtTexture", emissiveLayer)
                imports.dxDrawImage(0, 0, layerSizeX, layerSizeY, emissiveMapCache.validEmissivePasses.RT_BlurX.shader)
                return layerRT
            end,
            applyBlurY = function(emissiveLayer)
                if not emissiveLayer then return false end
                local layerSizeX, layerSizeY = emissiveMapCache.class.methods.getLayerSize(emissiveLayer)
                local layerRT = emissiveMapCache.class.pool.getFreeRT(layerSizeX, layerSizeY)
                if not layerRT then return false end
                imports.dxSetRenderTarget(layerRT, true) 
                imports.dxSetShaderValue(emissiveMapCache.validEmissivePasses.RT_BlurY.shader, "rtTexture", emissiveLayer)
                imports.dxDrawImage(0, 0, layerSizeX, layerSizeY, emissiveMapCache.validEmissivePasses.RT_BlurY.shader)
                return layerRT
            end
        },

        pool = {
            pooledRTs = {},
            resetPool = function()
                for i, j in imports.pairs(emissiveMapCache.class.pool.pooledRTs) do
                    j.isRTUsed = false
                end
            end,
            clearPool = function()
                for i, j in imports.pairs(emissiveMapCache.class.pool.pooledRTs) do
                    imports.destroyElement(i)
                end
                emissiveMapCache.class.pool.pooledRTs = {}
            end,
            getFreeRT = function(sizeX, sizeY)
                for i, j in imports.pairs(emissiveMapCache.class.pool.pooledRTs) do
                    if not j.isRTUsed and (j.sizeX == sizeX) and (j.sizeY == sizeY) then
                        j.isRTUsed = true
                        return i
                    end
                end
                local createdRT = imports.dxCreateRenderTarget(sizeX, sizeY)
                if createdRT then
                    emissiveMapCache.class.pool.pooledRTs[createdRT] = {isRTUsed = true, sizeX = sizeX, sizeY = sizeY}
                end
                return createdRT
            end
        }
    }

}


---------------------------------------------------
--[[ Functions: Creates/Destroys Emissive Mode ]]--
---------------------------------------------------

local function renderEmissiveMode()

    if CLIENT_MTA_MINIMIZED then return false end

    emissiveMapCache.class.pool.resetPool()
    local emissiveLayer = createdRTs.emissiveLayer
    emissiveLayer = emissiveMapCache.class.methods.applyBrightPass(emissiveLayer, CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2])
    emissiveLayer = emissiveMapCache.class.methods.applyDownSample(emissiveLayer)
    emissiveLayer = emissiveMapCache.class.methods.applyDownSample(emissiveLayer)
    emissiveLayer = emissiveMapCache.class.methods.applyBlurX(emissiveLayer)
    emissiveLayer = emissiveMapCache.class.methods.applyBlurY(emissiveLayer)
    imports.dxSetRenderTarget()
    if not emissiveLayer then return false end
    imports.dxSetShaderValue(emissiveMapCache.validEmissivePasses.RT_Blend.shader, "rtTexture", emissiveLayer)
    imports.dxDrawImage(0, 0, CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2], emissiveMapCache.validEmissivePasses.RT_Blend.shader, 0, 0, 0, emissiveMapCache.blend_color)
    
end

function createEmissiveMode()

    if emissiveMapCache.state then return false end

    emissiveMapCache.state = true
    for i, j in imports.pairs(emissiveMapCache.validEmissivePasses) do
        j.shader = imports.dxCreateShader(imports.unpack(j.rwData))
        for k, v in imports.pairs(j.parameters) do
            imports.dxSetShaderValue(j.shader, k, imports.unpack(v))
        end
    end
    imports.addEventHandler("onClientHUDRender", root, renderEmissiveMode, false, PRIORITY_LEVEL.Emissive_Render)
    return true

end

function destroyEmissiveMode()

    if not emissiveMapCache.state then return false end

    imports.removeEventHandler("onClientHUDRender", root, renderEmissiveMode)
    emissiveMapCache.class.pool.clearPool()
    emissiveMapCache.state = false
    return true

end
