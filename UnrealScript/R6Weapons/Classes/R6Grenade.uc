//=============================================================================
//  R6Grenade.uc : Base class for all grenades types
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/17/09 * Created by Sebastien Lussier
//=============================================================================
class R6Grenade extends R6Bullet
    abstract
    native;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

var (R6GrenadeSound) sound m_sndExplosionSound;
var (R6GrenadeSound) sound m_sndExplosionSoundStop;
var (R6GrenadeSound) sound m_sndExplodeMetal;
var (R6GrenadeSound) sound m_sndExplodeWater;
var (R6GrenadeSound) sound m_sndExplodeAir;
var (R6GrenadeSound) sound m_sndExplodeDirt;
var (R6GrenadeSound) sound m_ImpactSound;		// Sound made when projectile hits something.
var (R6GrenadeSound) sound m_ImpactGroundSound;
var (R6GrenadeSound) sound m_ImpactWaterSound;
var (R6GrenadeSound) Sound m_sndEarthQuake;


var Actor.EPhysics          m_eOldPhysic; //When physic changes in MP.
var R6DemolitionsGadget     m_Weapon;     // weapon who place or throw the grenade.  only use on demo gadgets.


var BOOL m_bFirstImpact;
var ESoundType m_eExplosionSoundType;
var Pawn.EGrenadeType m_eGrenadeType;

var BOOL    m_bDestroyedByImpact;
var FLOAT   m_fDuration;            // Time before all is stoped
var FLOAT   m_fShakeRadius;

// Pawn pose 
enum eGrenadePawnPose
{
    GPP_Stand,          // Stand & Prone Siding
    GPP_Crouch,         // Crouch
    GPP_ProneFacing     // Prone, facing the grenade
};

// Body part that can be affected by a grenade blast
enum eGrenadeBoneTarget
{
    GBT_Head,
    GBT_Body,
    GBT_LeftArm,
    GBT_RightArm,
    GBT_LeftLeg,
    GBT_RightLeg        
};

// Localized damage depending on the pawn position
struct sDamagePercentage
{
    var() FLOAT fHead;
    var() FLOAT fBody;
    var() FLOAT fArms;
    var() FLOAT fLegs;
};
var(R6Grenade) sDamagePercentage m_DmgPercentStand;
var(R6Grenade) sDamagePercentage m_DmgPercentCrouch;
var(R6Grenade) sDamagePercentage m_DmgPercentProne;

//
// Grenade Properties
//
var FLOAT   m_fEffectiveOutsideKillRadius;

var(R6Grenade) INT     m_iNumberOfFragments;

var(R6Grenade) class<emitter> m_pExplosionParticles;
var(R6Grenade) class<emitter> m_pExplosionParticlesLOW;
var(R6Grenade) emitter m_pEmmiter;
var(R6Grenade) class<light>   m_pExplosionLight;


//decals
var class<R6GrenadeDecal> m_GrenadeDecalClass;

simulated function class<emitter> GetGrenadeEmitter()
{
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();
    
    // Set the smoke emitter depending on the options
    if(pGameOptions.LowDetailSmoke == true && m_pExplosionParticlesLOW != none)
        return m_pExplosionParticlesLOW;
    else
        return m_pExplosionParticles;
}

function SelfDestroy()
{
    if(Level.NetMode != NM_Client)
        Destroy();
}

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripGrenadeA');
    super.PostBeginPlay();

    Activate();
    m_fEffectiveOutsideKillRadius = m_fExplosionRadius-m_fKillBlastRadius;
}

function Activate()
{
    if(m_fExplosionDelay != 0)
    {
        SetTimer(m_fExplosionDelay, false);
    }
}


event Timer()
{
    Explode();
    SelfDestroy();
}

simulated event Destroyed()
{
    local Light pEffectLight;
    local class<emitter> pExplosionParticles;
    
    super.Destroyed();

    pExplosionParticles = GetGrenadeEmitter();

    if(m_bDestroyedByImpact == false)
    {
        if(default.m_fDuration == 0) //instant grenades
        {
            if(pExplosionParticles != none)
            {
                m_pEmmiter = Spawn(pExplosionParticles);
                m_pEmmiter.RemoteRole = ROLE_None;
                m_pEmmiter.Role = ROLE_Authority;
            }
            if(m_pExplosionLight != none)
            {
                pEffectLight = Spawn(m_pExplosionLight);
            }
        }
        else
        {
            if (m_pEmmiter != None)
            {
                m_pEmmiter.Destroy();
            }
        }
    }
}

simulated function FirstPassReset()
{
    SelfDestroy();
}

simulated function Explode()
{
    local actor HitActor;
	local vector vHitLocation, vHitNormal;
    local material HitMaterial;

    local R6GrenadeDecal GrenadeDecal;
    local R6ActorSound pGrenadeSound;
    local rotator GrenadeDecalRotation;

    // set the right sound to play.
    if (m_sndExplosionSound == none)
    {
        HitActor = Trace(vHitLocation, vHitNormal, Location - vect(0,0,40), Location, false,, HitMaterial);

        if ((HitMaterial == None) && (m_sndExplodeAir != None))
        {
            m_sndExplosionSound = m_sndExplodeAir;
        }

        if (((m_sndExplosionSound == none) && (m_sndExplodeMetal != none)) && ((HitMaterial.m_eSurfIdForSnd == SURF_HardMetal) || (HitMaterial.m_eSurfIdForSnd == SURF_SheetMetal)))
        {
            m_sndExplosionSound = m_sndExplodeMetal;
        }

        if (((m_sndExplosionSound == none) && (m_sndExplodeWater != none)) && ((HitMaterial.m_eSurfIdForSnd == SURF_WaterPuddle) || (HitMaterial.m_eSurfIdForSnd == SURF_DeepWater)))
        {
            m_sndExplosionSound = m_sndExplodeWater;
        }

        if (m_sndExplosionSound == none)
        {
            if (m_sndExplodeDirt != none)
            {
                m_sndExplosionSound = m_sndExplodeDirt;
            }
            else
            {
                log("Missing SOUND for the grenade!");
            }
        }
    }

    //log("SOUND for the grenade is " @ m_sndExplosionSound );
    HurtPawns();
    R6MakeNoise( m_eExplosionSoundType );

/*
    if (IsA('R6FlashBang'))
        PlaySound(m_sndExplosionSound, SLOT_GrenadeEffect);
    else
        PlaySound(m_sndExplosionSound, SLOT_SFX);

*/
    //log("<<<<<<<<<<<<<<<<<Explode>>>>>>>>>>>>>>>" @ m_sndExplosionSound);

    //Spawn grenade decal
    if(m_GrenadeDecalClass != none)
    {
        GrenadeDecalRotation.Pitch = 0;
        GrenadeDecalRotation.Yaw = 0;
        GrenadeDecalRotation.Roll = 0;
        GrenadeDecal = Spawn(m_GrenadeDecalClass,,, Location, GrenadeDecalRotation);
    }

    pGrenadeSound = Spawn(class'Engine.R6ActorSound',,, Location);
    if (pGrenadeSound != none)
    {
        if (IsA('R6FlashBang'))
            pGrenadeSound.m_eTypeSound = SLOT_GrenadeEffect;
        else
            pGrenadeSound.m_eTypeSound = SLOT_Guns;

        pGrenadeSound.m_ImpactSound = m_sndExplosionSound;
        pGrenadeSound.m_ImpactSoundStop = m_sndExplosionSoundStop;
        if (m_eGrenadeType == GTYPE_Smoke)
            pGrenadeSound.m_fExplosionDelay = m_fDuration - 35;
        else
            pGrenadeSound.m_fExplosionDelay = m_fDuration;
    }


}

simulated function HitWall( vector HitNormal, actor Wall )
{
    local vector vHitLocation;
    local vector vHitNormal;
    local vector vTraceEnd;
    local vector vTraceStart;
    local actor pHit;
    local material HitMaterial;

    if(m_fExplosionDelay == 0)
    {
        Explode();
    }
    else
    {
		if((Wall != none) && (Instigator != none) && (Instigator.m_CollisionBox == Wall))
		{
			vTraceEnd = Location + 10*normal(velocity);
			SetLocation(vTraceEnd, true);
			return;
		}
   
		// Check if it's a fake backdrop
        if(Wall == Level)
        {
            vTraceStart = Location + 10*HitNormal;
            vTraceEnd = Location - 10*HitNormal;

            pHit = R6Trace( vHitLocation, vHitNormal, vTraceEnd, vTraceStart, TF_Visibility|TF_ShadowCast );
            if(pHit==none)
            {
                // Teleport other side of skybox
                SetLocation(vTraceEnd, true);
                return;
            }
        }

        // Check if it's an InteractiveObject that bullet pass through
        if((Wall != none) && Wall.m_bBulletGoThrough && Wall.IsA( 'R6InteractiveObject' ) )
        {
            Wall.R6TakeDamage( 10000, 10000, Instigator, vHitLocation, Velocity, 0);
            vTraceEnd = Location - 10*HitNormal;
            SetLocation(vTraceEnd, true);
            Velocity *= 0.5;
            return;
        }

        // For testing, the grenade stop there
        //Velocity = vect(0,0,0);
        //SetPhysics(PHYS_None);
        //bBounce = false;

        DesiredRotation = RotRand();
    
        // The grenade will bounce off the wall with 20% of it's original velocity
        Velocity = 0.2 * MirrorVectorByNormal( Velocity, HitNormal );

        // FRand() only affect visual here... does not modify any position
        RotationRate.Yaw   = 1000*VSize(Velocity) * FRand() - 500*VSize(Velocity);
        RotationRate.Pitch = 1000*VSize(Velocity) * FRand() - 500*VSize(Velocity);
        RotationRate.Roll  = 1000*VSize(Velocity) * FRand() - 500*VSize(Velocity);

        if( Velocity.Z > 400 )      // Max falling speed
        {
            Velocity.Z = 400;
        }
        else if ( VSize(Velocity) < 10 )
        {
            SetPhysics(PHYS_None);
            bBounce = false;
            RotationRate = rot(0,0,0);
        }
    
		if (m_bFirstImpact)
		{
			m_bFirstImpact =  false;
			// Play a sound on client

			// Set a sound by default
			m_ImpactSound = m_ImpactGroundSound;

			pHit = Trace(vHitLocation, vHitNormal, Location - vect(0,0,40), Location, false,, HitMaterial);

			if ((HitMaterial != none) && ((HitMaterial.m_eSurfIdForSnd == SURF_WaterPuddle) || (HitMaterial.m_eSurfIdForSnd == SURF_DeepWater)))
			{
				m_ImpactSound = m_ImpactWaterSound;
			}
        
			PlaySound( m_ImpactSound, SLOT_SFX);
			
		}
        R6MakeNoise( SNDTYPE_GrenadeImpact );
    }
}

simulated function Landed( vector HitNormal )
{
     HitWall( HitNormal, None );
}
    
simulated singular function Touch(Actor Other)
{
}

simulated function ProcessTouch(Actor Other, vector vHitLocation)
{
    HitWall( vHitLocation, Other);
}

function FLOAT GetLocalizedDamagePercentage( eGrenadePawnPose ePawnPose, eGrenadeBoneTarget eBoneTarget )
{
    switch( ePawnPose )
    {
    case GPP_Stand :          // Stand & Prone Siding
        switch( eBoneTarget )
        {
        case GBT_Head :     return m_DmgPercentStand.fHead;
        case GBT_Body :     return m_DmgPercentStand.fBody;
        case GBT_LeftArm :  
        case GBT_RightArm : return m_DmgPercentStand.fArms;
        case GBT_LeftLeg :
        case GBT_RightLeg : return m_DmgPercentStand.fLegs;
        }

    case GPP_Crouch:          // Crouch
        switch( eBoneTarget )
        {
        case GBT_Head :     return m_DmgPercentCrouch.fHead;
        case GBT_Body :     return m_DmgPercentCrouch.fBody;
        case GBT_LeftArm :  
        case GBT_RightArm : return m_DmgPercentCrouch.fArms;
        case GBT_LeftLeg :
        case GBT_RightLeg : return m_DmgPercentCrouch.fLegs;
        }

    case GPP_ProneFacing:    // Prone, facing the grenade
        switch( eBoneTarget )
        {
        case GBT_Head :     return m_DmgPercentProne.fHead;
        case GBT_Body :     return m_DmgPercentProne.fBody;
        case GBT_LeftArm :  
        case GBT_RightArm : return m_DmgPercentProne.fArms;
        case GBT_LeftLeg :
        case GBT_RightLeg : return m_DmgPercentProne.fLegs;
        }
    }

    return 0.0f;    // Hum... should not get here
}


function eGrenadeBoneTarget HitRandomBodyPart( eGrenadePawnPose ePawnPose )
{
    local FLOAT fRandVal;
    local FLOAT fLeftArmVal;
    local FLOAT fRightArmVal;
    local FLOAT fLeftLegVal;
    local FLOAT fRighLegVal;
    local FLOAT fBodyVal;
    local FLOAT fHeadVal;

    // Network Here, Aristo HELP!! :)
    fRandVal = FRand();

    fLeftArmVal  = GetLocalizedDamagePercentage( ePawnPose, GBT_LeftArm );
    fRightArmVal = GetLocalizedDamagePercentage( ePawnPose, GBT_RightArm ) + fLeftArmVal;
    fLeftLegVal  = GetLocalizedDamagePercentage( ePawnPose, GBT_LeftLeg ) + fRightArmVal;
    fRighLegVal  = GetLocalizedDamagePercentage( ePawnPose, GBT_RightLeg ) + fLeftLegVal;
    fBodyVal     = GetLocalizedDamagePercentage( ePawnPose, GBT_Body ) + fRighLegVal;
    fHeadVal     = GetLocalizedDamagePercentage( ePawnPose, GBT_Head ) + fBodyVal;

    if( fRandVal < fLeftArmVal )
    {
        return GBT_LeftArm;
    }
    else if( fRandVal < fRightArmVal ) 
    {
        return GBT_RightArm;
    }
    else if( fRandVal < fLeftLegVal ) 
    {
        return GBT_LeftLeg;
    }
    else if( fRandVal < fRighLegVal ) 
    {
        return GBT_RightLeg;
    }
    else if( fRandVal < fBodyVal ) 
    {
        return GBT_Body;
    }
    
    // Headshot !! :)
    return GBT_Head;
}


function eGrenadePawnPose GetPawnPose( R6Pawn aPawn )
{
    local FLOAT fDistFeet;
    local FLOAT fDistHead;

    local vector vFeet;
    local vector vHead;

    // If pawn is prone, find if it's facing the grenade or not
    if( aPawn.m_bIsProne )
    {
        vFeet = aPawn.GetBoneCoords( 'R6 L Foot' ).Origin;
        vHead = aPawn.GetBoneCoords( 'R6 Head' ).Origin;
        
        fDistHead = VSize( vHead - Location );
        fDistFeet = VSize( vFeet - Location );

        // Really cheap, there may be a better way... but it's working :)
        if( fDistFeet - fDistHead > (VSize(vFeet - vHead) * 0.75) )
        {
            return GPP_ProneFacing;
        }
        else
        {
            return GPP_Stand;
        }
    }

    // Pawn is crouching
    if( aPawn.bIsCrouched )
    {
        return GPP_Crouch;
    }

    return GPP_Stand;
}


function HurtPawns() 
{
    //Specific to each grenade.
}

defaultproperties
{
     m_eOldPhysic=PHYS_Falling
     m_eExplosionSoundType=SNDTYPE_Explosion
     m_iNumberOfFragments=4
     m_bFirstImpact=True
     m_fShakeRadius=1000.000000
     m_ImpactGroundSound=Sound'Foley_CommonGrenade.Play_Grenades_GroundImpacts'
     m_sndEarthQuake=Sound'CommonWeapons.Play_GrenadeQuake'
     m_bIsGrenade=True
     m_fExplosionDelay=3.000000
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_StaticMesh
     bHidden=False
     bStasis=False
     bNetTemporary=False
     bAlwaysRelevant=True
     m_bBypassAmbiant=True
     m_bRenderOutOfWorld=True
     m_bDoPerBoneTrace=False
     bIgnoreOutOfWorld=True
     bFixedRotationDir=True
}
