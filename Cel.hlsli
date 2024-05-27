//celstuff for stylish rendering
#include "Types.hlsli"


cbuffer	CelStuff : register(b10)
{
	float4	mValMin;	//between these
	float4	mValMax;	//two values,
	float4	mSnapTo;	//snap to this
	int		mNumSteps;
	float3	mPad;
}

float3	CelQuantize(float3 val)
{
	float3	ret	=float3(0, 0, 0);

	for(int i=0;i < mNumSteps;i++)
	{
		if(val.x > mValMin[i] && val.x < mValMax[i])
		{
			ret.x	=mSnapTo[i];
		}
		if(val.y > mValMin[i] && val.y < mValMax[i])
		{
			ret.y	=mSnapTo[i];
		}
		if(val.z > mValMin[i] && val.z < mValMax[i])
		{
			ret.z	=mSnapTo[i];
		}
	}

	return	ret;
}