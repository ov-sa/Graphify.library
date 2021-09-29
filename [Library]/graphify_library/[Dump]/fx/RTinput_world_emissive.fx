//
// RTinput_world_emissive.fx
//


//------------------------------------------------------------------------------------------
// Include some common stuff
//------------------------------------------------------------------------------------------
float4 gBlendFactor <string renderState="BLENDFACTOR";>;
int gZWriteEnable <string renderState="ZWRITEENABLE";>;
int gCullMode <string renderState="CULLMODE";>;  
int gStage1ColorOp <string stageState="1,COLOROP";>;
float4 gTextureFactor <string renderState="TEXTUREFACTOR";>;
int gStage0TextureTransformFlags <string stageState="0,TEXTURETRANSFORMFLAGS";>;
float4x4 gTransformTexture0 <string transformState="TEXTURE0";>; 
float4x4 gTransformTexture1 <string transformState="TEXTURE1";>; 
#include "mta-helper.fx"

//------------------------------------------------------------------------------------------
// Settings
//------------------------------------------------------------------------------------------
texture colorLayer <string renderTarget = "yes";>;

//------------------------------------------------------------------------------------------
// Sampler for the main texture
//------------------------------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};

sampler Sampler1 = sampler_state
{
    Texture = (gTexture1);
};

//------------------------------------------------------------------------------------------
// Structure of data sent to the vertex shader
//------------------------------------------------------------------------------------------
struct VSInput
{
  float3 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
  float2 TexCoord1 : TEXCOORD1;
};

//------------------------------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//------------------------------------------------------------------------------------------
struct PSInput
{
  float4 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
  float2 TexCoord1 : TEXCOORD1;
  float4 WorldPos : TEXCOORD3;
}; 

//------------------------------------------------------------------------------------------
// VertexShaderFunction
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    // Pass through tex coord
    PS.TexCoord = VS.TexCoord;
    PS.TexCoord1 = 0;
    if (gStage0TextureTransformFlags !=0) PS.TexCoord = mul(float3(VS.TexCoord.xy, 1), (float3x3)gTransformTexture0);
	
    // Calculate screen pos of vertex	
    float4 worldPos = mul(float4(VS.Position.xyz,1) , gWorld);	
    float4 viewPos = mul(worldPos, gView);
    float4 projPos = mul(viewPos, gProjection);
    PS.Position = projPos;
    PS.WorldPos = worldPos;

    // Calculate GTA vehicle lighting
    PS.Diffuse = MTACalcGTABuildingDiffuse(VS.Diffuse);
    return PS;
}

//------------------------------------------------------------------------------------------
// Structure of color data sent to the renderer ( from the pixel shader  )
//------------------------------------------------------------------------------------------
struct Pixel
{
    float4 World : COLOR0;      // Render target #0
    float4 Emissive : COLOR1;      // Render target #1
};

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//------------------------------------------------------------------------------------------
Pixel PixelShaderFunction(PSInput PS)
{
    Pixel output;
	
    // Get texture pixel
    float4 texel = tex2D(Sampler0, PS.TexCoord);

    // Apply diffuse lighting
    float4 Color = texel * PS.Diffuse;

    // Add detail
    float4 finalColor = texel;
    finalColor.a = Color.a;
    output.World = saturate(finalColor);
    output.Emissive.rgb = texel.rgb;
    output.Emissive.a = texel.a * PS.Diffuse.a;
    return output;
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique RTinput_world_emissive
{
    pass P0
    {
        SRGBWriteEnable = false;
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}