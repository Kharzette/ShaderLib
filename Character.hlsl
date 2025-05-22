//Character - stuff with bones

#include "Types.hlsli"
#include "CommonFunctions.hlsli"


cbuffer Character : register(b3)
{
	//matrii for skinning
	float4x4	mBones[MAX_BONES];	
}

//standard character format
StructuredBuffer<VPosNormTexColIdxBone>	SBVert : register(t0);

//functions
void	UnPackBone(uint4 squished,
	out uint4 indexes, out half4 weights)
{
	weights	=f16tof32(squished);

	squished	>>=16;

	indexes	=squished;
}

float4x4 GetSkinXForm(uint4 bnIdxs, half4 bnWeights, float4x4 bones[MAX_BONES])
{
	float4x4 skinTransform	=bones[bnIdxs.x] * bnWeights.x;

	skinTransform	+=bones[bnIdxs.y] * bnWeights.y;
	skinTransform	+=bones[bnIdxs.z] * bnWeights.z;
	skinTransform	+=bones[bnIdxs.w] * bnWeights.w;
	
	return	skinTransform;
}

struct	SkinOut
{
	float4	Position;
	half3	WorldPos;
	half3	WorldNormal;
};

//skin with world info
SkinOut	ComputeSkin(float3 pos, half3 norm,
	uint4 bnIdxs, half4 bnWeights,
	float4x4 bones[MAX_BONES])
{
	SkinOut	ret;
	
	float4	vertPos	=float4(pos, 1);
	
	//generate view-proj matrix
	float4x4	vp	=mul(mView, mProjection);
	
	//do the bone influences
	float4x4 skinTransform	=GetSkinXForm(bnIdxs, bnWeights, bones);
	
	//xform the vert to the character's boney pos
	vertPos	=mul(vertPos, skinTransform);
	
	//transform to world
	float4	worldPos	=mul(vertPos, mWorld);

	//viewproj
	ret.Position	=mul(worldPos, vp);

	//skin transform the normal
	float3	worldNormal	=mul(norm.xyz, skinTransform);
	
	//world transform the normal
	ret.WorldNormal	=mul(worldNormal, mWorld);
	ret.WorldPos	=worldPos;

	return	ret;
}


//skin world norm and pos and texcoord
WPosWNormTexColorIdx SkinVS(uint ID : SV_VertexID)
{
	VPosNormTexColIdxBone	vpn	=SBVert[ID];

	float4	norm, col;
	uint	idx;
	UnPackNormColIdx(vpn.NormVCol, norm, col, idx);

	uint4	indexes;
	float4	weights;
	UnPackBone(vpn.Bone, indexes, weights);

	SkinOut	so	=ComputeSkin(vpn.PositionU.xyz,
					norm.xyz, indexes, weights, mBones);

	WPosWNormTexColorIdx	output;

	output.Position		=so.Position;
	output.WorldNormalV	=half4(so.WorldNormal.xyz, norm.w);
	output.WorldPosU	=half4(so.WorldPos.xyz, vpn.PositionU.w);
	output.Color		=col;
	output.Idx			=idx;

	return	output;
}