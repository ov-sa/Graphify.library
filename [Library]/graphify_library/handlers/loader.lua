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
    dxDrawMaterialPrimitive3D = dxDrawMaterialPrimitive3D
}


---------------------------------
--[[ Event: On Graphify Load ]]--
---------------------------------

imports.addEventHandler("onGraphifyLoad", root, function()

    for i, j in imports.ipairs(createdRTs["__SORT_ORDER__"]) do
        createdRTs[j] = imports.dxCreateRenderTarget(CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2], false)
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
    setAmbienceMutiplier(DEFAULT_AMBIENCE)

    imports.addEventHandler("onClientPreRender", root, function()
        imports.dxDrawMaterialPrimitive3D("trianglelist", createdShaders.zBuffer.shader, false, {-0.5, 0.5, 0, 0, 1}, {-0.5, -0.5, 0, 0, 0}, {0.5, 0.5, 0, 1, 1}, {0.5, -0.5, 0, 1, 0}, {0.5, 0.5, 0, 1, 1}, {-0.5, -0.5, 0, 0, 0})
        for i, j in imports.ipairs(createdRTs["__SORT_ORDER__"]) do
            if createdRTs[j] then
                imports.dxSetRenderTarget(createdRTs[j], true)
            end
        end
        imports.dxSetRenderTarget()
    end, false, PRIORITY_LEVEL.RT_RENDER)

end)


--TODO: TESTING:
addEventHandler("onClientRender", root, function()

    if not createdRTs.colorLayer then return false end
 
    dxDrawImage(100, 100, 1366/3, 768/3, createdRTs.colorLayer)
    --dxDrawImage(100 + 1366/3 + 10, 100, 1366/3, 768/3, createdRTs.normalLayer)

end)