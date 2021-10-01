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
    ipairs = ipairs,
    unpack = unpack,
    addEventHandler = addEventHandler,
    syncRTWithShader = syncRTWithShader,
    setShaderTextureList = setShaderTextureList,
    dxCreateRenderTarget = dxCreateRenderTarget,
    dxCreateShader = dxCreateShader,
    dxSetRenderTarget = dxSetRenderTarget,
    dxSetShaderValue = dxSetShaderValue,
    dxDrawMaterialPrimitive3D = dxDrawMaterialPrimitive3D,
    dxDrawImage = dxDrawImage
}


---------------------------------
--[[ Event: On Graphify Load ]]--
---------------------------------

imports.addEventHandler("onGraphifyLoad", root, function()

    for i, j in imports.ipairs(createdRTs["__SORT_ORDER__"]) do
        createdRTs[(j.name)] = imports.dxCreateRenderTarget(CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2], j.alpha)
    end

    for i, j in imports.ipairs(createdShaders["__SORT_ORDER__"]) do
        if createdShaders[j] then
            createdShaders[j].shader = imports.dxCreateShader(imports.unpack(createdShaders[j].rwData))
            if createdShaders[j].shader then
                if createdShaders[j].syncRT then
                    imports.syncRTWithShader(createdShaders[j].shader)
                end
                for k, v in imports.pairs(createdShaders[j].parameters) do
                    imports.dxSetShaderValue(createdShaders[j].shader, k, imports.unpack(v))
                end
                for k, v in imports.ipairs(createdShaders[j].textureLists) do
                    imports.setShaderTextureList(createdShaders[j].shader, v.textureList, v.state)
                end
            end
        end
    end

    imports.addEventHandler("onClientPreRender", root, function()
        if not CLIENT_MTA_MINIMIZED then
            imports.dxDrawMaterialPrimitive3D("trianglelist", createdShaders.zBuffer.shader, false, {-0.5, 0.5, 0, 0, 1}, {-0.5, -0.5, 0, 0, 0}, {0.5, 0.5, 0, 1, 1}, {0.5, -0.5, 0, 1, 0}, {0.5, 0.5, 0, 1, 1}, {-0.5, -0.5, 0, 0, 0})
            for i, j in imports.ipairs(createdRTs["__SORT_ORDER__"]) do
                if createdRTs[(j.name)] and j.isSynced then
                    imports.dxSetRenderTarget(createdRTs[(j.name)], true)
                end
            end
            imports.dxSetRenderTarget()
        end
    end, false, PRIORITY_LEVEL.RT_RENDER)

    imports.dxSetShaderValue(createdShaders.sky_RT_Input.shader, "skyControlMap", createdRTs.emissiveLayer)
    imports.dxSetShaderValue(createdShaders.sky_RT_Input.shader, "skyControlTexture", skyTexture)
    setAmbienceMutiplier(DEFAULT_AMBIENCE)
    if DEFAULT_EMISSIVE then
        createEmissiveMode()
    end

end)


--TODO: TESTING:
blend_color = tocolor(204, 153, 130, 80)

skyTexture = dxCreateTexture("test.png")
imports.addEventHandler("onClientHUDRender", root, function()

    if not createdRTs.skyboxLayer then return false end
 
    --[[
    outputChatBox("YO: "..tostring(createdShaders.sky_RT_Input))
    imports.dxSetRenderTarget(createdRTs.skyboxLayer, true)
    dxDrawRectangle(0, 0, CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2], tocolor(255, 255, 255, 255))
    --imports.dxDrawImage(0, 0, CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2], createdRTs.emissiveLayer, 0, 0, 0, -16777216)
    imports.dxDrawImage(0, 0, CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2], createdRTs.emissiveLayer, 0, 0, 0, tocolor(0, 0, 0))
    imports.dxSetRenderTarget()
    imports.dxDrawImage(100, 100, 1366/3, 768/3, createdRTs.skyboxLayer, 0, 0, 0)
    --dxDrawImage(100 + 1366/3 + 10, 100, 1366/3, 768/3, createdRTs.normalLayer)]]
    
    imports.dxDrawImage(0, 0, 1366, 768, createdShaders.sky_RT_Input.shader)

end)