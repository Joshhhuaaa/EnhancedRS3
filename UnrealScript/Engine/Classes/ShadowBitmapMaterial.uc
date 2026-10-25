class ShadowBitmapMaterial extends BitmapMaterial
	native;

var const transient int	TextureInterfaces[2];

var Actor	ShadowActor;
var vector	LightDirection;
var float	LightDistance,
			LightFOV;
var bool	Dirty;
//R6SHADOW
var byte    m_bOpacity;
var vector  m_LightLocation;
var bool    m_bValid;


//
//	Default properties
//

defaultproperties
{
     m_bOpacity=128
     Dirty=True
     Format=TEXF_RGBA8
     UClampMode=TC_Clamp
     VClampMode=TC_Clamp
     UBits=7
     VBits=7
     USize=128
     VSize=128
     UClamp=128
     VClamp=128
}
