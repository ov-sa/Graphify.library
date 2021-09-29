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
    addEventHandler = addEventHandler,
    applyRTToShader = applyRTToShader,
    dxCreateRenderTarget = dxCreateRenderTarget,
    dxCreateShader = dxCreateShader,
    dxSetRenderTarget = dxSetRenderTarget,
    dxSetShaderValue = dxSetShaderValue
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
    zBuffer = AVAILABLE_SHADERS["Utilities"]["Z_Buffer"]
}


---------------------------------
--[[ Event: On Graphify Load ]]--
---------------------------------

imports.addEventHandler("onGraphifyLoad", root, function()

    for i, j in imports.pairs(createdRTs) do
        createdRTs[i] = imports.dxCreateRenderTarget(CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2], false) 
    end

    for i, j in imports.pairs(createdShaders) do
        createdShaders[i] = imports.dxCreateShader(j)
        if createdShaders[i] then
            if i == "zBuffer" then
                imports.dxSetShaderValue(createdShaders.zBuffer, "viewportSize", CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2])
            end
        end
    end

    imports.addEventHandler("onClientPreRender", root, function()
        dxDrawMaterialPrimitive3D("trianglelist", createdShaders.zBuffer, false, {-0.5, 0.5, 0, 0, 1}, {-0.5, -0.5, 0, 0, 0}, {0.5, 0.5, 0, 1, 1}, {0.5, -0.5, 0, 1, 0}, {0.5, 0.5, 0, 1, 1}, {-0.5, -0.5, 0, 0, 0})
        for i, j in imports.pairs(createdRTs) do
            imports.dxSetRenderTarget(j, true)
        end
        imports.dxSetRenderTarget()
    end, true, PRIORITY_LEVEL.RT_RENDER)

end)