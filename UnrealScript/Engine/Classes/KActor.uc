//=============================================================================
// KarmaActor.
// Just a handy class to derive off to make physics objects.
//=============================================================================

class KActor extends Actor
	native
	placeable;


var (Karma)		bool		bKTakeShot;
var (Karma)		float		fKImpulseFactor;

// Ragdoll impact sounds.
var() array<sound>		ImpactSounds;
var() float				ImpactVolume;

var() class<actor>		ImpactEffect;
var() bool				bOrientImpactEffect;

var() float				ImpactInterval;
var transient float		LastImpactTime;



// Default behaviour when shot is to apply an impulse and kick the KActor.
function INT R6TakeDamage( INT iKillValue, INT iStunValue, Pawn instigatedBy,
						   vector vHitLocation, vector vMomentum, INT iBulletToArmorModifier, optional int iBulletGoup)
{
	local vector ApplyImpulse;

	//Log("TakeDamage: "$self);

    if(bKTakeShot && iKillValue > 0)
	{
		if(VSize(vMomentum) < 0.001)
		{
			// DEBUG
			//Log("Zero momentum to KActor.TakeDamage");
			// END DEBUG
			return 0;
		}

		ApplyImpulse = Normal(vMomentum) * iKillValue / fKImpulseFactor;
		KAddImpulse(ApplyImpulse, vHitLocation);
	}
	return 0;
}

// Default behaviour when triggered is to wake up the physics.
function Trigger( actor Other, pawn EventInstigator )
{
	KWake();
}

// 
event KImpact(actor other, vector pos, vector impactVel, vector impactNorm)
{
	local int numSounds, soundNum;

	// If its time for another impact.
	if(Level.TimeSeconds > LastImpactTime + ImpactInterval)
	{
		// If we have some sounds, play a random one.
		numSounds = ImpactSounds.Length;
		if(numSounds > 0)
		{
			soundNum = Rand(numSounds);
			//Log("Play Sound:"$soundNum);
			// R6CODE // PlaySound(ImpactSounds[soundNum], SLOT_Ambient, ImpactVolume);
		}

//#ifndef R6KARMA
//		// If we have an effect class (and its relevant), spawn it.
//		if( (ImpactEffect != None) && EffectIsRelevant(pos, false) )
//		{
//			if(bOrientImpactEffect)
//				spawn(ImpactEffect, self, , pos, rotator(impactVel));
//			else
//				spawn(ImpactEffect, self, , pos);
//		}
//#endif // #ifndef R6KARMA

		LastImpactTime = Level.TimeSeconds;
	}
}

defaultproperties
{
     bKTakeShot=True
     fKImpulseFactor=1.000000
     Physics=PHYS_Karma
     RemoteRole=ROLE_None
     DrawType=DT_StaticMesh
     bNoDelete=True
     bAcceptsProjectors=True
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bProjTarget=True
     bBlockKarma=True
     bEdShouldSnap=True
     CollisionRadius=1.000000
     CollisionHeight=1.000000
}
