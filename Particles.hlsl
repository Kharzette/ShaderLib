#include	"lygia/generative/random.hlsl"
#include	"CommonFunctions.hlsli"

#define	DELTATIME			(1.0f / 60.0f)
#define	EMIT_SHAPE_POINT	0
#define	EMIT_SHAPE_SPHERE	1
#define	EMIT_SHAPE_BOX		2
#define	EMIT_SHAPE_LINE		3
#define	EMIT_SHAPE_PLANE	4

//basic ordinary particles
struct Particle
{
	float4	mPositionSize;	//size in w
	float4	mVelocityRot;	//rot angle in w

	float4	mColorVelocity;	//color changes over time
	float4	mLifeRSVels;	//life remaining, rotational velocity
							//size velocity, and blank
	float4	mColor;

	int		mNext;	//store next active or next free spot
};

//emitter
//these values control
//the ranges of possible values for particles
//when they are initially created
cbuffer EmitterCB : register(b11)
{
	int4	mShapeMaxPEOn;	//shape, max part, empty, bOn
	float4	mPositionSize;	//start size in w
	float4	mStartColor;
	float4	mLineAxisFreq;	//frequency in w
	
	float4	mRVelSizeCap;	//rot vel min, rot vel max
							//shape size, vcap
	float4	mColorVelMin;	//minimum color velocity
	float4	mColorVelMax;	//maximum color velocity

	float4	mVMinMaxLMinMax;	//velocity min, max
								//life min, max								

	float4	mSizeVMinMaxSecDelta;	//size vmin, vmax
									//seconds, rdelta
};

struct EmitterValues
{
	float	mTime;			//remainder
	int		mNumParticles;	//number active
	int		mLast;			//last particle index
	int		mNextFree;		//for allocing particles
	int		mLastActive;	//counts up during iteration
};

//particle vertices for drawing
//these are fed to ParticleVS in 2D.hlsl
//as VPos4Tex04Tex14
struct ParticleVert
{
	float4	mPositionTex;		//position, UV.x in w
	float4	mTexSizeRotBlank;	//UV.Y, size, rot
	float4	mColor;
};

//created here and updated here
RWStructuredBuffer<Particle>	sParticles : register(u0);

//stuff that changes over time
RWStructuredBuffer<EmitterValues>	sEmitterValues : register(u1);

//spat out to feed to vertex shader
RWStructuredBuffer<ParticleVert>	sPartVerts : register(u2);

//same verts in srv format
StructuredBuffer<ParticleVert>	VSParticles : register(t2);


//dealloc spots in the particle array
void	DeAllocateIndex(int idx)
{
	sParticles[idx].mNext	=sEmitterValues[0].mNextFree;

	sEmitterValues[0].mNextFree	=idx;
	
	sEmitterValues[0].mNumParticles--;
}

//alloc spots in the particle array
int	GetNextFreeIndex()
{
	int	nextFree	=sEmitterValues[0].mNextFree;

	if(sParticles[nextFree].mNext)
	{
		sEmitterValues[0].mNextFree	=sParticles[nextFree].mNext;
	}
	else
	{
		sEmitterValues[0].mNextFree++;
	}

	if(nextFree > sEmitterValues[0].mLast)
	{
		sEmitterValues[0].mLast	=nextFree;
	}

	sEmitterValues[0].mNumParticles++;

	return	nextFree;
}


//random position within the emitter shape bounds
float3	PositionForShape(float4 seed, float3 pos, float3 lineAxis, uint shape, float shapeSize)
{
	if(shape == EMIT_SHAPE_POINT)
	{
		return	pos;
	}

	float3	ret			=float3(0, 0, 0);

	float	sizeOverTwo	=shapeSize * 0.5f;

	float3	randVec		=random3(seed.xyz);

	if(shape == EMIT_SHAPE_BOX)
	{
		ret	=(randVec * sizeOverTwo);
	}
	else if(shape == EMIT_SHAPE_LINE)
	{
		ret	=(lineAxis * (randVec * sizeOverTwo));
	}
	else if(shape == EMIT_SHAPE_PLANE)
	{
		ret		=(randVec * sizeOverTwo);
		ret.y	=0.0f;
	}
	else if(shape == EMIT_SHAPE_SPHERE)
	{
		ret	=normalize(randVec);
		ret	*=sizeOverTwo;
	}

	ret	+=pos;

	return	ret;
}


//return random unit vector
float3	SortOfRandomDirection(float3 seed)
{
	float3	vec	=random(seed);

	return	normalize(vec);
}

//return value between min and max
float	SortOfRandomValue(float seed, float min, float max)
{
	//0 to 1
	float	val	=random(seed) * 0.5f;

	val	*=(max - min);

	return	val + min;
}

//return value between min and max
float	SortOfRandomValue(float2 seed, float min, float max)
{
	//0 to 1
	float	val	=random(seed) * 0.5f;

	val	*=(max - min);

	return	val + min;
}

float4	SortOfRandomVector4Range(float4 seed, float min, float max)
{
	float4	randVec		=random(seed);

	//0 to 2 range
	randVec	+=float4(1,1,1,1);

	float	range	=max - min;

	range	*=0.5f;

	float4	range4	=float4(range, range, range, range);

	randVec	*=range4;

	randVec	+=min;

	return	randVec;
}

float4	SortOfRandomVector4Range4(float4 seed, float4 min, float4 max)
{
	//this should produce a vec4 with values between -1 and 1
	float4	randVec		=random(seed);

	//0 to 2 range
	randVec	+=float4(1,1,1,1);

	float4	range	=max - min;

	range	*=0.5f;

	randVec	*=range;

	randVec	+=min;

	return	randVec;
}


Particle	Emit(int seedInt)
{
	Particle	ret;

	float	seedF		=seedInt;
	float	timeSeconds	=mSizeVMinMaxSecDelta.z + 1.0f;

	//make wacky values as a random seed
	float4	seed	=float4(seedF * timeSeconds, seedF * 0.2f * timeSeconds,
		seedF * 5.0f * timeSeconds, seedF * 111.0f / timeSeconds);

	//random position
	ret.mPositionSize.xyz	=PositionForShape(seed, mPositionSize.xyz,
		mLineAxisFreq.xyz, mShapeMaxPEOn.x, mRVelSizeCap.z);

	ret.mPositionSize.w		=mPositionSize.w;	//start size
	ret.mVelocityRot.w		=0;					//start rotation
	ret.mColor				=mStartColor;

	//velocity
	float3	velVec	=SortOfRandomDirection(seed.xyz);

	float	speed	=SortOfRandomValue(seed.w, mVMinMaxLMinMax.x, mVMinMaxLMinMax.y);

	ret.mVelocityRot.xyz	=velVec * speed;

	//life is a value between max and min life
	ret.mLifeRSVels.x	=SortOfRandomValue(ret.mPositionSize.xy,
		mVMinMaxLMinMax.z, mVMinMaxLMinMax.w);

	ret.mColorVelocity	=SortOfRandomVector4Range4(seed,
		mColorVelMin, mColorVelMax);

	//rotational velocity
	ret.mLifeRSVels.y	=SortOfRandomValue(seed.x * seed.z,
		mRVelSizeCap.x, mRVelSizeCap.y);

	//size velocity
	ret.mLifeRSVels.z	=SortOfRandomValue(seed.z * 3.0f,
		mSizeVMinMaxSecDelta.x, mSizeVMinMaxSecDelta.y);

	ret.mLifeRSVels.w	=0;	//unused for now

	ret.mNext	=0;

	return	ret;
}


[numthreads(1, 1, 1)]
void ParticleEmitter(uint3 dtID : SV_DispatchThreadID)
{
	float	dt	=mSizeVMinMaxSecDelta.w;

	for(int i=0;i <= sEmitterValues[0].mLast;i++)
	{
		//update any existing particles
		Particle	p	=sParticles[i];

		if(p.mLifeRSVels.x <= 0.0f)
		{
			continue;
		}

		//TODO: use passed in delta time
		p.mLifeRSVels.x	-=dt;
		if(p.mLifeRSVels.x < 0.0f)
		{
			DeAllocateIndex(i);

			//copy the expired life value
			sParticles[i].mLifeRSVels.x	=p.mLifeRSVels.x;
			continue;
		}

		sEmitterValues[0].mLastActive	=i;

		p.mPositionSize.xyz	+=(p.mVelocityRot.xyz * dt);
		p.mColor			+=(p.mColorVelocity * dt);
		p.mPositionSize.w	+=(p.mLifeRSVels.z * dt);
		p.mVelocityRot.w	+=(p.mLifeRSVels.y * dt);

		p.mColor	=clamp(p.mColor, half4(0,0,0,0), half4(1,1,1,1));

		sParticles[i]	=p;
	}

	sEmitterValues[0].mLast	=sEmitterValues[0].mLastActive;

	//update emitter if on
	//this might create new particles
	if(mShapeMaxPEOn.w)
	{
		sEmitterValues[0].mTime	+=dt;

		//check frequency
		while(sEmitterValues[0].mTime > mLineAxisFreq.w)
		{
			int	numActive	=sEmitterValues[0].mNumParticles;

			//max particles?
			if(numActive >= mShapeMaxPEOn.y)
			{
				//arrays are full
				sEmitterValues[0].mTime	-=mLineAxisFreq.w;
				continue;
			}

			int	idx	=GetNextFreeIndex();

			sParticles[idx]	=Emit(numActive);

			sEmitterValues[0].mTime	-=mLineAxisFreq.w;
		}
	}

	//crap out a VB to draw
	int	curVert	=0;
	for(int j=0;j <= sEmitterValues[0].mLast;j++)
	{
		//update any existing particles
		Particle	p	=sParticles[j];

		if(p.mLifeRSVels.x <= 0.0f)
		{
			continue;
		}

		//tri index 0
		sPartVerts[curVert].mPositionTex.xyz	=p.mPositionSize.xyz;
		sPartVerts[curVert].mPositionTex.w		=0;						//texcoord x

		sPartVerts[curVert].mTexSizeRotBlank.x	=1;						//texcoord y
		sPartVerts[curVert].mTexSizeRotBlank.y	=p.mPositionSize.w;		//size
		sPartVerts[curVert].mTexSizeRotBlank.z	=p.mVelocityRot.w;		//rotation
		sPartVerts[curVert].mTexSizeRotBlank.w	=0;						//unused

		sPartVerts[curVert].mColor	=p.mColor;

		curVert++;

		//tri index 1
		sPartVerts[curVert].mPositionTex.xyz	=p.mPositionSize.xyz;
		sPartVerts[curVert].mPositionTex.w		=1;						//texcoord x

		sPartVerts[curVert].mTexSizeRotBlank.x	=0;						//texcoord y
		sPartVerts[curVert].mTexSizeRotBlank.y	=p.mPositionSize.w;		//size
		sPartVerts[curVert].mTexSizeRotBlank.z	=p.mVelocityRot.w;		//rotation
		sPartVerts[curVert].mTexSizeRotBlank.w	=0;						//unused

		sPartVerts[curVert].mColor	=p.mColor;

		curVert++;

		//tri index 2
		sPartVerts[curVert].mPositionTex.xyz	=p.mPositionSize.xyz;
		sPartVerts[curVert].mPositionTex.w		=0;						//texcoord x

		sPartVerts[curVert].mTexSizeRotBlank.x	=0;						//texcoord y
		sPartVerts[curVert].mTexSizeRotBlank.y	=p.mPositionSize.w;		//size
		sPartVerts[curVert].mTexSizeRotBlank.z	=p.mVelocityRot.w;		//rotation
		sPartVerts[curVert].mTexSizeRotBlank.w	=0;						//unused

		sPartVerts[curVert].mColor	=p.mColor;

		curVert++;

		//tri2 index 0
		sPartVerts[curVert].mPositionTex.xyz	=p.mPositionSize.xyz;
		sPartVerts[curVert].mPositionTex.w		=1;						//texcoord x

		sPartVerts[curVert].mTexSizeRotBlank.x	=1;						//texcoord y
		sPartVerts[curVert].mTexSizeRotBlank.y	=p.mPositionSize.w;		//size
		sPartVerts[curVert].mTexSizeRotBlank.z	=p.mVelocityRot.w;		//rotation
		sPartVerts[curVert].mTexSizeRotBlank.w	=0;						//unused

		sPartVerts[curVert].mColor	=p.mColor;

		curVert++;

		//tri2 index 1
		sPartVerts[curVert].mPositionTex.xyz	=p.mPositionSize.xyz;
		sPartVerts[curVert].mPositionTex.w		=1;						//texcoord x

		sPartVerts[curVert].mTexSizeRotBlank.x	=0;						//texcoord y
		sPartVerts[curVert].mTexSizeRotBlank.y	=p.mPositionSize.w;		//size
		sPartVerts[curVert].mTexSizeRotBlank.z	=p.mVelocityRot.w;		//rotation
		sPartVerts[curVert].mTexSizeRotBlank.w	=0;						//unused

		sPartVerts[curVert].mColor	=p.mColor;

		curVert++;

		//tri2 index 2
		sPartVerts[curVert].mPositionTex.xyz	=p.mPositionSize.xyz;
		sPartVerts[curVert].mPositionTex.w		=0;						//texcoord x

		sPartVerts[curVert].mTexSizeRotBlank.x	=1;						//texcoord y
		sPartVerts[curVert].mTexSizeRotBlank.y	=p.mPositionSize.w;		//size
		sPartVerts[curVert].mTexSizeRotBlank.z	=p.mVelocityRot.w;		//rotation
		sPartVerts[curVert].mTexSizeRotBlank.w	=0;						//unused

		sPartVerts[curVert].mColor	=p.mColor;

		curVert++;
	}
}

//ps input
struct ParticlePSIn
{
	float4	Position	: SV_POSITION;
	float4	TexCoord0	: TEXCOORD0;
	float4	TexCoord1	: TEXCOORD1;
};

ParticlePSIn ParticleSBVS(uint ID : SV_VertexID)
{
	ParticlePSIn	output;

	ParticleVert	pv	=VSParticles[ID];

	float2	uv		=float2(pv.mPositionTex.w, -pv.mTexSizeRotBlank.x);
	float	size	=pv.mTexSizeRotBlank.y;

	//copy texcoords
	output.TexCoord0.xy	=uv;

	//copy color
	output.TexCoord1	=pv.mColor;

	float4x4	viewProj	=mul(mView, mProjection);

	//get matrix vectors
	float3	rightDir	=mView._m00_m10_m20;
	float3	upDir		=mView._m01_m11_m21;
	float3	viewDir		=mView._m02_m12_m22;

	//all verts at 000, add instance pos
	float4	pos	=float4(pv.mPositionTex.xyz, 1);
	
	//store distance to eye
	output.TexCoord0.z	=distance(mEyePos, pos.xyz);

	//w isn't used but shutup warning
	output.TexCoord0.w	=0;

	//centering offset
	float3	centering	=-rightDir * size;
	centering			-=upDir * size;
	centering			*=0.5;

	//quad offset mul by size stored in tex0.y
	float4	ofs	=float4(rightDir * uv.x * size, 1);
	ofs.xyz		+=upDir * uv.y * size;

	//add in centerpoint
	ofs.xyz	+=pos.xyz;

	//center around pos
	ofs.xyz	+=centering;

	//screen transformed centerpoint
	float4	screenPos	=mul(pos, viewProj);

	//screen transformed quad position
	float4	screenOfs	=mul(ofs, viewProj);

	//subtract the centerpoint to just rotate the offset
	screenOfs.xyz	-=screenPos.xyz;

	//rotate ofs by rotation stored in tex0.z
	float	rot		=pv.mTexSizeRotBlank.z;
	float	cosRot	=cos(rot);
	float	sinRot	=sin(rot);

	//build a 2D rotation matrix
	float2x2	rotMat	=float2x2(cosRot, -sinRot, sinRot, cosRot);

	//rotation mul
	screenOfs.xy	=mul(screenOfs.xy, rotMat);

	screenPos.xyz	+=screenOfs.xyz;

	output.Position	=screenPos;

	return	output;
}

float4 ParticleSBPS(ParticlePSIn input) : SV_Target
{
	//texture
	float4	texel	=mTexture0.Sample(Tex0Sampler, input.TexCoord0.xy);

	//multiply by color
	texel	*=input.TexCoord1;

	return	texel;
}