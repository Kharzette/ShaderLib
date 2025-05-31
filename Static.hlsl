//For static geometry
#include "Types.hlsli"
#include "CommonFunctions.hlsli"


//standard static format
StructuredBuffer<VPosNormTexColIdx>	SBVert : register(t0);

//worldpos and normal
WPosWNormTexColorIdx StaticVS(uint ID : SV_VertexID)
{
	VPosNormTexColIdx	vpn	=SBVert[ID];

	WPosWNormTexColorIdx	output;

	float4	norm, col;
	uint	idx;
	UnPackNormColIdx(vpn.NormVCol, norm, col, idx);

	//generate the world-view-proj matrix
	float4x4	wvp	=mul(mul(mWorld, mView), mProjection);

	//local scale, why I didn't want this in the world
	//matrix I sadly do not remember
	float3	scalyPos	=vpn.PositionU.xyz * mLocalScale.xyz;
	
	//transform the input position to the output
	output.Position		=mul(float4(scalyPos, 1), wvp);
	output.WorldNormalV	=mul(norm.xyz, mWorld);
	output.WorldPosU	=mul(float4(scalyPos.xyz, 1), mWorld);
	output.Color		=col;
	output.Idx			=idx;

	//direct copy of texcoords
	output.WorldPosU.w		=vpn.PositionU.w;
	output.WorldNormalV.w	=norm.w;
	
	//return the output structure
	return	output;
}