#include	"lygia/generative/random.hlsl"

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
	int4	mShapeMaxPEOn;	//shape, max part, max empty, bOn
	float4	mPositionSize;	//start size in w
	float4	mStartColor;
	float4	mLineAxisFreq;	//frequency in w
	
	float4	mRVelSizeCap;	//rot vel min, rot vel max
							//shape size, vcap
	float4	mColorVelMin;	//minimum color velocity
	float4	mColorVelMax;	//maximum color velocity

	float4	mVMinMaxLMinMax;	//velocity min, max
								//life min, max								

	float4	mSizeVMinMaxSec;	//size vmin, vmax
								//seconds, empty
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
	half4	mTexSizeRotBlank;	//UV.Y, size, rot
	half4	mColor;
};

//created here and updated here
RWStructuredBuffer<Particle>	sParticles : register(u0);

//stuff that changes over time
RWStructuredBuffer<EmitterValues>	sEmitterValues : register(u1);

//spat out to feed to vertex shader
RWStructuredBuffer<ParticleVert>	mPartVerts : register(u3);


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
	float	timeSeconds	=mSizeVMinMaxSec.z + 1.0f;

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
	float4	velVec	=SortOfRandomVector4Range(seed,
		mVMinMaxLMinMax.x, mVMinMaxLMinMax.y);

	ret.mVelocityRot.xyz	=velVec;

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
		mSizeVMinMaxSec.x, mSizeVMinMaxSec.y);

	ret.mLifeRSVels.w	=0;	//unused for now

	ret.mNext	=0;

	return	ret;
}


[numthreads(1, 1, 1)]
void ParticleEmitter(uint3 dtID : SV_DispatchThreadID)
{
	for(int i=0;i <= sEmitterValues[0].mLast;i++)
	{
		//update any existing particles
		Particle	p	=sParticles[i];

		if(p.mLifeRSVels.x <= 0.0f)
		{
			continue;
		}

		//TODO: use passed in delta time
		p.mLifeRSVels.x	-=DELTATIME;
		if(p.mLifeRSVels.x < 0.0f)
		{
			DeAllocateIndex(i);

			//copy the expired life value
			sParticles[i].mLifeRSVels.x	=p.mLifeRSVels.x;
			continue;
		}

		sEmitterValues[0].mLastActive	=i;

		p.mPositionSize.xyz	+=(p.mVelocityRot.xyz * DELTATIME);
		p.mColor			+=(p.mColorVelocity * DELTATIME);
		p.mPositionSize.w	+=(p.mLifeRSVels.z * DELTATIME);
		p.mVelocityRot.w	+=(p.mLifeRSVels.y * DELTATIME);

		p.mColor	=clamp(p.mColor, half4(0,0,0,0), half4(1,1,1,1));

		sParticles[i]	=p;
	}

	sEmitterValues[0].mLast	=sEmitterValues[0].mLastActive;

	//update emitter if on
	//this might create new particles
	if(mShapeMaxPEOn.w)
	{
		sEmitterValues[0].mTime	+=DELTATIME;

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
}