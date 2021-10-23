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

    ["__SORT_ORDER__"] = {
        {name = "colorLayer", alpha = false, isSynced = true},
        {name = "normalLayer", alpha = false, isSynced = true},
        {name = "emissiveLayer", alpha = true, isSynced = true},
        {name = "skyboxLayer", alpha = true, isSynced = false}
    }

}

createdShaders = {

    ["__SORT_ORDER__"] = {
        "zBuffer", "texClear",
        "world_RT_Input", "world_RT_Input_Ref", "world_RT_Input_Grass","world_RT_Input_NoZWrite", "world_RT_Input_Emissive",
        "ped_RT_Input",
        "vehicle_RT_Input",
        "sky_RT_Input", "sky_RT_Input_Transform",
        "water_RT_Input", "water_RT_Input_Detail", "water_RT_Input_WaterWake"
    },

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

    texClear = {
        rwData = {AVAILABLE_SHADERS["Utilities"]["Tex_Clear"], 1000, 0, false, "all"},
        syncRT = false,
        controlNormals = false,
        ambientSupport = false,
        parameters = {},
        textureLists = {}
    },

    world_RT_Input = {
        rwData = {((DEFAULT_VS_MODE and AVAILABLE_SHADERS["World"]["VS"]["No_Bump"]) or AVAILABLE_SHADERS["World"]["No_VS"]["No_Bump"])["RT_Input"], 0, 0, false, "world,object"},
        syncRT = true,
        controlNormals = (DEFAULT_VS_MODE and true) or false,
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
                textureList = {"roucghstonebrtb", "shad_exp", "shad_ped", "shad_car", "headlight", "headlight1", "shad_bike", "shad_heli", "shad_rcbaron", "vehiclescratch64", "lamp_shad_64", "particleskid", "boatsplash", "waterwake", "boatwake1", "coronaringa"}
            },
            {
                state = true,
                textureList = {"ws_tunnelwall2smoked", "shadover_law", "greenshade_64", "greenshade2_64", "venshade*", "blueshade2_64", "blueshade4_64", "greenshade4_64", "metpat64shadow", "bloodpool_*", "plaintarmac1"}
            }
        }
    },

    world_RT_Input_Ref = {
        rwData = {((DEFAULT_VS_MODE and AVAILABLE_SHADERS["World"]["VS"]) or AVAILABLE_SHADERS["World"]["No_VS"])["RT_Input_Ref"], 1, 0, false, "world,object"},
        syncRT = true,
        controlNormals = (DEFAULT_VS_MODE and true) or false,
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
        rwData = {((DEFAULT_VS_MODE and AVAILABLE_SHADERS["World"]["VS"]) or AVAILABLE_SHADERS["World"]["No_VS"])["RT_Input_Grass"], 0, 0, false, "world"},
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

    world_RT_Input_NoZWrite = {
        rwData = {((DEFAULT_VS_MODE and AVAILABLE_SHADERS["World"]["VS"]) or AVAILABLE_SHADERS["World"]["No_VS"])["RT_Input_NoZWrite"], 2, 0, false, "world,object,vehicle"},
        syncRT = true,
        controlNormals = (DEFAULT_VS_MODE and true) or false,
        ambientSupport = true,
        parameters = {},
        textureLists = {
            {
                state = true,
                textureList = {"roucghstonebrtb", "vehiclescratch64", "lamp_shad_64", "particleskid"}
            }
        }
    },

    world_RT_Input_Emissive = {
        rwData = {((DEFAULT_VS_MODE and AVAILABLE_SHADERS["World"]["VS"]) or AVAILABLE_SHADERS["World"]["No_VS"])["RT_Input_Emissive"], 3, 0, false, "world,object"},
        syncRT = true,
        controlNormals = (DEFAULT_VS_MODE and true) or false,
        ambientSupport = false,
        parameters = {},
        textureLists = {}
    },

    ped_RT_Input = {
        rwData = {AVAILABLE_SHADERS["Ped"]["RT_Input"], 0, 0, false, "ped"},
        syncRT = true,
        controlNormals = false,
        ambientSupport = true,
        parameters = {},
        textureLists = {
            {
                state = true,
                textureList = {"*"}
            },
            {
                state = false,
                textureList = {"unnamed"}
            }
        }
    },

    vehicle_RT_Input = {
        rwData = {((DEFAULT_VS_MODE and AVAILABLE_SHADERS["Vehicle"]["VS"]) or AVAILABLE_SHADERS["Vehicle"]["No_VS"])["RT_Input"], 0, 0, false, "vehicle"},
        syncRT = true,
        controlNormals = false,
        ambientSupport = true,
        parameters = {},
        textureLists = {
            {
                state = true,
                textureList = {
                    "*", "vehiclegeneric256", "vehiclegrunge256", "?emap*", "vehicleshatter128", "predator92body128", "monsterb92body256a", "monstera92body256a", "andromeda92wing", "fcr90092body128",
                    "hotknifebody128b", "hotknifebody128a", "rcbaron92texpage64", "rcgoblin92texpage128", "rcraider92texpage128", "rctiger92body128", "rhino92texpage256", "petrotr92interior128", "artict1logos", "rumpo92adverts256", "dash92interior128",
                    "coach92interior128", "combinetexpage128", "policemiami86body128", "policemiami868bit128", "hotdog92body256", "raindance92body128", "cargobob92body256", "andromeda92body", "at400_92_256", "nevada92body256", "polmavbody128a", "sparrow92body128",
                    "hunterbody8bit256a", "seasparrow92floats64","dodo92body8bit256", "cropdustbody256", "beagle256", "hydrabody256", "rustler92body256",
                    "shamalbody256", "skimmer92body128", "stunt256", "maverick92body128", "leviathnbody8bit256"
                }
            },
            {
                state = false,
                textureList = {"unnamed"}
            }
        }
    },

    sky_RT_Input = {
        rwData = {AVAILABLE_SHADERS["Sky"]["RT_Input"], 0, 0, false},
        syncRT = false,
        controlNormals = false,
        ambientSupport = false,
        parameters = {},
        textureLists = {}
    },

    sky_RT_Input_Transform = {
        rwData = {AVAILABLE_SHADERS["Sky"]["RT_Input_Transform"], 0, 0, false},
        syncRT = false,
        controlNormals = false,
        ambientSupport = false,
        parameters = {
            ["viewportSize"] = {CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2]}
        },
        textureLists = {}
    },

    water_RT_Input = {
        rwData = {AVAILABLE_SHADERS["Water"]["RT_Input"], 0, 0, false, "world,object"},
        syncRT = true,
        controlNormals = false,
        ambientSupport = true,
        parameters = {},
        textureLists = {
            {
                state = true,
                textureList = {"water*"}
            }
        }
    },

    water_RT_Input_Detail = {
        rwData = {AVAILABLE_SHADERS["Water"]["RT_Input_Detail"], 0, 0, false, "world,object"},
        syncRT = true,
        controlNormals = false,
        ambientSupport = true,
        parameters = {
            ["worldZBias"] = {0.01}
        },
        textureLists = {
            {
                state = true,
                textureList = {"boatsplash", "boatwake*", "coronaringa"}
            }
        }
    },

    water_RT_Input_WaterWake = {
        rwData = {AVAILABLE_SHADERS["Water"]["RT_Input_Detail"], 0, 0, false, "world,object"},
        syncRT = true,
        controlNormals = false,
        ambientSupport = true,
        parameters = {
            ["worldZBias"] = {0.45}
        },
        textureLists = {
            {
                state = true,
                textureList = {"waterwake"}
            }
        }
    }

}