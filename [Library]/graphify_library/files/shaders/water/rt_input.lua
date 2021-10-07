----------------------------------------------------------------
--[[ Resource: Graphify Library
     Shaders: water: rt_input.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Water's RT Inputter ]]--
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
    category = AVAILABLE_SHADERS["Water"],
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

shaderConfig.category[shaderConfig.reference] = [[
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

bool filterOverlayMode;
float4 filterColor;

struct Pixel {
    float4 World : COLOR0;
    float4 Color : COLOR1;
    float4 Normal : COLOR2;
    float4 Emissive : COLOR3;
};

struct VSInput {
    float3 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

struct PSInput {
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
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

    float4 worldPos = mul(float4(VS.Position.xyz, 1), gWorld);
    float4 viewPos = mul(worldPos, gView);
    float4 projPos = mul(viewPos, gProjection);
    PS.Position = projPos;
    PS.Diffuse = MTACalcGTABuildingDiffuse(VS.Diffuse);
    return PS;
}

Pixel PixelShaderFunction(PSInput PS) {
    Pixel output;
	
    float4 inputTexel = tex2D(inputSampler, PS.TexCoord);

    float4 worldColor = inputTexel*PS.Diffuse;
    if (filterOverlayMode) {
        worldColor += filterColor;
    } else {
        worldColor *= filterColor;
    }
    worldColor.a = inputTexel.a;
    output.World = saturate(worldColor);
    output.Color.rgb = inputTexel.rgb*PS.Diffuse.rgb;
    output.Color.a = inputTexel.a*PS.Diffuse.a;
    output.Emissive.rgb = 0;
    output.Emissive.a = 1;
    output.Normal = float4(0.5, 0.5, 0.589, 1);
    return output;
}


/*------------------
-->> Techniques <<--
--------------------*/

technique water_rtInput {
    pass P0 {
        ZWriteEnable = true;
        SRGBWriteEnable = false;
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

technique fallback {
    pass P0 {}
}
]]