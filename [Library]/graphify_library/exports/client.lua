----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: exports: client.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Client Sided Exports ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    disableNormals = disableNormals
}


---------------------------------
--[[ Function: Retrieves RTs ]]--
---------------------------------

function getRTs()

    if isGraphifySupported then 
        return createdRTs
    end
    return false

end


-------------------------------------------------
--[[ Function: Sets Normal Generator's State ]]--
-------------------------------------------------

function setNormalGeneratorState(...)

    if isGraphifySupported then 
        return imports.disableNormals(...)
    end
    return false

end