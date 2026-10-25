//============================================================================//
// Class            r6bullet
// Created By       Joel Tremblay
// Date             2001/05/08
// Description      Bullet for the Rainbow combat model
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6Bullet extends R6AbstractBullet
    native;

enum eHitResult
{
    HR_NoMaterial,
    HR_Explode,
    HR_Ricochet,
    HR_GoThrough,
};

//#exec OBJ LOAD FILE="..\textures\R6TextureWeapons.utx"  Package="R6TextureWeapons.Tracer"
#exec NEW StaticMesh FILE="models\Tracer.ASE" NAME="Tracer" Yaw=16384
//#exec TEXTURE IMPORT NAME=TracerTexture FILE=textures\Tracer.dds GROUP=Skins Mips=Off

var (Rainbow)string m_szAmmoName;
var (Rainbow)string m_szAmmoType;
var (Rainbow)string m_szBulletType;

var (Rainbow)INT m_iEnergy;
var (Rainbow)FLOAT m_fKillStunTransfer;
//for Range Conversion  x²/m_fRangeConversionConst + x  (for Kill)  x²/m_fRangeConversionConst (stun)
var (Rainbow)FLOAT m_fRangeConversionConst;
var (Rainbow)INT   m_iPenetrationFactor;

var (Rainbow)FLOAT m_fRange;
var (Rainbow)INT   m_iNoArmorModifier;

var(R6Grenade) FLOAT   m_fExplosionRadius;           
var(R6Grenade) FLOAT   m_fKillBlastRadius;

var(Rainbow) FLOAT      m_fExplosionDelay;  // delay before explosion (for grenades and mines)

var   BOOL   m_bBulletIsGone;
var   BOOL   m_bIsGrenade;

var   BOOL   m_bBulletDeactivated;
var   vector m_vSpawnedPosition;            //used by BulletGoesThroughSurface

var   BOOL   bShowLog;

var   INT    m_iBulletGroupID;    // Especially for shotguns, this is used to determine which other bullets where spawned
                                  // at the same time from the same weapon (I don't mean from rapid fire but fragments from 
                                  // shells)
var   actor m_AffectedActor;      // which pawn did this bullet/fragment affect.
var R6BulletManager m_BulletManager;


native(2001) final function eHitResult BulletGoesThroughSurface(Actor TouchedSurface,
                                                                vector vHitLocation,
                                                                out vector vBulletVelocity,         //Velocity is used for direction and ca be changed by the native function
                                                                out vector vRealHitLocation,        //Real hit location on the wall
                                                                out vector vexitLocation,           //Output Only
                                                                out vector vexitNormal,             //Output Only
                                                                out class<R6WallHit> TouchedEffects,
                                                                out class<R6WallHit> ExitEffects);

function BOOL DestroyedByImpact()  // for demolition gadgets
{
    return false;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    m_vSpawnedPosition = Location;

    m_bBulletIsGone = TRUE;
}

simulated function SetSpeed(FLOAT fBulletSpeed)
{
    Velocity = fBulletSpeed * vector(Rotation);
}

// Bullet are not destroyed, but Deactivated and the reactivated by the bullet manager.
function DeactivateBullet()
{
    SetPhysics(PHYS_None);
    bStasis=TRUE;
    SetCollision(false, false, false);
    m_bBulletDeactivated=true;
}

//==============
// Touching
simulated singular function Touch(Actor Other)
{
    local actor HitActor;
    local vector vHitLocation, vHitNormal;
    local Material pMaterial;

    if(Other == Instigator || m_bBulletIsGone == FALSE || (m_bBulletDeactivated == true) ||
       Instigator.m_collisionBox == Other) // hit the instigator colbox
    	return;
    
    if(R6Bullet(Other) != None)
    {
        if(R6Bullet(Other).DestroyedByImpact())
            DeactivateBullet();
    }

    if ( Other.bProjTarget || (Other.bBlockActors && Other.bBlockPlayers) || Other.IsA( 'R6ColBox' ) )
    {
        //get exact vHitLocation
        HitActor = Instigator.R6Trace(vHitLocation, vHitNormal, Location + Other.CollisionRadius * Normal(Location - m_vSpawnedPosition), m_vSpawnedPosition, TF_LineOfFire|TF_TraceActors );

        if (HitActor == Other)
        {
            ProcessTouch(Other, vHitLocation);
            if(pMaterial!=none)
                SpawnSFX( pMaterial.m_pHitEffect, vHitLocation, Rotator(vHitNormal), Other, HIT_Impact );
        }
        else
        {
            ProcessTouch(Other, Other.Location + Other.CollisionRadius * Normal(Location - Other.Location));
        }
    }
}
//============================================================================
// function ProcessTouch - 
//============================================================================
simulated function ProcessTouch(Actor Other, vector vHitLocation)
{
    local FLOAT     fResultKillEnergy;
    local FLOAT     fResultStunEnergy;
    local FLOAT     fRange;
    local R6Pawn    otherPawn;
    local R6Pawn    instigatorPawn;

    if(Other != Instigator)
    {
        if(Role == ROLE_Authority)
        {
            //Calculate distance
            fRange = VSize(Location - m_vSpawnedPosition);
            fRange /= 100;  //Centimeters to meters;

            //if the bullet reach the maximum kill distance, set it to zero
            fResultKillEnergy = m_iEnergy - RangeConversion(fRange);

            if(fResultKillEnergy < 10.0f)
                fResultKillEnergy = 10.0f;

            fResultStunEnergy = m_iEnergy + fResultKillEnergy * m_fKillStunTransfer - StunLoss(fRange);
            if(fResultKillEnergy < 15.0f)
                fResultKillEnergy = 15.0f;

            if(bShowLog) log("Bullet"$self$" Hit "$Other$" By :"$Instigator$" at location "$vHitLocation$" with energy : "$fResultKillEnergy$" : "$fResultKillEnergy);
            otherPawn = R6Pawn(Other);
            if ( otherPawn == none && Other.isA( 'R6ColBox' ) )
            {
                if ( R6ColBox( Other ).m_fFeetColBoxRadius != 0.f )
                    otherPawn = R6Pawn(Other.Base.Base); 
                else
                    otherPawn = R6Pawn(Other.Base); 
            }
            instigatorPawn = R6Pawn(Instigator);
				                     
            // friendlyfire: if applicable, don't hurt friend/neutral pawn 
			if( otherPawn != none
                && 
                (!instigatorPawn.m_bCanFireFriends  && instigatorPawn.IsFriend(otherPawn))  ||
                (!instigatorPawn.m_bCanFireNeutrals && instigatorPawn.IsNeutral(otherPawn))
              )
            {
				m_iEnergy = 0;
            }
			else
            {
                m_iEnergy = Other.R6TakeDamage(fResultKillEnergy, fResultStunEnergy, Instigator, vHitLocation,
                    Velocity, m_iNoArmorModifier, m_iBulletGroupID);
            }
			if(( m_iEnergy == 0) || (m_szBulletType == "JHP"))
			{
                DeactivateBullet();
		    }
        }
        if(bShowLog) log(Self@"Hit :"$Other.name);
    }
}

//============================================================================
// function SpawnSFX - 
//============================================================================
simulated function SpawnSFX( class<R6WallHit> fxClass, vector vLocation, Rotator vRotation, Actor pSource, R6WallHit.EHitType eType )
{
    local R6WallHit WallHitEffect;

    if(fxClass!=none)
    {
        WallHitEffect = Spawn(fxClass, , , vLocation, vRotation);

        // Check if you want to hear the bullet on the wall (For shotGun)
        if (WallHitEffect != none)
        {
            if (m_BulletManager.AffectActor(m_iBulletGroupID, pSource) == false)
            {
                WallHitEffect.m_bPlayEffectSound = false;
            }
        }
        WallHitEffect.m_eHitType = eType;
    }
}

//============================================================================
// event HitWall  - 
//============================================================================
simulated event HitWall (vector vHitNormal, actor Wall)
{
    local eHitResult    eHitResult;
    local class<R6WallHit>     CurrentHitEffect;
    local class<R6WallHit>     ExitHitEffect;
    local vector        vRealHitLocation;
    local vector        vExitLocation;
    local vector        vExitNormal;

    local INT           iInitialEnergy;
    local vector        vRangeVector;
    local FLOAT         fDistance;

    iInitialEnergy = m_iEnergy;
    eHitResult = BulletGoesThroughSurface(Wall, Location, Velocity, vRealHitLocation, vExitLocation, vExitNormal, CurrentHitEffect, ExitHitEffect);

    if(Wall.IsA('R6InteractiveObject') || Wall.IsA('R6MorphMeshActor') || Wall.IsA('Mover'))
    {
		vRangeVector = vRealHitLocation - m_vSpawnedPosition;
		fDistance = VSize(vRangeVector) * 0.01;  //Centimeters to Meters;
        Wall.R6TakeDamage(iInitialEnergy - RangeConversion(fDistance), 0, Instigator, vRealHitLocation, 
                           Velocity, m_iPenetrationFactor, -1);
    }

    switch(eHitResult)
    {
        case HR_GoThrough:
            //Spawn the impact effect
            SpawnSFX(CurrentHitEffect, vRealHitLocation, Rotator(vHitNormal), Wall, HIT_Impact);
            //Spawn the exit material
            SpawnSFX(ExitHitEffect, vExitLocation, Rotator(vExitNormal), Wall, HIT_Exit);
            //Set the bullet Location
            if(!SetLocation(vExitLocation + vExitNormal*2))
                DeactivateBullet();
            break;
        
        case HR_Explode:
            //bullet leaves a mark and is deactivated
            //log("!!! Explode !!!");
            SpawnSFX(CurrentHitEffect, vRealHitLocation, Rotator(vHitNormal), Wall, HIT_Impact);
            DeactivateBullet();
            break;
            
        case HR_Ricochet:
            //bullet leaves a mark and is deactivated
            //log("!!! Ricochet !!!" @ CurrentHitEffect);
            SpawnSFX(CurrentHitEffect, vRealHitLocation, Rotator(vHitNormal), Wall, HIT_Ricochet);
            DeactivateBullet();
            break;

        //usually Skybox and old textures have no material
        case HR_NoMaterial:  
            DeactivateBullet();
            break;
        
        default:
            log("!!! We have a serious problem HERE !!!");
    }
}

function FLOAT RangeConversion(FLOAT fRange)
{
    return fRange * fRange * m_fRangeConversionConst + m_fRangeConversionConst;
}

function FLOAT StunLoss(FLOAT fRange)
{
    return fRange * fRange * m_fRangeConversionConst;
}

defaultproperties
{
     m_iEnergy=100
     m_iPenetrationFactor=1
     m_fKillStunTransfer=0.010000
     m_fRangeConversionConst=0.100000
     m_fRange=100.000000
     m_szAmmoName="R6Bullet"
     m_szAmmoType="Normal"
     m_szBulletType="JHP"
     RemoteRole=ROLE_None
     DrawType=DT_None
     AmbientGlow=167
     SoundPitch=100
     bHidden=True
     bStasis=True
     bNetTemporary=True
     bReplicateInstigator=True
     m_bDeleteOnReset=True
     bGameRelevant=True
     bCollideActors=True
     bCollideWorld=True
     m_bDoPerBoneTrace=True
     bBounce=True
     SoundRadius=4.000000
     NetPriority=2.500000
}
