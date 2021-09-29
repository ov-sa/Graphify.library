----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: exports: client.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Client Sided Exports ]]--
----------------------------------------------------------------


---------------------------------
--[[ Function: Retrieves RTs ]]--
---------------------------------

function getRTs()

    if isGraphifySupported then 
        return createdRTs
    end
    return false

end