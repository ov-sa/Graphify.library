----------------------------------------------------------------
--[[ Resource: Graphify Library
     Shaders: world: vs: rt_input_controlmap.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: World's RT Control-Map Inputter ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    fetchFileData = fetchFileData
}


-------------------
--[[ Variables ]]--
-------------------

local shaderConfig = {
    category = AVAILABLE_SHADERS["World"]["VS"],
    reference = "RT_Input_ControlMap",
    dependencies = {},
    dependencyData = AVAILABLE_SHADERS["Utilities"]["MTA_Helper"]
}

for i, j in imports.pairs(shaderConfig.dependencies) do
    local fileData = imports.fetchFileData(j)
    if fileData then
        shaderConfig.dependencyData = shaderConfig.dependencyData.."\n"..fileData
    end
end


----------------
--[[ Shader ]]--
----------------

shaderConfig.category[shaderConfig.reference] = [[
/*---------------
-->> Imports <<--
-----------------*/

]]..shaderConfig.dependencyData..[[
int gCapsMaxAnisotropy <string deviceCaps="MaxAnisotropy";>;
texture colorLayer <string renderTarget = "yes";>;
texture normalLayer <string renderTarget = "yes";>;
texture emissiveLayer <string renderTarget = "yes";>;
// #define GENERATE_NORMALS


/*-----------------
-->> Variables <<--
-------------------*/

bool disableNormals = false;
bool enableBump = false;
bool enableFilterOverlay = false;
float4 filterColor;
texture bumpTexture;
float anisotropy = 1;
float redControlScale = 1;
float greenControlScale = 1;
float blueControlScale = 1;
texture redControlTexture;
texture greenControlTexture;
texture blueControlTexture;

struct Pixel {
    float4 World : COLOR0;
    float4 Color : COLOR1;
    float4 Normal : COLOR2;
    float4 Emissive : COLOR3;
};

struct VSInput {
    float3 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float3 Normal : NORMAL0;
    float2 TexCoord : TEXCOORD0;
};

struct PSInput {
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
    float3 Normal : TEXCOORD1;
    float4 WorldPos : TEXCOORD2;
};


/*----------------
-->> Samplers <<--
------------------*/

sampler controlSampler = sampler_state {
    Texture = (gTexture0);
    MipFilter = Linear;
    MaxAnisotropy = gCapsMaxAnisotropy*anisotropy;
    MinFilter = Anisotropic;
};

sampler bumpSampler = sampler_state {
    Texture = (bumpTexture);
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
};

sampler redControlSampler = sampler_state { 
    Texture = (redControlTexture);
    MipFilter = Linear;
    MaxAnisotropy = gCapsMaxAnisotropy*anisotropy;
    MinFilter = Anisotropic;
};

sampler greenControlSampler = sampler_state { 
    Texture = (greenControlTexture);
    MipFilter = Linear;
    MaxAnisotropy = gCapsMaxAnisotropy*anisotropy;
    MinFilter = Anisotropic;
};

sampler blueControlSampler = sampler_state { 
    Texture = (blueControlTexture);
    MipFilter = Linear;
    MaxAnisotropy = gCapsMaxAnisotropy*anisotropy;
    MinFilter = Anisotropic;
}; 


/*----------------
-->> Handlers <<--
------------------*/

PSInput VertexShaderFunction(VSInput VS) {
    PSInput PS = (PSInput)0;
    PS.TexCoord = VS.TexCoord;

    float3 Normal;
    if ((gDeclNormal != 1) || (disableNormals)) {
        Normal = float3(0, 0, 0);
    } else {
        Normal = mul(VS.Normal, (float3x3)gWorld);
    }
    PS.Normal = Normal;

    float4 worldPos = mul(float4(VS.Position.xyz, 1), gWorld);
    float4 viewPos = mul(worldPos, gView);
    float4 projPos = mul(viewPos, gProjection);
    PS.Position = projPos;
    PS.WorldPos = worldPos;
    PS.Diffuse = MTACalcGTABuildingDiffuse(VS.Diffuse);
    return PS;
}

Pixel PixelShaderFunction(PSInput PS) {
    Pixel output;

    float4 controlTexel = tex2D(controlSampler, PS.TexCoord);
    float4 redTexel = tex2D(redControlSampler, PS.TexCoord*redControlScale);
    float4 greenTexel = tex2D(greenControlSampler, PS.TexCoord*greenControlScale);
    float4 blueTexel = tex2D(blueControlSampler, PS.TexCoord*blueControlScale);

    float4 sampledControlTexel = lerp(controlTexel, redTexel, controlTexel.r);
    sampledControlTexel = lerp(controlTexel, redTexel, controlTexel.r);
    sampledControlTexel = lerp(controlTexel, redTexel, controlTexel.r);
    sampledControlTexel = lerp(sampledControlTexel, greenTexel, controlTexel.g);
    sampledControlTexel = lerp(sampledControlTexel, greenTexel, controlTexel.g);
    sampledControlTexel = lerp(sampledControlTexel, greenTexel, controlTexel.g);
    sampledControlTexel = lerp(sampledControlTexel, blueTexel, controlTexel.b);
    sampledControlTexel = lerp(sampledControlTexel, blueTexel, controlTexel.b);
    sampledControlTexel = lerp(sampledControlTexel, blueTexel, controlTexel.b);
    sampledControlTexel.rgb = sampledControlTexel.rgb/3;

    if (enableBump) {
        float4 bumpTexel = tex2D(bumpSampler, PS.TexCoord);
        sampledControlTexel.rgb *= bumpTexel.rgb;
    }
    float4 worldColor = sampledControlTexel;
    if (enableFilterOverlay) {
        worldColor += filterColor;
    } else {
        worldColor *= filterColor;
    }
    worldColor.a = controlTexel.a;
    output.World = saturate(worldColor);
    output.Color.rgb = sampledControlTexel.rgb;
    output.Color.a = sampledControlTexel.a*PS.Diffuse.a;
    output.Emissive.rgb = 0;
    output.Emissive.a = 1;
    float3 Normal = normalize(PS.Normal);
    if (PS.Normal.z == 0) {
        output.Normal = float4(0, 0, 0, 1);
    } else {
        output.Normal = float4((Normal.xy*0.5) + 0.5, Normal.z <0 ? 0.611 : 0.789, 1);
    }
    return output;
}


/*------------------
-->> Techniques <<--
--------------------*/

technique world_rtInputControlMap {
    pass P0 {
        SRGBWriteEnable = false;
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

technique fallback {
    pass P0 {}
}
]]