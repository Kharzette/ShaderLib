//shaders using TomF's trilights for light
//see http://home.comcast.net/~tom_forsyth/blog.wiki.html#Trilights

#include "CommonFunctions.hlsli"
#include "Cel.hlsli"

#define	NUM_CUSTOM_COLOURS	16


//A color table used to replace vert colours
//with colours the user wants.  Useful for like
//the eye colour of a character etc...
cbuffer CustomColours : register(b9)
{
	float4		mCColors[NUM_CUSTOM_COLOURS];
	float4x4	mCSPow;		//spec pow (used as array)
}


//functions
void	CelStuff(inout float3 lightVal, inout float3 specVal)
{
//for super retro goofy color action
#if defined(CELALL)
	lightVal	=CelQuantize(lightVal);
	specVal		=CelQuantize(specVal);
#else
	//this quantizes the light value
	#if defined(CELLIGHT)
		lightVal	=CelQuantize(lightVal);
	#endif

	//this will quantize the specularity as well
	#if defined(CELSPECULAR)
		specVal		=CelQuantize(specVal);
	#endif
#endif
}

//variants have tex, cel, vcolor, index
//just a solid colour
//Cel on solid colour
//tex
//texCel
//vcolor
//vcolorCel
//texVColor
//texVColorCel
//index
//indexCel
//texIndex
//texCelIndex


//Solid color, trilight, and specular
float4 TriPS(WPosWNormTexColorIdx input) : SV_Target
{
	float3	wpos	=input.WorldPosU.xyz;
	float3	wnorm	=normalize(input.WorldNormalV.xyz);

	float3	lightDir	=float3(mLightColor0.w, mLightColor1.w, mLightColor2.w);
	float3	triLight	=ComputeTrilight(wnorm, lightDir,
							mLightColor0, mLightColor1, mLightColor2);

	float3	specular	=ComputeGoodSpecular(wpos, lightDir, wnorm, triLight, mSpecColorPow.w);
	float3	litSolid	=mSolidColour.xyz * triLight;

	specular	=saturate(specular + litSolid);

	return	float4(specular, mSolidColour.w);
}

float4 TriCelPS(WPosWNormTexColorIdx input) : SV_Target
{
	float3	wpos	=input.WorldPosU.xyz;
	float3	wnorm	=normalize(input.WorldNormalV.xyz);

	float3	lightDir	=float3(mLightColor0.w, mLightColor1.w, mLightColor2.w);
	float3	triLight	=ComputeTrilight(wnorm, lightDir,
							mLightColor0, mLightColor1, mLightColor2);

	float3	specular	=ComputeGoodSpecular(wpos, lightDir, wnorm, triLight, mSpecColorPow.w);

	CelStuff(triLight, specular);

	float3	litSolid	=mSolidColour.xyz * triLight;

	specular	=saturate(specular + litSolid);

	return	float4(specular, mSolidColour.w);
}

//Texture, trilight, modulate solid, and specular
float4 TriTexPS(WPosWNormTexColorIdx input) : SV_Target
{
	float2	tex;

	tex.x	=input.WorldPosU.w;
	tex.y	=input.WorldNormalV.w;

	float4	texColor	=mTexture0.Sample(Tex0Sampler, tex);

	float3	wpos	=input.WorldPosU.xyz;
	float3	wnorm	=normalize(input.WorldNormalV.xyz);

	float3	lightDir	=float3(mLightColor0.w, mLightColor1.w, mLightColor2.w);
	float3	triLight	=ComputeTrilight(wnorm, lightDir,
							mLightColor0, mLightColor1, mLightColor2);

	float3	specular	=ComputeGoodSpecular(wpos, lightDir, wnorm, triLight, mSpecColorPow.w);

	float3	litColor	=texColor.xyz * triLight;

	specular	=saturate((specular + litColor.xyz) * mSolidColour.xyz);

	return	float4(specular, texColor.w);
}

//Texture, trilight, modulate solid, cel, and specular
float4 TriCelTexPS(WPosWNormTexColorIdx input) : SV_Target
{
	float2	texUV;

	texUV.x	=input.WorldPosU.w;
	texUV.y	=input.WorldNormalV.w;

	float4	texColor	=mTexture0.Sample(Tex0Sampler, texUV);

	float3	wpos	=input.WorldPosU.xyz;
	float3	wnorm	=normalize(input.WorldNormalV.xyz);

	float3	lightDir	=float3(mLightColor0.w, mLightColor1.w, mLightColor2.w);
	float3	triLight	=ComputeTrilight(wnorm, lightDir,
							mLightColor0, mLightColor1, mLightColor2);

	float3	specular	=ComputeGoodSpecular(wpos, lightDir, wnorm, triLight, mSpecColorPow.w);

	CelStuff(triLight, specular);

	float3	litColor	=texColor.xyz * triLight;

	specular	=saturate((specular + litColor.xyz) * mSolidColour.xyz);

	return	float4(specular, texColor.w);
}

//passed in color and specular
float4 TriColorPS(WPosWNormTexColorIdx input) : SV_Target
{
	float3	wpos	=input.WorldPosU.xyz;
	float3	wnorm	=normalize(input.WorldNormalV.xyz);
	float3	col		=input.Color.xyz;

	float3	lightDir	=float3(mLightColor0.w, mLightColor1.w, mLightColor2.w);
	float3	triLight	=ComputeTrilight(wnorm, lightDir,
							mLightColor0, mLightColor1, mLightColor2);

	float3	specular	=ComputeGoodSpecular(wpos, lightDir, wnorm, triLight, mSpecColorPow.w);

	float3	litSolid	=col * triLight;

	specular	=saturate(specular + litSolid);

	return	float4(specular, 1);
}

//cel, passed in color and specular
float4 TriCelColorPS(WPosWNormTexColorIdx input) : SV_Target
{
	float3	wpos	=input.WorldPosU.xyz;
	float3	wnorm	=normalize(input.WorldNormalV.xyz);
	float3	col		=input.Color.xyz;

	float3	lightDir	=float3(mLightColor0.w, mLightColor1.w, mLightColor2.w);
	float3	triLight	=ComputeTrilight(wnorm, lightDir,
							mLightColor0, mLightColor1, mLightColor2);

	float3	specular	=ComputeGoodSpecular(wpos, lightDir, wnorm, triLight, mSpecColorPow.w);

	CelStuff(triLight, specular);

	float3	litSolid	=col * triLight;

	specular	=saturate(specular + litSolid);

	return	float4(specular, 1);
}

//tex0, passed in color and specular
float4 TriTexColorPS(WPosWNormTexColorIdx input) : SV_Target
{
	float3	wpos	=input.WorldPosU.xyz;
	float3	wnorm	=normalize(input.WorldNormalV.xyz);
	float3	col		=input.Color.xyz;
	float2	texUV;

	texUV.x	=input.WorldPosU.w;
	texUV.y	=input.WorldNormalV.w;

	float4	texel	=mTexture0.Sample(Tex0Sampler, texUV);

	float3	lightDir	=float3(mLightColor0.w, mLightColor1.w, mLightColor2.w);
	float3	triLight	=ComputeTrilight(wnorm, lightDir,
							mLightColor0, mLightColor1, mLightColor2);

	float3	specular	=ComputeGoodSpecular(wpos, lightDir, wnorm, triLight, mSpecColorPow.w);

	float3	litSolid	=texel.xyz * col * triLight;

	specular	=saturate(specular + litSolid);

	return	float4(specular, texel.w);
}

//cel, tex0, passed in color and specular
float4 TriCelTexColorPS(WPosWNormTexColorIdx input) : SV_Target
{
	float3	wpos	=input.WorldPosU.xyz;
	float3	wnorm	=normalize(input.WorldNormalV.xyz);
	float3	col		=input.Color.xyz;
	float2	texUV;

	texUV.x	=input.WorldPosU.w;
	texUV.y	=input.WorldNormalV.w;

	float4	texel	=mTexture0.Sample(Tex0Sampler, texUV);

	float3	lightDir	=float3(mLightColor0.w, mLightColor1.w, mLightColor2.w);
	float3	triLight	=ComputeTrilight(wnorm, lightDir,
							mLightColor0, mLightColor1, mLightColor2);

	float3	specular	=ComputeGoodSpecular(wpos, lightDir, wnorm, triLight, mSpecColorPow.w);

	CelStuff(triLight, specular);

	float3	litSolid	=texel.xyz * col * triLight;

	specular	=saturate(specular + litSolid);

	return	float4(specular, texel.w);
}


//Solid color, color from a table, trilight, specular
float4 TriCTablePS(WPosWNormTexColorIdx input) : SV_Target
{
	float3	wnorm	=input.WorldNormalV.xyz;
	float3	wpos	=input.WorldPosU.xyz;
	uint	ctIdx	=input.Idx;

	uint	lowIdx	=ctIdx & 0x3;
	uint	hiIdx	=ctIdx >> 2;

	float3	vcolor	=mCColors[ctIdx].xyz;
	float	spow	=mCSPow[lowIdx][hiIdx];

	wnorm	=normalize(wnorm);

	float3	lightDir	=float3(mLightColor0.w, mLightColor1.w, mLightColor2.w);
	float3	triLight	=ComputeTrilight(wnorm, lightDir,
							mLightColor0, mLightColor1, mLightColor2);

	float3	specular	=ComputeGoodSpecular(wpos, lightDir, wnorm, triLight, spow);
	float3	litSolid	=mSolidColour.xyz * triLight * vcolor;

	specular	=saturate(specular + litSolid);

	return	float4(specular, mSolidColour.w);
}

//cel, Solid color, color from a table, trilight, specular
float4 TriCelCTablePS(WPosWNormTexColorIdx input) : SV_Target
{
	float3	wnorm	=input.WorldNormalV.xyz;
	float3	wpos	=input.WorldPosU.xyz;
	uint	ctIdx	=input.Idx;

	uint	lowIdx	=ctIdx & 0x3;
	uint	hiIdx	=ctIdx >> 2;

	float3	vcolor	=mCColors[ctIdx].xyz;
	float	spow	=mCSPow[lowIdx][hiIdx];

	wnorm	=normalize(wnorm);

	float3	lightDir	=float3(mLightColor0.w, mLightColor1.w, mLightColor2.w);
	float3	triLight	=ComputeTrilight(wnorm, lightDir,
							mLightColor0, mLightColor1, mLightColor2);

	float3	specular	=ComputeGoodSpecular(wpos, lightDir, wnorm, triLight, spow);

	CelStuff(triLight, specular);

	float3	litSolid	=mSolidColour.xyz * triLight * vcolor;

	specular	=saturate(specular + litSolid);

	return	float4(specular, mSolidColour.w);
}

//texture, Solid color, color from a table, trilight, specular
float4 TriTexCTablePS(WPosWNormTexColorIdx input) : SV_Target
{
	float2	texUV;

	texUV.x	=input.WorldPosU.w;
	texUV.y	=input.WorldNormalV.w;

	float4	texColor	=mTexture0.Sample(Tex0Sampler, texUV);
	float3	wnorm		=input.WorldNormalV.xyz;
	float3	wpos		=input.WorldPosU.xyz;
	uint	ctIdx		=input.Idx;

	uint	lowIdx	=ctIdx & 0x3;
	uint	hiIdx	=ctIdx >> 2;

	float3	vcolor	=mCColors[ctIdx].xyz;
	float	spow	=mCSPow[lowIdx][hiIdx];

	wnorm	=normalize(wnorm);

	float3	lightDir	=float3(mLightColor0.w, mLightColor1.w, mLightColor2.w);
	float3	triLight	=ComputeTrilight(wnorm, lightDir,
							mLightColor0, mLightColor1, mLightColor2);

	float3	specular	=ComputeGoodSpecular(wpos, lightDir, wnorm, triLight, spow);
	float3	litSolid	=mSolidColour.xyz * triLight * (texColor.xyz + vcolor);

	specular	=saturate(specular + litSolid);

	return	float4(specular, mSolidColour.w * texColor.w);
}

//cel, texture, Solid color, color from a table, trilight, specular
float4 TriCelTexCTablePS(WPosWNormTexColorIdx input) : SV_Target
{
	float2	texUV;

	texUV.x	=input.WorldPosU.w;
	texUV.y	=input.WorldNormalV.w;

	float4	texColor	=mTexture0.Sample(Tex0Sampler, texUV);
	float3	wnorm		=input.WorldNormalV.xyz;
	float3	wpos		=input.WorldPosU.xyz;
	uint	ctIdx		=input.Idx;

	uint	lowIdx	=ctIdx & 0x3;
	uint	hiIdx	=ctIdx >> 2;

	float3	vcolor	=mCColors[ctIdx].xyz;
	float	spow	=mCSPow[lowIdx][hiIdx];

	wnorm	=normalize(wnorm);

	float3	lightDir	=float3(mLightColor0.w, mLightColor1.w, mLightColor2.w);
	float3	triLight	=ComputeTrilight(wnorm, lightDir,
							mLightColor0, mLightColor1, mLightColor2);

	float3	specular	=ComputeGoodSpecular(wpos, lightDir, wnorm, triLight, spow);

	//the texture doesn't react well with cel
	//since it is an additive overlay of sorts, it tends
	//to glow in the dark a bit.
	float3	texNoCel	=triLight * texColor.xyz;

	CelStuff(triLight, specular);

	float3	litSolid	=mSolidColour.xyz * (triLight * vcolor) + texNoCel;

	specular	=saturate(specular + litSolid);

	return	float4(specular, mSolidColour.w * texColor.w);
}