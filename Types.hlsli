//commonly used types
#ifndef _TYPESFXH
#define _TYPESFXH


//vertex shader inputs
//these all generally have a POSITION and
//maybe some other stuff, and are the same
//on all feature levels except where ifdefd
struct VPos
{
	float3	Position	: POSITION;
};

struct VPosTex0
{
	float3	Position	: POSITION;
	half2	TexCoord0	: TEXCOORD0;
};

struct VPos2Tex02
{
	float2	Position	: POSITION;
	half2	TexCoord0	: TEXCOORD0;
};

struct VPos2Tex04
{
	float2	Position	: POSITION;
	half4	TexCoord0	: TEXCOORD0;
};

struct VPos2Col0
{
	float2	Position	: POSITION;
	half4	Color		: COLOR0;
};

struct VPos2Col0Tex04
{
	float2	Position	: POSITION;
	half4	Color		: COLOR0;
	half4	TexCoord0	: TEXCOORD0;
};

struct VPosNormTex0
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
	half2	TexCoord0	: TEXCOORD0;
};

struct VPosNormTex0Col0
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
	half2	TexCoord0	: TEXCOORD0;
	half4	Color		: COLOR0;	
};

struct VPosNormTex04
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
	half4	TexCoord0	: TEXCOORD0;	
};

struct VPosNormTex04Tex14
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
	half4	TexCoord0	: TEXCOORD0;	
	half4	TexCoord1	: TEXCOORD1;
};

struct VPosNormTex04Tex14Tex24Col0
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
	half4	TexCoord0	: TEXCOORD0;	
	half4	TexCoord1	: TEXCOORD1;	
	half4	TexCoord2	: TEXCOORD2;	
	half4	Color		: COLOR0;
};


//pixel shader input stuff for > 9_3 feature
//levels, uses SV_POSITION and the pixel shader
//is free to read from it.
struct VVPos
{
	float4	Position	: SV_POSITION;
};

struct VVPosCol0
{
	float4	Position	: SV_POSITION;
	half4	Color		: COLOR0;
};

struct VVPosTex0
{
	float4	Position	: SV_POSITION;
	half2	TexCoord0	: TEXCOORD0;
};

struct VVPosCol0Tex04
{
	float4	Position	: SV_POSITION;
	half4	Color		: COLOR0;
	half4	TexCoord0	: TEXCOORD0;
};

struct VVPosTex04
{
	float4	Position	: SV_POSITION;
	half4	TexCoord0	: TEXCOORD0;
};

struct VVPosCubeTex0
{
	float4	Position	: SV_POSITION;
	half3	TexCoord0	: TEXCOORD0;
};

struct VVPosTex04Tex14
{
	float4	Position	: SV_POSITION;
	half4	TexCoord0	: TEXCOORD0;
	half4	TexCoord1	: TEXCOORD1;
};

struct VVPosTex04Tex14Tex24
{
	float4	Position	: SV_POSITION;
	half4	TexCoord0	: TEXCOORD0;
	half4	TexCoord1	: TEXCOORD1;
	half4	TexCoord2	: TEXCOORD2;
};

struct VVPosTex04Tex14Tex24Tex31
{
	float4	Position	: SV_POSITION;
	half4	TexCoord0	: TEXCOORD0;
	half4	TexCoord1	: TEXCOORD1;
	half4	TexCoord2	: TEXCOORD2;
	float	TexCoord3	: TEXCOORD3;
};

struct VVPosTex04Tex14Tex24Tex34
{
	float4	Position	: SV_POSITION;
	half4	TexCoord0	: TEXCOORD0;
	half4	TexCoord1	: TEXCOORD1;
	half4	TexCoord2	: TEXCOORD2;
	half4	TexCoord3	: TEXCOORD3;
};

struct VVPosTex04Tex14Tex24Tex34Tex44Tex54
{
	float4	Position	: SV_POSITION;
	half4	TexCoord0	: TEXCOORD0;
	half4	TexCoord1	: TEXCOORD1;
	half4	TexCoord2	: TEXCOORD2;
	half4	TexCoord3	: TEXCOORD3;
	half4	TexCoord4	: TEXCOORD4;
	half4	TexCoord5	: TEXCOORD5;
};


//structs for using structured buffers and such
//eventually can get rid of the above stuff
struct	VPosNormTex
{
	float4		PositionU;	//w has U
	min16float4	NormalV;	//w has V
};

//this is the standard static format
//can cram in pos, texcoord, color, and index
struct	VPosNormTexColIdx
{
	float4		PositionU;	//w has U
	uint4		NormVCol;	//packed F16
};

//standard character format
struct	VPosNormTexColIdxBone
{
	float4		PositionU;	//w has U
	uint4		NormVCol;	//packed F16
	uint4		Bone;		//indexes and F16 weights
};

struct	UIVert
{
	float2	Position	: POSITION;
	uint4	ColorTex	: BLENDINDICES;
};

struct	TerrainVert
{
	float4	Position;
	uint4	TexWeights;	//8 packed F16
	uint4	NormVCol;	//packed F16
};


//PS structs
struct	WPosWNormTexColorIdx
{
	float4	Position		: SV_POSITION;
	half4	WorldPosU		: TEXCOORD0;
	half4	WorldNormalV	: TEXCOORD1;
	half4	Color			: COLOR;
	uint	Idx				: BLENDINDICES;
};

struct UIPosColTex
{
	float4	Position	: SV_POSITION;
	half4	Color		: COLOR;
	half4	TexCoord	: TEXCOORD;
};

struct	PSTerrain
{
	float4	Position	: SV_POSITION;
	half4	WorldPosFF	: TEXCOORD0;
	half4	WorldNormal	: TEXCOORD1;
	half4	TexWeight0	: TEXCOORD2;
	half4	TexWeight1	: TEXCOORD3;
	half4	Color		: COLOR;
};
#endif	//_TYPESFXH