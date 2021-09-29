----------------------------------------------------------------
--[[ Resource: Graphify Library
     Script: handlers: cache.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Cache Handler ]]--
----------------------------------------------------------------


-------------------
--[[ Variables ]]--
-------------------

createdRTs = {

    ["__SORT_ORDER__"] = {"colorLayer", "normalLayer", "emissiveLayer"}

}

createdShaders = {

    ["__SORT_ORDER__"] = {"zBuffer", "world_RT_Input", "world_RT_Input_Ref", "world_RT_Input_Grass", "world_RT_NoZWrite_", "world_RT_Emissive_"},

    zBuffer = {
        rwData = {AVAILABLE_SHADERS["Utilities"]["Z_Buffer"]},
        syncRT = false,
        controlNormals = false,
        ambientSupport = false,
        parameters = {
            ["viewportSize"] = {CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2]}
        },
        textureLists = {}
    },

    world_RT_Input = {
        rwData = {AVAILABLE_SHADERS["World"]["RT_Input"], 0, 0, false, "world,object"},
        syncRT = true,
        controlNormals = true,
        ambientSupport = true,
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
    },

    world_RT_Input_Ref = {
        rwData = {AVAILABLE_SHADERS["World"]["RT_Input_Ref"], 1, 0, false, "world,object"},
        syncRT = true,
        controlNormals = true,
        ambientSupport = false,
        parameters = {},
        textureLists = {
            {
                state = true,
                textureList = {"newaterfal1_256", "casinolit2_128", "casinolights6lit3_256", "casinolights1b_128n", "royaleroof01_64", "flmngo11_128", "flmngo05_256", "flmngo04_256"}
            }
        }
    },

    world_RT_Input_Grass = {
        rwData = {AVAILABLE_SHADERS["World"]["RT_Input_Grass"], 0, 0, false, "world"},
        syncRT = true,
        controlNormals = false,
        ambientSupport = true,
        parameters = {},
        textureLists = {
            {
                state = true,
                textureList = {"tx*"}
            }
        }
    },

    world_RT_NoZWrite_ = {
        rwData = {AVAILABLE_SHADERS["World"]["RT_Input_NoZWrite"], 2, 0, false, "world,object,vehicle"},
        syncRT = true,
        controlNormals = true,
        ambientSupport = true,
        parameters = {},
        textureLists = {
            {
                state = true,
                textureList = {"roucghstonebrtb", "vehiclescratch64" , "lamp_shad_64", "particleskid"}
            }
        }
    },

    world_RT_Emissive_ = {
        rwData = {AVAILABLE_SHADERS["World"]["RT_Input_Emissive"], 3, 0, false, "world,object"},
        syncRT = true,
        controlNormals = true,
        ambientSupport = false,
        parameters = {},
        textureLists = {}
    }

}