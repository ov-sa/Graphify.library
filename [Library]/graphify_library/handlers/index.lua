sX, sY = guiGetScreenSize()
isSM3DBSupported = (tonumber(dxGetStatus().VideoCardPSVersion) > 2) and (tostring(dxGetStatus().DepthBufferFormat) ~= "unknown")
tesselationUpdateDelay = 2500
framesPerSecond = 36
cameraElement = getCamera()
layerRT = dxCreateRenderTarget(sX, sY, true)
localCamera = {}
PrimitiveList = {
    plane = {
        {-0.5, 0.5, 0, 0, 1}, {-0.5, -0.5, 0, 0, 0}, {0.5, 0.5, 0, 1, 1},
        {0.5, -0.5, 0, 1, 0}, {0.5, 0.5, 0, 1, 1}, {-0.5, -0.5, 0, 0, 0}
    },
    cube = {
        {-0.5, -0.5, -0.5, 1, 0}, {-0.5, 0.5, -0.5, 1, 1}, {0.5, 0.5, -0.5, 0, 1},
        {0.5, 0.5, -0.5, 0, 1}, {0.5, -0.5, -0.5, 0, 0}, {-0.5, -0.5, -0.5, 1, 0},
        {-0.5, -0.5, 0.5, 0, 0}, {0.5, -0.5, 0.5, 1, 0}, {0.5, 0.5, 0.5, 1, 1},
        {0.5, 0.5, 0.5, 1, 1}, {-0.5, 0.5, 0.5, 0, 1}, {-0.5, -0.5, 0.5, 0, 0},
        {-0.5, -0.5, -0.5, 0, 0}, {0.5, -0.5, -0.5, 1, 0}, {0.5, -0.5, 0.5, 1, 1},
        {0.5, -0.5, 0.5, 1, 1}, {-0.5, -0.5, 0.5, 0, 1}, {-0.5, -0.5, -0.5, 0, 0},
        {0.5, -0.5, -0.5, 0, 0}, {0.5, 0.5, -0.5, 1, 0}, {0.5, 0.5, 0.5, 1, 1},
        {0.5, 0.5, 0.5, 1, 1}, {0.5, -0.5, 0.5, 0, 1}, {0.5, -0.5, -0.5, 0, 0},
        {0.5, 0.5, -0.5, 0, 0}, {-0.5, 0.5, -0.5, 1, 0}, {-0.5, 0.5, 0.5, 1, 1},
        {-0.5, 0.5, 0.5, 1, 1}, {0.5, 0.5, 0.5, 0, 1}, {0.5, 0.5, -0.5, 0, 0},
        {-0.5, 0.5, -0.5, 0, 0}, {-0.5, -0.5, -0.5, 1, 0}, {-0.5, -0.5, 0.5, 1, 1},
        {-0.5, -0.5, 0.5, 1, 1}, {-0.5, 0.5, 0.5, 0, 1}, {-0.5, 0.5, -0.5, 0, 0}
    }
}
isShaderBlacklist = {
    "fire*", "basketball2", "font*", "radar*", "sitem16", "snipercrosshair",
    "siterocket", "cameracrosshair", "*shad*", "coronastar", "coronamoon", "coronaringa", "coronaheadlightline",
    "lunar", "tx*", "cj_w_grad", "*cloud*", "*smoke*", "sphere_cj", "water*", "newaterfal1_256", "boatwake*", "splash_up", "carsplash_*",
    "fist", "*icon", "headlight*", "sphere", "plaintarmac*", "gensplash", "assetify_light_planar"
}

addEventHandler("onClientResourceStart", resourceRoot, function() collectgarbage("setpause", 100) end)
addEventHandler("onClientPreRender", root, function(msSinceLastFrame)
    lastFrameTickCount = msSinceLastFrame
	framesPerSecond = (1/msSinceLastFrame)*1000
end)

local shaderZBuffer = dxCreateShader(getZBufferFX())
dxSetShaderValue(shaderZBuffer, "fViewportSize", sX, sY)
addEventHandler("onClientPreRender", root, function()
	dxDrawMaterialPrimitive3D("trianglelist", shaderZBuffer, false, unpack(PrimitiveList.plane))
    dxSetRenderTarget(layerRT, true)
    dxSetRenderTarget()
end, true, "high+10")

addEventHandler("onClientHUDRender", root, function()
	localCamera.mat = cameraElement.matrix
	localCamera.position = cameraElement.position
	localCamera.fw = localCamera.mat.forward
	localCamera.farClipDistance = getFarClipDistance()
	localCamera.farClipFront = localCamera.position + (localCamera.mat.forward*localCamera.farClipDistance)
    --dxDrawImage(0, 0, sX*0.45, sY*0.45, layerRT)
end, true, "high+101")

local shaderWorld = dxCreateShader(getLayerFX(), 0, 300, true, "world,ped,object,other")
dxSetShaderValue(shaderWorld, "layerRT", layerRT)
engineApplyShaderToWorldTexture(shaderWorld, "*")
for i = 1, #isShaderBlacklist, 1 do
    local j = isShaderBlacklist[i]
    engineRemoveShaderFromWorldTexture(shaderWorld, j)
end

local shaderLayer = {}
shaderLayer[1] = dxCreateShader(getLayerFX(), 0, 300, true, "vehicle")
shaderLayer[2] = dxCreateShader(getLayerFX(), 0, 300, true, "object")
local shaderLayerElements = {}
for i, j in ipairs(shaderLayer) do
    dxSetShaderValue(j, "layerRT", layerRT)
    dxSetShaderValue(j, "layerBrightness", 0)
    dxSetShaderValue(j, "isAlphaEnabled", i == 1)
    if i == 1 then
        engineApplyShaderToWorldTexture(j, "*")
    end
end
for i = 1, #isShaderBlacklist, 1 do
    local j = isShaderBlacklist[i]
    engineRemoveShaderFromWorldTexture(shaderLayer[1], j)
end
addEventHandler("onClientPreRender", root, function()
    for i, j in ipairs(getElementsByType("vehicle", root, true)) do
        for k, v in ipairs(getAttachedElements(j)) do
            if not shaderLayerElements[v] then
                shaderLayerElements[v] = true
                engineApplyShaderToWorldTexture(shaderLayer[2], "*", v)
            end
        end
    end
end)

function getLayerRT() return layerRT end
function isEntityInFrontalSphere(position, attenuation) return (localCamera.farClipFront - position).length < (localCamera.farClipDistance + attenuation) end