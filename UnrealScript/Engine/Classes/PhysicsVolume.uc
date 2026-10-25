//=============================================================================
// PhysicsVolume:  a bounding volume which affects actor physics
// Each Actor is affected at any time by one PhysicsVolume
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class PhysicsVolume extends Volume
	native
	nativereplication;

var()		bool		bPainCausing;	 // Zone causes pain.
var()		vector		ZoneVelocity;
var()		vector		Gravity;
var()		float		GroundFriction;
var()		float		TerminalVelocity;
var()		float		DamagePerSec;
var()		int			Priority;	// determines which PhysicsVolume takes precedence if they overlap
var() sound  EntrySound;	//only if waterzone
var() sound  ExitSound;		// only if waterzone
var() class<actor> EntryActor;	// e.g. a splash (only if water zone)
var() class<actor> ExitActor;	// e.g. a splash (only if water zone)
var() float  FluidFriction;
var() vector ViewFlash, ViewFog;

var()		bool	bDestructive; // Destroys most actors which enter it.
var()		bool	bNoInventory;
var()		bool	bMoveProjectiles;// this velocity zone should impart velocity to projectiles and effects
var()		bool	bBounceVelocity;	// this velocity zone should bounce actors that land in it
var()		bool	bNeutralZone; // Players can't take damage in this zone.
var			bool	bWaterVolume;
var	Info PainTimer;

// Distance Fog
var(VolumeFog) bool   bDistanceFog;	// There is distance fog in this physicsvolume.
var(VolumeFog) color DistanceFogColor;
var(VolumeFog) float DistanceFogStart;
var(VolumeFog) float DistanceFogEnd;

var PhysicsVolume NextPhysicsVolume;

simulated function Destroyed()
{
	Super.Destroyed();
	Level.RemovePhysicsVolume(self);
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	Level.AddPhysicsVolume(self);

	if ( Role < ROLE_Authority )
		return;
	if ( bPainCausing )
		PainTimer = Spawn(class'VolumeTimer', self);
}

/* Called when an actor in this PhysicsVolume changes its physics mode
*/
event PhysicsChangedFor(Actor Other);

event ActorEnteredVolume(Actor Other);
event ActorLeavingVolume(Actor Other);

event PawnEnteredVolume(Pawn Other)
{
	if ( Other.IsPlayerPawn() )
		TriggerEvent(Event,self, Other);
}

event PawnLeavingVolume(Pawn Other)
{
	if ( Other.IsPlayerPawn() )
		UntriggerEvent(Event,self, Other);
}

/*
TimerPop
damage touched actors if pain causing.
since PhysicsVolume is static, this function is actually called by a volumetimer
*/
function TimerPop(VolumeTimer T)
{
	local actor A;

	if ( T == PainTimer )
	{
		if ( !bPainCausing )
			return;
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	// turn zone damage on and off
	if (DamagePerSec != 0)
	{
		bPainCausing = !bPainCausing;
		if ( bPainCausing && (PainTimer == None) )
			PainTimer = spawn(class'VolumeTimer', self);
	}
}

event touch(Actor Other)
{
	Super.Touch(Other);
	if ( bNoInventory && Other.IsA('Inventory') && (Other.Owner == None) )
	{
		Other.LifeSpan = 1.5;
		return;
	}
	if ( bMoveProjectiles && (ZoneVelocity != vect(0,0,0)) )
	{
		if ( Other.Physics == PHYS_Projectile )
			Other.Velocity += ZoneVelocity;
		else if ( Other.IsA('Effects') && (Other.Physics == PHYS_None) )
		{
			Other.SetPhysics(PHYS_Projectile);
			Other.Velocity += ZoneVelocity;
		}
	}
	if ( bPainCausing )
	{
		if ( Other.bDestroyInPainVolume )
		{
			Other.Destroy();
			return;
		}
	}
	if ( bWaterVolume && Other.CanSplash() )
		PlayEntrySplash(Other);
}

function PlayEntrySplash(Actor Other)
{
	local float SplashSize;
	local actor splash;

	splashSize = FClamp(0.00003 * Other.Mass * (250 - 0.5 * FMax(-600,Other.Velocity.Z)), 0.1, 1.0 );
	if( EntrySound != None )
	{
        //R6CODE        
//		PlaySound(EntrySound, SLOT_Interact, splashSize);
        //END R6CODE        
		if ( Other.Instigator != None )
			MakeNoise(SplashSize);
	}
	if( EntryActor != None )
	{
		splash = Spawn(EntryActor); 
		if ( splash != None )
			splash.SetDrawScale(splashSize);
	}
}

event untouch(Actor Other)
{
	if ( bWaterVolume && Other.CanSplash() )
		PlayExitSplash(Other);
}

function PlayExitSplash(Actor Other)
{
	local float SplashSize;
	local actor splash;

	splashSize = FClamp(0.003 * Other.Mass, 0.1, 1.0 );
//R6CODE        
//    if( ExitSound != None )
//		PlaySound(ExitSound, SLOT_Interact, splashSize); 
//END R6CODE        
	if( ExitActor != None )
	{
		splash = Spawn(ExitActor); 
		if ( splash != None )
			splash.SetDrawScale(splashSize);
	}
}

defaultproperties
{
     GroundFriction=8.000000
     TerminalVelocity=2500.000000
     FluidFriction=0.300000
     Gravity=(Z=-1500.000000)
     bAlwaysRelevant=True
     m_bSeeThrough=True
}
