//For static geometry
#include "Types.hlsli"
#include "CommonFunctions.hlsli"


void	UnPackStuff(uint4 stuff,
	out float4 lowVal, out float4 hiVal, out uint idx)
{
	lowVal	=f16tof32(stuff);

	stuff	>>=16;

	hiVal	=f16tof32(stuff);

	idx	=stuff.w;
}

//the vertex shaders here use a variety of different formats...
//each one will use t0 and be above the code that uses it
StructuredBuffer<VPosNormTexColExpIdx>	SBVert : register(t0);

//worldpos and normal
WPosWNormTexColorIdx WNormWPosTexColIdxVS(uint ID : SV_VertexID)
{
	VPosNormTexColExpIdx	vpn	=SBVert[ID];

	WPosWNormTexColorIdx	output;

	float4	norm, col;
	uint	idx;
	UnPackStuff(vpn.NormVCol, norm, col, idx);

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