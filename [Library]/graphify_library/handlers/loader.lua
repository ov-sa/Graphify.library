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
        rwData = {AVAILABLE_SHADERS["Utilities"]["Z_Buffer"]},
        syncRT = false,
        controlNormals = false,
        parameters = {
            ["viewportSize"] = {CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2]}
        },
        textureLists = {}
    },

    worldRTInput = {
        rwData = {AVAILABLE_SHADERS["World"]["RT_Input"], 0, 0, false, "world,object"},
        syncRT = true,
        controlNormals = true,
        parameters = {},
        textureLists = {
            {
                state = true,
                textureList = {"*"}
            },
            {
                state = false,
                textureList = DEFAULT_TEXTURE_CONFIG.BLACKLIST
            },
            {
                state = false,
                textureList = {"roucghstonebrtb", "shad_exp", "shad_ped", "shad_car", "headlight", "headlight1" , "shad_bike", "shad_heli", "shad_rcbaron", "vehiclescratch64" , "lamp_shad_64", "particleskid", "boatsplash", "waterwake", "boatwake1", "coronaringa"}
            },
            {
                state = true,
                textureList = {"ws_tunnelwall2smoked", "shadover_law", "greenshade_64", "greenshade2_64", "venshade*", "blueshade2_64", "blueshade4_64", "greenshade4_64", "metpat64shadow", "bloodpool_*", "plaintarmac1"}
            }
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
        j.shader = imports.dxCreateShader(imports.unpack(j.rwData))
        if j.shader then
            if j.syncRT then
                syncRTWithShader(j.shader)
            end
            for k, v in imports.pairs(j.parameters) do
                imports.dxSetShaderValue(j.shader, k, imports.unpack(v))
            end
            for k, v in imports.ipairs(j.textureLists) do
                setShaderTextureList(j.shader, v.textureList, v.state)
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


--TODO: TESTING:
addEventHandler("onClientRender", root, function()

    if not createdRTs.colorLayer then return false end
 
    dxDrawImage(100, 100, 1366/3, 768/3, createdRTs.colorLayer)

end)