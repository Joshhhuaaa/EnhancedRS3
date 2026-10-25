//=============================================================================
//  R6Terrorist.uc : This is the pawn class for all terrorists
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//    Eric - May 7th, 2001 - Add Basic Animations 
//    Eric - June 12th, 2001    - Add PatrolNode Interaction
//=============================================================================
class R6Terrorist extends R6Pawn
    notplaceable
    native
    abstract;

enum ETerroristCircumstantialAction
{
    CAT_None,
    CAT_Secure,
};

enum EStrategy
{
    STRATEGY_PatrolPath,
    STRATEGY_PatrolArea,
    STRATEGY_GuardPoint,
    STRATEGY_Hunt,
    STRATEGY_Test
};

enum EDefCon
{
    DEFCON_0,   // Don't exist, place holder for value of 0    
    DEFCON_1,   // Psycho
    DEFCON_2,   // Aggressive
    DEFCON_3,   // Agitated
    DEFCON_4,   // Nervous
    DEFCON_5    // Normal
};

enum ETerroPersonality
{
    PERSO_Coward,
    PERSO_DeskJockey,
    PERSO_Normal,
    PERSO_Hardened,
    PERSO_SuicideBomber,
    PERSO_Sniper
};

enum ENetworkSpecialAnim
{
    NWA_NonValid,
    NWA_Playing,
    NWA_Looping
};

// Variable defining the terrorist
var()       EDefCon             m_eDefCon;
var()       ETerroPersonality   m_ePersonality;
var()       EStrategy           m_eStrategy;
var()       string              m_szUsedTemplate;
var()       string              m_szPrimaryWeapon;
var         BOOL                m_bBoltActionRifle;
var()       string              m_szGrenadeWeapon;
var()       string              m_szGadget;
var()       INT                 m_iGroupID;
var()       EStance             m_eStartingStance;
var         EHeadAttachmentType m_eHeadAttachmentType;
var         ETerroristType      m_eTerroType;
var         R6THeadAttachment   m_HeadAttachment;
var         Actor               m_Radio;
var         R6TerroristAI       m_controller;
var()       BOOL                m_bHaveAGrenade;
var         BOOL                m_bInitFinished;
var()       BOOL                m_bAllowLeave;          // Whether the therrorist can or not leave his zone
var         BOOL                m_bPreventCrouching;    // Whether the therrorist can or not crouch
var(Debug)  BOOL                m_bHearNothing;         // Only for debug purpose
var()       BOOL                m_bSprayFire;           // Not the same animation when sprayfiring

// State variable
var         BOOL                m_bPreventWeaponAnimation;
var()       BOOL                m_bIsUnderArrest;

// Patrol Movements
var         BOOL                m_bPatrolForward;
var         R6DeploymentZone    m_DZone;

var         name                m_szSpecialAnimName;
var         ENetworkSpecialAnim m_eSpecialAnimValid;    // For network. When true, a newly relevant must play the special anim.

// Variable defining the terrorist state
var()       Rotator             m_rFiringRotation;
var()       BYTE                m_wWantedAimingPitch;   // Pitch wanted for the gun
var()       INT                 m_iCurrentAimingPitch;  // Current pitch of the gun.  Updated in UpdateAiming
var()       BYTE                m_wWantedHeadYaw;       // Yaw wanted for the head
var()       INT                 m_iCurrentHeadYaw;      // Current yaw of the head.  Updated in UpdateAiming
var()       INT                 m_iDiffLevel;           // Current difficulty level of this terrorist (from gameinfo)

var         BOOL				m_bEnteringView;

var         FLOAT               m_fPlayerCAStartTime;

replication
{
    reliable if( Role==Role_Authority )
        m_eDefCon, m_bIsUnderArrest, m_bSprayFire, m_bPreventWeaponAnimation, m_eSpecialAnimValid, m_szSpecialAnimName;

    unreliable if( Role==Role_Authority )
        m_wWantedAimingPitch, m_wWantedHeadYaw;
}

// Export to r6engineclasses.h

//============================================================================
// event Destroyed - 
//============================================================================
simulated event Destroyed()
{
    Super.Destroyed();
    if (m_HeadAttachment!=none)
    {
        m_HeadAttachment.destroy();
        m_HeadAttachment = none;
    }
}    

//============================================================================
// Rotator GetFiringRotation - 
//============================================================================
function Rotator GetFiringRotation()
{
    return m_rFiringRotation;
}

//============================================================================
// PostBeginPlay - 
//============================================================================
simulated function PostBeginPlay()
{
    local vector vTagLocation;
    local rotator rTagRotator;
    
    if ( Level.Game != none )
    {
        assert( default.m_iTeam == R6AbstractGameInfo(Level.Game).c_iTeamNumTerrorist );
    }

    Super.PostBeginPlay();

    SetMovementPhysics();
}

//============================================================================
// SetToNormalWeapon - 
//============================================================================
function SetToNormalWeapon()
{
    // Get the primary Weapon
	EngineWeapon = GetWeaponInGroup(1);
    if(EngineWeapon==None)
    {
        EngineWeapon = GetWeaponInGroup(2);
    }
    EngineWeapon.RemoteRole = ROLE_SimulatedProxy;
    if(EngineWeapon!=none)
    {
        AttachWeapon(EngineWeapon, 'TagRightHand');

        EngineWeapon.WeaponInitialization( Self );
        m_pBulletManager.SetBulletParameter( EngineWeapon );
    }

    #ifdefDEBUG if(bShowLog) logX( " got the weapon " $ EngineWeapon ); #endif
}

//============================================================================
// SetToGrenade - 
//============================================================================
function SetToGrenade()
{
    // If we are using the subgun animation, attach the gun to the left hand
    if(!EngineWeapon.m_bUseMicroAnim && EngineWeapon.m_eWeaponType!=WT_Pistol)
        AttachWeapon(EngineWeapon, 'TagLeftHand');
    
    EngineWeapon = GetWeaponInGroup(3);
    EngineWeapon.bHidden = false;
    AttachWeapon(EngineWeapon, 'TagRightHand');
}

//============================================================================
// FinishInitialization - 
//============================================================================
event FinishInitialization()
{
    CommonInit();    
}

//============================================================================
// CommonInit -  Common initialization between R6Terrorist and R6MatineeTerrorist
//============================================================================
function CommonInit()
{    
    local FLOAT fFactor;
    local R6EngineWeapon aGrenade;

    // Spawn the controller
    if(Controller!=None)
    {
        UnPossessed();
    }
	Controller = Spawn(ControllerClass);
    Controller.Possess( Self );

    // Give the weapons to the characters
    if(m_szPrimaryWeapon!="")
    {
        ServerGivesWeaponToClient(m_szPrimaryWeapon,1);
        // Get the primary Weapon
        SetToNormalWeapon();
    }

    if(m_szGrenadeWeapon!="")
    {
        ServerGivesWeaponToClient(m_szGrenadeWeapon,3);
        m_bHaveAGrenade = true;
        aGrenade = GetWeaponInGroup(3);
        aGrenade.RemoteRole = ROLE_SimulatedProxy;
        aGrenade.bHidden = true;
    }
    
    //Sound setting
    Controller.m_PawnRepInfo.m_PawnType = m_ePawnType;
    Controller.m_PawnRepInfo.m_bSex = bIsFemale;

    if (m_SoundRepInfo != none)
        m_SoundRepInfo.m_PawnRepInfo = Controller.m_PawnRepInfo;
    //Sound setting END


    if(EngineWeapon!=none)
    {
        if(EngineWeapon.m_eWeaponType==WT_Sniper && EngineWeapon.IsA('R6BoltActionSniperRifle'))
            m_bBoltActionRifle = true;

        // Terrorist have unlimited clip
        EngineWeapon.m_bUnlimitedClip = true;
        EngineWeapon.SetTerroristNbOfClips(1);
    }
    
    // Check for gadget
    if(( m_szGadget != "" ) && (Level.NetMode != NM_DedicatedServer))
    {
        R6AbstractWeapon(EngineWeapon).R6SetGadget(class<R6AbstractGadget>(DynamicLoadObject(m_szGadget, class'Class')));
        R6AbstractWeapon(EngineWeapon).m_SelectedWeaponGadget.ActivateGadget(true, true);
    }

    // Check for attachment
    if(m_eHeadAttachmentType!=ATTACH_None)
    {
        //attachClass = class<Actor>(DynamicLoadObject("R6Characters.R6THeadAttachment", class'Class'));
        m_HeadAttachment = Spawn( class'R6THeadAttachment' );

        if( m_HeadAttachment.SetAttachmentStaticMesh( m_eHeadAttachmentType, m_eTerroType ) )
        {
            //log( "Attachment mesh:" $ m_HeadAttachment.StaticMesh );
            m_HeadAttachment.SetOwner(Self);
    	    AttachToBone(m_HeadAttachment, 'R6 Head');

            // Check if it's a Gas Mask
            m_bHaveGasMask = (m_eHeadAttachmentType == ATTACH_GasMask);
        }
        else
        {
            //log( "Cannot find attachment:" $ m_HeadAttachment );
            m_HeadAttachment.Destroy();
            m_HeadAttachment = none;
        }
    }

    AttachCollisionBox( 2 );

    // Adjust skill from game difficulty
    if( R6AbstractGameInfo(Level.Game) != none )
    {       
        m_iDiffLevel = R6AbstractGameInfo(Level.Game).m_iDiffLevel;
        if(m_iDiffLevel==0)
            m_iDiffLevel = 2;
        
        switch(m_iDiffLevel)
        {
        case 1: fFactor = 0.40; break;
        case 2: fFactor = 0.70; break;
        case 3: fFactor = 1.25; break;
        }
        
        m_fSkillAssault *= fFactor;
        m_fSkillDemolitions *= fFactor;
        m_fSkillElectronics *= fFactor;
        m_fSkillSniper *= fFactor;
        m_fSkillStealth *= fFactor;
        m_fSkillSelfControl *= fFactor;
        m_fSkillLeadership *= fFactor;
        m_fSkillObservation *= fFactor;
    }
}

//============================================================================
// SetMovementPhysics - 
//============================================================================
simulated function SetMovementPhysics()
{
    SetPhysics(PHYS_Walking);
}

//============================================================================
// AnimateStandTurning
//============================================================================
simulated function AnimateStandTurning()
{
	if( m_bDroppedWeapon || EngineWeapon==none || m_eDefCon > DEFCON_3)
    {
	    TurnLeftAnim = 'RelaxTurnLeft';
	    TurnRightAnim = 'RelaxTurnRight';
    }
    else
    {
	    TurnLeftAnim = m_standTurnLeftName;
	    TurnRightAnim = m_standTurnRightName;
    }
}

//============================================================================
// AnimateWalking() 
//============================================================================
simulated function AnimateWalking()
{
	if( m_bDroppedWeapon || EngineWeapon==none || m_eDefCon > DEFCON_3)
    {
        m_fWalkingSpeed = 116.0;            // Relax walking speed
		MovementAnims[0] = 'RelaxWalkForward';
		MovementAnims[1] = m_standWalkLeftName;
		MovementAnims[2] = 'RelaxWalkForward';
		MovementAnims[3] = m_standWalkRightName;
    }
	else if(m_eHealth==HEALTH_Wounded)
	{
		m_fWalkingSpeed = 120.0;                    // Hurt walking speed
		MovementAnims[0] = 'HurtStandWalkForward';
		MovementAnims[1] = m_standWalkLeftName;
		MovementAnims[2] = 'HurtStandWalkBack';
		MovementAnims[3] = m_standWalkRightName;
	}
	else
	{
		m_fWalkingSpeed = 170.0;                    // Normal walking speed
		MovementAnims[0] = m_standWalkForwardName;
		MovementAnims[1] = m_standWalkLeftName;
		MovementAnims[2] = m_standWalkBackName;
		MovementAnims[3] = m_standWalkRightName;
	}
}

//============================================================================
// AnimateRunning() 
//============================================================================
simulated function AnimateRunning()
{
    local name nFoward;

    // default foward
    nFoward = 'StandRunSubGunForward';

    if(!m_bDroppedWeapon && EngineWeapon!=none)
    {
        switch(EngineWeapon.m_eWeaponType)
        {
            case WT_Sub:
                if(EngineWeapon.m_bUseMicroAnim)
                    nFoward = 'StandRunHandGun';
                break;
            case WT_Pistol:
		        nFoward = 'StandRunHandGun';
                break;
            default:
                break;
        }
    }
    else
		nFoward = 'StandRunHandGun';
    
	MovementAnims[0] = nFoward;          // Foward
	MovementAnims[1] = 'StandRunLeft';   // Left
	MovementAnims[2] = 'StandWalkBack';  // Back
	MovementAnims[3] = 'StandRunRight';  // Right
}

//============================================================================
// function AnimateWalkingUpStairs - 
//============================================================================
simulated function AnimateWalkingUpStairs()
{
    Super.AnimateWalkingUpStairs();
    
    if( m_bDroppedWeapon || EngineWeapon==none || m_eDefCon>DEFCON_3)
    {
        MovementAnims[0] = 'RelaxStairUp';      // walking forward towards top of stairs
    }
}

//============================================================================
// function AnimateWalkingDownStairs - 
//============================================================================
simulated function AnimateWalkingDownStairs()
{
    Super.AnimateWalkingDownStairs();
    
    if( m_bDroppedWeapon || EngineWeapon==none || m_eDefCon>DEFCON_3)
    {
        MovementAnims[0] = 'RelaxStairDown';      // walking forward towards bottom of stairs
    }
}

//============================================================================
// PlayWaiting - 
//============================================================================
simulated function PlayWaiting()
{
    local name anim;
    local EDefcon eDefCon;

    if(m_bDroppedWeapon || EngineWeapon==none)
        eDefCon = DEFCON_5;
    else
        eDefCon = m_eDefCon;

    if(physics == PHYS_Falling) {   PlayFalling();              return; }
    if(m_bIsUnderArrest)        {   PlayArrestWaiting();        return; }
    if(m_bIsKneeling)           {   PlayKneelWaiting();         return; }
    if(bIsCrouched)             {   PlayCrouchWaiting();        return; }
    if(m_bIsProne)              {   PlayProneWaiting();         return; }
    if(m_bIsClimbingLadder)     {   AnimateStoppedOnLadder();   return; }

    switch( eDefCon )
    {
        case DEFCON_1:
        case DEFCON_2:
        case DEFCON_3:
            SetRandomWaiting(6, true);
            switch(m_bRepPlayWaitAnim)
            {
                case 0:     anim = 'StandWaitLookFarSubGun01';  break;
                case 1:     anim = 'StandWaitLookFarSubGun02';  break;
                case 2:     anim = 'StandWaitResightSubGun';    break;
                case 3:     anim = 'StandWaitStiffLegsSubGun';  break;
                case 4:     anim = 'StandWaitStiffNeckSubGun';  break;
                default:    anim = 'StandWaitWipeNoseSubGun';
             }
            break;
        case DEFCON_4:
        case DEFCON_5:
            SetRandomWaiting(14);
            switch(m_bRepPlayWaitAnim)
            {
                case  0:  anim = 'RelaxWaitBreathe';        break;
                case  1:  anim = 'RelaxWaitBend';           break;
                case  2:  anim = 'RelaxWaitCrackNeck';      break;
                case  3:  anim = 'RelaxWaitLookAround01';   break;
                case  4:  anim = 'RelaxWaitLookAround02';   break;
                case  5:  anim = 'RelaxWaitLookFar';        break;
                case  6:  anim = 'RelaxWaitPickShoe';       break;
                case  7:  anim = 'RelaxWaitScratchNose';    break;
                case  8:  anim = 'RelaxWaitShiftWeight01';  break;
                case  9:  anim = 'RelaxWaitShiftWeight02';  break;
                case 10:  anim = 'RelaxWaitShiftWeight03';  break;
                case 11:  anim = 'RelaxWaitShuffle';        break;
                case 12:  anim = 'RelaxWaitSlapFly';        break;
                default:  anim = 'RelaxWaitStretch';        break;
             }
            break;
    }

    R6LoopAnim(anim, 1.0);
}

//============================================================================
// PlayCrouchWaiting() - 
//============================================================================
simulated function PlayCrouchWaiting()
{
    local name anim;

    SetRandomWaiting(6);
    switch(m_bRepPlayWaitAnim)
    {
        case 0:     anim = 'CrouchWaitBreatheSubGun01';     break;
        case 1:     anim = 'CrouchWaitBreatheSubGun02';     break;
        case 2:     anim = 'CrouchWaitLookAroundSubGun';    break;
        case 3:     anim = 'CrouchWaitLookAtSubGun';        break;
        case 4:     anim = 'CrouchWaitRepositionSubGun';    break;
        default:    anim = 'CrouchWaitStiffNeckSubGun';
    }

    R6LoopAnim(anim, 1.0);
}

//============================================================================
// PlayProneWaiting - 
//============================================================================
simulated function PlayProneWaiting()
{
    R6LoopAnim('ProneWaitBreathe', 1.0);
}

//============================================================================
// PlayKneelWaiting() - 
//============================================================================
simulated function PlayKneelWaiting()
{
    m_ePlayerIsUsingHands = HANDS_Both;
    R6LoopAnim('Kneel_nt', 0.01);
}

//============================================================================
// PlayArrestWaiting() - 
//============================================================================
simulated function PlayArrestWaiting()
{
    local name anim;

    m_ePlayerIsUsingHands = HANDS_Both;
    SetRandomWaiting(4);
    switch(m_bRepPlayWaitAnim)
    {
        case 0:     anim = 'KneelArrestWait01';     break;
        default:    anim = 'KneelArrestWait02';
    }

    R6LoopAnim(anim, 1.0);
}

//============================================================================
// PlayDuck - 
//============================================================================
simulated function PlayDuck()
{
    local name anim;

    if(EngineWeapon.m_bUseMicroAnim)
        anim = 'CrouchMicroHigh_nt';
    else if(EngineWeapon.m_eWeaponType==WT_Pistol)
        anim = 'CrouchHandGunHigh_nt';
    else
        anim = 'CrouchSubGunHigh_nt';

    R6LoopAnim(anim);
}

//============================================================================
// ResetArrest - 
//============================================================================
function ResetArrest()
{
    if(IsAlive())
    {
	    AnimBlendToAlpha( C_iPawnSpecificChannel, 0.0, 0.5 );
        m_ePlayerIsUsingHands = HANDS_None;
        PlayWeaponAnimation();
        m_bPawnSpecificAnimInProgress = false;		
	    
	    m_bIsUnderArrest = false;
	    PlayWaiting();
	    SetCollision(true, true, true);
    }
}

//============================================================================
// R6QueryCircumstantialAction - 
//============================================================================
event R6QueryCircumstantialAction( FLOAT fDistance, Out R6AbstractCircumstantialActionQuery Query, PlayerController playerController )
{ 
    if( m_bIsKneeling && IsAlive() )
    {
        Query.iHasAction = 1;
        if ( fDistance < m_fCircumstantialActionRange)
        {
            Query.iInRange = 1;
        }
        else
        {
            Query.iInRange = 0;
        }
        
        Query.textureIcon = Texture'R6ActionIcons.HandcuffTerrorist'; 

		Query.fPlayerActionTimeRequired = 0;
	    Query.bCanBeInterrupted = true;

        Query.iPlayerActionID      = eTerroristCircumstantialAction.CAT_Secure;
        Query.iTeamActionID        = eTerroristCircumstantialAction.CAT_Secure;
    
        Query.iTeamActionIDList[0] = eTerroristCircumstantialAction.CAT_Secure;
        Query.iTeamActionIDList[1] = eTerroristCircumstantialAction.CAT_None;
        Query.iTeamActionIDList[2] = eTerroristCircumstantialAction.CAT_None;
        Query.iTeamActionIDList[3] = eTerroristCircumstantialAction.CAT_None;
    }
    else
    {
        Query.iHasAction = 0;		
    }
}

//============================================================================
// string R6GetCircumstantialActionString - 
//============================================================================
simulated function string R6GetCircumstantialActionString( INT iAction )
{
    switch( iAction )
    {
		case eTerroristCircumstantialAction.CAT_Secure:		return Localize("RDVOrder", "Order_Secure", "R6Menu");
    }
    
    return "";
}

//===========================================================================//
// R6GetCircumstantialActionProgress() -                                      
//===========================================================================//
function INT  R6GetCircumstantialActionProgress( R6AbstractCircumstantialActionQuery Query, Pawn actingPawn )
{
	local name  anim;
	local FLOAT fFrame,fRate;
	
	actingPawn.GetAnimParams(C_iBaseBlendAnimChannel, anim, fFrame, fRate);	
	Clamp(fFrame, 0.f, 100.f);

    return fFrame*100;
}

//===========================================================================//
// R6CircumstantialActionProgressStart()                                     //
//===========================================================================//
function R6CircumstantialActionProgressStart( R6AbstractCircumstantialActionQuery Query )
{
    m_fPlayerCAStartTime = Level.TimeSeconds;
}

function ReleaseGrenade()
{
    #ifdefDEBUG if(bShowLog) logX( " throw his grenade"); #endif

    if(!IsAlive())
        return;
    
    m_rFiringRotation = m_controller.GetGrenadeDirection(m_controller.Enemy);
    EngineWeapon.ThrowGrenade();
    EngineWeapon.bHidden = TRUE;
    m_bHaveAGrenade = false;
}

function EndGrenade()
{
    #ifdefDEBUG if(bShowLog) logX( " end throwing his grenade"); #endif
}

simulated event AnimEnd( int iChannel )
{
    if( iChannel==C_iPawnSpecificChannel && m_eSpecialAnimValid!=NWA_Looping )
    {
        #ifdefDEBUG if(bShowLog) logX("AnimEnd: " $ iChannel ); #endif

        AnimBlendToAlpha( C_iPawnSpecificChannel, 0.0, 0.5 );
        m_ePlayerIsUsingHands = HANDS_None;
        PlayWeaponAnimation();
        m_bPawnSpecificAnimInProgress = false;
        if(Level.NetMode!=NM_Client)
            m_eSpecialAnimValid = NWA_NonValid;
    }

    Super.AnimEnd( iChannel );
}

//============================================================================
// BOOL R6TakeDamage - 
//============================================================================
function INT R6TakeDamage( INT iKillValue, INT iStunValue, Pawn instigatedBy, vector vHitLocation, 
                           vector vMomentum, INT iBulletToArmorModifier, optional int iBulletGoup )
{
    local INT iResult;
    
    iResult = Super.R6TakeDamage(iKillValue, iStunValue, instigatedBy, vHitLocation, vMomentum, iBulletToArmorModifier, iBulletGoup);

    // Changed animation when hurt
    ChangeAnimation();

    return iResult;
}

//============================================================================
// IsFighting: return true when the pawn is fighting
// - inherited
//============================================================================
function bool IsFighting()
{
    if ( m_bIsKneeling ) 
        return false;    
    
    if ( m_bIsFiringWeapon == 1 ) 
        return true;    

    // cannot fight if incapacitated or dead
    if ( IsAlive() && Controller.IsInState('Attack') )
    {
        return true;
    }

    return false;
}

//============================================================================
// R6TerroristMgr GetManager - 
//============================================================================
function R6TerroristMgr GetManager()
{
    return R6TerroristMgr( level.GetTerroristMgr() );
}

// Movement function not supposed to be called for a terrorist
simulated function AnimateCrouchRunning()
{
    #ifdefDEBUG if(bShowLog) logX("*WARNING* AnimateCrouchRunning called. Terrorists not supposed to CrouchRun!!!"); #endif
}

simulated function AnimateCrouchRunningUpStairs()
{
    #ifdefDEBUG if(bShowLog) logX("*WARNING* AnimateCrouchRunningUpStairs called.  Terrorists not supposed to CrouchRun!!!"); #endif
}

simulated function AnimateCrouchRunningDownStairs() 
{
    #ifdefDEBUG if(bShowLog) logX("*WARNING* AnimateCrouchRunningDownStairs called.  Terrorists not supposed to CrouchRun!!!"); #endif
}

event EndOfGrenadeEffect( EGrenadeType eType )
{
	if(eType == GTYPE_TearGas)
        SetNextPendingAction( PENDING_StopCoughing );
}

function StartHunting()
{
    if(!m_DZone.m_bHuntDisallowed)
    {
        m_eStrategy = STRATEGY_Hunt;
        m_controller.GotoStateNoThreat();
    }
}

//============================================================================
// function PlayMoving - 
//============================================================================
simulated function PlayMoving()
{
    m_ePlayerIsUsingHands = HANDS_None;
    Super.PlayMoving();
}

//============================================================================
// event ReceivedWeapons - 
//============================================================================
simulated event ReceivedWeapons()
{
	EngineWeapon = GetWeaponInGroup(1);
    if(EngineWeapon==None)
    {
        EngineWeapon = GetWeaponInGroup(2);
    }

    if(EngineWeapon!=none)
    {
        R6AbstractWeapon(EngineWeapon).CreateWeaponEmitters();
    }    
    PlayWeaponAnimation();
}

//============================================================================
// function GetNormalWeaponAnimation - 
//============================================================================
simulated function BOOL GetNormalWeaponAnimation( out STWeaponAnim stAnim )
{
    stAnim.bBackward = false;
    stAnim.bPlayOnce = false;
    stAnim.fTweenTime = 0.3;
    stAnim.fRate = 1.0;
    stAnim.nBlendName = 'R6 Spine';

    if(m_bPreventWeaponAnimation||m_bPawnSpecificAnimInProgress||m_bIsKneeling||m_bIsClimbingLadder)
        return false;
    
    m_ePlayerIsUsingHands = HANDS_None;

    if(m_bIsProne)
    {
        stAnim.nAnimToPlay = 'Prone_nt';
    }
    else if( m_bDroppedWeapon || EngineWeapon==none )
    {
        stAnim.nBlendName = 'R6 R Clavicle';
        stAnim.nAnimToPlay = 'Relax_nt';
    }
    else if(bIsCrouched)
    {
        if(m_bUseHighStance && m_eDefCon <= DEFCON_3)
        {
            if(EngineWeapon.m_bUseMicroAnim)
                stAnim.nAnimToPlay = 'CrouchMicroHigh_nt';
            else if(EngineWeapon.m_eWeaponType==WT_Pistol)
                stAnim.nAnimToPlay = 'CrouchHandGunHigh_nt';
            else
                stAnim.nAnimToPlay = 'CrouchSubGunHigh_nt';
        }
        else
        {
            if(EngineWeapon.m_bUseMicroAnim)
                stAnim.nAnimToPlay = 'CrouchMicroLow_nt';
            else if(EngineWeapon.m_eWeaponType==WT_Pistol)
                stAnim.nAnimToPlay = 'CrouchHandGunLow_nt';
            else
                stAnim.nAnimToPlay = 'CrouchSubGunLow_nt';
        }
    }
    else
    {
        if(m_bUseHighStance)
        {
            if(m_bSprayFire)
            {
                if(EngineWeapon.m_bUseMicroAnim)
                    stAnim.nAnimToPlay = 'StandMicroMid_nt';
                else if(EngineWeapon.m_eWeaponType==WT_Pistol)
                    stAnim.nAnimToPlay = 'StandHandGunHigh_nt';
                else
                    stAnim.nAnimToPlay = 'StandSubGunMid_nt';
            }
            else
            {
                if(EngineWeapon.m_bUseMicroAnim)
                    stAnim.nAnimToPlay = 'StandMicroHigh_nt';
                else if(EngineWeapon.m_eWeaponType==WT_Pistol)
                    stAnim.nAnimToPlay = 'StandHandGunHigh_nt';
                else
                    stAnim.nAnimToPlay = 'StandSubGunHigh_nt';
            }
        }
        else
        {
            if(m_eDefCon <= DEFCON_3)
            {
                if(EngineWeapon.m_bUseMicroAnim)
                    stAnim.nAnimToPlay = 'StandMicroLow_nt';
                else if(EngineWeapon.m_eWeaponType==WT_Pistol)
                    stAnim.nAnimToPlay = 'StandHandGunLow_nt';
                else
                    stAnim.nAnimToPlay = 'StandSubGunLow_nt';
            }
            else if(m_eDefCon <= DEFCON_4 )
            {
                stAnim.nBlendName = 'R6 R Clavicle';
                if(EngineWeapon.m_bUseMicroAnim)
                    stAnim.nAnimToPlay = 'RelaxMicro_nt';
                else if(EngineWeapon.m_eWeaponType==WT_Pistol)
                    stAnim.nAnimToPlay = 'RelaxHandGun_nt';
                else
                    stAnim.nAnimToPlay = 'RelaxSubGun_nt';
            }
            else
            {
                if( EngineWeapon.m_bUseMicroAnim || EngineWeapon.m_eWeaponType==WT_Pistol )
                {
                    m_ePlayerIsUsingHands = HANDS_Both;
                }
                else
                {
                    stAnim.nAnimToPlay = 'RelaxSubGunShoulder_nt';
                    stAnim.nBlendName = 'R6 R Clavicle';
                    m_ePlayerIsUsingHands = HANDS_Left;
                }
            }
        }
    }
    
    return true;
}

//============================================================================
// function GetFireWeaponAnimation - 
//============================================================================
simulated function BOOL GetFireWeaponAnimation( out STWeaponAnim stAnim )
{
    local R6EngineWeapon.EWeaponType eWT;

    stAnim.bBackward = false;
    stAnim.bPlayOnce = EngineWeapon.GetRateOfFire() == ROF_Single;
    stAnim.fRate = 1.0;
    stAnim.fTweenTime = 0.05;
    stAnim.nBlendName='R6 Spine';

    if(m_bIsProne)  
    {
        if( m_bBoltActionRifle )
            stAnim.nAnimToPlay = 'ProneFireAndBoltRifle';
        else
            stAnim.nAnimToPlay = 'ProneFire';
    }
    else
    {
        if(EngineWeapon.m_bUseMicroAnim && m_bSprayFire && !bIsCrouched)
            stAnim.nAnimToPlay = 'StandSprayFireMicro';
        else
        {
            // Set the weapon type
            eWT = EngineWeapon.m_eWeaponType;
            if(EngineWeapon.m_bUseMicroAnim)
            {
                stAnim.fTweenTime = 0.1;
                stAnim.fRate = 3.0;
                eWT = WT_Pistol;
            }
            if( eWT == WT_Sniper && !m_bBoltActionRifle )
                eWT = WT_Sub;

            switch(eWT)
            {
                case WT_ShotGun:
                    if(bIsCrouched)
                        stAnim.nAnimToPlay = 'CrouchFireShotGun';
                    else
                    {
                        if(m_bSprayFire)
                            stAnim.nAnimToPlay = 'StandSprayFireShotgun';
                        else
                            stAnim.nAnimToPlay = 'StandFireShotGun';
                    }
                    break;
                case WT_Pistol:
                    if(bIsCrouched)
                        stAnim.nAnimToPlay = 'CrouchFireHandGun';
                    else
                        stAnim.nAnimToPlay = 'StandFireHandGun';
                    break;
                case WT_LMG:
                    if(bIsCrouched)
                        stAnim.nAnimToPlay = 'CrouchFireLmg';
                    else
                        stAnim.nAnimToPlay = 'StandFireLmg';
                    break;
                case WT_Sniper:
                    if(bIsCrouched)
                        stAnim.nAnimToPlay = 'CrouchFireAndBoltRifle';
                    else
                        stAnim.nAnimToPlay = 'StandFireAndBoltRifle';
                    break;
                default:
                    if(bIsCrouched)
                        stAnim.nAnimToPlay = 'CrouchFireSubGun';
                    else
                    {
                        if(m_bSprayFire)
                            stAnim.nAnimToPlay = 'StandSprayFireSubGun';
                        else
                            stAnim.nAnimToPlay = 'StandFireSubGun';
                    }
                    break;
            }
        }
    }
    
    return true;
}

//============================================================================
// function GetReloadAnimation - 
//============================================================================
simulated function BOOL GetReloadWeaponAnimation( out STWeaponAnim stAnim )
{
    local R6EngineWeapon.EWeaponType eWT;

    m_bWeaponTransition = true;
    m_ePlayerIsUsingHands = HANDS_None;

    stAnim.bBackward = false;
    stAnim.bPlayOnce = true;
    stAnim.fRate = 1.0;
    stAnim.fTweenTime = 0.1;
    stAnim.nBlendName='R6 Spine2';

    if(m_bIsProne)
        stAnim.nAnimToPlay = 'ProneReloadSubGun';
    else
    {
        // Set the weapon type
        eWT = EngineWeapon.m_eWeaponType;
        if(EngineWeapon.m_bUseMicroAnim)
            eWT = WT_Pistol;
        if( eWT == WT_ShotGun && !EngineWeapon.IsA('R6PumpShotgun') )
            eWT = WT_Sub;

        switch(eWT)
        {
            case WT_Pistol:
                if(bIsCrouched)
                    stAnim.nAnimToPlay = 'CrouchReloadHandGun';
                else
                    stAnim.nAnimToPlay = 'StandReloadHandGun';
                break;
            case WT_ShotGun:
                if(bIsCrouched)
                    stAnim.nAnimToPlay = 'CrouchReloadShotGun';
                else
                    stAnim.nAnimToPlay = 'StandReloadShotGun';
                break;
            default:
                if(bIsCrouched)
                    stAnim.nAnimToPlay = 'CrouchReloadSubGun';
                else
                    stAnim.nAnimToPlay = 'StandReloadSubGun';
                break;
        }
    }

    return true;
}

//============================================================================
// vector EyePosition - 
//============================================================================
event vector EyePosition()
{
    local vector vEyeHeight;

    if(bIsCrouched)
        vEyeHeight.Z = 40;
    else if(m_bIsProne)
        vEyeHeight.Z = 0;
    else if(m_bIsKneeling)
        vEyeHeight.Z = 20;
    else
        vEyeHeight.Z = 70;

    return vEyeHeight;
}

//============================================================================
// StartCrouch - 
//============================================================================
event StartCrouch(float HeightAdjust)
{
    SetWalking( true );
    Super.StartCrouch( HeightAdjust );
}

//============================================================================
// EndCrouch - 
//============================================================================
event EndCrouch(float fHeight)
{
    if(m_eMovementPace==PACE_Run)
        SetWalking( false );
    Super.EndCrouch( fHeight );
}

//============================================================================
//##### ####  #####  #### ####  ###  ##      ###   #### ##### ####  ###  #   #   
//##    ##  # ##    ##     ##  ##  # ##     ##  # ##     ##    ##  ##  # ##  #   
//##### ####  ####  ##     ##  ##### ##     ##### ##     ##    ##  ##  # # # #   
//   ## ##    ##    ##     ##  ##  # ##     ##  # ##     ##    ##  ##  # #  ##   
//##### ##    #####  #### #### ##  # #####  ##  #  ####  ##   ####  ###  #   #   
//============================================================================

//============================================================================
// PlaySpecialPendingAction - Called from UpdateMovementAnimation to
//                            play special animation on all clients
//============================================================================
simulated event PlaySpecialPendingAction( EPendingAction eAction, INT iActionInt )
{
    #ifdefDEBUG if(bShowLog) logX("PlaySpecialPendingAction " $ eAction ); #endif
    switch(eAction)
    {
        case PENDING_StopCoughing:      StopCoughing();         break;
        case PENDING_ThrowGrenade:      PlayThrowGrenade();     break;
        case PENDING_Surrender:         PlaySurrender();        break;
        case PENDING_Kneeling:          PlayKneeling();         break;
        case PENDING_Arrest:            PlayArrest();           break;
        case PENDING_CallBackup:        PlayCallBackup();       break;
        case PENDING_SpecialAnim:       PlaySpecialAnim();      break;
        case PENDING_LoopSpecialAnim:   LoopSpecialAnim();      break;
        case PENDING_StopSpecialAnim:   StopSpecialAnim();      break;
        default:
            Super.PlaySpecialPendingAction( eAction, iActionInt );
    }
}

simulated function PlayCoughing()
{
	#ifdefDEBUG if(bShowLog) log(self$" : PlayCoughing()"); #endif
 
    if ( m_bIsClimbingLadder )
        return;

    m_ePlayerIsUsingHands = HANDS_Both;
    PlayWeaponAnimation();
    AnimBlendParams( C_iPawnSpecificChannel, 1.0,,, 'R6 Spine2' );
    PlayAnim( 'StandGazed_c', 1, 0.5, C_iPawnSpecificChannel );
    m_bPawnSpecificAnimInProgress = true;

    AnimBlendParams( C_iPawnSpecificChannel+1, 1.0,,, 'R6 Spine2' );
    LoopAnim( 'StandGazedWalkForward', 1, 0.5, C_iPawnSpecificChannel+1 );
}

simulated function StopCoughing()
{
    AnimBlendToAlpha( C_iPawnSpecificChannel+1, 0.0, 0.5 );
}

simulated function PlayBlinded()
{
    if ( m_bIsClimbingLadder  )
    {
        return;
    }

    m_ePlayerIsUsingHands = HANDS_Both;
    PlayWeaponAnimation();
    AnimBlendParams( C_iPawnSpecificChannel, 1.0,,, 'R6 Spine2'  );
    if(bIsCrouched || m_bIsProne )
        PlayAnim( 'CrouchBlinded', 1, 0.5, C_iPawnSpecificChannel );
    else
        PlayAnim( 'StandBlinded', 1, 0.5, C_iPawnSpecificChannel );
    m_bPawnSpecificAnimInProgress = true;
}

simulated function PlaySurrender()
{
    #ifdefDEBUG if(bShowLog) logX("PlaySurrender"); #endif

    m_ePlayerIsUsingHands = HANDS_Both;
    PlayWeaponAnimation();
    ClearChannel( C_iPawnSpecificChannel );
    if( m_bDroppedWeapon || EngineWeapon==none || m_eDefCon>DEFCON_3 )
        PlayAnim( 'RelaxToSurrender', 1, 0.2, C_iPawnSpecificChannel );
    else
        PlayAnim( 'StandToSurrender', 1, 0.2, C_iPawnSpecificChannel );
    AnimBlendToAlpha( C_iPawnSpecificChannel, 1.0, 0.1 );
    m_bPawnSpecificAnimInProgress = true;
}

simulated function PlayKneeling()
{
    #ifdefDEBUG if(bShowLog) logX("PlayKneeling"); #endif

	m_bIsKneeling = true;
    ClearChannel( C_iPawnSpecificChannel );
    PlayAnim( 'SurrenderToKneel', 1, 0.0, C_iPawnSpecificChannel );
    AnimBlendToAlpha( C_iPawnSpecificChannel, 1.0, 0.1 );
    m_bPawnSpecificAnimInProgress = true;
    PlayWaiting();
    PlayMoving();
}

simulated function PlayArrest()
{
    m_ePlayerIsUsingHands = HANDS_Both;
    PlayWeaponAnimation();
    AnimBlendParams( C_iPawnSpecificChannel, 1.0 );
    PlayAnim( 'KneelArrest', 1, 0.0, C_iPawnSpecificChannel );
    m_bPawnSpecificAnimInProgress = true;
    PlayWaiting();
}

simulated function PlayCallBackup()
{
    local name nAnimName;
    local bool bOldEngaged;

    #ifdefDEBUG if(bShowLog) logX("PlayCallBackup"); #endif

    switch( m_iPendingActionInt[m_iLocalCurrentActionIndex] ) 
    {
        case 0:   nAnimName = 'StandYellAlarm';             break;
        case 1:   nAnimName = 'StandYellAlarm';             break;
    }

    if(m_iPendingActionInt[m_iLocalCurrentActionIndex]==0)
    {
        // Make sure that we have the wait0 in channel 0
        bOldEngaged = m_bEngaged;
        m_bEngaged = true;
        PlayWaiting();
        m_bEngaged = bOldEngaged;

        m_ePlayerIsUsingHands = HANDS_None;
        PlayWeaponAnimation();
        AnimBlendParams( C_iPawnSpecificChannel, 1.0,,, 'R6 Head' );
        PlayAnim( nAnimName, 1, 0.5, C_iPawnSpecificChannel );
        m_bPawnSpecificAnimInProgress = true;
    }
    else
    {
        m_ePlayerIsUsingHands = HANDS_Both;
        PlayWeaponAnimation();
        AnimBlendParams( C_iPawnSpecificChannel, 1.0 );
        PlayAnim( nAnimName, 1, 0.5, C_iPawnSpecificChannel );
        m_bPawnSpecificAnimInProgress = true;
    }
}

simulated function PlayThrowGrenade()
{
    m_ePlayerIsUsingHands = HANDS_Both;
    PlayWeaponAnimation();
    AnimBlendParams( C_iPawnSpecificChannel, 1.0 );
    PlayAnim( 'StandThrowGrenade', 1, 0.5, C_iPawnSpecificChannel );
    m_bPawnSpecificAnimInProgress = true;
}

simulated function PlayDoorAnim(R6IORotatingDoor door)
{
    local   bool    bOpensTowardsPawn;
    local   FLOAT   fRate;

    m_ePlayerIsUsingHands = HANDS_Both;
    PlayWeaponAnimation();
    ClearChannel( C_iPawnSpecificChannel );
    AnimBlendParams( C_iPawnSpecificChannel, 1.0,,, 'R6 Spine2' );

	bOpensTowardsPawn = door.DoorOpenTowardsActor(self);

    if( m_iPendingActionInt[m_iLocalCurrentActionIndex] == 0 )
    {
        // Not locked
        // door opens towards pawn
        if(bOpensTowardsPawn)
            PlayAnim( 'StandDoorPull', 1, 0.1, C_iPawnSpecificChannel );
        else  // door opens away from pawn
            PlayAnim( 'StandDoorPush', 1, 0.1, C_iPawnSpecificChannel );
    }
    else
    {
        // Unlock door
        PlayAnim( 'StandDoorUnlock', 1, 0.1, C_iPawnSpecificChannel );
    }
    m_bPawnSpecificAnimInProgress = true;
}

simulated event PlaySpecialAnim()
{
    #ifdefDEBUG if(bShowLog) logX("Play anim " $  m_szSpecialAnimName ); #endif

    if(Level.NetMode!=NM_Client)
        m_eSpecialAnimValid = NWA_Playing;

    m_ePlayerIsUsingHands = HANDS_Both;
    PlayWeaponAnimation();
    AnimBlendParams( C_iPawnSpecificChannel, 1.0 );
    PlayAnim( m_szSpecialAnimName, 1, 0.5, C_iPawnSpecificChannel );
    m_bPawnSpecificAnimInProgress = true;
}

simulated event LoopSpecialAnim()
{
    #ifdefDEBUG if(bShowLog) logX("Play anim " $  m_szSpecialAnimName ); #endif

    if(Level.NetMode!=NM_Client)
        m_eSpecialAnimValid = NWA_Looping;

    m_ePlayerIsUsingHands = HANDS_Both;
    PlayWeaponAnimation();
    AnimBlendParams( C_iPawnSpecificChannel, 1.0 );
    LoopAnim( m_szSpecialAnimName, 1, 0.5, C_iPawnSpecificChannel );
    m_bPawnSpecificAnimInProgress = true;
}

simulated event StopSpecialAnim()
{
    #ifdefDEBUG if(bShowLog) logX("Play anim " $  m_szSpecialAnimName ); #endif

    if(Level.NetMode!=NM_Client)
        m_eSpecialAnimValid = NWA_NonValid;

    m_ePlayerIsUsingHands = HANDS_None;
    PlayWeaponAnimation();
    AnimBlendToAlpha( C_iPawnSpecificChannel, 0.0, 0.5 );
    m_bPawnSpecificAnimInProgress = false;
}

function AffectedByGrenade( Actor aGrenade, EGrenadeType eType )
{
    Super.AffectedByGrenade( aGrenade, eType );

    // Play a sound for tear gas when we have a gas mask
    if(eType==GTYPE_TearGas && m_bHaveGasMask)
        m_controller.m_VoicesManager.PlayTerroristVoices(Self, TV_SeesTearGas);
        
}

//== End Special Action ======================================================

defaultproperties
{
     m_eDefCon=DEFCON_2
     m_ePersonality=PERSO_Normal
     m_eStrategy=STRATEGY_GuardPoint
     m_iDiffLevel=2
     m_bPatrolForward=True
     m_szPrimaryWeapon="R63rdWeapons.NormalSubHKMP5A4"
     m_bCanClimbObject=True
     m_bAutoClimbLadders=True
     m_bAvoidFacingWalls=False
     m_bCanArmBomb=True
     m_bCanFireNeutrals=True
     m_fWalkingSpeed=120.000000
     m_fWalkingBackwardStrafeSpeed=518.000000
     m_fRunningSpeed=518.000000
     m_fCrouchedWalkingSpeed=87.000000
     m_fCrouchedWalkingBackwardStrafeSpeed=87.000000
     m_fCrouchedRunningSpeed=518.000000
     m_fCrouchedRunningBackwardStrafeSpeed=518.000000
     m_standStairWalkUpName="StandStairWalkUp"
     m_standStairWalkUpBackName="StandWalkBack"
     m_standStairWalkUpRightName="StandWalkRight"
     m_standStairWalkDownName="StandStairWalkDown"
     m_standStairWalkDownBackName="StandWalkBack"
     m_standStairWalkDownRightName="StandWalkRight"
     m_standStairRunUpName="StandStairRunUp"
     m_standStairRunUpBackName="StandStairRunUp"
     m_standStairRunUpRightName="StandRunRight"
     m_standStairRunDownName="StandStairRunDown"
     m_standStairRunDownBackName="StandStairRunDown"
     m_standStairRunDownRightName="StandRunRight"
     m_crouchStairWalkDownName="CrouchWalkForward"
     m_crouchStairWalkDownBackName="CrouchWalkBack"
     m_crouchStairWalkDownRightName="CrouchWalkRight"
     m_crouchStairWalkUpName="CrouchWalkForward"
     m_crouchStairWalkUpBackName="CrouchWalkBack"
     m_crouchStairWalkUpRightName="CrouchWalkRight"
     m_standDefaultAnimName="Relax_nt"
     m_ePawnType=PAWN_Terrorist
     m_iTeam=1
     m_bCanProne=False
     CrouchRadius=40.000000
     m_fHeartBeatFrequency=65.000000
     ControllerClass=Class'R6Engine.R6TerroristAI'
     m_wTickFrequency=2
     m_bReticuleInfo=False
     m_bSkipTick=True
     CollisionRadius=40.000000
     CollisionHeight=85.000000
     NetUpdateFrequency=10.000000
     Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel22
         KConvulseSpacing=(Max=2.200000)
         KSkeleton="terroskel"
         KStartEnabled=True
         bHighDetailOnly=False
         KLinearDamping=0.500000
         KAngularDamping=0.500000
         KBuoyancy=1.000000
         KVelDropBelowThreshold=50.000000
         KFriction=0.600000
         KRestitution=0.300000
         KImpactThreshold=150.000000
         Name="KarmaParamsSkel22"
     End Object
     KParams=KarmaParamsSkel'R6Engine.KarmaParamsSkel22'
}
