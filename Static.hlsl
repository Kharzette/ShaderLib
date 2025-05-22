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
	
	//transform the input position to the output
	output.Position		=mul(float4(vpn.PositionU.xyz, 1), wvp);
	output.WorldNormalV	=mul(norm.xyz, mWorld);
	output.WorldPosU	=mul(float4(vpn.PositionU.xyz, 1), mWorld);
	output.Color		=col;
	output.Idx			=idx;

	//direct copy of texcoords
	output.WorldPosU.w		=vpn.PositionU.w;
	output.WorldNormalV.w	=norm.w;
	
	//return the output structure
	return	output;
}