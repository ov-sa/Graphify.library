----------------------------------------------------------------
--[[ Resource: Graphify Library
     Shaders: world: rt_input.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: World's RT Inputter ]]--
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
    category = "World",
    reference = "RT_Input",
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

AVAILABLE_SHADERS[shaderConfig.category][shaderConfig.reference] = [[
/*---------------
-->> Imports <<--
-----------------*/

]]..shaderConfig.dependencyData..[[
texture colorLayer <string renderTarget = "yes";>;
texture normalLayer <string renderTarget = "yes";>;
texture emissiveLayer <string renderTarget = "yes";>;
// #define GENERATE_NORMALS


/*-----------------
-->> Variables <<--
-------------------*/

bool disableNormals = false;
float ambienceMultiplier = false;

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

sampler inputSampler = sampler_state {
    Texture = (gTexture0);
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
	
    float4 inputTexel = tex2D(inputSampler, PS.TexCoord);

    float4 worldColor = inputTexel*PS.Diffuse;
    if (ambienceMultiplier) {
        worldColor.rgb = ambienceMultiplier;
    }
    output.World = saturate(worldColor);
    output.Color.rgb = inputTexel.rgb;
    output.Color.a = inputTexel.a*PS.Diffuse.a;
    output.Emissive.rgb = 0;
    output.Emissive.a = 1;
    float3 Normal = normalize(PS.Normal);
    if (PS.Normal.z == 0) {
        output.Normal = float4(0, 0, 0, 1);
    } else {
        output.Normal = float4((Normal.xy*0.5) + 0.5, Normal.z < 0 ? 0.611 : 0.789, 1);
    }
    return output;
}


/*------------------
-->> Techniques <<--
--------------------*/

technique world_rtInput {
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