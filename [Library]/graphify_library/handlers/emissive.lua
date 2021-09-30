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
    addEventHandler = addEventHandler
}


-------------------
--[[ Variables ]]--
-------------------

emissiveCache = {
    state = false
}


-------------------------------------
--[[ Event: On Client HUD Render ]]--
-------------------------------------

imports.addEventHandler("onClientHUDRender", root, function()

    if not emissiveCache.state then return false end

    --TODO: PROCESS EMISSIVE HERE

end)


---------------------------------
--[[ Event: On Graphify Load ]]--
---------------------------------

imports.addEventHandler("onGraphifyLoad", root, function()

    --TODO: INITILAIZE SHADER..
    setEmissiveMode(DEFAULT_EMISSIVE)

end)