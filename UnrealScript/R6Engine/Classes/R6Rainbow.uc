//=============================================================================
//  R6Rainbow.uc : This is the base pawn class for all members of Rainbow
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/04 * Created by Rima Brek
//    Eric - May 7th, 2001 - Add More Basic Animations
//
//============================================================================//
class R6Rainbow extends R6Pawn
    notplaceable
    native
    abstract;

// Load Voice SOund Package
//#exec OBJ LOAD FILE=..\Sounds\R6SoundProto.uax PACKAGE=R6SoundProto

var         string          m_szPrimaryWeapon;
var         string          m_szPrimaryGadget;
var         string          m_szPrimaryBulletType;
var         string          m_szSecondaryWeapon;
var         string          m_szSecondaryGadget;
var         string          m_szSecondaryBulletType;
var         string          m_szPrimaryItem;
var         string          m_szSecondaryItem;
var         string          m_szSpecialityID;           // specialty of the rainbow
var         rotator         m_rFiringRotation;
var         INT             m_iOperativeID;             // Id operative for the campaign file
var         Material        m_FaceTexture;
var         Plane           m_FaceCoords;

var         bool            m_bHasDataObject;
var         bool            m_bIsTheIntruder;
var         bool            m_bTweenFirstTimeOnly;          // workaround the problem of tweening 
var         bool            m_bHasLockPickKit;
var         bool            m_bHasDiffuseKit;
var         bool            m_bHasElectronicsKit;
var         bool            m_bWeaponIsSecured;

var         bool            m_bThrowGrenadeWithLeftHand;

var         bool            m_bIsLockPicking;
var         bool            m_bReloadToFullAmmo;
var         vector          m_vStartLocation;
var         INT             m_iCurrentWeapon;

var         INT             m_iKills;
var         INT             m_iBulletsFired;
var         INT             m_iBulletsHit;

var         R6GasMask				m_GasMask;
var         class<R6GasMask>		m_GasMaskClass;
var			bool					m_bScaleGasMaskForFemale;

var         R6AbstractHelmet        m_Helmet;

var         R6NightVision			m_NightVision;
var         class<R6NightVision>	m_NightVisionClass;

var         bool            m_bInitRainbow;
var			bool			m_bGettingOnLadder;		// set to false when getting off a ladder

var         BYTE            m_u8DesiredPitch;    // desired pitch for rainbow NPCs
var         BYTE            m_u8CurrentPitch;
var         BYTE            m_u8DesiredYaw;      // desired yaw for rainbow NPCs
var         BYTE            m_u8CurrentYaw;

var         INT             m_iExtraPrimaryClips;
var         INT             m_iExtraSecondaryClips;

// for multiplayer NPCs only
var         bool            m_bRainbowIsFemale;
var         INT             m_iRainbowFaceID;
// this var is being used in the switch weapon animation system (particularly in 1st person view or in MP)
var         R6EngineWeapon m_preSwitchWeapon;

// escort
var         R6Hostage       m_aEscortedHostage[4];

var	enum eLadderSlide
{
	SLIDE_Start,
	SLIDE_Sliding,
	SLIDE_End,
	SLIDE_None
} m_eLadderSlide;

enum eComAnimation
{
	COM_None,
	COM_FollowMe,
	COM_Cover,
	COM_Go,
	COM_Regroup,
	COM_Hold,	
};

var enum eEquipWeapon
{
	EQUIP_SecureWeapon,
	EQUIP_EquipWeapon,
	EQUIP_NoWeapon,
	EQUIP_Armed
} m_eEquipWeapon;

// MPF1
//---------- MissionPack1
enum eRainbowCircumstantialAction
{
    CAR_None,
    CAR_Secure,
	CAR_Free,
};

var bool	m_bIsSurrended;
var bool	m_bIsUnderArrest;   // true when arrested
// MPF_Milan_7_1_2003 deprecated var bool	m_bSurrenderWait;
// MPF_Milan_7_12003 deprecated var bool	m_bArrestWait;
var bool	m_bIsBeingArrestedOrFreed; //true when transitioning from surrender to arrest or from arrest to free
//---------- End MissionPack1


replication
{
    reliable if (Role < ROLE_Authority)
        ServerSetComAnim, ServerToggleNightVision;

	reliable if (Role == ROLE_Authority)
		m_u8DesiredPitch, m_u8DesiredYaw, m_bRainbowIsFemale, m_iRainbowFaceID, m_iExtraPrimaryClips, m_iExtraSecondaryClips, 
		m_bHasLockPickKit, m_bHasDiffuseKit, m_bHasElectronicsKit;

    reliable if (Role == ROLE_Authority)
        ClientFinishAnimation;

    unreliable if (Role == ROLE_Authority)
		m_bIsLockPicking, m_NightVision;

    unreliable if (Role == ROLE_Authority )
        ClientQuickResetPeeking;

	// MissionPack1 // MPF1
	reliable if (Role == ROLE_Authority)
		m_bIsUnderArrest, ClientSetCrouch;// MPF_Milan_7_1_2003 deprecated ,m_bSurrenderWait,m_bArrestWait;/*m_bIsSurrended,m_bIsBeingArrestedOrFreed, MPF_Milan - already set trhough replicated functions*/ 
	// Missionpack1 2 // MPF1
	reliable if (Role < ROLE_Authority)
		ServerSetCrouch;

	reliable if (Role == ROLE_Authority)
		m_bHasDataObject, m_bIsTheIntruder;
}




// ----MissionPack1
simulated function ResetOriginalData()
{
	// log("R6Rainbow::ResetOriginalData()");
	Super.ResetOriginalData();

	m_bIsSurrended = false; 
	m_bIsUnderArrest = false; 
	m_bIsBeingArrestedOrFreed = false; 
	//MPF_Milan_7_1_2003 m_bSurrenderWait = false;
	//MPF_Milan_7_1_2003 m_bArrestWait = false;
}
// ----End MissionPack1


//------------------------------------------------------------------
// GetReticuleInfo
//	
//------------------------------------------------------------------
simulated event bool GetReticuleInfo( Pawn ownerReticule, OUT string szName ) 
{
    if( m_bIsPlayer )
    {
        if ( Level.NetMode == NM_Standalone )
            szName = m_CharacterName;
        else if(PlayerReplicationInfo != none)
            szName = PlayerReplicationInfo.PlayerName;
        else
            return false;
    }
	else
    {
        if(m_TeamMemberRepInfo != none)
            szName = m_TeamMemberRepInfo.m_CharacterName;
        else
            szName = m_CharacterName;
    }

	if(ownerReticule == none)
		return false;
	
    return ownerReticule.IsFriend(self) || ownerReticule.IsNeutral(self);
}

// the following three functions are to keep stats for Rainbow in Single Player Games
function IncrementKillCount()
{
	m_iKills++;
	#ifdefDEBUG if(bShowLog) log(self$" IncrementKillCount() m_iKills="$m_iKills);	#endif
}

function IncrementBulletsFired()
{
	m_iBulletsFired++;
	#ifdefDEBUG if(bShowLog) log(self$" IncrementBulletsFired() m_iBulletsFired="$m_iBulletsFired);	#endif
}

function IncrementRoundsHit()
{
	m_iBulletsHit++;
	#ifdefDEBUG if(bShowLog) log(self$" IncrementRoundsHit() m_iBulletsHit="$m_iBulletsHit);	#endif
}

simulated function StartSliding()
{
	m_eLadderSlide = SLIDE_Start;
	SendPlaySound(R6LadderVolume(m_Ladder.myLadder).m_SlideSound, SLOT_SFX);
	m_eLadderSlide = SLIDE_Sliding;
}

simulated function EndSliding()
{
	m_eLadderSlide = SLIDE_End;
    SendPlaySound(R6LadderVolume(m_Ladder.myLadder).m_SlideSoundStop, SLOT_SFX);
	m_eLadderSlide = SLIDE_None;
}

simulated event Destroyed()
{
    // make sure the effect are turned off
	if ( IsLocallyControlled() && (Controller != none))
	{
        ToggleHeatProperties(false, none, none );
        ToggleNightProperties(false, none, none );
        ToggleScopeProperties(false, none, none );
        if(R6PlayerController(Controller) != none)
			R6PlayerController(Controller).ResetBlur();
    }

    Super.Destroyed();
    if (m_Helmet != none)
    {
        m_Helmet.destroy();
        m_Helmet = none;
    }
	
	if (m_NightVision != none)
	{
		m_NightVision.destroy();
		m_NightVision = none;
	}

	if (m_GasMask != none)
	{
		m_GasMask.destroy();
		m_GasMask = none;
	}
}    

simulated function SetRainbowFaceTexture() {}

simulated function AttachNightVision()
{
    if ( m_NightVision == none )
        m_NightVision = Spawn(m_NightVisionClass, self);
    m_NightVision.bHidden = true;
    AttachToBone(m_NightVision, 'R6 Head');
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    SetMovementPhysics();
    if (Level.NetMode != NM_Client )
    {
        AttachCollisionBox( 2 );

		// spawn night vision gadget and attach to pawn
		AttachNightVision();
    }

    // spawn helmet
    if ( m_Helmet != none )
        m_Helmet.Destroy();
    if ( m_bUseSpecialSkin == true )
        m_Helmet = R6AbstractHelmet(Spawn(m_HelmetClass, self));
    else if ( m_iDefaultTeam == c_iTeamNumBravo && Level.NetMode != NM_Standalone )
        m_Helmet = R6AbstractHelmet(Spawn(Level.RedHelmet, self));
    else
        m_Helmet = R6AbstractHelmet(Spawn(Level.GreenHelmet, self));
    if ( m_Helmet != none )
    {
        AttachToBone(m_Helmet, 'R6 Head');
	}
}

simulated event PostNetBeginPlay()
{	
	if(Level.NetMode == NM_Client)
	{
		if(m_bIsPlayer && (PlayerReplicationInfo != none))
		{
			bIsFemale = PlayerReplicationInfo.bIsFemale;
			m_iOperativeID = PlayerReplicationInfo.iOperativeID;	
		}
		else
		{
			bIsFemale = m_bRainbowIsFemale;	
			m_iOperativeID = m_iRainbowFaceID;
		}	
	}

	if(Level.NetMode == NM_Client || Level.NetMode == NM_Standalone)
		SetRainbowFaceTexture();

	#ifdefDEBUG if(bShowLog) log(self$" R6Rainbow PostNetBeginPlayer() (m_bIsPlayer="$m_bIsPlayer$") : ====== bIsFemale :"$bIsFemale$" m_iOperativeID="$m_iOperativeID);	#endif
	Super.PostNetBeginPlay();

    if((Level.NetMode == NM_ListenServer) || (Level.NetMode == NM_DedicatedServer))
    {
        m_TeamMemberRepInfo = Spawn(class'R6TeamMemberReplicationInfo');
        m_TeamMemberRepInfo.m_iTeam = m_iTeam;
        m_TeamMemberRepInfo.Instigator = Self;

        m_TeamMemberRepInfo.m_CharacterName = m_CharacterName;

        m_TeamMemberRepInfo.m_iTeamPosition = m_iId;
    }

	InitializeRainbowAnimations();
}

simulated function InitializeRainbowAnimations()
{
	// initialize Rainbow Animation
	if( Physics == PHYS_Ladder )
	{
		m_eEquipWeapon = EQUIP_NoWeapon;
		m_ePlayerIsUsingHands = HANDS_Both;
		PlayAnim('StandLadder_nt'); 
	}
    else if ( m_bIsProne )
        PlayAnim('ProneWaitBreathe');
    else if ( bIsCrouched )
        PlayAnim('CrouchWaitBreathe01');
    else
        PlayAnim('StandWaitBreathe');        

    PlayWeaponAnimation();

    if ( m_ePeekingMode == PEEK_full )
    {
        if(m_bPeekingLeft)
            m_fPeeking = m_fPeekingGoal+1;
        else
            m_fPeeking = m_fPeekingGoal-1;
    }
}

function PossessedBy(Controller C)
{
    Super.PossessedBy(C);

	if(!m_bIsPlayer)
	{
		bCanStrafe = false;
	}
	else
	{
		if( (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer) )
		{
			if(PlayerReplicationInfo != none)
			{
				bIsFemale = PlayerReplicationInfo.bIsFemale;
				m_iOperativeID = PlayerReplicationInfo.iOperativeID;				
				SetRainbowFaceTexture();
			}
		}
	}
}

function UnPossessed()
{
    if(!m_bIsClimbingLadder && m_Ladder != none)
	{
		R6LadderVolume(m_Ladder.myLadder).RemoveClimber(self);
		R6LadderVolume(m_Ladder.myLadder).DisableCollisions(m_Ladder);
	}
	Super.UnPossessed();
}

simulated event AnimEnd(int iChannel)
{
	if((m_bIsFiringWeapon > 0) && (EngineWeapon!=none && !EngineWeapon.IsA('R6GrenadeWeapon')) && (m_ePlayerIsUsingHands != HANDS_None))
	{
		// if night vision activation or deactivation was interrupted - skip to end
		if(m_bNightVisionAnimation)
			SecureNightVisionGoggles();
	}

	if(iChannel == C_iBaseAnimChannel)
	{				
		m_bInitRainbow = false;
		if(m_bIsPlayer && m_bSlideEnd)
			m_bSlideEnd = false;

        if(physics != PHYS_RootMotion)		
            PlayWaiting();
	}
	else if(iChannel == C_iBaseBlendAnimChannel)
	{
		if(m_bPostureTransition && !m_bInteractingWithDevice && !m_bIsLockPicking)
		{
			if(m_bNightVisionAnimation)
				SecureNightVisionGoggles();
            m_bSoundChangePosture=false;        
			m_bIsLanding = false;          
			m_bPostureTransition = false;	
    		m_ePlayerIsUsingHands = HANDS_None;
            PlayWeaponAnimation();
		}		
		if(bIsCrouched)
			BlendKneeOnGround();
	}	
	else if((iChannel == C_iPawnSpecificChannel) && m_bPawnSpecificAnimInProgress)
	{
		m_bPawnSpecificAnimInProgress = false;
	}
	else if(iChannel == C_iWeaponLeftAnimChannel)
	{
		if(!m_bIsPlayer && m_bReloadToFullAmmo)
			FinishedReloadingWeapon();
			
		if(m_bPlayingComAnimation || m_bNightVisionAnimation)
		{
			m_bPlayingComAnimation = false;
			if(m_bNightVisionAnimation)
			{
				if(IsUsingHeartBeatSensor())
					R6ResetAnimBlendParams(C_iWeaponLeftAnimChannel);
				SecureNightVisionGoggles();
			}
			m_ePlayerIsUsingHands = HANDS_None;
			PlayWeaponAnimation();
		}
	}
    else if ((iChannel == C_iWeaponRightAnimChannel) && m_bWeaponTransition) 
    {
        m_bWeaponTransition = false;		
        if(Role == ROLE_Authority)
        {
            if (m_eGrenadeThrow != GRENADE_RemovePin) // To stay in the last frame of this animation don't call the PlayWeaponAnimation
            {
                #ifdefDEBUG if (bShowLog) log("Call THE PlayWeaponAnimation");	#endif
                PlayWeaponAnimation();
            }
            if (Level.NetMode != NM_Standalone)
            {
                ClientFinishAnimation();
            }
        }
		PlayWeaponAnimation();
    }
}

// this is used as a backup - to make sure if the activation or deactivation of the night vision was
// interrupted, the final state of the goggles is correct.
simulated function SecureNightVisionGoggles()
{
	#ifdefDEBUG if(bShowLog) log(" SecureNightvisionGoggles() was called.... m_bActivateNightVision="$m_bActivateNightVision);	#endif
	m_bNightVisionAnimation = false;
	if(m_bActivateNightVision)
	{
		m_NightVision.bHidden = false;
		AttachToBone(m_NightVision, 'R6 Head');
		if(m_eArmorType==ARMOR_Heavy)
			m_Helmet.SetHelmetStaticMesh(true);
	}
	else
	{
		m_NightVision.bHidden = true;
		if((m_eArmorType==ARMOR_Heavy) && !m_bHaveGasMask)
			m_Helmet.SetHelmetStaticMesh(false);	
	}

	m_ePlayerIsUsingHands = HANDS_None;
	PlayWeaponAnimation();
}

simulated function PlayActivateNightVisionAnimation()
{
	#ifdefDEBUG if(bShowLog) log(" PlayActivateNightVisionAnimation() is called... ");	#endif
	m_ePlayerIsUsingHands = HANDS_Left;
	PlayWeaponAnimation();
	m_bActivateNightVision = true;
	AnimBlendParams(C_iWeaponLeftAnimChannel, 1.0,,, 'R6 L Clavicle');
	m_bNightVisionAnimation = true;
	if(m_bIsProne)
		PlayAnim('ProneNightVision', 1.0, 0.2, C_iWeaponLeftAnimChannel);
	else
		PlayAnim('CrouchNightVision', 1.0, 0.2, C_iWeaponLeftAnimChannel);
}

simulated function PlayDeactivateNightVisionAnimation()
{
	#ifdefDEBUG if(bShowLog) log(" PlayDeactivateNightVisionAnimation() ");	#endif
	m_ePlayerIsUsingHands = HANDS_Left;
	PlayWeaponAnimation();
	m_bActivateNightVision = false;
	AnimBlendParams(C_iWeaponLeftAnimChannel, 1.0,,, 'R6 L Clavicle');
	m_bNightVisionAnimation = true;
	if(m_bIsProne)
		PlayAnim('ProneNightVision', 1.0, 0.2, C_iWeaponLeftAnimChannel, true);
	else
		PlayAnim('CrouchNightVision', 1.0, 0.2, C_iWeaponLeftAnimChannel, true);
}

simulated function GetNightVision()
{
	#ifdefDEBUG if(bShowLog) log(self$" GetNightVision() is called... m_bActivateNightVision="$m_bActivateNightVision);		#endif
	if(!m_bActivateNightVision)
		return;

	// attach goggles to left hand
	AttachToBone(m_NightVision, 'TagNightVision');
	m_NightVision.bHidden = false;
}

simulated function RaiseHelmetVisor()
{
	if(!m_bActivateNightVision)
		return;

	if(m_eArmorType==ARMOR_Heavy)
		m_Helmet.SetHelmetStaticMesh(true);
}

simulated function ActivateNightVision()
{
	#ifdefDEBUG if(bShowLog) log(self$" ActivateNightVision() is called... m_bActivateNightVision="$m_bActivateNightVision);	#endif
	if(!m_bActivateNightVision)
		return;

	AttachToBone(m_NightVision, 'R6 Head');
}

simulated function RemoveNightVision()
{
	#ifdefDEBUG if(bShowLog) log(self$" RemoveNightVision() is called... m_bActivateNightVision="$m_bActivateNightVision);	#endif
	if(m_bActivateNightVision)
		return;

	// attach goggles to left hand
	AttachToBone(m_NightVision, 'TagNightVision');
	m_NightVision.bHidden = false;
}

simulated function DeactivateNightVision()
{
	#ifdefDEBUG if(bShowLog) log(self$" DeactivateNightVision() is called... m_bActivateNightVision="$m_bActivateNightVision);	#endif
	if(m_bActivateNightVision)
		return;

	if((m_eArmorType==ARMOR_Heavy) && !m_bHaveGasMask)
		m_Helmet.SetHelmetStaticMesh(false);
	m_NightVision.bHidden = true;	
}

exec function ToggleNightVision()
{	
	if((physics != PHYS_Walking) || m_bIsLanding || m_bPostureTransition)
		return;

	#ifdefDEBUG if(bShowLog) log(self$" ToggleNightVision() is called... m_bNightVisionAnimation="$m_bNightVisionAnimation);	#endif
	
	// if previous night vision action was not completed, finish it
	if(m_bNightVisionAnimation)
		SecureNightVisionGoggles();

	Super.ToggleNightVision();
}

function MandatoryToggleNightVision()
{
    ToggleNightVision();
}

function ServerToggleNightVision(bool bActivateNightVision)
{
	#ifdefDEBUG if(bShowLog) log("  ServerToggleNightvision() ...bActivateNightVision="$bActivateNightVision);	#endif

	m_bActivateNightVision = bActivateNightVision;
	if(bActivateNightVision)
		SetNextPendingAction(PENDING_ActivateNightVision); 
	else
		SetNextPendingAction(PENDING_DeactivateNightVision);
}

function ClientFinishAnimation()
{
    #ifdefDEBUG if (bShowLog) log("Put WeaponTransition to FALSE");	#endif
    m_bWeaponTransition = false;
    if (m_eGrenadeThrow != GRENADE_RemovePin) // To stay in the last frame of this animation don't call the PlayWeaponAnimation
    {
        #ifdefDEBUG if (bShowLog) log("Call THE PlayWeaponAnimation");	#endif
        PlayWeaponAnimation();
    }
}

simulated function FLOAT ArmorSkillEffect()
{
	if(m_eArmorType==ARMOR_Heavy)
		return 0.6f;
	else if(m_eArmorType==ARMOR_Medium)
		return 0.8f;

	return 1.f;
}

function vector GetHandLocation()
{
	if(m_bThrowGrenadeWithLeftHand)
		return GetBoneCoords( 'R6 L Hand' ).Origin;
	else
		return GetBoneCoords( 'R6 R Hand' ).Origin;
}

event EndOfGrenadeEffect( EGrenadeType eType )
{
	if(m_bIsPlayer)
		return;

	if(eType == GTYPE_TearGas)
	{
		#ifdefDEBUG if(bShowLog) log("  End of TearGas GrenadeEffect ");	#endif
		R6RainbowAI(controller).m_TeamManager.GasGrenadeCleared(Self);
	}
	else if(eType == GTYPE_FlashBang)
	{
		#ifdefDEBUG if(bShowLog) log("  End of FLASH BANG effect ");	#endif
	}
}

function TurnAwayFromNearbyWalls()
{
	if((controller == none) || (R6RainbowAI(controller) == none))
		return;

	if(!m_bIsProne && !m_bIsClimbingStairs && (R6RainbowAI(controller).m_eFormation != FORM_SingleFileWallBothSides))
		Super.TurnAwayFromNearbyWalls();
}

simulated function PlayStartClimbing()
{
	m_bGettingOnLadder = true;
	Super.PlayStartClimbing();
}

simulated function PlayEndClimbing()
{
	m_bGettingOnLadder = false;
	Super.PlayEndClimbing();
}

//===================================================================================================
// ClimbStairs()
//===================================================================================================
simulated function ClimbStairs(vector vStairDirection)
{
	if(!m_bIsPlayer && controller != none)
		R6RainbowAI(controller).m_bUseStaggeredFormation = false;

	//R6RainbowAI(controller).SetRainbowOrientation();
	Super.ClimbStairs(vStairDirection);
}

//===================================================================================================
// EndClimbStairs()
//===================================================================================================
simulated function EndClimbStairs()
{
	if(!m_bIsPlayer && controller != none)
		R6RainbowAI(controller).m_bUseStaggeredFormation = true;
		
	//R6RainbowAI(controller).SetRainbowOrientation();
	Super.EndClimbStairs();
}

simulated function PlaySecureTerrorist()
{
	#ifdefDEBUG if(bShowLog) log(self$" : PlaySecureTerrorist()");	#endif
	R6ResetAnimBlendParams(C_iPeekingAnimChannel);

    //both hands are used to get in prone position
    m_ePlayerIsUsingHands = HANDS_Both;
	PlayWeaponAnimation();
	m_bPostureTransition = true;
	AnimBlendParams(C_iBaseBlendAnimChannel, 1.0, 0.0, 0.0);
	PlayAnim('StandArrest', 1.0, 0.2, C_iBaseBlendAnimChannel);  	
}

//---------MissionPack1 // MPF1

// MPF_Milan2 - changed all channels to specific
simulated function PlayStartSurrender()
{
    #ifdefDEBUG if(bshowlog) logX("R6Rainbow::PlayStartSurrender | " $ self); 	#endif
    R6ResetAnimBlendParams(C_iPawnSpecificChannel);
    ClearChannel(C_iPawnSpecificChannel);

    AnimBlendParams(C_iPawnSpecificChannel, 1.0, , , );
    m_ePlayerIsUsingHands = HANDS_Both;
    PlayAnim( 'RelaxToSurrender', 1, 0.2, C_iPawnSpecificChannel );
    m_bPawnSpecificAnimInProgress = true;
}

simulated function PlaySurrender()
{
    #ifdefDEBUG if(bshowlog) logX("R6Rainbow::PlaySurrender | " $ self);	#endif

    m_ePlayerIsUsingHands = HANDS_Both;
    
    AnimBlendParams(C_iPawnSpecificChannel, 1.0, , , );
    PlayAnim('SurrenderWaitBreathe', 1, 0.0, C_iPawnSpecificChannel); //We are playing hands-up breating in C_iPawnSpecificChannel to avoid being alpha blended by chan 14 and 15.
    m_bPawnSpecificAnimInProgress = true;
}

simulated function PlayEndSurrender()
{
    #ifdefDEBUG if(bshowlog) logX("R6Rainbow::PlayEndSurrender | " $ self);	#endif

    AnimBlendParams(C_iPawnSpecificChannel, 1.0, , , );
    m_ePlayerIsUsingHands = HANDS_None;
    PlayAnim( 'RelaxToSurrender', 1, 0.2, C_iPawnSpecificChannel, true); // play animation backward
    m_bPawnSpecificAnimInProgress = true;
}

/* MPF_Milan_7_1_2003 deprecated
simulated function PlayStartArrest()
{
    #ifdefDEBUG if(bshowlog) logX("R6Rainbow::PlayStartArrest | " $ self);	#endif

    AnimBlendParams(C_iPawnSpecificChannel, 1.0, , , );
    m_ePlayerIsUsingHands = HANDS_Both;
    PlayAnim( 'SurrenderToKneel',1.0, 0.2, C_iPawnSpecificChannel); 
    m_bPawnSpecificAnimInProgress = true;
}
*/

simulated function PlayArrest()
{
    #ifdefDEBUG if(bshowlog) logX("R6Rainbow::PlayArrest | " $ self);	#endif

	ClearChannel(C_iPawnSpecificChannel) ; // MPF_Milan_7_1_2003
    AnimBlendParams(C_iPawnSpecificChannel, 1.0, , , );
    m_ePlayerIsUsingHands = HANDS_Both;
    PlayAnim( 'SurrenderToKneel', 1.0, 0.2, C_iPawnSpecificChannel); 
    m_bPawnSpecificAnimInProgress = true;
}

simulated function PlayArrestKneel()
{
    #ifdefDEBUG if(bshowlog) logX("R6Rainbow::PlayArrestKneel | " $ self);	#endif

    AnimBlendParams(C_iPawnSpecificChannel, 1.0, , , );
    m_ePlayerIsUsingHands = HANDS_Both;
    PlayAnim( 'KneelArrest', 1.0, 0.2, C_iPawnSpecificChannel); 
    m_bPawnSpecificAnimInProgress = true;
}

// MPF_Milan_7_1_2003 - changed to specific channel, not loop
simulated function PlayArrestWaiting()
{
    local name anim;

    #ifdefDEBUG if(bshowlog) logX("R6Rainbow::PlayArrestWaiting | " $ self); #endif

	//ClearChannel(C_iPawnSpecificChannel) ; // MPF_Milan_7_1_2003

	SetRandomWaiting(4);
    switch(m_bRepPlayWaitAnim)
    {
        case 0:     anim = 'KneelArrestWait01';     break;
        default:    anim = 'KneelArrestWait02';
    }

 
    AnimBlendParams(C_iPawnSpecificChannel, 1.0, , , );
    m_ePlayerIsUsingHands = HANDS_Both;
    PlayAnim( anim,1.0, 0.2, C_iPawnSpecificChannel); 
    m_bPawnSpecificAnimInProgress = true;
}

// NEW
simulated function PlayEndArrest()
{
    #ifdefDEBUG if(bshowlog) logX("R6Rainbow::PlayEndArrest | " $ self);	#endif

    AnimBlendParams(C_iPawnSpecificChannel, 1.0, , , );
    m_ePlayerIsUsingHands = HANDS_Both;
    PlayAnim( 'KneelArrest', 1, 0.2, C_iPawnSpecificChannel , true); // play animation backward
    m_bPawnSpecificAnimInProgress = true;
}
// End MPF_Milan_7_1_2003 

simulated function PlaySetFree()
{
    #ifdefDEBUG if(bshowlog) logX("R6Rainbow::PlaySetFree | " $ self);	#endif

    AnimBlendParams(C_iPawnSpecificChannel, 1.0, , , );
    m_ePlayerIsUsingHands = HANDS_Both;
    PlayAnim( 'SurrenderToKneel', 1, 0.2, C_iPawnSpecificChannel , true); // play animation backward
    m_bPawnSpecificAnimInProgress = true;
}

simulated function PlayPostEndSurrender()
{
    #ifdefDEBUG if(bShowLog) logX("R6Rainbow::PlayPostEndSurrender | " $ self); #endif
    m_ePlayerIsUsingHands = HANDS_None;//HANDS_Both
}

//--------- End MissionPack1


simulated function PlayLockPickDoorAnim()
{
    // do not blend hand animations while opening doors
	#ifdefDEBUG if(bShowLog) log(self$" : PlayLockPickDoorAnim()");	#endif
    m_ePlayerIsUsingHands = HANDS_Both;	
    R6ResetAnimBlendParams(C_iPeekingAnimChannel);
	PlayWeaponAnimation();
	m_bPostureTransition = true;
	AnimBlendParams(C_iBaseBlendAnimChannel, 1.0, 0.0, 0.0);

	if(bIsCrouched)
		LoopAnim('CrouchLockPick_c', 2.0, 0.2, C_iBaseBlendAnimChannel);
	else
		LoopAnim('StandLockPick_c', 2.0, 0.2, C_iBaseBlendAnimChannel);
}

 
//============================================================================
// PlaySpecialPendingAction - Called from UpdateMovementAnimation to
//                            play special animation on all clients
//============================================================================
simulated event PlaySpecialPendingAction( EPendingAction eAction, INT iActionInt )
{	
    switch(eAction)
    {
		case PENDING_SetRemoteCharge:		PlayRemoteChargeAnimation();				break;
		case PENDING_SetClaymore:			PlayClaymoreAnimation();					break;
		case PENDING_SetBreachingCharge:	PlayBreachDoorAnimation();					break;
		case PENDING_LockPickDoor:			PlayLockPickDoorAnim();						break;
		case PENDING_ComFollowMe:			PlayCommunicationAnimation(COM_FollowMe);	break;
		case PENDING_ComCover:				PlayCommunicationAnimation(COM_Cover);		break;
		case PENDING_ComGo:					PlayCommunicationAnimation(COM_Go);			break;
		case PENDING_ComRegroup:			PlayCommunicationAnimation(COM_Regroup);	break;
		case PENDING_ComHold:				PlayCommunicationAnimation(COM_Hold);		break;
		case PENDING_ActivateNightVision:	PlayActivateNightVisionAnimation();			break;
		case PENDING_DeactivateNightVision:	PlayDeactivateNightVisionAnimation();		break;
		case PENDING_SecureWeapon:			RainbowSecureWeapon();						break;
		case PENDING_EquipWeapon:			RainbowEquipWeapon();						break;
		case PENDING_SecureTerrorist:		PlaySecureTerrorist();						break;
		//----- MissionPack1 // MPF1
		case PENDING_StartSurrender:        PlayStartSurrender();	                    break;
		case PENDING_Surrender:             PlaySurrender();	                        break; // MPF_Milan - re-added
		case PENDING_EndSurrender:			PlayEndSurrender();	                        break;
        case PENDING_Arrest:				PlayArrest();	                            break;
        case PENDING_ArrestKneel:			PlayArrestKneel();	                        break; // MPF_Milan
        case PENDING_ArrestWaiting:			PlayArrestWaiting();	break; // MPF_Milan
        case PENDING_EndArrest:				PlayEndArrest();	break; // MPF_Milan_7_1_2003
        case PENDING_SetFree:				PlaySetFree();	                            break;
		case PENDING_PostEndSurrender:      PlayPostEndSurrender();	                    break;
		//----- End MissionPack1

        default:
            Super.PlaySpecialPendingAction( eAction, iActionInt );
    }
}

simulated function ResetPawnSpecificAnimation()
{
	m_ePlayerIsUsingHands = HANDS_None;
	m_bPawnSpecificAnimInProgress = false;
	R6ResetAnimBlendParams(C_iPawnSpecificChannel);	
}

simulated function PlayCoughing()
{
	#ifdefDEBUG if(bShowLog) log(self$" : PlayCoughing()");    #endif

    if ( m_bIsClimbingLadder || m_bWeaponTransition)
		return;

	m_ePlayerIsUsingHands = HANDS_Both;
	m_bPawnSpecificAnimInProgress = true;
	AnimBlendParams(C_iPawnSpecificChannel, 1.0, 0.5, 0.0, 'R6 Spine');
	if(m_bIsProne)
		PlayAnim('ProneGazed', 1.0, 0.0, C_iPawnSpecificChannel); 	
	else if(bIsCrouched)
		PlayAnim('CrouchGazed', 1.0, 0.0, C_iPawnSpecificChannel); 	
	else
		PlayAnim('StandGazed', 1.0, 0.0, C_iPawnSpecificChannel); 	
}

simulated function PlayBlinded()
{
	#ifdefDEBUG if(bShowLog) log(self$" : PlayBlinded()");	#endif
    
    if ( m_bIsClimbingLadder || m_bWeaponTransition)
        return;

    m_ePlayerIsUsingHands = HANDS_Both;
	m_bPawnSpecificAnimInProgress = true;
	AnimBlendParams(C_iPawnSpecificChannel, 1.0, 0.5, 0.0, 'R6 Spine');
	if(m_bIsProne)
		PlayAnim('ProneBlinded', 1.0, 0.0, C_iPawnSpecificChannel); 	
	else if(bIsCrouched)
		PlayAnim('CrouchBlinded', 1.0, 0.0, C_iPawnSpecificChannel); 	
	else
		PlayAnim('StandBlinded', 1.0, 0.0, C_iPawnSpecificChannel); 
}

simulated function SetCommunicationAnimation(eComAnimation eComAnim)
{
	ServerSetComAnim(eComAnim);
}

simulated function ServerSetComAnim(eComAnimation eComAnim)
{
	switch(eComAnim)
	{
		case COM_FollowMe:		SetNextPendingAction(PENDING_ComFollowMe);		break;
		case COM_Cover:			SetNextPendingAction(PENDING_ComCover);			break;
		case COM_Go:			SetNextPendingAction(PENDING_ComGo);			break;
		case COM_Regroup:		SetNextPendingAction(PENDING_ComRegroup);		break;
		case COM_Hold:			SetNextPendingAction(PENDING_ComHold);			break;
	}
}

simulated function PlayCommunicationAnimation(eComAnimation eComAnim)
{
	// todo : add other exceptions?
	// do not play communication animation if player is in the process of changing/reloading weapon
	if(m_bReloadingWeapon || m_bChangingWeapon)
		return;

	m_ePlayerIsUsingHands = HANDS_Left;
	PlayWeaponAnimation();
	AnimBlendParams(C_iWeaponLeftAnimChannel, 1.0,,, 'R6 L Clavicle');

	m_bPlayingComAnimation = true;
	switch(eComAnim)
	{
		case COM_FollowMe:		
			if(m_bIsProne)
				PlayAnim('ProneComFollowMe', 1.0, 0.2, C_iWeaponLeftAnimChannel);
			else
				PlayAnim('StandComFollowMe', 1.0, 0.2, C_iWeaponLeftAnimChannel);		
			break;

		case COM_Cover:			
			if(m_bIsProne)
				PlayAnim('ProneComCover', 1.0, 0.2, C_iWeaponLeftAnimChannel);
			else
				PlayAnim('StandComCover', 1.0, 0.2, C_iWeaponLeftAnimChannel);			
			break;
		
		case COM_Go:			
			if(m_bIsProne)
				PlayAnim('ProneComGo', 1.0, 0.2, C_iWeaponLeftAnimChannel);
			else
				PlayAnim('StandComGo', 1.0, 0.2, C_iWeaponLeftAnimChannel);			
			break;
		
		case COM_Regroup:
			if(m_bIsProne)
				PlayAnim('ProneComRegroup', 1.0, 0.2, C_iWeaponLeftAnimChannel);
			else
				PlayAnim('StandComRegroup', 1.0, 0.2, C_iWeaponLeftAnimChannel);			
			break;
		
		case COM_Hold:		
			if(m_bIsProne)
				PlayAnim('ProneComHold', 1.0, 0.2, C_iWeaponLeftAnimChannel);
			else
				PlayAnim('StandComHold', 1.0, 0.2, C_iWeaponLeftAnimChannel);			
			break;
	}
}

simulated function RainbowSecureWeapon()
{
	#ifdefDEBUG if(bShowLog) log(self$" : RainbowSecureWeapon() was called...");	#endif
	if(!m_bIsPlayer && (engineWeapon != none))
		engineWeapon.GotoState('PutWeaponDown');
	m_eEquipWeapon = EQUIP_SecureWeapon;
	PlayWeaponAnimation();
}

simulated function RainbowEquipWeapon()
{
	#ifdefDEBUG if(bShowLog) log(self$" : RainbowEquipWeapon() was called...");	#endif
	if(!m_bIsPlayer && (engineWeapon != none))
		engineWeapon.GotoState('BringWeaponUp');
	m_eEquipWeapon = EQUIP_EquipWeapon;
	PlayWeaponAnimation();
}

simulated function bool CheckForPassiveGadget(string aClassName)
{
    if(aClassName == "PRIMARYMAGS")
    {
		#ifdefDEBUG if(bShowLog) log(" add extra PRIMARY MAGAZINE GetWeaponInGroup(1)="$GetWeaponInGroup(1));	#endif
        m_iExtraPrimaryClips++; 
		return true;
    }
    else if(aClassName == "SECONDARYMAGS")
    {
		#ifdefDEBUG if(bShowLog) log(" add extra SECONDARY MAGAZINE GetWeaponInGroup(2)="$GetWeaponInGroup(2));	#endif
        m_iExtraSecondaryClips++; 
		return true;
    }
	else if(aClassName == "LOCKPICKKIT")
	{
		#ifdefDEBUG if(bShowLog) log(self$" has a lock pick kit...");	#endif
		m_bHasLockPickKit = true;
		return true;
	}
	else if(aClassName == "DIFFUSEKIT")
	{
		#ifdefDEBUG if(bShowLog) log(self$" has a diffusekit... ");	#endif
		m_bHasDiffuseKit = true;		
		return true;
	}
	else if(aClassName == "ELECTRONICKIT")
	{
		#ifdefDEBUG if(bShowLog) log(self$" has an electronics kit....");	#endif
		m_bHasElectronicsKit = true;
		return true;
	}
	else if(aClassName == "GASMASK")
	{
		#ifdefDEBUG if(bShowLog) log(self$" has an gas mask....");	#endif
		m_bHaveGasMask = true;
		return true;
	}
    else if(aClassName == "DoubleGadget")
	{
		#ifdefDEBUG if(bShowLog) log(self$" Gadget Was selected twice");	#endif
        if(GetWeaponInGroup(3) != none)
        {
            //An Gadget was selected twice
            GetWeaponInGroup(3).GiveMoreAmmo();
        }
        return true;
	}

	return false;
}

simulated function GiveDefaultWeapon()
{
    local INT   iLastAllocated;
    local INT i;
    local string szCurrentGadget;
    local string caps_szPrimaryWeapon, caps_szSecondaryWeapon, caps_szCurrentGadget;

    // Give the weapons to the characters
    if ((Level.NetMode == NM_Standalone) || !m_bIsPlayer)
    {
        caps_szPrimaryWeapon = caps(m_szPrimaryWeapon);
        if ((caps_szPrimaryWeapon != "R6WEAPONS.NONE") && (caps_szPrimaryWeapon !=""))
        {
            ServerGivesWeaponToClient(m_szPrimaryWeapon,1, m_szPrimaryBulletType, m_szPrimaryGadget);
        }
        caps_szSecondaryWeapon = caps(m_szSecondaryWeapon);
        if ((caps_szSecondaryWeapon != "R6WEAPONS.NONE") && (caps_szSecondaryWeapon !=""))
        {
            ServerGivesWeaponToClient(m_szSecondaryWeapon,2, m_szSecondaryBulletType, m_szSecondaryGadget);
        }

        iLastAllocated = 3;
        for( i=0; i<2; i++)
        {
            if(i==0)
                szCurrentGadget = m_szPrimaryItem;
            else
                szCurrentGadget = m_szSecondaryItem;

            caps_szCurrentGadget = caps(szCurrentGadget);
            if ((caps_szCurrentGadget != "R6WEAPONGADGETS.NONE") && (caps_szCurrentGadget !=""))
            {
                if(caps_szCurrentGadget == "PRIMARYMAGS")
                {
                    GetWeaponInGroup(1).AddExtraClip();
                }
                else if(caps_szCurrentGadget == "SECONDARYMAGS")
                {
                    GetWeaponInGroup(2).AddExtraClip();
                }
		        else if(caps_szCurrentGadget == "LOCKPICKKIT")
		        {
			        #ifdefDEBUG if(bShowLog) log(self$" has a lock pick kit...");	#endif
			        m_bHasLockPickKit = true;
		        }
		        else if(caps_szCurrentGadget == "DIFFUSEKIT")
		        {
			        #ifdefDEBUG if(bShowLog) log(self$" has a diffusekit... ");	 #endif
			        m_bHasDiffuseKit = true;
		        }
		        else if(caps_szCurrentGadget == "ELECTRONICKIT")
		        {
			        #ifdefDEBUG if(bShowLog) log(self$" has an electronics kit....");	#endif
			        m_bHasElectronicsKit = true;
		        }
		        else if(caps_szCurrentGadget == "GASMASK")
		        {
			        #ifdefDEBUG if(bShowLog) log(self$" has an gas mask....");	#endif
			        m_bHaveGasMask = true;
		        }
                else if((i == 1) && (caps(m_szPrimaryItem) == caps(m_szSecondaryItem)))
                {
                	#ifdefDEBUG if(bShowLog) log(self$" Gadget Was selected twice");	#endif
                    GetWeaponInGroup(3).GiveMoreAmmo();
                }
                else
                {
                    ServerGivesWeaponToClient(szCurrentGadget, iLastAllocated );
                    iLastAllocated++;
                }
            }
        }
        
        if (Controller != none)
        {
            Controller.m_PawnRepInfo.m_PawnType = m_ePawnType;
            Controller.m_PawnRepInfo.m_bSex = bIsFemale;
        }

        ReceivedWeapons();
    }

	if(m_bHaveGasMask)
		AttachGasMask();
}

simulated function AttachGasMask()
{
	if(m_Helmet != none)
	{
		if(m_eArmorType==ARMOR_Heavy)
			m_Helmet.SetHelmetStaticMesh(true);
	}
    if(m_GasMask == none)
    {
	    m_GasMask = Spawn(m_GasMaskClass);
	    AttachToBone(m_GasMask, 'R6 Head');
    }
////////////////////////
    if(bIsFemale && m_bScaleGasMaskForFemale)
        m_GasMask.DrawScale=1.0;
}

simulated event ReceivedEngineWeapon()
{	
    AttachWeapon(EngineWeapon, EngineWeapon.m_AttachPoint);
	// bring weapon up immediately at start (without requiring pawn to move or change posture first)
	PlayWeaponAnimation();
}

simulated event PlayWeaponAnimation()
{
	if(m_bPawnSpecificAnimInProgress 
		&& (m_bReloadingWeapon || m_bChangingWeapon || EngineWeapon.bFiredABullet || (m_eGrenadeThrow != GRENADE_None)))
		ResetPawnSpecificAnimation();

	Super.PlayWeaponAnimation();
}

simulated event ReceivedWeapons()
{
    local int i;
    local R6EngineWeapon aWeapon;

	if(Level.NetMode!=NM_Standalone && m_bHaveGasMask)
		AttachGasMask();

    for(i=1; i<=4; i++)
    {
        aWeapon = GetWeaponInGroup(i);
        #ifdefDEBUG if(bShowLog) log("RECEIVEDWEAPONS: spot " $ i $ " Weapon: " $ aWeapon $ " for " $ Self );	#endif

        if(aWeapon!=none)
        {
            if(i==4)
                aWeapon.m_HoldAttachPoint = aWeapon.m_HoldAttachPoint2;

            AttachWeapon(aWeapon, aWeapon.m_HoldAttachPoint);
            aWeapon.WeaponInitialization( Self );

            if(IsLocallyControlled())
            {
                if(m_bIsPlayer)
                    aWeapon.LoadFirstPersonWeapon(self);
                else
                    aWeapon.RemoteRole = ROLE_SimulatedProxy;

                if(i==1)
                {
                    if(m_bIsPlayer)
                    {
                        //Load first Person Weapons only for the player controlled by the character.
                        #ifdefDEBUG if (bShowLog) log("RECEIVEDWEAPONS: spot 0 Load 1st person weapon " $ aWeapon $ " for "$self$" owner is "$owner);	#endif

			            while(m_iExtraPrimaryClips > 0)
			            {			
				            aWeapon.AddExtraClip();
				            m_iExtraPrimaryClips--;
			            }
                    }
                    #ifdefDEBUG if(bShowLog) log("Give initial Weapon: " $ aWeapon $ " to: " $ self);	#endif
                }

                if(i==2)
                {
			        while(m_iExtraSecondaryClips > 0)
			        {					
				        aWeapon.AddExtraClip();
				        m_iExtraSecondaryClips--;
			        }
                }
            }
        }
    }

    if(IsLocallyControlled())
    {        
		EngineWeapon = GetWeaponInGroup(1);
        m_iCurrentWeapon = 1;
        if (m_SoundRepInfo != none)
            m_SoundRepInfo.m_CurrentWeapon = 0;
        if(EngineWeapon==none)
        {
            EngineWeapon = GetWeaponInGroup(2);

            if (m_SoundRepInfo != none)
                m_SoundRepInfo.m_CurrentWeapon = 1;
            m_iCurrentWeapon = 2;
        }
        // no wpn in group 1 and 2
        if ( EngineWeapon != none )
        {
            ServerChangedWeapon(none, EngineWeapon);
            if(m_bIsPlayer )
            {
                EngineWeapon.GotoState('RaiseWeapon');
            }
            else
            {
                EngineWeapon.GotoState('');
            }
        }
    }

    if(EngineWeapon!=none)
        AttachWeapon(EngineWeapon, EngineWeapon.m_AttachPoint);

	// bring weapon up immediately at start (without requiring pawn to move or change posture first)
	PlayWeaponAnimation();
}


function SetMovementPhysics()
{
    SetPhysics(PHYS_Walking);
}

// choose a random wait animation to play; this overrides the function in R6Pawn.uc
simulated function PlayWaiting()
{    
	if(m_bSlideEnd)
		return;

    if(m_bInitRainbow)
		return;
	
	if(physics == PHYS_Falling)	{		PlayFalling();				return;	}
	if(m_bIsClimbingLadder)
	{
		AnimateStoppedOnLadder();	
		return;  
	}

	/* MPF_Milan_7_1_2003 commenteed; not needed anymore
	// -----MissionPack1 // MPF1
	if(m_bArrestWait)		
    {		
        PlayArrestWaiting();		
        return;	
    } 
	else if(m_bSurrenderWait)		
	{
		PlaySurrender();
		return;	
	} 
	// -----End MissionPack1
	*/

	if(bIsCrouched)				
	{		
	    PlayCrouchWaiting();		
	    return;	
	}
	if(m_bIsProne)				
	{
	    PlayProneWaiting();			
	    return;
	}

	if(!m_bNightVisionAnimation)
		m_ePlayerIsUsingHands = HANDS_None;

    if(m_fPeeking != C_fPeekMiddleMax || isPeeking() || (m_u8CurrentYaw != 0))
	{
        // fix to prevent peeking throu walls
        if ( bIsCrouched != bWasCrouched )
            m_bTweenFirstTimeOnly = true;

        if ( m_bTweenFirstTimeOnly )
        {
            // set the peek anim
            PlayPeekingAnim( true );
            m_bTweenFirstTimeOnly = false;
            R6PlayAnim('StandWaitBreathe');
        }
        else
            PlayAnim('StandWaitBreathe'); 	
    
        return;
    }

	// if this is a player, or when bone control is used on an NPC, we should use a very simple/basic wait animation
	if(m_bIsPlayer || (m_TrackActor != none) || m_bIsSniping)
	{		
		if(EngineWeapon != none)
			R6PlayAnim('StandWaitBreathe'); 	
		else
			R6PlayAnim('StandSubGunHigh_nt');
		return; 
	}

	SetRandomWaiting(12);
	switch(m_bRepPlayWaitAnim)
	{
		case 0:  R6PlayAnim('StandWaitBreathe');         break;
		case 1:  R6PlayAnim('StandWaitCrackNeck');       break;
		case 2:  R6PlayAnim('StandWaitLookAround01');    break;
		case 3:  R6PlayAnim('StandWaitLookAround02');    break;
		case 4:  R6PlayAnim('StandWaitLookBack01');      break;
		case 5:  R6PlayAnim('StandWaitLookBack02');      break;
		case 6:  R6PlayAnim('StandWaitLookWatch');       break;	//HANDS_Left
		case 7:  R6PlayAnim('StandWaitScratchNose');     break;	//HANDS_Left
		case 8:  R6PlayAnim('StandWaitShiftWeight');     break;
		case 9:	 R6PlayAnim('StandWaitUpDown01');        break;
		case 10: R6PlayAnim('StandWaitUpDown02');        break;
		default: R6PlayAnim('StandWaitWipeFace');        break;	//HANDS_Left
	}

//	if(!IsStationary())
//		m_ePlayerIsUsingHands = HANDS_None;
}

simulated event SetAnimAction(name NewAction)
{
    AnimAction = NewAction;
    AnimBlendParams(C_iWeaponRightAnimChannel, 1, 0.2, 0, 'R6 Spine2');
    PlayAnim(NewAction, 1.0, 0, C_iWeaponRightAnimChannel);
}

simulated function StopPeeking()
{
	if(m_ePeekingMode == PEEK_full)
		SetPeekingInfo(PEEK_none, C_fPeekMiddleMax);
}

// special case - to reset peeking instantly (no transition)
// used when player switches control to an NPC who is currently peeking

simulated function ClientQuickResetPeeking()
{
    SetPeekingInfo(PEEK_none, C_fPeekMiddleMax);
    SetCrouchBlend( 0 );
}

/*
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
											CROUCH FUNCTIONS
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/

event EndCrouch(float fHeight)
{
	Super.EndCrouch(fHeight);
	EndKneeDown();
}

simulated function PlayDuck()
{
    PlayCrouchWaiting();
}

simulated function BlendKneeOnGround()
{
	if(m_bPostureTransition)
		return;

	AnimBlendParams(C_iBaseBlendAnimChannel, 1.0, 0.0, 0.0, 'R6 R Thigh');  
	LoopAnim('Kneel_nt', 1.0, 0.2, C_iBaseBlendAnimChannel);
}

simulated function EndKneeDown()
{
	// the only purpose for doing this is to make sure that there is another animation presetn in this channel, 
	// so that the next time we go crouched, it does not ignore the tween time...
	PlayAnim('CrouchSubGunLow_nt', 1.0, 0.2, C_iBaseBlendAnimChannel);  
	AnimBlendToAlpha(C_iBaseBlendAnimChannel, 0.0, 0.5);
}

event StartCrouch(float HeightAdjust)
{
    Super.StartCrouch( HeightAdjust );
}

simulated function PlayCrouchWaiting()
{
	if(physics == PHYS_Falling)
	{
		PlayFalling();
		return;
	}

	if(!m_bNightVisionAnimation)
		m_ePlayerIsUsingHands = HANDS_None;
	
	if ( m_fPeeking != C_fPeekMiddleMax || isPeeking() )
    {   
        // fix to prevent peeking throu walls
        if ( bIsCrouched != bWasCrouched )
            m_bTweenFirstTimeOnly = true;

        if ( m_bTweenFirstTimeOnly )
        {
            // set the peek anim
            PlayPeekingAnim( true );
            m_bTweenFirstTimeOnly = false;
            R6PlayAnim('CrouchWaitBreathe01');
        }
        else
            PlayAnim('CrouchWaitBreathe01');

        return;
    }

    if(m_bIsPlayer || (m_TrackActor != none) || m_bIsSniping)
        R6PlayAnim('CrouchWaitBreathe01');
	else
    {
		SetRandomWaiting(5);
		switch(m_bRepPlayWaitAnim)
		{
			case 0:  R6PlayAnim('CrouchWaitBreathe01');     break;
			case 1:  R6PlayAnim('CrouchWaitBreathe02');     break;
			case 2:  R6PlayAnim('CrouchWaitCrackNeck');     break;
			case 3:  R6PlayAnim('CrouchWaitLookWatch');     break;	//HANDS_Left
			default: R6PlayAnim('CrouchWaitLookUp');   
		}
	}

	// blend knee down... 
	if(physics != PHYS_RootMotion && m_eEquipWeapon != EQUIP_NoWeapon)
		BlendKneeOnGround();   //-- works but does not reset alpha to zero when we begin to move....
}

/*
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
											PRONE FUNCTIONS
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/
simulated function PlayProneWaiting()
{
	if(m_bIsPlayer || (m_TrackActor != none) || m_bIsSniping)
	{
		if(engineWeapon == none)
			R6LoopAnim('ProneWaitBreathe');
        else if(EngineWeapon.m_eWeaponType == WT_LMG)
		    R6LoopAnim('ProneBipodLMGBreathe');
        else if(EngineWeapon.m_eWeaponType == WT_Sniper)
		    R6LoopAnim('ProneBipodSniperBreathe');
        else
		    R6LoopAnim('ProneWaitBreathe');
	}
	else
    {
        SetRandomWaiting(3);
        switch(m_bRepPlayWaitAnim)
		{
			case 0:  
				if(engineWeapon == none)
					R6LoopAnim('ProneWaitBreathe');	 
                else if(EngineWeapon.m_eWeaponType == WT_LMG)
		            R6LoopAnim('ProneBipodLMGBreathe');
                else if(EngineWeapon.m_eWeaponType == WT_Sniper)
		            R6LoopAnim('ProneBipodSniperBreathe');
                else
                    R6LoopAnim('ProneWaitBreathe');	 
                break;
			case 1:  
                R6LoopAnim('ProneWaitCrackNeck');	 
                break;
			default:  
                R6LoopAnim('ProneWaitLookAround'); 
		}
	}
}

function Rotator GetFiringRotation()
{
    local R6RainbowAI ai;

    if(m_bIsPlayer)
    {
        #ifdefDEBUG if(bShowLog) log("Get Firing Rotation Contrl Rot : "$controller.rotation$" Rot Offset "$m_rRotationOffset);	#endif
        return GetViewRotation();
    }

    ai = R6RainbowAI(controller);

	if(EngineWeapon.m_eWeaponType == WT_Grenade)
    {
        if ( ai.m_vLocationOnTarget != vect(0,0,0) )
			return ai.GetGrenadeDirection( none, ai.m_vLocationOnTarget );
        else
            return controller.rotation;
    }

	return m_rFiringRotation;
}

simulated function BOOL HasPawnSpecificWeaponAnimation()
{
	if( m_eEquipWeapon == EQUIP_EquipWeapon || m_eEquipWeapon == EQUIP_SecureWeapon )
		return true;

	return false;
}

/////////////////////////////////////////////////////////////////////////////
//							NOTIFICATIONS
/////////////////////////////////////////////////////////////////////////////
simulated function BoltActionSwitchToLeft()
{
    m_bReAttachToRightHand = true;
	AttachWeapon(EngineWeapon, 'TagBoltRifle');
}

simulated function BoltActionSwitchToLeftProne()
{
    m_bReAttachToRightHand = true;
    AttachWeapon(EngineWeapon, 'TagBipodBoltRifle');
}

simulated function BoltActionSwitchToRight()
{
    m_bReAttachToRightHand = false;
	AttachWeapon(EngineWeapon, 'TagRightHand');
}

simulated function SecureWeapon()
{
	m_bWeaponTransition=false;
	if(m_eEquipWeapon == EQUIP_EquipWeapon)
	{
		m_eEquipWeapon = EQUIP_Armed;
		PlayWeaponAnimation();
		return;
	}

	if(EngineWeapon != none)
		AttachWeapon(EngineWeapon, EngineWeapon.m_HoldAttachPoint);
	m_eEquipWeapon = EQUIP_NoWeapon;
}

simulated function EquipWeapon()
{
	if(m_eEquipWeapon == EQUIP_SecureWeapon)
		return;

    if((EngineWeapon.m_eWeaponType == WT_Pistol) || (EngineWeapon.m_eWeaponType == WT_Gadget))
	{
		// attach immediately to right hand
		AttachWeapon(EngineWeapon, EngineWeapon.m_AttachPoint);
	}
	else
	{
		// attach to left hand first
		AttachWeapon(EngineWeapon, 'TagLeftHand');
	}
}

// this notification is only called for all weapons except handguns, and gadgets
simulated function EquipHands()
{
	if(m_eEquipWeapon == EQUIP_EquipWeapon)
	{
		// switch weapon from left hand to right 
		AttachWeapon(EngineWeapon, EngineWeapon.m_AttachPoint);
	}
	else if(m_eEquipWeapon == EQUIP_SecureWeapon)
	{
		// switch from right hand to left 
		AttachWeapon(EngineWeapon, 'TagLeftHand');
	}
}

function FinishedReloadingWeapon()
{
	if(controller == none)
		return;

	// if rainbow is not currently engaging, reload until full...
	if(engineWeapon.IsPumpShotGun() && (controller.enemy == none) && !engineWeapon.GunIsFull() && (engineWeapon.GetNbOfClips() > 0))
		R6RainbowAI(controller).RainbowReloadWeapon();
	else
		m_bReloadToFullAmmo = false;
}

simulated function BOOL GetNormalWeaponAnimation( out STWeaponAnim stAnim )
{
	if(m_bPlayingComAnimation)
		return false;
		
    stAnim.bBackward = false;
    stAnim.bPlayOnce = false;

	if(m_bIsFiringWeapon > 0)
		stAnim.fTweenTime = 0.f;
	else
		stAnim.fTweenTime = 0.1;	// rbrek todo : maybe for SP use 0.3 - looks more natural
    stAnim.fRate = 1.0;

	if(IsUsingHeartBeatSensor())
		stAnim.nBlendName='R6 Spine2'; 
	else
		stAnim.nBlendName='R6 R Clavicle';

    if(m_bIsProne)
    {
        if(EngineWeapon!=none && R6AbstractWeapon(EngineWeapon).m_BipodGadget == none)
            stAnim.nAnimToPlay = EngineWeapon.GetProneWaitAnimName();
        else
        {
            //If weapon has a bipod, don't play hands anims.
            m_ePlayerIsUsingHands = HANDS_Both;
            return false;
        }
    }
    else
    {
		if( m_eEquipWeapon == EQUIP_NoWeapon || EngineWeapon==none )
			stAnim.nAnimToPlay = 'StandNoGun_nt';
        else if(m_bUseHighStance)
            stAnim.nAnimToPlay = EngineWeapon.GetHighWaitAnimName();
        else
            stAnim.nAnimToPlay = EngineWeapon.GetWaitAnimName();
    }

    return true;
}

//============================================================================
// function GetFireWeaponAnimation - 
//============================================================================
simulated function BOOL GetFireWeaponAnimation( out STWeaponAnim stAnim )
{
    stAnim.bBackward = false;
    stAnim.bPlayOnce = true;
    stAnim.fRate = 1.5;
    stAnim.fTweenTime = 0.05;	
	stAnim.nBlendName='R6 R Clavicle';

    if(m_bIsProne)  
        stAnim.nAnimToPlay = EngineWeapon.GetProneFiringAnimName();
    else
        stAnim.nAnimToPlay = EngineWeapon.GetFiringAnimName();
    
    return true;
}

//============================================================================
// function GetReloadAnimation - 
//============================================================================
simulated function BOOL GetReloadWeaponAnimation( out STWeaponAnim stAnim )
{
    if(m_bIsProne)
    {
        if(EngineWeapon.NumberOfBulletsLeftInClip() != 0)
        {
            stAnim.nAnimToPlay = EngineWeapon.GetProneReloadAnimTacticalName();
        }
        else
        {
            stAnim.nAnimToPlay = EngineWeapon.GetProneReloadAnimName();
        }
    }
    else
    {
        if(EngineWeapon.NumberOfBulletsLeftInClip() != 0)
        {
            stAnim.nAnimToPlay = EngineWeapon.GetReloadAnimTacticalName();
        }
        else
        {
            stAnim.nAnimToPlay = EngineWeapon.GetReloadAnimName();
        }
    }

    if(stAnim.nAnimToPlay == m_WeaponAnimPlaying)
    {
        return false;
    }

    m_bWeaponTransition = true;
    m_ePlayerIsUsingHands = HANDS_None;

    stAnim.bBackward = false;
    stAnim.bPlayOnce = true;
    stAnim.fRate = m_fReloadSpeedMultiplier;
    stAnim.fTweenTime = 0.1;
    stAnim.nBlendName='R6 Spine2';

    return true;
}

//============================================================================
// function GetChangeWeaponAnimation - 
//============================================================================
simulated function BOOL GetChangeWeaponAnimation( out STWeaponAnim stAnim )
{
    m_bWeaponTransition = true;
    m_WeaponAnimPlaying = 'None';
    
    stAnim.bBackward = false;
    stAnim.bPlayOnce = true; 
    stAnim.fRate = ArmorSkillEffect() * 2.5 * m_fGunswitchSpeedMultiplier;
    stAnim.fTweenTime = 0.1;
    stAnim.nBlendName = 'R6 Spine2';

    //Function was called and Rainbow is dead
    if(EngineWeapon == none)
        return false;
    
    #ifdefDEBUG if (bShowLog) log("Get change Weapon Anim EW : "$EngineWeapon$" PW = "$PendingWeapon$" SW : "$m_preSwitchWeapon);	#endif
    if( PendingWeapon == none)
    {
        m_bPreviousAnimPlayOnce = false;
        stAnim.nAnimToPlay = m_WeaponAnimPlaying;
        m_eLastUsingHands = m_ePlayerIsUsingHands;
        return true;
    }

    SendPlaySound(EngineWeapon.m_UnEquipSnd, SLOT_SFX, true);

    // adjust fRate based on armor effect...        
    switch(EngineWeapon.m_eWeaponType)
    {
        case WT_Grenade:
        case WT_Gadget:
            #ifdefDEBUG if(bShowLog) log("Current Weapon: Grenade");	#endif
            switch(PendingWeapon.m_eWeaponType)
            {
                case WT_Sub:
                case WT_Sniper:
                case WT_LMG:
                case WT_ShotGun:
                case WT_Assault:
                    if(bIsCrouched)
                        stAnim.nAnimToPlay = 'CrouchSubGunToGrenade';
                    else if(m_bIsProne)
                    {
                        if(PendingWeapon.GotBipod())
                            stAnim.nAnimToPlay = 'ProneBipodSubGunToGrenade';
                        else
                            stAnim.nAnimToPlay = 'ProneSubGunToGrenade';
                    }
                    else
                        stAnim.nAnimToPlay = 'StandSubGunToGrenade';
                    stAnim.bBackward = true;
                    break;

                case WT_Pistol:
                    if(m_bIsProne)
                        stAnim.nAnimToPlay = 'ProneHandGunToGrenade';
                    else
                        stAnim.nAnimToPlay = 'StandHandGunToGrenade';
                    stAnim.bBackward = true;
                    break;

                case WT_Gadget:// By default and when is the gadget we use the grenade to grenade anim.
                    
                default: // Not Suppose to be Here
                    if(m_bIsProne)
                        stAnim.nAnimToPlay = 'ProneGrenadeChange';
                    else
                        stAnim.nAnimToPlay = 'StandGrenadeChange';
                    break;
            }
            break;
        case WT_Pistol:
            #ifdefDEBUG if(bShowLog) log("Current Weapon: Handgun");	#endif
            switch (PendingWeapon.m_eWeaponType)
            {
                case WT_Sub:
                case WT_Sniper:
                case WT_LMG:
                case WT_ShotGun:
                case WT_Assault:
                    if(bIsCrouched)
                        stAnim.nAnimToPlay = 'CrouchSubGunToHandGun';
                    else if(m_bIsProne)
                    {
                        if(PendingWeapon.GotBipod())
                            stAnim.nAnimToPlay = 'ProneBipodSubGunToHandGun';
                        else
                            stAnim.nAnimToPlay = 'ProneSubGunToHandGun';
                    }
                    else
                        stAnim.nAnimToPlay = 'StandSubGunToHandGun';
                    stAnim.bBackward = true;
                    break;

                case WT_Grenade:
                case WT_Gadget:
                    if(bIsCrouched)
                        stAnim.nAnimToPlay = 'CrouchHandGunToGrenade';
                    else if(m_bIsProne)
                        stAnim.nAnimToPlay = 'ProneHandGunToGrenade';
                    else
                        stAnim.nAnimToPlay = 'StandHandGunToGrenade';
                    break;
            }
            break;

        case WT_Sub:
        case WT_Sniper:
        case WT_LMG:
        case WT_ShotGun:
        case WT_Assault:
            #ifdefDEBUG if(bShowLog) log("Current Weapon: SubGun");		#endif
            switch( PendingWeapon.m_eWeaponType )
            {
                case WT_Pistol:
                    if(bIsCrouched) 
                        stAnim.nAnimToPlay = 'CrouchSubGunToHandGun';
                    else if(m_bIsProne)
                    {
                        if(EngineWeapon.GotBipod())
                            stAnim.nAnimToPlay = 'ProneBipodSubGunToHandGun';
                        else
                            stAnim.nAnimToPlay = 'ProneSubGunToHandGun';
                    }
                    else
                        stAnim.nAnimToPlay = 'StandSubGunToHandGun';
                    break;  

                case WT_Grenade:
                case WT_Gadget:
                    if(bIsCrouched)
                        stAnim.nAnimToPlay = 'CrouchSubGunToGrenade';
                    else if(m_bIsProne)
                    {
                        if(EngineWeapon.GotBipod())
                            stAnim.nAnimToPlay = 'ProneBipodSubGunToGrenade';
                        else
                            stAnim.nAnimToPlay = 'ProneSubGunToGrenade';
                    }
                    else
                        stAnim.nAnimToPlay = 'StandSubGunToGrenade';
                    break;

                default:
                    if(m_bIsProne)
                        stAnim.nAnimToPlay = 'ProneGrenadeChange';
                    else
                        stAnim.nAnimToPlay = 'StandGrenadeChange';
                    break;
            }
            break;
    }
    return true;
}

//============================================================================
// function GetThrowGrenadeAnimation - 
//  . for grenade animations that play on clavicle (except for PullPin) we 
//    don't want to play the animation on both arms because this will result
//    in the animation notifications being called twice
//============================================================================
simulated function BOOL GetThrowGrenadeAnimation( out STWeaponAnim stAnim )
{
    m_bWeaponTransition = true;

    stAnim.bBackward = false;
    stAnim.bPlayOnce = true;
    stAnim.fRate = ArmorSkillEffect();
    stAnim.fTweenTime = 0.1;
    stAnim.nBlendName='R6 R Clavicle';
	m_bThrowGrenadeWithLeftHand = false;

    
    if (Level.NetMode != NM_DedicatedServer)
    {
        if ((R6PlayerController(Controller) == none) || !R6PlayerController(controller).Player.IsA('Viewport'))
        {
            if (m_eGrenadeThrow == GRENADE_RemovePin)
                PlaySound(EngineWeapon.m_ReloadSnd, SLOT_SFX);
            else
                PlaySound(EngineWeapon.m_BurstFireStereoSnd, SLOT_SFX);
        }
    }

    switch(m_eGrenadeThrow)
    {
        case GRENADE_Throw:
            if(m_bIsProne)  
                stAnim.nAnimToPlay = 'ProneThrowGrenade';
            else
                stAnim.nAnimToPlay = 'StandThrowGrenade';
            break;  
        case GRENADE_Roll:
            if(m_bIsProne) 
                stAnim.nAnimToPlay = 'ProneRollGrenade';
            else
                stAnim.nAnimToPlay = 'StandRollGrenade';
            break;
        case GRENADE_RemovePin:
            if(m_bIsProne) 
                stAnim.nAnimToPlay = 'PronePullPin';
            else
                stAnim.nAnimToPlay = 'StandPullPin';
            break;
        case GRENADE_PeekLeft:
			if(!m_bIsPlayer)
			{
				stAnim.nBlendName = 'R6 Spine';
				stAnim.fTweenTime = 0.5;
			}
			m_bThrowGrenadeWithLeftHand = true;
            stAnim.nAnimToPlay = 'PeekLeftRollGrenade';            
            break;
		case GRENADE_PeekLeftThrow:
			if(!m_bIsPlayer)
			{
				stAnim.nBlendName = 'R6 Spine';
				stAnim.fTweenTime = 0.5;
			}
			m_bThrowGrenadeWithLeftHand = true;
			stAnim.nAnimToPlay = 'PeekLeftThrowGrenade';
			break;
        case GRENADE_PeekRight:
            if(!m_bIsPlayer)
			{
				stAnim.nBlendName = 'R6 Spine';
				stAnim.fTweenTime = 0.5;
			}
			stAnim.nAnimToPlay = 'PeekRightRollGrenade';            
            break;
		case GRENADE_PeekRightThrow:
			if(!m_bIsPlayer)
			{
				stAnim.nBlendName = 'R6 Spine';
				stAnim.fTweenTime = 0.5;
			}
			stAnim.nAnimToPlay = 'PeekRightThrowGrenade';
			break;
    }

    if(stAnim.nAnimToPlay == m_WeaponAnimPlaying)
    {
        return false;
    }
    
    m_eGrenadeThrow = GRENADE_None;
    return true;
}

//============================================================================
// function GetPawnSpecificAnimation - 
//============================================================================
simulated function BOOL GetPawnSpecificAnimation( out STWeaponAnim stAnim )
{
    m_bWeaponTransition = true;
    m_bWeaponIsSecured = false;
	m_WeaponAnimPlaying = 'None';
    stAnim.bPlayOnce = true;
    stAnim.fRate = ArmorSkillEffect() * 1.5;
	stAnim.fTweenTime = 0.1;
    stAnim.nBlendName = 'R6 Spine2';
	stAnim.bBackward = false;

	#ifdefDEBUG if(bShowLog) log(self$" : GetEquipingWeaponAnimation()  m_eEquipWeapon="$m_eEquipWeapon);	#endif
	m_ePlayerIsUsingHands = HANDS_None;
	switch(EngineWeapon.m_eWeaponType)
	{
		case WT_Sub:
		case WT_Sniper:
		case WT_LMG:
		case WT_ShotGun:
		case WT_Assault:
			stAnim.nAnimToPlay = 'StandSubGun_b';
			break;

		case WT_Pistol:
			stAnim.nAnimToPlay = 'StandHandGun_b';
			break;

		case WT_Gadget:          
		default: 
			stAnim.nAnimToPlay = 'StandGrenade_b';
			break;		
	}
		
	if( m_eEquipWeapon == EQUIP_SecureWeapon )
	{
        SendPlaySound(EngineWeapon.m_UnEquipSnd, SLOT_SFX, true);
		m_bWeaponIsSecured = true;
		stAnim.bBackward = true;
	}
    else
    {
        SendPlaySound(EngineWeapon.m_EquipSnd, SLOT_SFX, true);
    }

    return true;
}

simulated function GetWeapon(R6AbstractWeapon NewWeapon)
{
    #ifdefDEBUG if(bShowLog) log("IN: GetWeapon() engineWeapon="$engineWeapon$" newWeapon="$NewWeapon);	#endif
    // Check if the weapon is not the current weapon
	if (NewWeapon != EngineWeapon)
	{
        if (Level.NetMode!=NM_Client)
            m_pBulletManager.SetBulletParameter( NewWeapon );

		// Check if the have current weapon
		if (EngineWeapon != None)
		{
            EngineWeapon.DisableWeaponOrGadget();

            //Turn the gadget off when switching weapons
            if(m_bWeaponGadgetActivated == true)
            {
                m_bWeaponGadgetActivated = false;
                R6AbstractWeapon(EngineWeapon).m_SelectedWeaponGadget.ActivateGadget(FALSE);
            }
            
            PendingWeapon = NewWeapon;		
			if(!m_bIsPlayer)
				m_bChangingWeapon = true;
        }
    }
    #ifdefDEBUG if(bShowLog) log("OUT: GetWeapon() engineWeapon="$engineWeapon$" pendingWeapon="$NewWeapon);	#endif
}

// The same animation is use for both "SubGun to HandGun" and "HandGun to Subgun" transition
// We have to check the current weapon state to know which transition we are doing
simulated function SubToHand_Step1()
{
    m_preSwitchWeapon = EngineWeapon;

    #ifdefDEBUG if(bShowLog) log("IN: SubToHand_Step1, EW= "$EngineWeapon$" PW= "$PendingWeapon$" SW= "$m_preSwitchWeapon);	#endif

    //Function was called and Rainbow is dead
    if(EngineWeapon == none)
        return;

	if(R6AbstractWeapon(EngineWeapon).m_bHiddenWhenNotInUse)
		EngineWeapon.bHidden = true;

    switch(EngineWeapon.m_eWeaponType)
    {
        case WT_Pistol:
        case WT_Gadget:
        case WT_Grenade:
            AttachWeapon(EngineWeapon, EngineWeapon.m_HoldAttachPoint);
            switch(PendingWeapon.m_eWeaponType)
            {
                case WT_Pistol:
                case WT_Gadget:
                case WT_Grenade:
                    break;

                case WT_Sub:
                case WT_Assault:
                case WT_ShotGun:
                case WT_Sniper:
                case WT_LMG:
                    AttachWeapon(PendingWeapon, 'TagLeftHand');
                    break;
            }
            break;
        case WT_Sub:
        case WT_Assault:
        case WT_ShotGun:
        case WT_Sniper:
        case WT_LMG:
            AttachWeapon(EngineWeapon, 'TagLeftHand');
            break;
    }
	
    #ifdefDEBUG if(bShowLog) log("OUT: SubToHand_Step1");	#endif
}

simulated function SubToHand_Step2()
{
    #ifdefDEBUG if(bShowLog) log("IN: SubToHand_Step2, EW= "$EngineWeapon$" PW= "$PendingWeapon$" SW= "$m_preSwitchWeapon);	#endif
	   
    //Function was called and Rainbow is dead
    if(EngineWeapon == none)
        return;

	PendingWeapon.bHidden = false;
    SendPlaySound(PendingWeapon.m_EquipSnd, SLOT_SFX, true);

#ifdefDEBUG 
    if (bShowLog) 
    {
        log("SubToHand_Step2: m_preSwitchWeapon ="$m_preSwitchWeapon$" attachpoint = "$m_preSwitchWeapon.m_HoldAttachPoint);
        log("SubToHand_Step2: EngineWeapon ="$EngineWeapon$" attachpoint = "$ EngineWeapon.m_HoldAttachPoint);
        log("SubToHand_Step2: PendingWeapon ="$PendingWeapon$" attachpoint = "$ PendingWeapon.m_AttachPoint);
    }
#endif

    if (m_preSwitchWeapon!=none)
    {
        AttachWeapon(m_preSwitchWeapon, m_preSwitchWeapon.m_HoldAttachPoint);
        if(Level.NetMode != NM_DedicatedServer)
        {
            //turn off emitters that are not used.
            m_preSwitchWeapon.TurnOffEmitters(true);
        }
        m_preSwitchWeapon=none;
    }
    else
    {
        AttachWeapon(EngineWeapon, EngineWeapon.m_HoldAttachPoint);
        if(Level.NetMode != NM_DedicatedServer)
        {
            //turn off emitters that are not used.
            EngineWeapon.TurnOffEmitters(true);
        }
    }
    AttachWeapon(PendingWeapon, PendingWeapon.m_AttachPoint);

    if (Level.NetMode != NM_DedicatedServer)
    {
        //turn on emitters.
        PendingWeapon.TurnOffEmitters(false);
    }

    #ifdefDEBUG if (bShowLog) log("OUT: SubToHand_Step2");	#endif
}

// this function must be move in R6Pawn.
function ChangingWeaponEnd()
{
    #ifdefDEBUG if (bShowLog) log("IN: ChangingWeaponEnd, EW= "$EngineWeapon$" PW= "$PendingWeapon$" SW= "$m_preSwitchWeapon);	#endif
    
    //Function was called and Rainbow is dead
    if(EngineWeapon == none)
        return;

    if ((Level.NetMode != NM_Standalone) && (!bNetOwner) && (Role != ROLE_Authority))
    {
        #ifdefDEBUG if (bShowLog) log("OUT: ChangingWeaponEnd EARLY!!! 1");		#endif
        return;
    }
    
    m_bChangingWeapon = FALSE;
   
    if(Controller.IsA('R6PlayerController') && (R6PlayerController(Controller).bBehindView == false) && (Level.Netmode == NM_Standalone))
    {
        // If in first person view, get out!!!
        #ifdefDEBUG if (bShowLog) log("OUT: ChangingWeaponEnd EARLY!!! 2");		#endif
        return;
    }

    #ifdefDEBUG if(bShowLog) log("Notify ChangingWeaponEnd "$EngineWeapon$" : "$PendingWeapon);	#endif

    EngineWeapon = PendingWeapon;
    
    if (Level.NetMode == NM_Standalone)
    {
        PendingWeapon = None;
    }

	#ifdefDEBUG if(bShowLog) log("OUT: ChangingWeaponEnd: Weapon State: " $ EngineWeapon.GetStateName());	#endif
}

function ChangeProneAttach()
{
    //TagBackProne is only for weapon carried ZERO
    if(m_WeaponsCarried[0] != none)
    {
        if(m_WeaponsCarried[0].m_HoldAttachPoint == m_WeaponsCarried[0].Default.m_HoldAttachPoint)
        {
            #ifdefDEBUG if(bShowLog) log("changing "$m_WeaponsCarried[0]$" TO TagBackProne");	#endif
            m_WeaponsCarried[0].m_HoldAttachPoint = 'TagBackProne';
        }
        else
        {
            #ifdefDEBUG if(bShowLog) log("changing "$m_WeaponsCarried[0]$" TO "$m_WeaponsCarried[0].Default.m_HoldAttachPoint);	#endif
            m_WeaponsCarried[0].m_HoldAttachPoint = m_WeaponsCarried[0].Default.m_HoldAttachPoint;
        }

        if(m_WeaponsCarried[0] != EngineWeapon)
        {
            //Change weapon attachment
            AttachWeapon(m_WeaponsCarried[0], m_WeaponsCarried[0].m_HoldAttachPoint);
        }
    }
}

event R6QueryCircumstantialAction( FLOAT fDistance, Out R6AbstractCircumstantialActionQuery Query, PlayerController playerController )
{ 
    // MPF1 check to optimize
	local R6Rainbow pInteractor; // MPF_Milan_7_15_2003 - optimization

    if ( class'Actor'.static.GetModMgr().IsMissionPack() )
    {
	    // ---------MissionPack1
	    if(Query.aQueryOwner.IsA('R6PlayerController') && Query.aQueryTarget.IsA('R6Rainbow') && IsAlive())
	    {
			pInteractor = (R6PlayerController(Query.aQueryOwner)).m_pawn; // MPF_Milan_7_15_2003 - optimization
		    if( m_bIsSurrended && !m_bIsUnderArrest && pInteractor.m_iTeam != R6Rainbow(Query.aQueryTarget).m_iTeam && 
			    !pInteractor.m_bIsSurrended && !pInteractor.m_bIsClimbingLadder) // MPF_Milan_7_15_2003 no interaction while climbing ladder
		    {
			    Query.iHasAction = 1;
			    if ( fDistance < m_fCircumstantialActionRange 
					&& abs(location.z - pInteractor.location.z) <110) // MPF_Milan_7_15_2003 - check also height before enabling arrest
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

			    Query.iPlayerActionID      = eRainbowCircumstantialAction.CAR_Secure;
			    Query.iTeamActionID        = eRainbowCircumstantialAction.CAR_Secure;
    
			    Query.iTeamActionIDList[0] = eRainbowCircumstantialAction.CAR_Secure;
			    Query.iTeamActionIDList[1] = eRainbowCircumstantialAction.CAR_None;
			    Query.iTeamActionIDList[2] = eRainbowCircumstantialAction.CAR_None;
			    Query.iTeamActionIDList[3] = eRainbowCircumstantialAction.CAR_None;
		    }
		    else if( m_bIsUnderArrest && pInteractor.m_iTeam == R6Rainbow(Query.aQueryTarget).m_iTeam 
				&& !pInteractor.m_bIsClimbingLadder) // MPF_Milan_7_15_2003 no interaction while climbing ladder
		    {
			    Query.iHasAction = 1;
			    if ( fDistance < m_fCircumstantialActionRange
					&& abs(location.z - pInteractor.location.z) <110) // MPF_Milan_7_15_2003 - check also height before enabling rescue
			    {
				    Query.iInRange = 1;
			    }
			    else
			    {
				    Query.iInRange = 0;
			    }
			    
			    Query.textureIcon = Texture'R6ActionIcons.FreeRainbow';
	    
			    Query.fPlayerActionTimeRequired = 0;
			    Query.bCanBeInterrupted = true;
	    
			    Query.iPlayerActionID      = eRainbowCircumstantialAction.CAR_Free;
			    Query.iTeamActionID        = eRainbowCircumstantialAction.CAR_Free;
		    
			    Query.iTeamActionIDList[0] = eRainbowCircumstantialAction.CAR_Free;
			    Query.iTeamActionIDList[1] = eRainbowCircumstantialAction.CAR_None;
			    Query.iTeamActionIDList[2] = eRainbowCircumstantialAction.CAR_None;
			    Query.iTeamActionIDList[3] = eRainbowCircumstantialAction.CAR_None;
		    }
		    else
			    Query.iHasAction = 0;
        } // end MissionPack1
	}
	else 
    {
        Query.iHasAction = 0;    
    }
}

// MPF1 
//-------------- MissionPack1

//============================================================================
// string R6GetCircumstantialActionString - 
//============================================================================
simulated function string R6GetCircumstantialActionString( INT iAction )
{
    
	switch( iAction )
    {
		case eRainbowCircumstantialAction.CAR_Secure:		return Localize("RDVOrder", "Order_Secure", "R6Menu");
		// TO DO: localize set free
		case eRainbowCircumstantialAction.CAR_Free:		return Localize("RDVOrder", "Order_Secure", "R6Menu");
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
    //m_fPlayerCAStartTime = Level.TimeSeconds;
	// variable m_fPlayerCAStartTime is defined in R6Terrorist class but it's not used
}


//============================================================================
// ResetArrest - 
//============================================================================
function ResetArrest()
{
	//if (!R6PlayerController(Controller).IsInState('PlayerSurrended'))
	//{
	#ifdefDEBUG if(bShowLog) log("*****ResetArrest");  #endif

		AnimBlendToAlpha( C_iPawnSpecificChannel, 0.0, 0.5 );
	    m_ePlayerIsUsingHands = HANDS_Both;
//    PlayWeaponAnimation();
//    m_bPawnSpecificAnimInProgress = false;		
		m_bIsUnderArrest = false;
		if(Level.NetMode == NM_Client)
			R6PlayerController(Controller).ServerStartSurrended();
		R6PlayerController(Controller).GotoState('PlayerSurrended');
		R6PlayerController(Controller).m_fStartSurrenderTime = Level.TimeSeconds;
		m_bIsBeingArrestedOrFreed = false;
		PlayWaiting();
	//}

}



function ServerSetCrouch(bool bCrouch) // MissionPack1 2
{
	bWantsToCrouch = bCrouch; 
}

function ClientSetCrouch(bool bCrouch) // MissionPack1 2
{
	bWantsToCrouch = bCrouch; 
}


//--------------- End MissionPack1
function bool HasBumpPriority( R6Pawn bumpedBy )
{
	if(R6RainbowAI(controller).m_TeamManager.m_bGrenadeInProximity)
		return true;

	// bumps into a member of another team (non player)
	if((m_iTeam != bumpedBy.m_iTeam) && !bumpedBy.m_bIsPlayer)
		return true;

	// check if bumpedBy is a pawn that has higher rank
    if( (bumpedBy.m_iId <= m_iId) && !bumpedBy.IsStationary() )
        return false;

    return true;
}

//-----------------------------------------------------------------//
// --                 Rainbow Skill Advancement                 -- //
// --   called at the end of a mission to update skill levels   -- //
// -- TODO : (x.5) add special clause for members that did not  -- //
// --        participate in this mission and were in training   -- //
// --        MOVE THIS TO NATIVE CODE LATER                     -- //
//-----------------------------------------------------------------//
function UpdateRainbowSkills()
{
    local INT iD5;
    local INT iD2;

    if ( !IsAlive() )    
        return; //this guys is dead


    if(m_szSpecialityID == "")
        return;             // this pawn has no speciality

    iD5 = rand(5) + 1; 
    iD2 = rand(2) + 1;

    // -- assault skill -- //
    if(m_szSpecialityID == "ID_ASSAULT")
    {
        m_fSkillAssault += (FLOAT(iD5+5)/100.f)*(1-m_fSkillAssault);
    }
    else
    {
        m_fSkillAssault += (FLOAT(iD2+2)/100.f)*(1-m_fSkillAssault);
    }

    // -- demolitions skill -- //
    if(m_szSpecialityID == "ID_DEMOLITIONS")
    {
        m_fSkillDemolitions += (FLOAT(iD5+5)/100.f)*(1-m_fSkillDemolitions);
    }
    else 
    {
        if(FRand() <= 0.2)
        {
            m_fSkillDemolitions += (0.02*(1-m_fSkillDemolitions));
        }
    }

    // -- electronics skill -- //
    if(m_szSpecialityID == "ID_ELECTRONICS")
    { 
        m_fSkillElectronics += (FLOAT(iD5+5)/100.f)*(1-m_fSkillElectronics);
    }
    else 
    {
        if(FRand() <= 0.2)
        {
            m_fSkillElectronics += (0.02*(1-m_fSkillElectronics));
        }
    }

    // -- stealth skill -- //
    if(m_szSpecialityID == "ID_RECON")
    {
        m_fSkillStealth += (FLOAT(iD5+5)/100.f)*(1-m_fSkillStealth);
    }
    else
    {
        if(FRand() <= 0.2)
        {
            m_fSkillStealth += (0.02*(1-m_fSkillStealth));
        }
    }

    // -- sniper skill -- //
    if(m_szSpecialityID == "ID_SNIPER")
    {
        m_fSkillSniper += (FLOAT(iD5+5)/100.f)*(1-m_fSkillSniper);
    }
    else
    {
        if(FRand() <= 0.2)
        {
            m_fSkillSniper += (0.02*(1-m_fSkillSniper));    
        }
    }

    // -- self control -- //
    if(FRand() <= 0.2)
    {
        m_fSkillSelfControl += (0.02*(1-m_fSkillSelfControl));
	}
    
    // -- leadership -- //
    if(FRand() <= 0.2)
    {
        m_fSkillLeadership += (0.02*(1-m_fSkillLeadership));
    }

    // -- observation -- //
    if(FRand() <= 0.2)
    {
        m_fSkillObservation += (0.02*(1-m_fSkillObservation));
    }
}

//============================================================================
// IsFighting: return true when the pawn is fighting
// - inherited
//============================================================================
function bool IsFighting()
{
    // cannot fight if incapacitated or dead
    if ( !IsAlive() )
        return false;

    if ( m_bIsFiringWeapon == 1) 
        return true;    
    
	if(controller.enemy != none)
		return true;

    return false;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
//									GRENADE FUNCTIONS
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
function GrenadeThrow()
{
	local INT iChannel;

    // logX("notification: GrenadeThrow EngineWeapon=" $EngineWeapon.name );
    iChannel = GetNotifyChannel();
	if(iChannel == C_iWeaponLeftAnimChannel)
		return; 

    if (Role == ROLE_Authority)
    {
        EngineWeapon.ThrowGrenade();
    }

    EngineWeapon.bHidden = TRUE;
}

function GrenadeAnimEnd()
{
    EngineWeapon.bHidden = FALSE;
    m_eGrenadeThrow = GRENADE_None;
    PlayWeaponAnimation();
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	
	// for ladder slide sound management
	if(m_bIsClimbingLadder && !bIsWalking && (acceleration.z < 0))
	{
		if(m_eLadderSlide == SLIDE_None)		
			StartSliding();
	}
	else if(m_eLadderSlide != SLIDE_None)
		EndSliding();
}

//------------------------------------------------------------------
// GetTeamMgr
//	
//------------------------------------------------------------------
function R6RainbowTeam GetTeamMgr()
{
    if ( controller == none )
        return none;

    if ( m_bIsPlayer )
        return R6PlayerController(controller).m_TeamManager;
    else
        return R6RainbowAI(controller).m_TeamManager;
}

//------------------------------------------------------------------
// Escort_GetPawnToFollow
//	
//------------------------------------------------------------------
function R6Rainbow Escort_GetPawnToFollow( OPTIONAL bool bRunningTowardMe )
{
    local R6RainbowTeam team;

    team = GetTeamMgr();
    if ( team != none )
        return team.Escort_GetPawnToFollow( self, bRunningTowardMe );
}

//------------------------------------------------------------------
// Escort_AddHostage
//	
//------------------------------------------------------------------
function bool Escort_AddHostage( R6Hostage hostage, OPTIONAL bool bNoFeedbackByHostage, OPTIONAL bool bOrderedByRainbow )
{
    local INT       i;
    local INT       totalR6;
    local INT       r6index;
    local INT       iSndIndex;

	if(hostage.m_bCivilian)//MissionPack1 // MPF1
		return false;

    i = 0;
    while ( i < ArrayCount(m_aEscortedHostage) && m_aEscortedHostage[i] != none )
    {
        // if the hostage is already in the list, break and keep the same index
        if ( m_aEscortedHostage[i] == hostage)
            break; 

        i++;
    }

    // if there's no empty spot. We should increase the array size?
    if ( i >= ArrayCount(m_aEscortedHostage)  )
    {
        #ifdefDEBUG if ( bShowLog ) log( "Warning: Escort_AddHostage failed to add the hostage");	#endif
        return false;
    }

    #ifdefDEBUG if ( bShowLog ) log( "Escort_AddHostage: " $hostage.name$ " index = " $i );	#endif

    // insert the hostage
    m_aEscortedHostage[i] = hostage;
    hostage.m_escortedByRainbow = self;

    Escort_UpdateTeamSpeed();
    Escort_UpdateList();

    if (!bNoFeedbackByHostage && hostage.IsAlive())
    {
        if ( m_bIsPlayer )
        {
            if ( bOrderedByRainbow )
            {
                if ( GetTeamMgr().m_PlayerVoicesMgr != none )
                    GetTeamMgr().m_PlayerVoicesMgr.PlayRainbowPlayerVoices(self, RPV_HostageFollow);
            }
            else
            {
                if ( GetTeamMgr().m_PlayerVoicesMgr != none )
                    GetTeamMgr().m_PlayerVoicesMgr.PlayRainbowPlayerVoices(self, RPV_HostageSafe);
            }
            if ( Controller != none )
                Controller.PlaySoundCurrentAction(RTV_EscortingHostage);
        }
        else
        {
            if ( bOrderedByRainbow )
            {
                if ( GetTeamMgr().m_MemberVoicesMgr != none )
                    GetTeamMgr().m_MemberVoicesMgr.PlayRainbowMemberVoices(self, RMV_HostageFollow);
            }
            else
            {
                if ( GetTeamMgr().m_MemberVoicesMgr != none )
                    GetTeamMgr().m_MemberVoicesMgr.PlayRainbowMemberVoices(self, RMV_HostageSafe);
            }
        }

        if (hostage.m_controller != none)
            hostage.m_controller.ProcessPlaySndInfo( hostage.m_mgr.HSTSNDEvent_FollowRainbow );
    }

    return true;
}

//------------------------------------------------------------------
// RemoveEscortedHostage: remove an hostage from the escort list,
//  update the escort list and call UpdateEscortList
//  return true is succesfull
//------------------------------------------------------------------
function bool Escort_RemoveHostage( R6Hostage hostage, OPTIONAL bool bNoFeedbackByHostage, OPTIONAL bool bOrderedByRainbow )
{
    local INT removeIndex;
    local INT escortIndex;
    local INT r6index;
    local INT iSndIndex;
    local R6RainbowTeam teamMgr;

    if ( hostage.m_escortedByRainbow == none )
        return false;

    removeIndex = 0;
    while ( removeIndex < ArrayCount(m_aEscortedHostage) && m_aEscortedHostage[removeIndex] != none )
    {
        // if it's the hostage
        if ( m_aEscortedHostage[removeIndex] == hostage )
            break; 

        ++removeIndex;

    }

    hostage.m_escortedByRainbow = none;

    // failed to find the hostage
    if ( removeIndex >= ArrayCount(m_aEscortedHostage) || m_aEscortedHostage[removeIndex] != hostage )
    {
        #ifdefDEBUG if ( bShowLog ) log( "Escort_RemoveHostage: failed to find the hostage" );	#endif
        return false;
    }

    #ifdefDEBUG if ( bShowLog ) log( "Escort_RemoveHostage: hostage = " $hostage.name$ " index=" $removeIndex );	#endif

    // offset everyone in the list one pos to the left
    escortIndex = removeIndex;
    while ( escortIndex < ArrayCount(m_aEscortedHostage) && m_aEscortedHostage[ escortIndex ] != none )
    {
        // if the last one, set to none
        if ( escortIndex == ArrayCount(m_aEscortedHostage) - 1 )
        {
            m_aEscortedHostage[ escortIndex ] = none;
        }
        else
        {
            m_aEscortedHostage[ escortIndex ] = m_aEscortedHostage[ escortIndex+1 ];
        }
        ++escortIndex;
    } 

    Escort_UpdateTeamSpeed();
    Escort_UpdateList();

    // if leader and the hostage is still alive
    if (hostage.isAlive() && !bNoFeedbackByHostage  )
    {
        teamMgr = GetTeamMgr();
        if (!hostage.m_bExtracted )
        {
            if ( bOrderedByRainbow )
            {
                if ( m_bIsPlayer )
                {
                    if ( teamMgr.m_PlayerVoicesMgr != none )
                        teamMgr.m_PlayerVoicesMgr.PlayRainbowPlayerVoices(self, RPV_HostageStay );
                }
                else
                {
                    if ( teamMgr.m_MemberVoicesMgr != none )
                        teamMgr.m_MemberVoicesMgr.PlayRainbowMemberVoices(self, RMV_HostageStay);
                }
            }

            if (hostage.m_controller != none)
                hostage.m_controller.ProcessPlaySndInfo( hostage.m_mgr.HSTSNDEvent_AskedToStayPut );
        }
        else
        {
            if ( Controller != none )
                Controller.PlaySoundCurrentAction(RTV_HostageSecured);
        }
    }

    return true;
}

//------------------------------------------------------------------
// Escort_UpdateCloserToLead
//	
//------------------------------------------------------------------
function Escort_UpdateCloserToLead()
{
    local R6HostageAI   closerAI, hostageAI; 
    local INT           index;
    local INT           searchIndex;
    local INT           nbEscortedHostage;
    local R6Hostage     hostage;
    local R6Hostage     aNewList[8];
    local float         fShortestDistance;
    local float         fDistance;
    local R6Hostage     closerToLead;

    closerToLead = m_aEscortedHostage[0];

    // check if the current closer to lead is close to him
    if ( closerToLead != none )
    {
        closerAI = R6HostageAI(closerToLead.controller);

        if ( closerAI.m_pawnToFollow != none) 
        {
            if ( VSize( closerAI.m_pawnToFollow.location - closerToLead.location) <= closerAI.c_iDistanceMax )
            {
                return; // ok, the closer to lead is close to him!
            }
            // if the lead is prone, check with is col box 2
            else if ( closerAI.m_pawnToFollow.m_eMovementPace == PACE_Prone )
            {
                if ( VSize( closerAI.m_pawnToFollow.m_collisionBox.location - closerToLead.location) <= closerAI.c_iDistanceMax )
                {
                    return; // ok, the closer to lead is close to him!
                }
            }
        }
    }

    // no escorted hostage, return
    if ( m_aEscortedHostage[0] == none  )
    {
        #ifdefDEBUG if(bShowLog) log( "UpdateCloserToLead: no lead OR no escorted hostage" );	#endif
        return;    
    }

    // find the closer hostage from the lead
    closerToLead = none;
    fShortestDistance = 999999; 
    index = 0;
    while ( index < ArrayCount(m_aEscortedHostage) && m_aEscortedHostage[index] != none )
    {
        fDistance = VSize( m_aEscortedHostage[index].location - location );

        if ( fDistance < fShortestDistance )
        {
            fShortestDistance = fDistance;
            closerToLead = m_aEscortedHostage[index];
        }

        // reset who he was following
        R6HostageAI(m_aEscortedHostage[index].controller).m_pawnToFollow = none;
        index++;
    }

    #ifdefDEBUG if(bShowLog) log( "Full update of the escort list of" $name );	#endif

    // update the escort list
    nbEscortedHostage = index;
    aNewList[0] = closerToLead;
    R6HostageAI(closerToLead.controller).m_pawnToFollow = self;
    index = 0;
    
    // search who is closed to this hostage and not already escorted
    while ( index < nbEscortedHostage - 1 ) // -1 cause the last one doesn't have a follower
    {
        hostage = none;
        fShortestDistance = 999999;
        for ( searchIndex = 0; searchIndex < nbEscortedHostage; searchIndex++ )
        {
            // if it's the same one 
            if ( m_aEscortedHostage[searchIndex] == aNewList[index] )
            {
                continue;
            }
            // if this hostage has already a followPawn setted
            else if ( R6HostageAI(m_aEscortedHostage[searchIndex].controller).m_pawnToFollow != none )
            {
                continue;
            }
            else
            {
                fDistance = VSize( m_aEscortedHostage[searchIndex].location - aNewList[index].location );
                
                if ( fDistance < fShortestDistance )
                {
                    fShortestDistance = fDistance;
                    hostage = m_aEscortedHostage[searchIndex];
                }
            }
        }

        // if found 
        if ( hostage != none )
        {
            // this hostage is the closet to aNewList[index]
            R6HostageAI(hostage.controller).m_pawnToFollow = aNewList[index];
            aNewList[index+1] = hostage;
        }
        index++;
    }

    // copy the new escort list and who follows who
    for ( index = 0; index < nbEscortedHostage; index++ )
    {
        m_aEscortedHostage[index] = aNewList[index];
    }
#ifdefDEBUG 
    // debug output 
    if(bShowLog)
    {
        index = 0;
        while ( index < ArrayCount(m_aEscortedHostage) && m_aEscortedHostage[index] != none )
        {
            log( "            " @index@ ": " @m_aEscortedHostage[index].name@ 
                              " follows " @R6HostageAI(m_aEscortedHostage[index].controller).m_pawnToFollow );
            index++;    
        }
        log( "EscortList: " @index@ " hostage(s) escorted" );
    }
#endif
}

//------------------------------------------------------------------
// Escort_UpdateList
//	- if leader is dead, it finds someone else to escort the hostage
//  - 
//------------------------------------------------------------------
function Escort_UpdateList()
{
    local int i, j;
    local R6HostageAI hostageAI;
    local R6Hostage   hostage;
    local R6Rainbow newLeadRainbow;
    local R6RainbowTeam teamMgr;

    if ( m_aEscortedHostage[0] == none ) 
        return;

    // log( "Escort_UpdateList: " $self.name$ " alive=" $IsAlive() );
    // if rainbow died, manage his list of escorted hostage
    if ( !IsAlive() )
    {
        // find another rainbow to escort
        newLeadRainbow = Escort_FindRainbow( m_aEscortedHostage[0] );
        if ( newLeadRainbow == none ) 
        {
            // log( "Escort_UpdateList: no more rainbow" ); 
            i = 0;
            while ( i < ArrayCount(m_aEscortedHostage) && m_aEscortedHostage[i] != none )
            {
                hostageAI = R6HostageAI(m_aEscortedHostage[i].controller);
                hostageAI.Order_StayHere( false );
                ++i;
            }
        }
        else
        {
            // from this rainbow, get the appropriate rainbow and copy the list
            newLeadRainbow = newLeadRainbow.Escort_GetPawnToFollow();
            // log( "Escort_UpdateList: copy the list to " $newLeadRainbow.name ); 
            i = 0;
            while ( i < ArrayCount(m_aEscortedHostage) && m_aEscortedHostage[i] != none )
            {
                hostage = m_aEscortedHostage[i];
                newLeadRainbow.Escort_AddHostage( hostage, true );
                m_aEscortedHostage[i] = none;
                ++i;
            }
        }

        return;
    }

    i = 0;
    while ( i < ArrayCount(m_aEscortedHostage) && m_aEscortedHostage[i] != none )
    {
        if ( !m_aEscortedHostage[i].isAlive() )
        {
            j = i;
            while ( j+1 < ArrayCount(m_aEscortedHostage) ) 
            {
                m_aEscortedHostage[j] = m_aEscortedHostage[j+1];
                j++;
            }
            m_aEscortedHostage[j] = none;
            continue;
        }
        i++;
    }

    Escort_UpdateCloserToLead();

    i = 0;
    while ( i < ArrayCount(m_aEscortedHostage) && m_aEscortedHostage[i] != none )
    {
        hostageAI = R6HostageAI(m_aEscortedHostage[i].controller);
        
        if ( i == 0 )   // the first hostage follows a rainbow
            hostageAI.m_pawnToFollow = self;
        else            // other hostage follow hostage
            hostageAI.m_pawnToFollow = m_aEscortedHostage[i-1];

        ++i;
    }
#ifdefDEBUG 
    // output 
    if ( bShowLog )
    {
        i = 0;
        while ( i < ArrayCount(m_aEscortedHostage) && m_aEscortedHostage[i] != none )
        {
            log( "            " @i@ ": " @m_aEscortedHostage[i].name@ 
                              " follows " @R6HostageAI(m_aEscortedHostage[i].controller).m_pawnToFollow );
            ++i;    
        }
        log( "Escort_UpdateList: " @i@ "hostage(s) escorted" );
    }
#endif
}

//------------------------------------------------------------------
// Escort_IsPawnCloseToMe: return true if there's a pawn in my radius
//
//------------------------------------------------------------------
function bool Escort_IsPawnCloseToMe( R6Hostage me, float fMyRadius )
{
    local INT   index;
    local R6Hostage h;
    local R6Rainbow rainbow;
    local bool bSeparated;
    local R6RainbowTeam team;
    
    index = 0;
    // check if some is close
    while ( index < ArrayCount(m_aEscortedHostage) && m_aEscortedHostage[index] != none )
    {
        h = m_aEscortedHostage[index];
        // if not me, distance is lesser
        if ( me != h && VSize(h.location - me.location) < fMyRadius )
        {
            return true;
        }
        else if ( h.m_eMovementPace == PACE_Prone )
        {
            if ( VSize( h.m_collisionBox.location - me.Location ) < fMyRadius )
            {
                return true;
            }
        }
        
        index++;
    }

    // check for rainbow in the team
    team = GetTeamMgr();
    if ( team == none ) // prevent accessed none: not suppossed to happen
        return true;
    
    bSeparated = team.m_bTeamIsSeparatedFromLeader;
    index = 0;
    while ( index < ArrayCount( team.m_Team ) && team.m_Team[index] != none )
    {
        rainbow = team.m_Team[index];
        
        // if separated from team, we only want to check slef
        if ( bSeparated && rainbow != self )
        {
            index++;
            continue;
        }

        if ( VSize( rainbow.location - me.location) < fMyRadius )
        {
            return true;
        }
        else if ( rainbow.m_eMovementPace == PACE_Prone )
        {
            if ( VSize( rainbow.m_collisionBox.location - me.Location ) < fMyRadius )
            {
                return true;
            }
        }

        index++;
    }

    return false;
}

//------------------------------------------------------------------
// Escort_UpdateTeamSpeed
//	
//------------------------------------------------------------------
function Escort_UpdateTeamSpeed()
{
    local R6RainbowTeam team;

    team = GetTeamMgr();
    if ( team != none )
        team.Escort_UpdateTeamSpeed();
}

//------------------------------------------------------------------
// Escort_FindRainbow
//	find a rainbow who is visible and close to me
//------------------------------------------------------------------
function R6Rainbow Escort_FindRainbow( R6Hostage hostage )
{
    local R6Pawn    p;
    local R6Hostage h;

    foreach VisibleActors( class'R6Pawn', p, hostage.sightRadius, hostage.location )
    {
        // not a friend and not alive
        if ( !(hostage.IsFriend( p ) && p.IsAlive()) )
        {
            continue;
        }

        if ( p.m_ePawnType == PAWN_Rainbow )
        {
            return R6Rainbow(p);
        }
        else if ( p.m_ePawnType == PAWN_Hostage )
        {
            // check who escort this hostage
            if ( h.m_escortedByRainbow != none && h.m_escortedByRainbow.isAlive() )
            {
                return h.m_escortedByRainbow;
            }
        }
    }
   
    return none;
}

//------------------------------------------------------------------
// ProcessBuildDeathMessage
//	return true if the build death msg can be build by "static BuildDeathMessage"
//------------------------------------------------------------------
function bool ProcessBuildDeathMessage( Pawn Killer, OUT string szPlayerName )
{
    if ( Level.NetMode != NM_Standalone ) // we don't want to process the deathmsg in single player
    {
        if ( Killer.m_ePawnType == PAWN_Terrorist )
        {
            m_bSuicideType = DEATHMSG_RAINBOW_KILLEDBYTERRO;
        }

        // AI who got kill by a rainbow, no msg
        if ( Killer.m_ePawnType == PAWN_Rainbow && !m_bIsPlayer )
            return false;
    }

    return Super.ProcessBuildDeathMessage( Killer, szPlayerName );
}


//------------------------------------------------------------------
// CanInteractWithObjects
//	MPF_Milan_7_1_2003 - ovverridden from R6Pawn for Mission pack - capture the enemy
//------------------------------------------------------------------
function bool CanInteractWithObjects()
{
    if( m_bIsProne 
        || m_bChangingWeapon 
        || m_bReloadingWeapon 
        || m_bIsFiringState 
		|| m_bIsSurrended // that's the difference 
        || Level.m_bInGamePlanningActive)
        return false;

    return true;
}

defaultproperties
{
     m_eLadderSlide=SLIDE_None
     m_eEquipWeapon=EQUIP_Armed
     m_iCurrentWeapon=1
     m_bTweenFirstTimeOnly=True
     m_bScaleGasMaskForFemale=True
     m_bInitRainbow=True
     m_GasMaskClass=Class'R6Engine.R6GasMask'
     m_NightVisionClass=Class'R6Engine.R6NightVision'
     m_szSpecialityID="ID_ASSAULT"
     m_eArmorType=ARMOR_Heavy
     m_bCanDisarmBomb=True
     m_bHasArmPatches=True
     m_fSkillAssault=0.850000
     m_fSkillDemolitions=0.850000
     m_fSkillElectronics=0.850000
     m_fSkillSniper=0.850000
     m_fSkillStealth=0.850000
     m_fSkillSelfControl=0.850000
     m_fSkillLeadership=0.850000
     m_fSkillObservation=0.850000
     m_fWalkingSpeed=250.000000
     m_fWalkingBackwardStrafeSpeed=100.000000
     m_fRunningSpeed=400.000000
     m_fRunningBackwardStrafeSpeed=250.000000
     m_fCrouchedWalkingSpeed=125.000000
     m_fCrouchedWalkingBackwardStrafeSpeed=50.000000
     m_fCrouchedRunningSpeed=250.000000
     m_fCrouchedRunningBackwardStrafeSpeed=100.000000
     m_fProneSpeed=65.000000
     m_fProneStrafeSpeed=35.000000
     m_fPeekingGoalModifier=0.350000
     m_ePawnType=PAWN_Rainbow
     m_iTeam=2
     bCanStrafe=True
     m_bMakesTrailsWhenProning=True
     PeripheralVision=0.170000
     MeleeRange=30.000000
     CrouchRadius=38.000000
     ControllerClass=Class'R6Engine.R6RainbowAI'
     CollisionRadius=38.000000
     CollisionHeight=80.000000
     m_fAttachFactor=0.909091
     Begin Object Class=KarmaParamsSkel Name=R6RainbowRagDoll
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
         Name="R6RainbowRagDoll"
     End Object
     KParams=KarmaParamsSkel'R6Engine.R6RainbowRagDoll'
     Skins(5)=Texture'R61stWeapons_T.Hands.R61stHands'
}
