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
    imports.dxSetShaderValue(createdShaders.sky_RT_Input.shader, "skyControlTexture", createdRTs.skyboxLayer)
    setSkyMapTexture(DEFAULT_SKY_MAP)
    imports.addEventHandler("onClientHUDRender", root, function()
        imports.dxSetRenderTarget(createdRTs.skyboxLayer, true)
        imports.dxDrawImage(0, 0, CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2], createdShaders.sky_RT_Input_Transform.shader, 0, 0, 0)
        imports.dxSetRenderTarget()
        imports.dxDrawImage(0, 0, CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2], createdShaders.sky_RT_Input.shader)
    end, false, PRIORITY_LEVEL.Sky_Render)

    setFilterColor(DEFAULT_FILTER_COLOR)
    if DEFAULT_EMISSIVE_MODE then
        createEmissiveMode()
    end

end)