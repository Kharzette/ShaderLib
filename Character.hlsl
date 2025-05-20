//Character - stuff with bones

#include "Types.hlsli"
#include "CommonFunctions.hlsli"


cbuffer Character : register(b3)
{
	//matrii for skinning
	float4x4	mBones[MAX_BONES];	
}


//functions
//skinning with a dangly force applied
VVPosTex03Tex13 ComputeSkinWorldDangly(VPosNormBoneTexCol input, float4x4 bones[MAX_BONES])
{
	VVPosTex03Tex13	output;
	
	float4	vertPos	=float4(input.PositionU.xyz, 1);
	
	//generate view-proj matrix
	float4x4	vp	=mul(mView, mProjection);
	
	//do the bone influences
	float4x4 skinTransform	=GetSkinXForm(input.Blend0, input.Weight0, bones);
	
	//xform the vert to the character's boney pos
	vertPos	=mul(vertPos, skinTransform);
	
	//transform to world
	float4	worldPos	=mul(vertPos, mWorld);

	//dangliness
	worldPos.xyz	-=input.Color.x * mDanglyForceMID.xyz;

	output.TexCoord1	=worldPos.xyz;

	//viewproj
	output.Position	=mul(worldPos, vp);

	//skin transform the normal
	float3	worldNormal	=mul(input.NormalV.xyz, skinTransform);
	
	//world transform the normal
	output.TexCoord0	=mul(worldNormal, mWorld);

	return	output;
}

//skin pos and normal
VVPosNorm ComputeSkin(VPosNormBoneTex input, float4x4 bones[MAX_BONES])
{
	VVPosNorm	output;
	
	float4	vertPos	=float4(input.PositionU.xyz, 1);
	
	//generate the world-view-proj matrix
	float4x4	wvp	=mul(mul(mWorld, mView), mProjection);
	
	//do the bone influences
	float4x4 skinTransform	=GetSkinXForm(input.Blend0, input.Weight0, bones);
	
	//xform the vert to the character's boney pos
	vertPos	=mul(vertPos, skinTransform);
	
	//transform the input position to the output
	output.Position	=mul(vertPos, wvp);

	//skin transform the normal
	float3	worldNormal	=mul(input.NormalV.xyz, skinTransform);
	
	//world transform the normal
	output.Normal	=mul(worldNormal, mWorld);

	return	output;
}

//compute the position and color of a skinned vert
VVPosCol0 ComputeSkinTrilight(VPosNormBoneTex input, float4x4 bones[MAX_BONES],
							 float3 lightDir, float4 c0, float4 c1, float4 c2)
{
	VVPosCol0	output;
	VVPosNorm	skinny	=ComputeSkin(input, bones);

	output.Position		=skinny.Position;	
	output.Color.xyz	=ComputeTrilight(skinny.Normal.xyz, lightDir, c0, c1, c2);
	output.Color.w		=1.0;
	
	return	output;
}

//skin with world info
VVPosTex03Tex13 ComputeSkinWorld(VPosNormBoneTex input, float4x4 bones[MAX_BONES])
{
	VVPosTex03Tex13	output;
	
	float4	vertPos	=float4(input.PositionU.xyz, 1);
	
	//generate view-proj matrix
	float4x4	vp	=mul(mView, mProjection);
	
	//do the bone influences
	float4x4 skinTransform	=GetSkinXForm(input.Blend0, input.Weight0, bones);
	
	//xform the vert to the character's boney pos
	vertPos	=mul(vertPos, skinTransform);
	
	//transform to world
	float4	worldPos	=mul(vertPos, mWorld);
	output.TexCoord1	=worldPos.xyz;

	//viewproj
	output.Position	=mul(worldPos, vp);

	//skin transform the normal
	float3	worldNormal	=mul(input.NormalV.xyz, skinTransform);
	
	//world transform the normal
	output.TexCoord0	=mul(worldNormal, mWorld);

	return	output;
}


//the vertex shaders here use a variety of different formats...
//each one will use t0 and be above the code that uses it
StructuredBuffer<VPosNormBoneTex>	SBPosNormBoneTex : register(t0);

//skin world norm and pos and texcoord
VVPosTex04Tex14 SkinWNormWPosTexVS(uint ID : SV_VertexID)
{
	VPosNormBoneTex	vpn	=SBPosNormBoneTex[ID];

	VVPosTex03Tex13	skint	=ComputeSkinWorld(vpn, mBones);

	VVPosTex04Tex14	output;

	output.Position			=skint.Position;
	output.TexCoord0.xyz	=skint.TexCoord0.xyz;
	output.TexCoord1.xyz	=skint.TexCoord1.xyz;

	//direct copy of texcoords
	output.TexCoord0.w	=vpn.PositionU.w;
	output.TexCoord1.w	=vpn.NormalV.w;
	
	return	output;
}


StructuredBuffer<VPosNormBoneTexCol>	SBPosNormBoneTexCol : register(t0);

//skin, world norm, world pos, vert color
VVPosTex04Tex14Tex24 SkinWNormWPosTexColorVS(uint ID : SV_VertexID)
{
	VPosNormBoneTexCol	vpn	=SBPosNormBoneTexCol[ID];

	VPosNormBoneTex	inSkin;

	inSkin.PositionU	=vpn.PositionU;
	inSkin.NormalV		=vpn.NormalV;
	inSkin.Blend0		=vpn.Blend0;
	inSkin.Weight0		=vpn.Weight0;

	VVPosTex03Tex13	skin	=ComputeSkinWorld(inSkin, mBones);

	VVPosTex04Tex14Tex24	ret;

	ret.Position		=skin.Position;
	ret.TexCoord0.xyz	=skin.TexCoord0;
	ret.TexCoord1.xyz	=skin.TexCoord1;
	ret.TexCoord2		=vpn.Color;

	//direct copy of texcoords
	ret.TexCoord0.w	=vpn.PositionU.w;
	ret.TexCoord1.w	=vpn.NormalV.w;

	return	ret;
}

//vert color's red multiplies dangliness
VVPosTex04Tex14 SkinDanglyWnormWPosTexVS(uint ID : SV_VertexID)
{
	VPosNormBoneTexCol	vpn	=SBPosNormBoneTexCol[ID];

	VVPosTex03Tex13	skin	=ComputeSkinWorldDangly(vpn, mBones);

	VVPosTex04Tex14	ret;

	ret.Position		=skin.Position;
	ret.TexCoord0.xyz	=skin.TexCoord0;
	ret.TexCoord1.xyz	=skin.TexCoord1;

	//direct copy of texcoords
	ret.TexCoord0.w	=vpn.PositionU.w;
	ret.TexCoord1.w	=vpn.NormalV.w;

	return	ret;
}


StructuredBuffer<VPosNormBoneTexIdx>	SBPosNormBoneTexIdx : register(t0);

//skin world norm and pos and texcoord
WPosWNormTexColorIdx SkinWNormWPosTexIdxVS(uint ID : SV_VertexID)
{
	VPosNormBoneTexIdx	vpn	=SBPosNormBoneTexIdx[ID];

	VPosNormBoneTex	inSkin;

	inSkin.PositionU	=vpn.PositionU;
	inSkin.NormalV		=vpn.NormalV;
	inSkin.Blend0		=vpn.Blend0;
	inSkin.Weight0		=vpn.Weight0;

	VVPosTex03Tex13	skin	=ComputeSkinWorld(inSkin, mBones);
	
	WPosWNormTexColorIdx	output;

	output.Position			=skin.Position;
	output.WorldPosU.xyz	=skin.TexCoord0.xyz;
	output.WorldNormalV.xyz	=skin.TexCoord1.xyz;
	output.Idx				=vpn.Idx;
	output.Color			=float4(1,1,1,1);

	//direct copy of texcoords
	output.WorldPosU.w		=vpn.PositionU.w;
	output.WorldNormalV.w	=vpn.NormalV.w;
	
	return	output;
}
