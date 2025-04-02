#include	"lygia/generative/random.hlsl"
#include	"CommonFunctions.hlsli"

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


//indexes into emitter values uint array
//these are arguments to the DrawInstanced call
#define	VERT_COUNT_PER_INSTANCE_IDX	0
#define	INSTANCE_COUNT_IDX			1
#define	START_VERT_INDEX_IDX		2
#define	START_INSTANCE_INDEX_IDX	3
#define	TIME_IDX					4
#define	NUM_PARTICLES_IDX			5
#define	LAST_IDX					6
#define	NEXT_FREE_IDX				7
#define	LAST_ACTIVE_IDX				8


//created here and updated here
RWStructuredBuffer<Particle>	sParticles : register(u0);

//This stores emitter values that change frame to frame
//and also the arguments for the drawcall
RWStructuredBuffer<uint>	sEmitterValues : register(u1);

//SRV of sParticles so the vertex shader can access it
StructuredBuffer<Particle>	VSParticles : register(t2);


//dealloc spots in the particle array
void	DeAllocateIndex(int idx)
{
	sParticles[idx].mNext	=sEmitterValues[NEXT_FREE_IDX];

	//really just want the store
	InterlockedCompareStore(sEmitterValues[NEXT_FREE_IDX],
		sEmitterValues[NEXT_FREE_IDX], idx);

	InterlockedAdd(sEmitterValues[NUM_PARTICLES_IDX], -1);
}

//alloc spots in the particle array
int	GetNextFreeIndex()
{
	uint	nextFree	=sEmitterValues[NEXT_FREE_IDX];

	if(sParticles[nextFree].mNext)
	{
		InterlockedCompareStore(sEmitterValues[NEXT_FREE_IDX],
			sEmitterValues[NEXT_FREE_IDX], sParticles[nextFree].mNext);
	}
	else
	{
		InterlockedAdd(sEmitterValues[NEXT_FREE_IDX], 1);
	}

	InterlockedMax(sEmitterValues[LAST_IDX], nextFree);

	InterlockedAdd(sEmitterValues[NUM_PARTICLES_IDX], 1);

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

void	UpdateLoop(uint idx, float deltaTime)
{
	//update any existing particles
	Particle	p	=sParticles[idx];

	//life expired?
	if(p.mLifeRSVels.x <= 0.0f)
	{
		return;
	}

	//subtract deltatime
	p.mLifeRSVels.x	-=deltaTime;
	if(p.mLifeRSVels.x < 0.0f)
	{
		DeAllocateIndex(idx);

		//copy the expired life value
		sParticles[idx].mLifeRSVels.x	=p.mLifeRSVels.x;
		return;
	}

	//last active counts up the biggest index
	InterlockedMax(sEmitterValues[LAST_ACTIVE_IDX], idx);

	p.mPositionSize.xyz	+=(p.mVelocityRot.xyz * deltaTime);
	p.mColor			+=(p.mColorVelocity * deltaTime);
	p.mPositionSize.w	+=(p.mLifeRSVels.z * deltaTime);
	p.mVelocityRot.w	+=(p.mLifeRSVels.y * deltaTime);

	p.mColor	=clamp(p.mColor, half4(0,0,0,0), half4(1,1,1,1));

	//copy changes back into the array
	sParticles[idx]	=p;
}

//must match particleboss
#define	THREADX	32

[numthreads(THREADX, 1, 1)]
void UpdateExistingParticles(uint3 dtID : SV_DispatchThreadID)
{
	uint	thread	=dtID.x;
	float	dt		=mSizeVMinMaxSecDelta.w;

	uint	lastActive	=sEmitterValues[LAST_IDX];
	if(lastActive < THREADX)
	{
		UpdateLoop(thread, dt);
		return;
	}

	uint	slice	=lastActive / THREADX;
	uint	ofs		=slice * thread;

	for(uint i=ofs;i < (ofs + slice);i++)
	{
		UpdateLoop(i, dt);
	}

	//TODO: remainder?

}

//this is hard to paralleleleleleleelize, maybe better on cpu?
[numthreads(1, 1, 1)]
void UpdateEmitter(uint3 dtID : SV_DispatchThreadID)
{
	float	dt	=mSizeVMinMaxSecDelta.w;

	sEmitterValues[LAST_IDX]	=sEmitterValues[LAST_ACTIVE_IDX];

	//TIME_IDX would be nice to have as a float
	//but the UAV creation would always fail when
	//using a struct instead of <uint>, so scale up
	//the value to nanoseconds or something
	uint	dtNano		=dt * 100000.0f;
	uint	freqNano	=mLineAxisFreq.w * 100000.0f;

	//update emitter if on
	//this might create new particles
	if(mShapeMaxPEOn.w)
	{
		sEmitterValues[TIME_IDX]	+=dtNano;

		//check frequency
		while(sEmitterValues[TIME_IDX] > freqNano)
		{
			int	numActive	=sEmitterValues[NUM_PARTICLES_IDX];

			//max particles?
			if(numActive >= mShapeMaxPEOn.y)
			{
				//arrays are full
				sEmitterValues[TIME_IDX]	-=freqNano;
				continue;
			}

			int	idx	=GetNextFreeIndex();

			sParticles[idx]	=Emit(numActive);

			sEmitterValues[TIME_IDX]	-=freqNano;
		}
	}

	//set up the draw call
	sEmitterValues[VERT_COUNT_PER_INSTANCE_IDX]	=sEmitterValues[LAST_IDX] * 6;
	sEmitterValues[INSTANCE_COUNT_IDX]			=1;
	sEmitterValues[START_VERT_INDEX_IDX]		=0;
	sEmitterValues[START_INSTANCE_INDEX_IDX]	=0;
}

//ps input
struct ParticlePSIn
{
	float4	Position	: SV_POSITION;
	float4	TexCoord0	: TEXCOORD0;
	float4	TexCoord1	: TEXCOORD1;
};

//this should be called with emitter.mLast * 6
//some expired particles will be in the data
ParticlePSIn ParticleSBVS(uint ID : SV_VertexID)
{
	ParticlePSIn	output	=(ParticlePSIn)0;

	uint	partIdx	=ID / 6;
	uint	vIdx	=ID % 6;

	Particle	p	=VSParticles[partIdx];

	//expired?
	if(p.mLifeRSVels.x <= 0.0f)
	{
		//submit a pixel behind the camera
		output.Position	=float4(0, 0, -10, -10);
		return	output;
	}

	float2	uv		=float2(0, 0);
	switch(vIdx)
	{
		case	0:
			uv	=float2(0, 0);
			break;
		case	1:
			uv	=float2(1, 0);
			break;
		case	2:
			uv	=float2(0, 1);
			break;
		case	3:
			uv	=float2(0, 1);
			break;
		case	4:
			uv	=float2(1, 0);
			break;
		case	5:
			uv	=float2(1, 1);
			break;
	}

	float	size	=p.mPositionSize.w;

	//copy texcoords
	output.TexCoord0.xy	=uv;

	//copy color
	output.TexCoord1	=p.mColor;

	float4x4	viewProj	=mul(mView, mProjection);

	//get matrix vectors
	float3	rightDir	=mView._m00_m10_m20;
	float3	upDir		=mView._m01_m11_m21;
	float3	viewDir		=mView._m02_m12_m22;

	//all verts at 000, add instance pos
	float4	pos	=float4(p.mPositionSize.xyz, 1);
	
	//store distance to eye
	output.TexCoord0.z	=distance(mEyePos.xyz, pos.xyz);

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

	//rotate ofs by rotation
	float	rot		=p.mVelocityRot.w;
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