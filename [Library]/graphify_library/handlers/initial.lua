----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: handlers: initial.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Library Initializer ]]--
----------------------------------------------------------------


-------------------
--[[ Variables ]]--
-------------------

local imports = {
    tonumber = tonumber,
    tostring = tostring,
    collectgarbage = collectgarbage,
    dxGetStatus = dxGetStatus,
    addEvent = addEvent,
    addEventHandler = addEventHandler,
    triggerEvent = triggerEvent
}


-------------------
--[[ Variables ]]--
-------------------

local GPUStatus = imports.dxGetStatus()
isGraphifySupported = (imports.tonumber(GPUStatus.VideoCardNumRenderTargets) > 1) and (imports.tonumber(GPUStatus.VideoCardPSVersion) > 2) and (imports.tostring(GPUStatus.DepthBufferFormat) ~= "unknown")


-----------------------------------------------
--[[ Events: On Client Resource Start/Stop ]]--
-----------------------------------------------

imports.addEvent("onGraphifyLoad", false)
imports.addEvent("onGraphifyUnLoad", false)

imports.addEventHandler("onClientResourceStart", resource, function()

    if isGraphifySupported then
        imports.collectgarbage("setpause", 100)
        imports.triggerEvent("onGraphifyLoad", resource)
    end

end)

imports.addEventHandler("onClientResourceStop", resource, function()

    if isGraphifySupported then
        imports.triggerEvent("onGraphifyUnLoad", resource)
    end

end)
