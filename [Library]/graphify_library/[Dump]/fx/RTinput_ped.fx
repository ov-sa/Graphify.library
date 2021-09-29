//
// RTinput_ped.fx
//

//------------------------------------------------------------------------------------------
// Settings
//------------------------------------------------------------------------------------------
static const float pi = 3.141592653589793f;

//------------------------------------------------------------------------------------------
// Settings
//------------------------------------------------------------------------------------------
texture colorLayer <string renderTarget = "yes";>;
texture normalLayer <string renderTarget = "yes";>;

//------------------------------------------------------------------------------------------
// Include some common stuff
//------------------------------------------------------------------------------------------
//#define GENERATE_NORMALS      // Uncomment for normals to be generated
#include "mta-helper.fx"

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
  float3 Normal : NORMAL0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
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
};

//------------------------------------------------------------------------------------------
// VertexShaderFunction
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    // Make sure normal is valid
    MTAFixUpNormal( VS.Normal );

    // Set information to do specular calculation
    PS.Normal = mul(VS.Normal, (float3x3)gWorld);

    // Pass through tex coord
    PS.TexCoord = VS.TexCoord;

    // Calculate screen pos of vertex	
    PS.Position = mul( float4(VS.Position.xyz,1) , gWorldViewProjection);	

    // Calculate GTA lighting for Vehicles
    PS.Diffuse = MTACalcGTACompleteDiffuse(PS.Normal, VS.Diffuse);
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

    // Color render target
    output.Color.rgb = texel.rgb;
    output.Color.a = texel.a * PS.Diffuse.a;
		
   // Normal render target
   float3 Normal = normalize(PS.Normal);
   
   output.Normal = float4((Normal.xy * 0.5) + 0.5, Normal.z <0 ? 0.811 : 0.989, 1);
   
    return output;
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique RTinput_ped
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