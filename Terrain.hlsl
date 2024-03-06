#include "Types.hlsli"
#include "CommonFunctions.hlsli"


//Compute fog factor, swiped from basic effect
float ComputeFogFactor(float d)
{
    return clamp((d - mFogStart) / (mFogEnd - mFogStart), 0, 1) * mFogEnabled;
}


VVPosTex04Tex14 SkyBoxVS(VPosNormTex0 input)
{
	VVPosTex04Tex14	output;
	
	float4x4	viewProj	=mul(mView, mProjection);

	//worldpos
	float4	worldPos	=mul(float4(input.Position, 1), mWorld);

	output.Position			=mul(worldPos, viewProj);
	output.TexCoord0.xyz	=mul(input.Normal.xyz, mWorld);	
	output.TexCoord1.xyz	=worldPos;

	output.TexCoord0.w	=0;
	output.TexCoord1.w	=0;
	
	//return the output structure
	return	output;
}


//worldpos and normal and 8 texture factors newer from C
VVPosTex04Tex14Tex24Tex34 WNormWPosTexFactVS(VPosNormTex04Tex14 input)
{
	VVPosTex04Tex14Tex24Tex34	output;
	
	float4x4	viewProj	=mul(mView, mProjection);

	//worldpos
	float4	worldPos	=mul(float4(input.Position, 1), mWorld);

	output.Position			=mul(worldPos, viewProj);
	output.TexCoord0.xyz	=mul(input.Normal.xyz, mWorld);	
	output.TexCoord1.xyz	=worldPos;
	output.TexCoord2		=input.TexCoord0;	//4 texture factors (adds to 1)
	output.TexCoord3		=input.TexCoord1;	//4 texture factors (adds to 1)

	//store fog factor
	output.TexCoord0.w	=ComputeFogFactor(length(worldPos - mEyePos));
	output.TexCoord1.w	=0;
	
	//return the output structure
	return	output;
}


//trilight with 8 texture lookups in an atlas
float4	TriTexFact8PS(VVPosTex04Tex14Tex24Tex34 input) : SV_Target
{
	float4	texColor	=float4(0, 0, 0, 0);

	//texcoord1 has worldspace position
	float2	worldXZ	=input.TexCoord1.xz;

	//might make this a per element scale factor
	worldXZ	*=0.01;

	float2	tcoord	=frac(worldXZ);

	//4 textures in x, 2 in y
	tcoord.x	*=0.25f;
	tcoord.y	*=0.5f;

	texColor	+=mTexture0.Sample(Tex0Sampler, tcoord) * input.TexCoord2.x;

	tcoord.x	+=0.25f;
	texColor	+=mTexture0.Sample(Tex0Sampler, tcoord) * input.TexCoord2.y;

	tcoord.x	+=0.25f;
	texColor	+=mTexture0.Sample(Tex0Sampler, tcoord) * input.TexCoord2.z;

	tcoord.x	+=0.25f;
	texColor	+=mTexture0.Sample(Tex0Sampler, tcoord) * input.TexCoord2.w;

	tcoord.x	-=1.0f;
	tcoord.y	+=0.5f;
	texColor	+=mTexture0.Sample(Tex0Sampler, tcoord) * input.TexCoord3.x;

	tcoord.x	+=0.25f;
	texColor	+=mTexture0.Sample(Tex0Sampler, tcoord) * input.TexCoord3.y;

	tcoord.x	+=0.25f;
	texColor	+=mTexture0.Sample(Tex0Sampler, tcoord) * input.TexCoord3.z;

	tcoord.x	+=0.25f;
	texColor	+=mTexture0.Sample(Tex0Sampler, tcoord) * input.TexCoord3.w;

	float3	pnorm	=input.TexCoord0.xyz;
	float	fog		=input.TexCoord0.w;

	pnorm	=normalize(pnorm);

	float3	triLight	=ComputeTrilight(pnorm, mLightDirection,
							mLightColor0, mLightColor1, mLightColor2);

	texColor.xyz	*=triLight;

	float3	skyColor	=CalcSkyColorGradient(input.TexCoord1.xyz, mSkyGradient0, mSkyGradient1);

	texColor.xyz	=lerp(texColor.xyz, skyColor, fog);

	return	texColor;
}


float4 SkyGradientFogPS(VVPosTex04Tex14 input) : SV_Target
{
	float3	skyColor	=CalcSkyColorGradient(input.TexCoord1.xyz, mSkyGradient0, mSkyGradient1);

	return	float4(skyColor, 1);
}