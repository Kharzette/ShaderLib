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

	half4	mColorVelocity;	//color changes over time
	half4	mLifeRSVels;	//life remaining, rotational velocity
							//size velocity, and blank
	half4	mColor;
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

	float4	mSizeVMinMax;	//size vmin, vmax
							//empty, empty
};

struct EmitterValues
{
	float	mTime;
	int		mNumParticles;
	int		mNumEmpty;
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

//keep track of expired particles
RWStructuredBuffer<uint>	sFreeSlots : register(u2);

//spat out to feed to vertex shader
RWStructuredBuffer<ParticleVert>	mPartVerts : register(u3);


float3	PositionForShape(float3 pos, float3 lineAxis, uint shape, float shapeSize)
{
	if(shape == EMIT_SHAPE_POINT)
	{
		return	pos;
	}

	float3	ret			=float3(0, 0, 0);

	float	sizeOverTwo	=shapeSize * 0.5f;

	float3	randVec		=random3(pos);

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


Particle	Emit()
{
	Particle	ret;

	//random position
	ret.mPositionSize.xyz	=PositionForShape(mPositionSize.xyz,
		mLineAxisFreq.xyz, mShapeMaxPEOn.x, mRVelSizeCap.z);

	ret.mPositionSize.w		=mPositionSize.w;	//start size
	ret.mVelocityRot.w		=0;					//start rotation
	ret.mColor				=mStartColor;

	//velocity
	float3	velVec	=random3(ret.mPositionSize.xyz);
	velVec	=normalize(velVec);

	velVec	*=SortOfRandomValue(ret.mPositionSize.xz * 3.0f,
		mVMinMaxLMinMax.x, mVMinMaxLMinMax.y);

	ret.mVelocityRot.xyz	=velVec;

	//life is a value between max and min life
	ret.mLifeRSVels.x	=SortOfRandomValue(ret.mPositionSize.xy,
		mVMinMaxLMinMax.z, mVMinMaxLMinMax.w);

	float4	seed	=float4(ret.mPositionSize.xyz, ret.mLifeRSVels.x);

	ret.mColorVelocity	=SortOfRandomVector4Range(seed,
		mRVelSizeCap.x, mRVelSizeCap.y);

	//rotational velocity
	ret.mLifeRSVels.y	=SortOfRandomValue(seed.x * seed.z,
		mRVelSizeCap.x, mRVelSizeCap.y);

	//size velocity
	ret.mLifeRSVels.z	=SortOfRandomValue(seed.z * 3.0f,
		mSizeVMinMax.x, mSizeVMinMax.y);

	ret.mLifeRSVels.w	=0;	//unused for now

	return	ret;
}

[numthreads(1, 1, 1)]
void ParticleEmitter(uint3 dtID : SV_DispatchThreadID)
{
	int	adjustNumParticles	=0;

	//update any existing particles
	for(int i=0;i < sEmitterValues[0].mNumParticles;i++)
	{
		Particle	p	=sParticles[i];

		p.mLifeRSVels.x	-=DELTATIME;
		if(p.mLifeRSVels.x < 0.0f)
		{
			//too many empty slots in use?
			if(sEmitterValues[0].mNumEmpty >= mShapeMaxPEOn.z)
			{
				abort();
			}
			//mark empty
			sFreeSlots[sEmitterValues[0].mNumEmpty]	=i;
			sEmitterValues[0].mNumEmpty++;
		}

		p.mPositionSize.xyz	+=(p.mVelocityRot.xyz * DELTATIME);
		p.mColor			+=(p.mColorVelocity * DELTATIME);
		p.mPositionSize.w	+=(p.mLifeRSVels.z * DELTATIME);
		p.mVelocityRot.w	+=(p.mLifeRSVels.y * DELTATIME);

		p.mColor	=clamp(p.mColor, 0, 1);
	}

	//update emitter if on
	//this might create new particles
	if(mShapeMaxPEOn.w)
	{
		sEmitterValues[0].mTime	+=DELTATIME;

		while(sEmitterValues[0].mTime > mLineAxisFreq.w)
		{
			int	numEmpty	=sEmitterValues[0].mNumEmpty;
			int	numParts	=sEmitterValues[0].mNumParticles;
			int	numActive	=numParts - numEmpty;

			//max particles?
			if(numActive >= mShapeMaxPEOn.y)
			{
				//arrays are full
				sEmitterValues[0].mTime	-=mLineAxisFreq.w;
				continue;
			}

			Particle p	=Emit();

			//recover empty spots in the array if possible
			if(numEmpty > 0)
			{
				uint	lastIndex	=numEmpty - 1;
				uint	freeIdx		=sFreeSlots[lastIndex];
				sParticles[freeIdx]	=p;
				sEmitterValues[0].mNumEmpty--;
			}
			else
			{
				sParticles[numParts]	=p;
				sEmitterValues[0].mNumParticles++;
			}

			sEmitterValues[0].mTime	-=mLineAxisFreq.w;
		}
	}	
}