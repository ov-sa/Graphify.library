----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: handlers: loader.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Library Loader ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    unpack = unpack,
    addEventHandler = addEventHandler,
    syncRTWithShader = syncRTWithShader,
    dxCreateRenderTarget = dxCreateRenderTarget,
    dxCreateShader = dxCreateShader,
    dxSetRenderTarget = dxSetRenderTarget,
    dxSetShaderValue = dxSetShaderValue,
    dxDrawMaterialPrimitive3D = dxDrawMaterialPrimitive3D
}


-------------------
--[[ Variables ]]--
-------------------

createdRTs = {
    colorLayer = false,
    normalLayer = false,
    emissiveLayer = false
}

createdShaders = {
    zBuffer = {
        rwData = AVAILABLE_SHADERS["Utilities"]["Z_Buffer"],
        syncRT = false,
        controlNormals = false,
        parameters = {
            ["viewportSize"] = {CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2]}
        }
    }
}


---------------------------------
--[[ Event: On Graphify Load ]]--
---------------------------------

imports.addEventHandler("onGraphifyLoad", root, function()

    for i, j in imports.pairs(createdRTs) do
        createdRTs[i] = imports.dxCreateRenderTarget(CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2], false) 
    end

    for i, j in imports.pairs(createdShaders) do
        j.shader = imports.dxCreateShader(j.rwData)
        if j.shader then
            if j.syncRT then
                syncRTWithShader(j.shader)
            end
            for k, v in imports.pairs(j.parameters) do
                imports.dxSetShaderValue(j.shader, k, imports.unpack(v))
            end
        end
    end

    imports.addEventHandler("onClientPreRender", root, function()
        imports.dxDrawMaterialPrimitive3D("trianglelist", createdShaders.zBuffer.shader, false, {-0.5, 0.5, 0, 0, 1}, {-0.5, -0.5, 0, 0, 0}, {0.5, 0.5, 0, 1, 1}, {0.5, -0.5, 0, 1, 0}, {0.5, 0.5, 0, 1, 1}, {-0.5, -0.5, 0, 0, 0})
        for i, j in imports.pairs(createdRTs) do
            imports.dxSetRenderTarget(j, true)
        end
        imports.dxSetRenderTarget()
    end, true, PRIORITY_LEVEL.RT_RENDER)

end)