#include "Types.hlsli"
#include "CommonFunctions.hlsli"


//Compute fog factor, swiped from basic effect
float ComputeFogFactor(float d)
{
    return clamp((d - mFog.x) / (mFog.y - mFog.x), 0, 1) * mFog.z;
}


StructuredBuffer<VPosNormTex>	SBPosNormTex : register(t0);

VVPosTex04Tex14 SkyBoxVS(uint ID : SV_VertexID)
{
	VPosNormTex	vpn	=SBPosNormTex[ID];

	VVPosTex04Tex14	output;
	
	float4x4	viewProj	=mul(mView, mProjection);

	//worldpos
	float4	worldPos	=mul(float4(vpn.PositionU.xyz, 1), mWorld);

	output.Position			=mul(worldPos, viewProj);
	output.TexCoord0.xyz	=mul(vpn.NormalV.xyz, mWorld);	
	output.TexCoord1.xyz	=worldPos;

	//direct copy of texcoords
	output.TexCoord0.w	=vpn.PositionU.w;
	output.TexCoord1.w	=vpn.NormalV.w;
	
	//return the output structure
	return	output;
}


StructuredBuffer<TerrainVert>	SBTerrain : register(t0);

//worldpos and normal and 8 texture factors newer from C
PSTerrain TerrainVS(uint ID : SV_VertexID)
{
	PSTerrain	output;

	TerrainVert	tv	=SBTerrain[ID];
	
	float4	norm, col;
	UnPackStuff(tv.NormVCol, norm, col);

	float4	tweight0, tweight1;
	UnPackStuff(tv.TexWeights, tweight0, tweight1);

	float4x4	viewProj	=mul(mView, mProjection);

	//worldpos
	float4	worldPos	=mul(float4(tv.Position.xyz, 1), mWorld);

	output.Position			=mul(worldPos, viewProj);
	output.WorldNormal.xyz	=mul(norm.xyz, mWorld);	
	output.WorldPosFF.xyz	=worldPos.xyz;
	output.TexWeight0		=tweight0;	//4 texture factors (adds to 1)
	output.TexWeight1		=tweight1;	//4 texture factors (adds to 1)
	output.Color			=col;

	//store fog factor
	output.WorldPosFF.w	=ComputeFogFactor(length(worldPos.xyz - mEyePos.xyz));

	//not using this at the moment
	output.WorldNormal.w	=0;
	
	//return the output structure
	return	output;
}


//trilight with 8 texture lookups in an atlas
float4	TerrainPS(PSTerrain input) : SV_Target
{
	float4	texColor	=float4(0, 0, 0, 0);

	float2	worldXZ	=input.WorldPosFF.xz;

	//might make this a per element scale factor
	worldXZ	*=0.01;

	float2	tcoord	=frac(worldXZ);

	//4 textures in x, 2 in y
	tcoord.x	*=0.25f;
	tcoord.y	*=0.5f;

	texColor	+=mTexture0.Sample(Tex0Sampler, tcoord) * input.TexWeight0.x;

	tcoord.x	+=0.25f;
	texColor	+=mTexture0.Sample(Tex0Sampler, tcoord) * input.TexWeight0.y;

	tcoord.x	+=0.25f;
	texColor	+=mTexture0.Sample(Tex0Sampler, tcoord) * input.TexWeight0.z;

	tcoord.x	+=0.25f;
	texColor	+=mTexture0.Sample(Tex0Sampler, tcoord) * input.TexWeight0.w;

	tcoord.x	-=1.0f;
	tcoord.y	+=0.5f;
	texColor	+=mTexture0.Sample(Tex0Sampler, tcoord) * input.TexWeight1.x;

	tcoord.x	+=0.25f;
	texColor	+=mTexture0.Sample(Tex0Sampler, tcoord) * input.TexWeight1.y;

	tcoord.x	+=0.25f;
	texColor	+=mTexture0.Sample(Tex0Sampler, tcoord) * input.TexWeight1.z;

	tcoord.x	+=0.25f;
	texColor	+=mTexture0.Sample(Tex0Sampler, tcoord) * input.TexWeight1.w;

	float3	wnorm	=input.WorldNormal.xyz;
	float	fog		=input.WorldPosFF.w;

	wnorm	=normalize(wnorm);

	float3	lightDir	=float3(mLightColor0.w, mLightColor1.w, mLightColor2.w);

	float3	triLight	=ComputeTrilight(wnorm, lightDir,
							mLightColor0.xyz, mLightColor1.xyz, mLightColor2.xyz);

	texColor.xyz	*=triLight;

	float3	skyColor	=CalcSkyColorGradient(input.WorldPosFF.xyz, mSkyGradient0, mSkyGradient1);

	texColor.xyz	=lerp(texColor.xyz, skyColor, fog);

	return	texColor;
}


float4 SkyGradientFogPS(VVPosTex04Tex14 input) : SV_Target
{
	float3	skyColor	=CalcSkyColorGradient(input.TexCoord1.xyz, mSkyGradient0, mSkyGradient1);

	return	float4(skyColor, 1);
}