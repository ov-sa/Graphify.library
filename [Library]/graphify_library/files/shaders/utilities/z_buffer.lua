----------------------------------------------------------------
--[[ Resource: Graphify Library
     Shaders: utilities: z_buffer.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Z-Buffer Recoverer ]]--
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
    category = "Utilities",
    reference = "Z_Buffer",
    dependencies = {},
    dependencyData = ""
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
texture gDepthBuffer : DEPTHBUFFER;
int gCapsMaxAnisotropy <string deviceCaps="MaxAnisotropy";>;
int CUSTOMFLAGS <string skipUnusedParameters = "yes";>;


/*-----------------
-->> Variables <<--
-------------------*/

float2 viewportSize = float2(800, 600);
float2 viewportScale = float2(1, 1);
float2 viewportSPosition = float2(0, 0);

struct Pixel {
    float4 World : COLOR0;
    float Depth : DEPTH;      
};

struct VSInput {
    float3 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
};

struct PSInput {
    float4 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
};


/*----------------
-->> Samplers <<--
------------------*/

sampler bufferSampler = sampler_state {
    Texture = (gDepthBuffer);
    AddressU = Clamp;
    AddressV = Clamp;
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = None;
    MaxMipLevel = 0;
    MipMapLodBias = 0;
};


/*-----------------
-->> Utilities <<--
-------------------*/

float4x4 createTranslationMatrix(float3 trans) {
    return float4x4(
        1,  0,  0,  0,
        0,  1,  0,  0,
        0,  0,  1,  0,
        trans.x, trans.y, trans.z, 1
   );
}

float4x4 createImageProjectionMatrix(float2 viewportPos, float2 viewportSize, float2 viewportScale, float adjustZFactor, float nearPlane, float farPlane) {
    float Q = farPlane/(farPlane - nearPlane);
    float rcpSizeX = 2.0f/viewportSize.x;
    float rcpSizeY = -2.0f/viewportSize.y;
    rcpSizeX *= adjustZFactor;
    rcpSizeY *= adjustZFactor;
    float viewportPosX = 2*viewportPos.x;
    float viewportPosY = 2*viewportPos.y;
    float4x4 sProjection = {
        float4(rcpSizeX*viewportScale.x, 0, 0,  0), float4(0, rcpSizeY*viewportScale.y, 0, 0), float4(viewportPosX, -viewportPosY, Q, 1),
        float4((-viewportSize.x/2.0f - 0.5f)*rcpSizeX, (-viewportSize.y/2.0f - 0.5f)*rcpSizeY, -Q*nearPlane, 0)
    };
    return sProjection;
}

float fetchDepthBufferValue(float2 uv) {
    float4 texel = tex2D(bufferSampler, uv);
    if (IS_DEPTHBUFFER_RAWZ) {
        float3 rawval = floor(255.0*texel.arg + 0.5);
        float3 valueScaler = float3(0.996093809371817670572857294849, 0.0038909914428586627756752238080039, 1.5199185323666651467481343000015e-5);
        return dot(rawval, valueScaler/255.0);
    } else {
        return texel.r;
    }
}


/*----------------
-->> Handlers <<--
------------------*/

PSInput VertexShaderFunction(VSInput VS) {
    PSInput PS = (PSInput)0;
    VS.Position.xyz = float3(VS.TexCoord, 0);
    VS.Position.xy *= viewportSize;

    float4x4 sProjection = createImageProjectionMatrix(viewportSPosition, viewportSize, viewportScale, 1000, 100, 10000);
    float4 viewPos = mul(float4(VS.Position.xyz, 1), createTranslationMatrix(float3(0,0, 1000)));
    PS.Position = mul(viewPos, sProjection);
    PS.TexCoord = VS.TexCoord;
    return PS;
}

Pixel PixelShaderFunction(PSInput PS) {
    Pixel output;

    output.Depth = fetchDepthBufferValue(PS.TexCoord);
    output.World = 0;
    return output;
}


/*------------------
-->> Techniques <<--
--------------------*/

technique utilities_zBuffer {
    pass P0 {
        ZEnable = true;
        ZFunc = LessEqual;
        ZWriteEnable = true;
        CullMode = 1;
        ShadeMode = Gouraud;
        AlphaBlendEnable = true;
        SrcBlend = SrcAlpha;
        DestBlend = InvSrcAlpha;
        AlphaTestEnable = false;
        AlphaRef = 1;
        AlphaFunc = GreaterEqual;
        Lighting = false;
        FogEnable = false;
        VertexShader = compile vs_3_0 VertexShaderFunction();
        PixelShader  = compile ps_3_0 PixelShaderFunction();
    }
}

technique fallback {
    pass P0 {}
}
]]