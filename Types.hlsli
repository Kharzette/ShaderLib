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

//struct VPosNorm
//{
//	float3	Position	: POSITION;
//	half4	Normal		: NORMAL;
//};

struct VPosTex0
{
	float3	Position	: POSITION;
	half2	TexCoord0	: TEXCOORD0;
};

struct VPosTex01
{
	float3	Position	: POSITION;
	half	TexCoord0	: TEXCOORD0;
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

struct VPos4Tex04Tex14
{
	float4	Position	: POSITION;
	half4	TexCoord0	: TEXCOORD0;
	half4	TexCoord1	: TEXCOORD1;
};

struct VPosCol0
{
	float3	Position	: POSITION;
	half4	Color		: COLOR0;
};

struct VPosCol0Tex04Tex14Tex24
{
	float3	Position	: POSITION;
	half4	Color		: COLOR0;
	half4	TexCoord0	: TEXCOORD0;
	half4	TexCoord1	: TEXCOORD1;
	half4	TexCoord2	: TEXCOORD2;
};

struct VPosBone
{
	float3	Position	: POSITION;
#if defined(SM2)
	half4	Blend0		: BLENDINDICES0;
#else
	int4	Blend0		: BLENDINDICES0;
#endif
	half4	Weight0		: BLENDWEIGHTS0;
};

struct VPosTex0Col0
{
	float3	Position	: POSITION;
	half2	TexCoord0	: TEXCOORD0;
	half4	Color		: COLOR0;	
};

struct VPosTex0Col0Tan
{
	float3	Position	: POSITION;
	half2	TexCoord0	: TEXCOORD0;
	half4	Color		: COLOR0;
	half4	Tangent		: TANGENT0;
};

struct VPosTex0Tex1Col0
{
	float3	Position	: POSITION;
	half2	TexCoord0	: TEXCOORD0;
	half2	TexCoord1	: TEXCOORD1;
	half4	Color		: COLOR0;	
};

struct VPosTex0Tex1Col0Col1
{
	float3	Position	: POSITION;
	half2	TexCoord0	: TEXCOORD0;
	half2	TexCoord1	: TEXCOORD1;
	half4	Color0		: COLOR0;
	half4	Color1		: COLOR1;
};

struct VPosTex0Tex1
{
	float3	Position	: POSITION;
	half2	TexCoord0	: TEXCOORD0;
	half2	TexCoord1	: TEXCOORD1;
};

struct VPosNormTex0
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
	half2	TexCoord0	: TEXCOORD0;
};

struct VPosNormTanTex0
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
	half4	Tangent		: TANGENT0;
	half2	TexCoord0	: TEXCOORD0;
};

/*
struct VPosNormBone
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
#if defined(SM2)
	half4	Blend0		: BLENDINDICES0;
#else
	int4	Blend0		: BLENDINDICES0;
#endif

	half4	Weight0		: BLENDWEIGHTS0;
};*/

struct VPosNormTex0Col0
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
	half2	TexCoord0	: TEXCOORD0;
	half4	Color		: COLOR0;	
};

struct VPosNormTex0Tex1
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
	half2	TexCoord0	: TEXCOORD0;
	half2	TexCoord1	: TEXCOORD1;
};

struct VPosNormCol0
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
	half4	Color		: COLOR0;	
};

/*
struct VPosNormBoneTex0
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
#if defined(SM2)
	half4	Blend0		: BLENDINDICES0;
#else
	int4	Blend0		: BLENDINDICES0;
#endif

	half4	Weight0		: BLENDWEIGHTS0;
	half2	TexCoord0	: TEXCOORD0;
};*/

struct VPosNormBoneTex0Tex1
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
#if defined(SM2)
	half4	Blend0		: BLENDINDICES0;
#else
	int4	Blend0		: BLENDINDICES0;
#endif

	half4	Weight0		: BLENDWEIGHTS0;
	half2	TexCoord0	: TEXCOORD0;
	half2	TexCoord1	: TEXCOORD1;
};

/*
struct VPosNormBoneCol0
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
#if defined(SM2)
	half4	Blend0		: BLENDINDICES0;
#else
	int4	Blend0		: BLENDINDICES0;
#endif

	half4	Weight0		: BLENDWEIGHTS0;
	half4	Color		: COLOR0;	
};

struct VPosNormBoneTex0Col0
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
#if defined(SM2)
	half4	Blend0		: BLENDINDICES0;
#else
	int4	Blend0		: BLENDINDICES0;
#endif

	half4	Weight0		: BLENDWEIGHTS0;
	half2	TexCoord0	: TEXCOORD0;
	half4	Color		: COLOR0;	
};*/

struct VPosNormTex0Tex1Col0
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
	half2	TexCoord0	: TEXCOORD0;
	half2	TexCoord1	: TEXCOORD1;
	half4	Color		: COLOR0;	
};

struct VPosNormTex04
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
	half4	TexCoord0	: TEXCOORD0;	
};

struct VPosNormTex04Col0
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
	half4	TexCoord0	: TEXCOORD0;	
	half4	Color		: COLOR0;
};

struct VPosNormTex04Tex14
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
	half4	TexCoord0	: TEXCOORD0;	
	half4	TexCoord1	: TEXCOORD1;
};

struct VPosNormTex04Tex14Tex24
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
	half4	TexCoord0	: TEXCOORD0;	
	half4	TexCoord1	: TEXCOORD1;
	half4	TexCoord2	: TEXCOORD2;	
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

//I normally put bone before tex / col etc
//but the newer format or maybe blender
//is putting the tex right after normal
struct VPosNormTex0Bone
{
	float3	Position	: POSITION;
	half4	Normal		: NORMAL;
	half2	TexCoord0	: TEXCOORD0;

#if defined(SM2)
	half4	Blend0		: BLENDINDICES0;
#else
	int4	Blend0		: BLENDINDICES0;
#endif
	half4	Weight0		: BLENDWEIGHTS0;
};


//pixel shader input stuff for > 9_3 feature
//levels, uses SV_POSITION and the pixel shader
//is free to read from it.
struct VVPosNorm
{
	float4	Position	: SV_POSITION;
	half3	Normal		: NORMAL;
};

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

struct VVPosTex01
{
	float4	Position	: SV_POSITION;
	float	TexCoord0	: TEXCOORD0;
};

struct VVPosTex03
{
	float4	Position	: SV_POSITION;
	half3	TexCoord0	: TEXCOORD0;
};

struct VVPosTex04
{
	float4	Position	: SV_POSITION;
	half4	TexCoord0	: TEXCOORD0;
};

struct VVPosTex04RTAI
{
	float4	Position	: SV_POSITION;
	half4	TexCoord0	: TEXCOORD0;
	uint	CubeFace	: SV_RenderTargetArrayIndex;
};

struct VVPosTex0TanBiNorm
{
	float4	Position	: SV_POSITION;
	half2	TexCoord0	: TEXCOORD0;
	half3	Tangent		: TEXCOORD1;
	half3	BiNormal	: TEXCOORD2;
};

struct VVPosCubeTex0
{
	float4	Position	: SV_POSITION;
	half3	TexCoord0	: TEXCOORD0;
};

struct VVPosTex0Tex13
{
	float4	Position	: SV_POSITION;
	half2	TexCoord0	: TEXCOORD0;
	half3	TexCoord1	: TEXCOORD1;
};

struct VVPosTex0Tex14
{
	float4	Position	: SV_POSITION;
	half2	TexCoord0	: TEXCOORD0;
	half4	TexCoord1	: TEXCOORD1;
};

struct VVPosTex0Col0
{
	float4	Position	: SV_POSITION;
	half2	TexCoord0	: TEXCOORD0;
	half4	Color		: COLOR0;	
};

struct VVPosTex0Col0TanBiNorm
{
	float4	Position	: SV_POSITION;
	half2	TexCoord0	: TEXCOORD0;
	half4	Color		: COLOR0;	
	half4	Tangent		: TANGENT0;
	half4	BiNormal	: BINORMAL0;
};

struct VVPosTex0Tex1SingleCol0
{
	float4	Position	: SV_POSITION;
	half2	TexCoord0	: TEXCOORD0;
	float	TexCoord1	: TEXCOORD1;
	half4	Color		: COLOR0;	
};

struct VVPosTex0Single
{
	float4	Position	: SV_POSITION;
	float	TexCoord0	: TEXCOORD0;
};

struct VVPosTex0Tex1Single
{
	float4	Position	: SV_POSITION;
	half2	TexCoord0	: TEXCOORD0;
	float	TexCoord1	: TEXCOORD1;
};

struct VVPosTex0Tex1
{
	float4	Position	: SV_POSITION;
	half2	TexCoord0	: TEXCOORD0;
	half2	TexCoord1	: TEXCOORD1;
};

struct VVPosTex03Tex13
{
	float4	Position	: SV_POSITION;
	half3	TexCoord0	: TEXCOORD0;
	half3	TexCoord1	: TEXCOORD1;
};

struct VVPosTex03Tex13Tex23
{
	float4	Position	: SV_POSITION;
	half3	TexCoord0	: TEXCOORD0;
	half3	TexCoord1	: TEXCOORD1;
	half3	TexCoord2	: TexCoord2;
};

struct VVPosNormTex0Tex1
{
	float4	Position	: SV_POSITION;
	half3	Normal		: NORMAL;
	half2	TexCoord0	: TEXCOORD0;
	half2	TexCoord1	: TEXCOORD1;
};

struct VVPosNormTanBiTanTex0
{
	float4	Position	: SV_POSITION;
	half3	Normal		: TEXCOORD0;
	half3	Tangent		: TEXCOORD1;
	half3	BiTangent	: TEXCOORD2;
	half2	TexCoord0	: TEXCOORD3;
};

struct VVPosNormTanBiTanTex0Tex1
{
	float4	Position	: SV_POSITION;
	half3	Normal		: TEXCOORD0;
	half3	Tangent		: TEXCOORD1;
	half3	BiTangent	: TEXCOORD2;
	half2	TexCoord0	: TEXCOORD3;
	half2	TexCoord1	: TEXCOORD4;
};

struct VVPosNormTanBiTanTex0Col0
{
	float4	Position	: SV_POSITION;
	half3	Normal		: TEXCOORD0;
	half3	Tangent		: TEXCOORD1;
	half3	BiTangent	: TEXCOORD2;
	half2	TexCoord0	: TEXCOORD3;
	half4	Color		: COLOR0;
};

struct VVPosTex0Tex1Col0
{
	float4	Position	: SV_POSITION;
	half2	TexCoord0	: TEXCOORD0;
	half2	TexCoord1	: TEXCOORD1;
	half4	Color		: COLOR0;	
};

struct VVPosTex0Tex1Col0Col1
{
	float4	Position	: SV_POSITION;
	half2	TexCoord0	: TEXCOORD0;
	half2	TexCoord1	: TEXCOORD1;
	half4	Color0		: COLOR0;
	half4	Color1		: COLOR0;
};

struct VVPosTex0Tex1Tex2Tex3Tex4Col0Intensity
{
	float4	Position	: SV_POSITION;
	half2	TexCoord0	: TEXCOORD0;
	half2	TexCoord1	: TEXCOORD1;
	half2	TexCoord2	: TEXCOORD2;
	half2	TexCoord3	: TEXCOORD3;
	half2	TexCoord4	: TEXCOORD4;
	half4	Color		: COLOR0;
	half4	Intensity	: TEXCOORD5;
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

struct VVPosTex04Tex14Tex24Tex34Tex44
{
	float4	Position	: SV_POSITION;
	half4	TexCoord0	: TEXCOORD0;
	half4	TexCoord1	: TEXCOORD1;
	half4	TexCoord2	: TEXCOORD2;
	half4	TexCoord3	: TEXCOORD3;
	half4	TexCoord4	: TEXCOORD4;
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


//9_3 specific pixel shader inputs, these
//use VPOS instead of SV_POSITION for
//screen stuff, since SV_POSITION can't be
//read from 9_3
struct VVPos93
{
	float4	Position	: SV_POSITION;
	float4	VPos		: VPOS;
};

//structs for using structured buffers and such
//eventually can get rid of the above stuff
struct	VPosNormTex
{
	float4		PositionU;	//w has U
	min16float4	NormalV;	//w has V
};

struct	VPosNormTexIdx
{
	float4		PositionU;	//w has U
	min16float4	NormalV;	//w has V
	min16uint	Idx;
};

struct	VPosNormTexCol
{
	float4		PositionU;	//w has U
	min16float4	NormalV;	//w has V
	min16float4	Color;
};

struct	VPosNormTexColExpIdx
{
	float4		PositionU;	//w has U
	uint4		NormVCol;	//packed F16
};


struct	VPosNormBoneTex
{
	float4		PositionU;	//w has U
	min16float4	NormalV;	//w has V
	min16uint4	Blend0;
	min16float4	Weight0;
};

struct	VPosNormBoneTexCol
{
	float4		PositionU;	//w has U
	min16float4	NormalV;	//w has V
	min16float4	Color;
	min16uint4	Blend0;
	min16float4	Weight0;
};

struct	VPosNormBoneTexIdx
{
	float4		PositionU;	//w has U
	min16float4	NormalV;	//w has V
	min16uint4	Blend0;
	min16float4	Weight0;
	min16uint	Idx;
};


struct	UIVert
{
	float2	Position	: POSITION;
	uint4	ColorTex	: BLENDINDICES;
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

struct	PSTest
{
	float4	Position	: SV_POSITION;
	uint4	LowVal		: TEXCOORD0;
	uint4	HiVal		: TEXCOORD1;
	uint	Index		: TEXCOORD2;
};

#endif	//_TYPESFXH