class TexRotator extends TexModifier
	editinlinenew
	native;


enum ETexRotationType
{
	TR_FixedRotation,
	TR_ConstantlyRotating,
	TR_OscillatingRotation,
};

var Matrix M;
var() ETexRotationType TexRotationType;
var() rotator Rotation;
var deprecated bool ConstantRotation;
var() float UOffset;
var() float VOffset;
var() rotator OscillationRate;
var() rotator OscillationAmplitude;
var() rotator OscillationPhase;

defaultproperties
{
}
