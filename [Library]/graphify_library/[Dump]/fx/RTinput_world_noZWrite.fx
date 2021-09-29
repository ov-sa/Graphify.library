//
// RTinput_world_noZWrite.fx
//

//------------------------------------------------------------------------------------------
// Settings
//------------------------------------------------------------------------------------------
float2 sPixelSize = float2(0.00125,0.00166);
float2 sHalfPixel = float2(0.000625,0.00083);
bool disableNormals = false;

//------------------------------------------------------------------------------------------
// Include some common stuff
//------------------------------------------------------------------------------------------
//#define GENERATE_NORMALS      // Uncomment for normals to be generated
#include "mta-helper.fx"

//------------------------------------------------------------------------------------------
// Settings
//------------------------------------------------------------------------------------------
texture colorLayer <string renderTarget = "yes";>;
texture normalLayer <string renderTarget = "yes";>;

//------------------------------------------------------------------------------------------
// Sampler for the main texture
//------------------------------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};

//------------------------------------------------------------------------------------------
// Structure of data sent to the vertex shader
//------------------------------------------------------------------------------------------
struct VSInput
{
  float3 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float3 Normal : NORMAL0;
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
  float3 Normal : TEXCOORD1;
  float4 WorldPos : TEXCOORD4;
}; 

//------------------------------------------------------------------------------------------
// VertexShaderFunction
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    // Pass through tex coord
    PS.TexCoord = VS.TexCoord;
	
    float3 Normal;
    if ((gDeclNormal != 1) || (disableNormals)) Normal = float3(0,0,0);
    else Normal = mul(VS.Normal, (float3x3)gWorld);
    PS.Normal = Normal;
	
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
    float4 Color : COLOR1;      // Render target #1
    float4 Normal : COLOR2;      // Render target #2
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
    float4 finalColor = texel * PS.Diffuse;

    output.World = saturate(finalColor);
	
    // Compare with current pixel depth
    // Color render target
    output.Color.rgb = texel.rgb * PS.Diffuse.rgb;
    output.Color.a = texel.a * PS.Diffuse.a;
		
    // Normal render target
	float3 Normal = normalize(PS.Normal);
    if (PS.Normal.z == 0) output.Normal = float4(0,0,0,0);
       else output.Normal = float4((Normal.xy * 0.5) + 0.5, Normal.z <0 ? 0.611 : 0.789, 1);

    return output;
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique RTinput_world_noZWrite
{
    pass P0
    {
        ZWriteEnable = false;
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