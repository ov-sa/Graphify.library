//
// RTinput_world_refAnim.fx
//

//------------------------------------------------------------------------------------------
// Settings
//------------------------------------------------------------------------------------------
bool disableNormals = false;

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
  float2 TexCoord1 : TEXCOORD1;
  float3 Normal : TEXCOORD2;
  float4 WorldPos : TEXCOORD3;
}; 

//------------------------------------------------------------------------------------------
// VertexShaderFunction
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;
	
    float3 Normal;
    if (gDeclNormal != 1) Normal = float3(0,0,0);
    else Normal = mul(VS.Normal, (float3x3)gWorld);
    PS.Normal = Normal;
    float3 ViewNormal = mul(VS.Normal, (float3x3)gWorldView);
	
    // Pass through tex coord
    PS.TexCoord = VS.TexCoord;
    PS.TexCoord1 = 0;
    if (gStage1ColorOp == 25) PS.TexCoord1 = ViewNormal.xy;
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

    // Apply spherical reflection
    // MultiplyAdd = 25
    if (gStage1ColorOp == 25) {
        float4 sphTexel = tex2D(Sampler1, PS.TexCoord1.xy);
        finalColor.rgb += sphTexel.rgb * gTextureFactor.r;
    }	

    output.World = saturate(finalColor);
	
    // Compare with current pixel depth
    // Color render target
    output.Color.rgb = texel.rgb;
    output.Color.a = texel.a * PS.Diffuse.a;
		
    // Normal render target
	float3 Normal = normalize(PS.Normal);
    if ((PS.Normal.z == 0) || (disableNormals)) output.Normal = float4(0,0,0,1);
       else output.Normal = float4((Normal.xy * 0.5) + 0.5, Normal.z <0 ? 0.611 : 0.789, 1);

    return output;
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique RTinput_world_refAnim
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