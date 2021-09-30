----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: handlers: controlmap.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Control-Map Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    isElement = isElement,
    destroyElement = destroyElement,
    addEventHandler = addEventHandler
}


-------------------
--[[ Variables ]]--
-------------------

controlMapCache = {
    controlMaps = {}
}


------------------------------------------
--[[ Event: On Client Element Destroy ]]--
------------------------------------------


imports.addEventHandler("onClientElementDestroy", resourceRoot, function()

    if not isLibraryResourceStopping then
        if controlMapCache.controlMaps[source] then
            for i, j in imports.pairs(controlMapCache.controlMaps[source].controls) do
                if j and imports.isElement(j) then
                    imports.destroyElement(j)
                end
            end
            controlMapCache.controlMaps[source] = nil
        end
    end

end)

function createControlMap()

    --[[
    if emissiveCache["__STATE__"] then return false end

    emissiveCache["__STATE__"] = true
    for i, j in imports.pairs(emissiveCache) do
        if (i ~= "__STATE__") and (i ~= "__BLEND_COLOR__") and (i ~= "__EMISSIVE_CLASS_") then
            j.shader = imports.dxCreateShader(imports.unpack(j.rwData))
            for k, v in imports.pairs(j.parameters) do
                imports.dxSetShaderValue(j.shader, k, imports.unpack(v))
            end
        end
    end
    imports.addEventHandler("onClientHUDRender", root, renderEmissiveMode, false, PRIORITY_LEVEL.Emissive_Render)
    ]]--
    return true

end

--[[
world_RT_Input_ControlMap = {
    rwData = {AVAILABLE_SHADERS["World"]["RT_Input_ControlMap"], 3, 0, false, "world,object"},
    syncRT = true,
    controlNormals = true,
    ambientSupport = true,
    parameters = {

    },
    textureLists = {}
},]]
