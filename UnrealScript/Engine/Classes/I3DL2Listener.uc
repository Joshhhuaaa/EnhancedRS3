//=============================================================================
// I3DL2Listener: Base class for I3DL2 room effects.
//=============================================================================

class I3DL2Listener extends Object
	abstract
	editinlinenew
	native;


var()			float		EnvironmentSize;
var()			float		EnvironmentDiffusion;
var()			int			Room;
var()			int			RoomHF;
var()			float		DecayTime;
var()			float		DecayHFRatio;
var()			int			Reflections;
var()			float		ReflectionsDelay;
var()			int			Reverb;
var()			float		ReverbDelay;
var()			float		RoomRolloffFactor;
var()			float		AirAbsorptionHF;
var()			bool		bDecayTimeScale;
var()			bool		bReflectionsScale;
var()			bool		bReflectionsDelayScale;
var()			bool		bReverbScale;
var()			bool		bReverbDelayScale;
var()			bool		bDecayHFLimit;


var	transient	int			Environment;
var transient	int			Updated;

defaultproperties
{
     Room=-1000
     RoomHF=-100
     Reflections=-2602
     Reverb=200
     bDecayTimeScale=True
     bReflectionsScale=True
     bReflectionsDelayScale=True
     bReverbScale=True
     bReverbDelayScale=True
     bDecayHFLimit=True
     EnvironmentSize=7.500000
     EnvironmentDiffusion=1.000000
     DecayTime=1.490000
     DecayHFRatio=0.830000
     ReflectionsDelay=0.007000
     ReverbDelay=0.011000
     AirAbsorptionHF=-5.000000
}
