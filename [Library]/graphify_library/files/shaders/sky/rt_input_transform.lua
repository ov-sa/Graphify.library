----------------------------------------------------------------
--[[ Resource: Graphify Library
     Shaders: sky: rt_input_transform.lua
     Server: -
     Author: OvileAmriam, Ren712
     Developer: Aviril
     DOC: 29/09/2021 (OvileAmriam)
     Desc: Sky's RT Transformation Inputter ]]--
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
    category = AVAILABLE_SHADERS["Sky"],
    reference = "RT_Input_Transform",
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


/*-----------------
-->> Variables <<--
-------------------*/

texture skyMapTexture;

struct VSInput {
    float3 Position : POSITION0;
    float3 Normal : NORMAL0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

struct PSInput {
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
    float4 TexCoord1 : TEXCOORD1;
};


/*----------------
-->> Samplers <<--
------------------*/

sampler inputSampler = sampler_state {
    Texture = (skyMapTexture);
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
    AddressU = Clamp;
    AddressV = Clamp;
};


/*-----------------
-->> Utilities <<--
-------------------*/

float4x4 inverseMatrix(float4x4 matrixInput) {
     #define minor(a, b, c) determinant(float3x3(matrixInput.a, matrixInput.b, matrixInput.c))
     float4x4 cofactors = float4x4(
        minor(_22_23_24, _32_33_34, _42_43_44), 
        -minor(_21_23_24, _31_33_34, _41_43_44),
        minor(_21_22_24, _31_32_34, _41_42_44),
        -minor(_21_22_23, _31_32_33, _41_42_43),
        -minor(_12_13_14, _32_33_34, _42_43_44),
        minor(_11_13_14, _31_33_34, _41_43_44),
        -minor(_11_12_14, _31_32_34, _41_42_44),
        minor(_11_12_13, _31_32_33, _41_42_43),
        minor(_12_13_14, _22_23_24, _42_43_44),
        -minor(_11_13_14, _21_23_24, _41_43_44),
        minor(_11_12_14, _21_22_24, _41_42_44),
        -minor(_11_12_13, _21_22_23, _41_42_43),
        -minor(_12_13_14, _22_23_24, _32_33_34),
        minor(_11_13_14, _21_23_24, _31_33_34),
        -minor(_11_12_14, _21_22_24, _31_32_34),
        minor(_11_12_13, _21_22_23, _31_32_33)
     );
     #undef minor
     return transpose(cofactors)/determinant(matrixInput);
}

float3 GetFarClipPosition(float2 coords, float4 view) {
    return float3(coords.x*view.x + view.z, (1 - coords.y)*view.y + view.w, 1.0)*(gProjectionMainScene[3][2]/(1 - gProjectionMainScene[2][2]));
}

float2 getReflectionCoords(float3 dir, float2 div) {
    return float2(((atan2(dir.x, dir.z)/(PI*div.x)) + 1)/2,  (acos(- dir.y)/(PI*div.y)));
}


/*----------------
-->> Handlers <<--
------------------*/

PSInput VertexShaderFunction(VSInput VS) {
    PSInput PS = (PSInput)0;
    PS.TexCoord = VS.TexCoord;

    float4 worldPos = mul(float4(VS.Position.xyz, 1), gWorld);
    float4 viewPos = mul(worldPos, gView);
    float2 viewAdd = - 1/float2(gProjectionMainScene[0][0], gProjectionMainScene[1][1]);	
    float2 viewMul = -2.0*viewAdd.xy;
    PS.Position = mul(viewPos, gProjection);
    PS.TexCoord1 = float4(viewMul, viewAdd);
    PS.Diffuse = VS.Diffuse;
    return PS;
}

float4 PixelShaderFunction(PSInput PS) : COLOR0 {
    float4x4 sViewInverse = inverseMatrix(gViewMainScene);
    float3 viewPos = GetFarClipPosition(PS.TexCoord, PS.TexCoord1);
    float3 worldPos = mul(float4(viewPos, 1), sViewInverse).xyz;
    float3 viewDir = normalize(worldPos - sViewInverse[3].xyz);
    float2 texCoord = getReflectionCoords(-viewDir.xzy, float2(1, 1));
    float4 inputTexel = tex2D(inputSampler, texCoord);	
    float4 worldColor = inputTexel*PS.Diffuse;
    return worldColor;
} 


/*------------------
-->> Techniques <<--
--------------------*/

technique sky_rtInputTransform {
    pass P0 {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

technique fallback {
    pass P0 {}
}
]]