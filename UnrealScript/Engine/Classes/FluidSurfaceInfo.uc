class FluidSurfaceInfo extends Info
	showcategories(Movement,Collision,Lighting,LightColor,Karma,Force)
	native
	noexport
	placeable;

var () enum EFluidGridType
{
	FGT_Square,
	FGT_Hexagonal
} FluidGridType;

var () float						FluidGridSpacing; // distance between grid points
var () int							FluidXSize; // num vertices in X direction
var () int							FluidYSize; // num vertices in Y direction

var () float						FluidHeightScale; // vertical scale factor

var () float						FluidSpeed; // wave speed
var () float						FluidDamping; // between 0 and 1

var () float						FluidNoiseFrequency;
var () range						FluidNoiseStrength;

var () bool							TestRipple;
var () float						TestRippleSpeed;
var () float						TestRippleStrength;
var () float						TestRippleRadius;

var () float						UTiles;
var () float						UOffset;
var	() float						VTiles;
var () float						VOffset;
var () float						AlphaCurveScale;
var () float						AlphaHeightScale;
var () byte 						AlphaMax;

// How hard to ripple water when shot
var () float						ShootStrength;

// How much to ripple the water when interacting with actors
var () float						RippleVelocityFactor;
var () float						TouchStrength;

// Effect spawned when water surface it shot or touched by an actor
var () class<Effects>				ShootEffect;
var () bool							OrientShootEffect;

var () class<Effects>				TouchEffect;
var () bool							OrientTouchEffect;

// Bitmap indicating which water verts are 'clamped' ie. dont move
var const array<int>				ClampBitmap;

// Terrain used for auto-clamping water verts if below terrain level.
var () edfindable TerrainInfo		ClampTerrain;

var () bool							bShowBoundingBox;

// Amount of time to simulate during postload before water is first displayed
var () float						WarmUpTime;

// Rate at which fluid sim will be updated (default 30Hz)
var () float						UpdateRate;

// Sim storage
var transient const array<float>	Verts0;
var transient const array<float>	Verts1;
var transient const array<byte>		VertAlpha;

var transient const int				LatestVerts;

var transient const box				FluidBoundingBox;	// Current world-space AABB
var transient const vector			FluidOrigin;		// Current bottom-left corner

var transient const float			TimeRollover;
//var transient const float			AverageTimeStep;
//var transient const int  			StepCount;
var transient const float			TestRippleAng;

var transient const FluidSurfacePrimitive			Primitive;
var transient const array<FluidSurfaceOscillator>	Oscillators;
var transient const bool			bHasWarmedUp;

// Functions

// Ripple water at a particlar location.
// Ignores 'z' componenet of position.
native final function Pling(vector Position, float Strength, optional float Radius);

// Default behaviour when shot is to apply an impulse and kick the KActor.
function INT R6TakeDamage( INT iKillValue, INT iStunValue, Pawn instigatedBy,
						   vector vHitLocation, vector vMomentum, INT iBulletToArmorModifier, optional int iBulletGoup)
{
	// Vibrate water at hit location.
	Pling(vHitLocation, ShootStrength, 0);

	// If present, spawn splashy hit effect.
	if(ShootEffect != None)
	{
		if(OrientShootEffect)
			spawn(ShootEffect, self, , vHitLocation, rotator(vMomentum));
		else
			spawn(ShootEffect, self, , vHitLocation);
	}
	return 0;
}

function Touch(Actor Other)
{
	local vector touchLocation;

	Super.Touch(Other);

	if(Other.bDisturbFluidSurface == false)
		return;

	touchLocation = Other.Location;
	touchLocation.Z = Location.Z;

	Pling(touchLocation, TouchStrength, Other.CollisionRadius);

	if(ShootEffect != None)
	{
		if(OrientTouchEffect)
			spawn(TouchEffect, self, , touchLocation, rotator(Other.Velocity));
		else
			spawn(TouchEffect, self, , touchLocation);
	}
}

defaultproperties
{
     FluidGridType=FGT_Hexagonal
     FluidGridSpacing=32.000000
     FluidXSize=32
     FluidYSize=32
     FluidHeightScale=1.000000
     FluidSpeed=150.000000
     FluidDamping=0.300000
     FluidNoiseStrength=(Min=-100.000000,Max=100.000000)
     TestRippleSpeed=6000.000000
     TestRippleStrength=-300.000000
     TestRippleRadius=34.000000
     UTiles=1.000000
     VTiles=1.000000
     AlphaHeightScale=10.000000
     AlphaMax=128
     ShootStrength=-300.000000
     RippleVelocityFactor=-0.040000
     TouchStrength=-200.000000
     WarmUpTime=2.000000
     UpdateRate=30.000000
     DrawType=DT_FluidSurface
     bHidden=False
     bCollideActors=True
     bProjTarget=True
     Texture=Texture'Engine.S_TerrainInfo'
}
