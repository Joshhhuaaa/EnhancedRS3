//=============================================================================
// FluidSurfaceOscillator.
//=============================================================================
class FluidSurfaceOscillator extends Actor
	native
	placeable;


// FluidSurface to oscillate
var() edfindable FluidSurfaceInfo	FluidInfo;
var() float							Frequency;
var() byte							Phase;
var() float							Strength;
var() float							Radius;

var transient const float			OscTime;

defaultproperties
{
     Frequency=1.000000
     Strength=10.000000
     bHidden=True
}
