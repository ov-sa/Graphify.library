  
----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: settings: client.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Client Sided Settings ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    dxCreateTexture = dxCreateTexture
}


------------------
--[[ Settings ]]--
------------------

DEFAULT_VS_MODE = true
DEFAULT_EMISSIVE_MODE = true
DEFAULT_FILTER_COLOR = {0, 0, 0, 0}
DEFAULT_SKY_MAP = imports.dxCreateTexture("files/textures/sky/default.jpg", "argb", true, "clamp")
DEFAULT_TEXTURE_CONFIG = {
    BLACKLIST = {
        "",	"unnamed", "fire*", "basketball2", "skybox_tex*", "font*", "radar*", "sitem16", "snipercrosshair",
        "siterocket", "cameracrosshair", "*shad*", "coronastar", "coronamoon", "coronaringa", "coronaheadlightline",
        "lunar", "tx*", "cj_w_grad", "*cloud*", "*smoke*", "sphere_cj", "water*", "newaterfal1_256", "boatwake*", "splash_up", "carsplash_*",
        "fist", "*icon", "headlight*", "sphere", "plaintarmac*", "vehiclegrunge256", "?emap*", "vehiclegeneric*", "gensplash"
    }
}

PRIORITY_LEVEL = {
    RT_RENDER = "high+1000",
    Sky_Render = "low-1000",
    Emissive_Render = "low-999"
}