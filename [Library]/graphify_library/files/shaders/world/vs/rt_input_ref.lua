----------------------------------------------------------------
--[[ Resource: Graphify Library
     Shaders: world: vs: rt_input_ref.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: World's RT Ref Inputter ]]--
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
    reference = "RT_Input_Ref",
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
float4 gBlendFactor <string renderState="BLENDFACTOR";>;
int gZWriteEnable <string renderState="ZWRITEENABLE";>;
int gCullMode <string renderState="CULLMODE";>;
int gStage1ColorOp <string stageState="1,COLOROP";>;
float4 gTextureFactor <string renderState="TEXTUREFACTOR";>;
int gStage0TextureTransformFlags <string stageState="0,TEXTURETRANSFORMFLAGS";>;
float4x4 gTransformTexture0 <string transformState="TEXTURE0";>;
float4x4 gTransformTexture1 <string transformState="TEXTURE1";>;
texture colorLayer <string renderTarget = "yes";>;
texture normalLayer <string renderTarget = "yes";>;
texture emissiveLayer <string renderTarget = "yes";>;
// #define GENERATE_NORMALS


/*-----------------
-->> Variables <<--
-------------------*/

bool disableNormals = false;

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
    float2 TexCoord1 : TEXCOORD1;
};

struct PSInput {
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
    float2 TexCoord1 : TEXCOORD1;
    float3 Normal : TEXCOORD2;
    float4 WorldPos : TEXCOORD3;
}; 


/*----------------
-->> Samplers <<--
------------------*/

sampler inputSampler1 = sampler_state {
    Texture = (gTexture0);
};

sampler inputSampler2 = sampler_state {
    Texture = (gTexture1);
};


/*----------------
-->> Handlers <<--
------------------*/

PSInput VertexShaderFunction(VSInput VS) {
    PSInput PS = (PSInput)0;

    float3 Normal;
    if (gDeclNormal != 1) {
        Normal = float3(0, 0, 0);
    } else {
        Normal = mul(VS.Normal, (float3x3)gWorld);
    }
    PS.Normal = Normal;

    float3 ViewNormal = mul(VS.Normal, (float3x3)gWorldView);
    PS.TexCoord = VS.TexCoord;
    PS.TexCoord1 = 0;
    if (gStage1ColorOp == 25) {
        PS.TexCoord1 = ViewNormal.xy;
    }
    if (gStage0TextureTransformFlags != 0) {
        PS.TexCoord = mul(float3(VS.TexCoord.xy, 1), (float3x3)gTransformTexture0);
    }
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

    float4 inputTexel = tex2D(inputSampler1, PS.TexCoord);

    float4 worldColor = inputTexel*PS.Diffuse;
    if (gStage1ColorOp == 25) {
        float4 sphTexel = tex2D(inputSampler2, PS.TexCoord1.xy);
        worldColor.rgb += sphTexel.rgb*gTextureFactor.r;
    }
    output.World = saturate(worldColor);
    output.Color.rgb = inputTexel.rgb;
    output.Color.a = inputTexel.a*PS.Diffuse.a;
    output.Emissive.rgb = 0;
    output.Emissive.a = 1;
	float3 Normal = normalize(PS.Normal);
    if ((PS.Normal.z == 0) || (disableNormals)) {
        output.Normal = float4(0, 0, 0, 1);
    } else {
        output.Normal = float4((Normal.xy*0.5) + 0.5, Normal.z < 0 ? 0.611 : 0.789, 1);
    }
    return output;
}


/*------------------
-->> Techniques <<--
--------------------*/

technique world_rtInputRef {
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