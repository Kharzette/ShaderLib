//shader for UI and particles and such
#include "Types.hlsli"
#include "CommonFunctions.hlsli"

cbuffer TwoD : register(b7)
{
	float2	mTextPosition, mSecondLayerOffset;
	float2	mTextScale;
	float2	mPad;			//use later for something
	float4	mTextColor;		//can't cross 16 boundary
}

VVPosTex0 TextVS(VPos2Tex02 input)
{
	VVPosTex0	output;

	float4	pos;

	pos.xy	=(input.Position.xy * mTextScale) + mTextPosition;
	pos.z	=-0.5;
	pos.w	=1;

	output.Position	=mul(pos, mProjection);

	output.TexCoord0.x	=input.TexCoord0.x;
	output.TexCoord0.y	=input.TexCoord0.y;

	return	output;
}


//text or 2D shapes
VVPosCol0Tex04 UIStuffVS(VPos2Col0Tex04 input)
{
	VVPosCol0Tex04	output;

	float4	pos;

	pos.xy	=input.Position.xy;
	pos.z	=-0.5;	//is this why my culling is backwards?
	pos.w	=1;

	output.Position		=mul(pos, mProjection);
	output.TexCoord0	=input.TexCoord0;
	output.Color		=input.Color;

	return	output;
}


VVPosCol0 ShapeVS(VPos2Col0 input)
{
	VVPosCol0	output;

	float4	pos;

	pos.xy	=input.Position.xy;
	pos.z	=-0.5;
	pos.w	=1;

	output.Position	=mul(pos, mProjection);

	output.Color	=input.Color;

	return	output;
}


VVPosTex04 KeyedGumpVS(VPos2Tex04 input)
{
	VVPosTex04	output;

	float4	pos;

	pos.xy	=(input.Position.xy * mTextScale) + mTextPosition;
	pos.z	=-0.5;
	pos.w	=1;

	float4x4	viewProj	=mul(mView, mProjection);

	output.Position	=mul(pos, viewProj);

	output.TexCoord0	=input.TexCoord0;

	return	output;
}

float4 TextPS(VVPosTex0 input) : SV_Target
{
	//texture
	float4	texel	=mTexture0.Sample(Tex0Sampler, input.TexCoord0.xy);

	//multiply by color
	texel	*=mTextColor;

	return	texel;
}

float4 UIStuffPS(VVPosCol0Tex04 input) : SV_Target
{
	//texture
	float4	texel	=mTexture0.Sample(Tex0Sampler, input.TexCoord0.xy);

	//texcoord z is a texture modulator
	//for standard shapes this can zero
	//out the texture value
	texel	*=input.TexCoord0.z;

	//texcoord w is an additive
	//this boosts to white for shapes
	texel	+=input.TexCoord0.w;

	//multiply by color
	texel	*=input.Color;

	return	texel;
}

float4 ShapePS(VVPosCol0 input) : SV_Target
{
	return	input.Color;
}

float4 KeyedGumpPS(VVPosTex04 input) : SV_Target
{
	//2 layers
	//top is a mask
	//second draws multiplied by top alpha
	float4	texel	=mTexture0.Sample(Tex0Sampler, input.TexCoord0.xy);
	float4	texel2	=mTexture1.Sample(Tex1Sampler,
		input.TexCoord0.zw + mSecondLayerOffset);

	//multiply under layer by color
	texel2	*=mTextColor;

	//mask
	texel2	*=texel.w;

	return	texel2;
}

float4 GumpPS(VVPosTex04 input) : SV_Target
{
	float4	texel	=mTexture0.Sample(Tex0Sampler, input.TexCoord0.xy);

	texel	*=mTextColor;

	return	texel;
}