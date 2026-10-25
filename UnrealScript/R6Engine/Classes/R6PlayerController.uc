//=============================================================================
//  R6PlayerController.uc : This is the Player Controller class for all Rainbow 6
//                          characters.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//    02 May 2001  Aristo Kolokathis        Added varibles for needed by R6Weapons
//    2001/07/24   Joel Tremblay            Add Shake view and Damage Attitude to
//  Note: if you make R6PlayerController native then you will need to take care so
//  that the names in eDefaultCircumstantialAction do not conflict with other enums
//=============================================================================

class R6PlayerController extends PlayerController
    native
    config(User);


struct STImpactShake
{
    var() INT    iBlurIntensity;
    var() FLOAT  fWaveTime;     //Time to wave
    var() FLOAT  fRollMax;      //Max Roll Angle ±(0-16384)
    var() FLOAT  fRollSpeed;    //Current Roll Speed 
    var() FLOAT  fReturnTime;   //Effect on character Position
};

// Camera mode used once player has died
enum eDeathCameraMode
{
    eDCM_FIRSTPERSON,
    eDCM_THIRDPERSON,
    eDCM_FREETHIRDPERSON,
    eDCM_GHOST,
    eDCM_FADETOBLACK
};

var					R6Rainbow			m_pawn;
var input			BYTE				m_bSpecialCrouch;
var input			BYTE				m_bSpeedUpDoor;
var input			BYTE				m_bPeekLeft;
var input			BYTE				m_bPeekRight;
var input           BYTE                m_bReloading;

var					BYTE				m_bOldPeekLeft;
var					BYTE				m_bOldPeekRight;

var config			INT					m_iDoorSpeed;
var config			INT					m_iFastDoorSpeed;
var config			INT					m_iFluidMovementSpeed;
var					FLOAT				m_fOxygeneLevel;
var					FLOAT				m_fCompteurFrameDetection;
var config			FLOAT				m_fTeamMoveToDistance;		// used for the 
var config          string              m_szLastAdminPassword;

// this is where we hardcode the walk, fastwalk and run speeds.
// these values are compared with the pawn's velocity in order to determine what accuracy it has
var()				INT					m_iSpeedLevels[3];			// 0 -> slowest 2 -> fastest

//R6MOTIONBLUR
var					FLOAT				m_fTimedBlurValue;          //Current Blur value with a specific timer to reach 0
var					INT					m_iShakeBlurIntensity;      //Blur intensity when hit by a bullet
var					FLOAT				m_fBlurReturnTime;          //Time to recover from the intensity 
//END R6MOTIONBLUR

// For shake
var                 FLOAT               m_fHitEffectTime;
var                 Rotator             m_rHitRotation;
var                 FLOAT               m_fShakeTime;
var                 FLOAT               m_fMaxShake;
var                 FLOAT               m_fCurrentShake;
var                 FLOAT               m_fMaxShakeTime;

var					R6RainbowTeam		m_TeamManager;

// fluid movement key is used to set the posture as well as reset it to normal (double click)... need to make sure that
// the double click does not restart the fluid movement mode.
var					FLOAT				m_fPostFluidMovementDelay;                                                                                                                                    

var					BOOL				m_bHelmetCameraOn;			// false by default: helmet camera for the rainbow 6 player
var                 BOOL                m_bScopeZoom;               // to switch between 3x and 9x zoom
var                 BOOL                m_bSniperMode;          // Character activated the zoom with a sniper rifle
var                 BOOL                m_bShowFPWeapon;            // True by default: display of not the FP Weapon
var                 BOOL                m_bShowHitLogs;             // True will display all the hit logs

// rbrek 30 aug 2001  
// this flag will prevent attempting to initiate another circumstantial action while one is in progress...
// also hides the circumstantial info during this time...
var					bool                m_bCircumstantialActionInProgress;                                                      
var					bool                m_bAllTeamsHold;
var					bool				m_bFixCamera;			// R6DEBUG
															
// For Debug Purposes
var()				bool				bShowLog;

//  Auto Aim
var                 BYTE                m_wAutoAim;                 // 0 (off), 1(low), 2(medium) or 3(high)
var                 FLOAT               m_fRetLockPosX;             // Desired Reticule X position on screen
var                 FLOAT               m_fRetLockPosY;             // Desired Reticule Y position on screen
var                 FLOAT               m_fCurrRetPosX;             // Current Reticule X position on screen
var                 FLOAT               m_fCurrRetPosY;             // Current Reticule Y position on screen
var                 FLOAT               m_fRetLockTime;             // Time remaining before the reticule hit the lock pos
var                 R6Pawn              m_targetedPawn;             // Currently targeted pawn
var                 vector              m_vAutoAimTarget;           // Position of targeted pawn.  Only valid when target pawn != none

// Spam Filter Variables
var transient		FLOAT				m_fLastBroadcastTimeStamp;     //Time of last "say"
var transient		FLOAT				m_fPreviousBroadcastTimeStamp; //Time of the "say" before the last one
var transient		FLOAT				m_fEndOfChatLockTime;		   //Set to -1.0 to unlock chatlock
var transient       FLOAT               m_fLastVoteEmoteTimeStamp;     //Time of the last "vote" message sent

// DEBUG - for freezing the position of the camera...
var					vector				m_vCameraLocation;
var					rotator				m_rCameraRotation;

//shake Camera values
var                 BOOL                m_bShakeActive;
var					rotator				m_rCurrentShakeRotation;
var					FLOAT				m_fShakeReturnTime;
var					rotator				m_rTotalShake;

var(R6Impact)		STImpactShake		m_stImpactHit;
var(R6Impact)		STImpactShake		m_stImpactStun;
var(R6Impact)		STImpactShake		m_stImpactDazed;
var(R6Impact)		STImpactShake		m_stImpactKO;

//Fire Shake values
var                 INT                 m_iReturnSpeed;         // Current Weapon return speed for shake
var                 vector              m_vNewReturnValue;      // new pitch the camera will return to when the firing is over.
var                 INT                 m_iPitchReturn;
var                 INT                 m_iYawReturn;           // speed the yaw is returning to his original position
var                 rotator             m_rLastBulletDirection; // direction of the last bullet to shake the camera in that direction
//Tweak shaking
var                 FLOAT               m_fDesignerSpeedFactor;
var                 FLOAT               m_fDesignerJumpFactor;

var                 string              m_szMileStoneMessage;
var                 BOOL                m_bDisplayMilestoneMessage;
var                 FLOAT               m_fMilestoneMessageDuration;
var                 FLOAT               m_fMilestoneMessageLeft;

var					FLOAT				m_fCurrentDeltaTime;
var					INT					m_iSpectatorYaw;
var					INT					m_iSpectatorPitch;

var                 BOOL                m_bUseFirstPersonWeapon;   // set to display or not to display the first person weapons.
var                 BOOL                m_bPlacedExplosive;

var					bool				m_bAttachCameraToEyes;

var                 BOOL                m_bCameraGhost;             
var                 BOOL                m_bCameraFirstPerson;       
var                 BOOL                m_bCameraThirdPersonFixed;  
var                 BOOL                m_bCameraThirdPersonFree;   
var                 BOOL                m_bFadeToBlack;
var					BOOL				m_bSpectatorCameraTeamOnly;

var					BOOL				m_bSkipBeginState;

// Variable for the training
var                 BOOL                m_bPreventTeamMemberUse;
var                 BOOL                m_bDisplayMessage;


// this flag tells the server if the client sent the end of round data to the server
var                 BOOL                m_bEndOfRoundDataReceived;

// this flag used to keep track of which admins are in the server options or kit restriction page
// only valid for admins
var                 BOOL                m_bInAnOptionsPage;

var                 BOOL                m_bPawnInitialized;

var                 BOOL                m_bCanChangeMember;
// Default Circumstantial Actions
enum eDefaultCircumstantialAction
{
    PCA_None,
    PCA_TeamRegroup,
    PCA_TeamMoveTo,
    PCA_MoveAndGrenade,
	PCA_GrenadeFrag,
	PCA_GrenadeGas,
	PCA_GrenadeFlash,
	PCA_GrenadeSmoke	
};

var			R6CircumstantialActionQuery m_CurrentCircumstantialAction;      // CA of the object that the player is currently looking at
var			R6CircumstantialActionQuery m_RequestedCircumstantialAction;    // Action sent to the team (or to self)
var         R6CircumstantialActionQuery m_PlayerCurrentCA;                  // Player current action

var         INT                         m_iPlayerCAProgress;                // Player action progress (0-100)
var			BOOL						m_bDisplayActionProgress;

var         BOOL                        m_bAMenuIsDisplayed;                // Used to prevent display two menu at the same time

// Interactions (registered to the InteractionMaster)
var         InteractionMaster                   m_InteractionMaster;
var         R6InteractionCircumstantialAction   m_InteractionCA;    // server can't access the client's RoseDesVents class
var         R6InteractionInventoryMnu           m_InteractionInventory;

// For default action : Move Team To
var					vector              m_vDefaultLocation;
var					vector				m_vRequestedLocation;

//R6Matinee:
var					BOOL				m_bMatineeRunning;
var					R6Rainbow			m_BackupTeamLeader;//used to remove an Access None when
														   //we take possession of the camera in Matinee
 	
var					Actor				m_PrevViewTarget;

const MAX_Pitch = 2000;  // If shake is hight than MAX_Pitch, the camera will not return to his original pitch.
const MAX_ProneSpeedRotation = 6600; //*DeltaTime (default 0.03) 
var float LastDoorUpdateTime;
var float m_fLastUpdateServerCheckTime;

// this is used on server side to remember where controller was spawned so that pawn will be spawned at the same place
var NavigationPoint						StartSpot;                  
var R6GameMenuCom						m_MenuCommunication;
var R6GameOptions						m_GameOptions;

var					Color				m_SpectatorColor;
var					INT					m_iTeamId;			// for spectator camera when player dies and is restricted to team only camera

var					string				m_CharacterName;
var input			byte				m_bPlayerRun;

var                 BOOL                m_bHasAPenalty; // this player broke the rules and killed a team-mate
var                 BOOL                m_bPenaltyBox;  // at the next round, if m_bHasAPenalty, we set this flag to true
var                 EPawnType           m_ePenaltyForKillingAPawn;
var                 BOOL                m_bRequestTKPopUp;  // request if this player wants to apply penalty to team-mate killer
var                 BOOL                m_bProcessingRequestTKPopUp; //client side, waiting on pop-up
var R6PlayerController m_TeamKiller;
var BOOL            m_bAlreadyPoppedTKPopUpBox;         // denotes if this pop-up box was already popped
var					Sound				m_sndUpdateWritableMap;
var					Sound				m_sndDeathMusic;
var                 Sound               m_sndMissionComplete;
var                 BOOL                m_bPlayDeathMusic;
var                 R6CommonRainbowVoices       m_CommonPlayerVoicesMgr;

var BOOL            m_bDeadAfterTeamSel;    //go to dead state after team selection

var BOOL            m_bShowCompleteHUD;

var                 BOOL                m_bWantTriggerLag;
var                 BOOL                m_bQuitToUpdateServerDisplayed;

//============================================================================
// BEGIN Vars and consts used in kicking
//============================================================================
const   K_MinVote       = 0;
const   K_CanNotVote    = 0;    // can not vote yet, playercontroller probably not fully logged in yet
const   K_VotedYes      = 1;    // okay let's kick the player
const   K_VotedNo       = 2;    // let's not kick the player
const   K_EmptyBallot   = 3;    // an empty ballot, all empty ballots will count as a no vote
const   K_MaxVote       = 3;
const   K_KickFreqTime  = 300; // minimum time that must elapse before we can kick again
var     INT m_iVoteResult;
var     FLOAT m_fLastVoteTime;  // previous time we tried kicking someone or changing map


//============================================================================
// END Vars and consts used in kicking
//============================================================================
var                 INT                m_iAdmin;       // this player is logged in as an administrator
const   Authority_None  = 0;
const   Authority_Admin = 1;
const   Authority_Max   = 1;

#ifndefSPDEMO
var R6AbstractGameService m_GameService;    // points to the local player's GameService class
#endif

struct stSoundPriority
{
    var R6SoundReplicationInfo  aSoundRepInfo;
    var Sound                   sndPlayVoice;
    var INT                     iPriority;
    var BYTE                    eSlotUse;
    var BYTE                    ePawnType;
    var FLOAT                   fTimeStart;
    var BOOL                    bIsPlaying;
    var BOOL                    bWaitToFinishSound;
};

struct stSoundPriorityPtr { var int Ptr; };	// Hack to to fool C++ header generation...

var Array<stSoundPriorityPtr> m_PlayVoicesPriority;


const K_MaxBanPageSize = 10;
struct STBanPage
{
    var string szBanID[K_MaxBanPageSize];
};

var int m_iBanPage;
var string m_szBanSearch;
var STBanPage m_BanPage;

enum eGamePasswordRes
{
    GPR_None,
    GPR_MissingPasswd,
    GPR_PasswdSet,
    GPR_PasswdCleared
};

// MPF1
var float m_fStartSurrenderTime; //MissionPack1
var bool m_bIsSecuringRainbow; // MissionPack1 true if is Secure action, false if is Free action
// MissionPack1 2
var R6IOSelfDetonatingBomb m_pSelfDetonatingBomb; 
var bool m_bBombSearched; // true if a self detonating bomb has been detected in the level (temporary? It's like a patch)
var R6Pawn m_pInteractingRainbow; // equal to the pawn which is arresting/rescuing this
// End MissionPack1 2

native(2211) final function UpdateCircumstantialAction();
native(1843) final function UpdateReticule( FLOAT fDeltaTime );
native(2213) final function UpdateSpectatorReticule();
native(1840) final function DebugFunction();
native(1224) final function PlayerController FindPlayer(string inPlayerIdent, BOOL bIsIdInt);  // find a player based on player name or id
native(2724) final function string LocalizeTraining(string SectionName, string KeyName, string PackageName, INT iBox, INT iParagraph);
native(1521) final function string GetLocStringWithActionKey(string szText, string szActionKey );
native(2726) final function PlayVoicesPriority(R6SoundReplicationInfo aAudioRepInfo, Sound sndPlayVoice,  Actor.ESoundSlot eSlotUse, INT iPriority,  optional BOOL bWaitToFinishSound, optional FLOAT fTime);

replication
{
    unreliable if (Role==ROLE_Authority)        // functions replicated to client here
        R6ClientWeaponShake,
        ClientActionProgressDone,ClientDisableFirstPersonViewEffects,ClientVoteSessionAbort,
        ClientNewPassword,ClientPasswordTooLong,ClientPasswordMessage,ClientNoAuthority,ClientAdminKickOff,ResetBlur,ClientVoteInProgress,ClientNoKickAdmin,
        ClientCantRequestKickYet, ClientResetGameMsg, ClientAdminBanOff, ClientCantRequestChangeMapYet,
		ClientShowWeapon,R6Shake,ClientHideReticule, ClientMPMiscMessage;//ClientSetRequestedCircumstantialAction,

    reliable if (Role==ROLE_Authority)        // reliable functions replicated to client here
        ClientChangeMap,ClientKickBadId,ClientKickVoteMessage,ClientKickedOut,ClientBanned, ClientAdminLogin,ClientPlayerVoteMessage,ClientForceUnlockWeapon,
        ClientVoteResult,ClientRestartRoundMsg,ClientRestartMatchMsg,ServerIndicatesInvalidCDKey,ClientNotifySendMatchResults,
        ClientUpdateLadderStat, ClientFadeCommonSound, ClientFadeSound, ClientPlayMusic,
        ClientServerChangingInfo, ClientServerMap,ClientNotifySendStartMatch, ClientPlayVoices, ClientSetWeaponSound, 
        ClientNewLobbyConnection, ClientFinalizeLoading,ClientTeamFullMessage, ClientTeamIsDead, 
        ClientSetMultiplayerSkins, ClientStopFadeToBlack, TKPopUpBox, ClientEndSurrended, // MPF_Milan2 ClientPreBeginSurrending, 
        ClientGameMsg,ClientMissionObjMsg, ClientDeathMessage,CountDownPopUpBox,CountDownPopUpBoxDone,ToggleHelmetCameraZoom,
        ClientNoBanMatches,ClientBanMatches,ClientPlayerUnbanned,ClientPBVersionMismatch,
        ClientGameTypeDescription, ClientChatAbuseMsg, ClientChatDisabledMsg, ClientNextMapVoteMessage;
    
    reliable if (Role==ROLE_Authority)        // reliable variables replicated to client here
        m_bRequestTKPopUp, m_iAdmin, m_bSkipBeginState;

    unreliable if (Role==ROLE_Authority)        // vars replicated to client here
        m_TeamManager,m_rCurrentShakeRotation,m_pawn,m_iPlayerCAProgress,m_CurrentCircumstantialAction;

    unreliable if (Role<ROLE_Authority)         // functions replicated to server here
        ServerChangeTeams,ServerNextMember,ServerPreviousMember,
        ServerWeaponUpAnimDone,ServerUpdatePeeking,ServerReloadWeapon,ServerGraduallyOpenDoor,
        ServerGraduallyCloseDoor,ServerExecFire,ServerSetHelmetParams,ServerSetPlayerStartInfo,
        RegroupOnMe,ToggleTeamHold,ToggleAllTeamsHold,ServerNetLogActor,ServerLogBandWidth,
        ServerActionKeyReleased,ServerPlayerActionProgress,ServerActionProgressStop,ServerBroadcast,
        ServerSetBipodRotation, ServerSetPeekingInfoLeft, ServerSetPeekingInfoRight, ServerSetCrouchBlend, 
		ServerNewPing, ServerSendGoCode, ServerChangeOperative;

    reliable if (Role<ROLE_Authority)
        VoteKick,VoteKickID,VoteNextMap,Vote,ServerAdminLogin,Kick,KickID,Ban,BanID,UnBan,ServerBanList,RestartMatch,
        RestartRound,ServerMap,NewPassword,AutoAdminLogin,LoadServer,ServerNewGeneralSettings,ServerSwitchWeapon,
        SendSettingsAndRestartServer,ServerPausePreGameRoundTime,ServerUnPausePreGameRoundTime,
        ServerStartChangingInfo,ServerNewMapListSettings,ServerSetGender,Admin,
        ServerNewKitRestSettings,ServerSetUbiID,ServerEndOfRoundDataSent, ServerPlayRecordedMsg, 
		ServerStartSurrended, ReplicateTriggerLagInfo,
        ServerRequestSkins,ServerActionKeyPressed,ServerStartClimbingLadder,LockServer;//,ServerGetSavedStats;// MissionPack1 ServerStartSurrending, 
        

#ifdefDEBUG
    unreliable if (Role<ROLE_Authority)         // functions replicated to server here
        LogVoteInfo,LogPlayerInfo,LogAllPlayerInfo, ToggleRestart,
        SetFragStat,SetDeathsStat,SetHealthStat,SetRoundsHitStat,SetRoundsFiredStat,
        SetRoundsPlayedStat,SetRoundsWonStat,
        ServerUnlockCheat,
        ServerGhost, ServerWalk, ServerPlayerInvisible, 
        ServerAbortMission, ServerCompleteMission,
        ServerLogActors,ServerLogPawn,ServerDbgLogActor;
#endif
}





//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
    if ( m_bResetSystemLog ) LogResetSystem( false );
    Super.ResetOriginalData();

    m_GameOptions = class'Actor'.static.GetGameOptions();

    m_bPawnInitialized = false;

    m_bEndOfRoundDataReceived         = false;
    m_bCircumstantialActionInProgress = false;
    m_iPlayerCAProgress               = 0;
    m_TeamManager                     = none;
    m_bAMenuIsDisplayed               = false;
    m_PrevViewTarget                  = none;
    LastDoorUpdateTime                = default.LastDoorUpdateTime;    

    m_bShakeActive                      = true;
    CancelShake();
    m_bSniperMode                       = false;
    m_bCircumstantialActionInProgress   = false;
    DesiredFOV              = default.DesiredFOV;
    DefaultFOV              = default.DefaultFOV;
    ResetFOV();
    m_bOldPeekLeft          = 0;
    m_bOldPeekRight         = 0;
    m_bHelmetCameraOn       = false;
    m_bUseFirstPersonWeapon = default.m_bUseFirstPersonWeapon;
    m_bHideReticule         = default.m_bHideReticule;
    m_bScopeZoom            = false;
    m_bAllTeamsHold         = false;
    m_bFixCamera            = default.m_bFixCamera;				//R6DEBUG
    m_bAttachCameraToEyes   = default.m_bAttachCameraToEyes;
    bCheatFlying            = default.bCheatFlying;
    m_bInitFirstTick        = default.m_bInitFirstTick;

	m_eCameraMode = CAMERA_FirstPerson;
    m_bCrawl = false;
    bDuck    = 0;
    Enemy = none;
    Target = none;
    LastSeenPos = vect(0,0,0);
    LastSeeingPos = vect(0,0,0);
    LastSeenTime = 0;
    m_bRequestTKPopUp=false;  // request if this player wants to apply penalty to team-mate killer
    m_bProcessingRequestTKPopUp=false; //client side, waiting on pop-up
    m_TeamKiller=none;
    m_bPlayDeathMusic=false;
    m_bFirstTimeInZone=true;
    m_bLoadSoundGun=false;
    m_bInstructionTouch=false;

    UpdateTriggerLagInfo();

    if (PlayerReplicationInfo != none)
        PlayerReplicationInfo.iOperativeID = -1;
    
	// local player
    if( (Level.NetMode == NM_Client) || ((Level.NetMode == NM_ListenServer) && (Viewport(Player) != none)) )
		ServerSetGender(m_GameOptions.Gender > 0);

    ResetBlur();
    
    if ((m_CurrentCircumstantialAction==none) && (Role==ROLE_Authority))
    {
        m_CurrentCircumstantialAction = Spawn(class'R6CircumstantialActionQuery', self);
    }

    // Be sure we are not displaying the Interaction Menus
    if ( m_CurrentCircumstantialAction != none )
    {
        m_CurrentCircumstantialAction.aQueryOwner = self;
    }

    if (m_InteractionCA != None)        
    {
        m_InteractionCA.DisplayMenu(false);
        m_InteractionCA.m_bActionKeyDown = false;
    }

    if (m_InteractionInventory != None)
    {
        m_InteractionInventory.DisplayMenu(false);
        m_InteractionInventory.m_bActionKeyDown = false;
    }
    m_bAlreadyPoppedTKPopUpBox = false;

    // this may become necessary in the future if the PlayerController gets stuck in the dead state when
    // reseting the round
    //    GotoState('BaseSpectating');
}

//------------------------------------------------------------------
// ResettingLevel
//	the server inform the client to reset the level
//------------------------------------------------------------------
simulated function ResettingLevel(int iNbOfRestart)
{
    #ifdefDEBUG if(bShowLog)log("R6PlayerController::ResettingLevel()");	#endif
	Pawn = none;
    m_pawn = none; // it's safe to set it to none here
    
    SetViewTarget(none);
    if(m_TeamManager!=none)
        m_TeamManager.ResetTeam();

    if (m_MenuCommunication!= none)
    {        
        #ifdefDEBUG if(bShowLog)log("R6PlayerController::ResettingLevel() CMS_DisplayStat");	#endif
        //m_MenuCommunication.SetStatMenuState( CMS_DisplayStat);    // try and sneak this one in
        m_MenuCommunication.SetStatMenuState( CMS_DisplayForceStat);    // try and sneak this one in
    }
    if ( Level.NetMode == NM_Client )
		Level.ResetLevel( iNbOfRestart );
    
    UpdateTriggerLagInfo();
}


simulated function FirstPassReset()
{
    SetViewTarget(none);
    if ( m_TeamManager != none )
    {
        m_TeamManager.ResetTeam();
        m_TeamManager = none;
    }
}

function Reset()
{
    Super.Reset();
    UpdateTriggerLagInfo();
    m_bFirstTimeInZone=true;
}

function bool ShouldDisplayIncomingMessages()
{
    if(m_MenuCommunication != none)
        return m_MenuCommunication.GetPlayerDidASelection();

    return true;
}

function ClientChangeMap()
{    
    if(m_MenuCommunication != none)
    {
        m_TeamSelection=PTS_UnSelected;        
        #ifdefDEBUG if(bShowLog)log("R6PlayerController::ClientChangeMap() CMS_DisplayForceStatLocked");	#endif
        m_MenuCommunication.SetStatMenuState( CMS_DisplayForceStatLocked );    // try and sneak this one in      
        m_MenuCommunication.SetPlayerReadyStatus(false);
    }    
}

function ClearReferences()
{    
    if(m_MenuCommunication != none)          
        m_MenuCommunication.ClearLevelReferences();
    
    DestroyInteractions();
}

function ClientNewLobbyConnection(int iLobbyID, int iGroupID)
{
#ifndefSPDEMO
    GameReplicationInfo.m_iGameSvrGroupID = iGroupID;
    GameReplicationInfo.m_iGameSvrLobbyID = iLobbyID;
    m_GameService.m_bMSClientRouterDisconnect = true;
//    m_GameService.m_bMSClientLobbyDisconnect = true;
#endif
}


function ClientDeathMessage(string Killer, string Killed, byte bSuicideType )
{
    // Eric's request
    if(Level.NetMode == NM_Standalone)
        return;

    if(myHUD != none)
    {
        if (bSuicideType == DEATHMSG_CONNECTIONLOST)
        {
            myHUD.AddTextMessage(class'R6Pawn'.static.BuildDeathMessage(Killer, Killed, bSuicideType), class'LocalMessage');
        }
        else if (bSuicideType != DEATHMSG_SWITCHTEAM)
        {
			// MPF1
			//Missionpack1
			if(GameReplicationInfo.m_szGameTypeFlagRep == "RGM_CaptureTheEnemyAdvMode")
				myHUD.AddDeathTextMessage(Killed$" "$ Localize("MPDeathMessages", "PlayerHasBeenShot", "ASGameMode")$" "$Killer$" "$Localize("MPDeathMessages", "PlayerSurrender", "ASGameMode"), class'LocalMessage');
			else
			//End MissionPack1
            myHUD.AddDeathTextMessage(class'R6Pawn'.static.BuildDeathMessage(Killer, Killed, bSuicideType), class'LocalMessage');
        }
    }
}

function ClientMPMiscMessage(string szMsgID, string Name, optional string szEndOfMsg )
{
    local string szMsg;
    if(myHUD != none)
    {
        if ( Name != "" )
            szMsg = Name$" "$Localize("MPMiscMessages", szMsgID, "R6GameInfo");
        else
            szMsg =          Localize("MPMiscMessages", szMsgID, "R6GameInfo");

        if ( szEndOfMsg != "" )
            szMsg = szMsg$" " $szEndOfMsg;

        myHUD.AddTextMessage(szMsg, class'LocalMessage');
    }

}

function ClientPlayMusic(Sound Sound)
{
    #ifdefDEBUG log("*** ClientPlayMusic"@ Sound @"for"@ Self); #endif
    if ((Sound != none) && Viewport(Player) != none)
        PlayMusic(Sound);
}

function ServerReadyToLoadWeaponSound()
{
	local Controller aController;
    local R6Terrorist aTerrorist;
	local R6Rainbow aRainbow;
    local ZoneInfo aZoneInfo;

    for (aController=Level.ControllerList; aController!=None; aController=aController.NextController )
    {
        if (aController.IsA('R6PlayerController') || aController.IsA('R6RainbowAI'))
        {
            aRainbow = R6Rainbow(aController.Pawn);
            if (aRainbow != none)
            {
                SetWeaponSound(aController.m_PawnRepInfo, aRainbow.m_szPrimaryWeapon, 0);
                SetWeaponSound(aController.m_PawnRepInfo, aRainbow.m_szSecondaryWeapon, 1);
                SetWeaponSound(aController.m_PawnRepInfo, aRainbow.m_szPrimaryItem, 2);
                SetWeaponSound(aController.m_PawnRepInfo, aRainbow.m_szSecondaryItem, 3);
            }
        }
        else if (aController.IsA('R6TerroristAI'))
        {
            aTerrorist = R6Terrorist(aController.Pawn);
            if (aTerrorist != none)
            {
                SetWeaponSound(aController.m_PawnRepInfo, aTerrorist.m_szPrimaryWeapon, 0);
                SetWeaponSound(aController.m_PawnRepInfo, aTerrorist.m_szGrenadeWeapon, 2);
            }
        }
    }
    if (Pawn != none)
        aZoneInfo = Pawn.Region.Zone;
    else
        aZoneInfo = Region.Zone;

    ClientFinalizeLoading(aZoneInfo);
}


function SetWeaponSound(R6PawnReplicationInfo PawnRepInfo, string szCurrentWeaponTxt, BYTE u8CurrentWepon) // iCurrentWepon: 0=PrimaryWeapon, 1=SecondaryWeapon, etc.
{
	local class<R6EngineWeapon> WeaponClass;
    local String caps_szWeaponName;

    caps_szWeaponName = Caps(szCurrentWeaponTxt);

    // passive gadgets are not R6AbstractWeapon types
    if (( caps_szWeaponName == "R6WEAPONGADGETS.NONE") || ( caps_szWeaponName == "PRIMARYMAGS")   ||
        ( caps_szWeaponName == "SECONDARYMAGS")        || ( caps_szWeaponName == "LOCKPICKKIT")   ||
        ( caps_szWeaponName == "DIFFUSEKIT")           || ( caps_szWeaponName == "ELECTRONICKIT") ||
        ( caps_szWeaponName == "GASMASK")              || ( caps_szWeaponName == "NONE")          ||
        ( caps_szWeaponName == "")
	   )
    {
        return;
    }

//    log("*** SetWeaponSound for" @ Self @ "#1" @ PawnRepInfo.m_ControllerOwner.Pawn @ "szCurrentWeaponTxt =" @ szCurrentWeaponTxt);

    WeaponClass = class<R6EngineWeapon>(DynamicLoadObject(szCurrentWeaponTxt, class'Class'));

    if(WeaponClass != none)
        ClientSetWeaponSound(PawnRepInfo, WeaponClass, u8CurrentWepon);
}


function ClientSetWeaponSound(R6PawnReplicationInfo PawnRepInfo, class<R6EngineWeapon> PrimaryWeaponClass, BYTE u8CurrentWeapon)
{

//    log ("+++ PawnRepInfo = " @ PawnRepInfo @ u8CurrentWeapon);
    if (PawnRepInfo != none)
        PawnRepInfo.AssignSound(PrimaryWeaponClass, u8CurrentWeapon);
}

function ClientFinalizeLoading(ZoneInfo aZoneInfo)
{
    Level.FinalizeLoading();
    m_CurrentAmbianceObject = aZoneInfo;
    Level.m_bCanStartStartingSound = true;
}

function ServerIndicatesInvalidCDKey(string _szErrorMsgKey)
{
    Player.Console.R6ConnectionFailed(_szErrorMsgKey);
}

event InitInputSystem()
{	
	Super.InitInputSystem();
	
    InitInteractions();    
}

event InitMultiPlayerOptions()
{
#ifndefSPDEMO
    Super.InitMultiPlayerOptions();
    ToggleRadar(GetGameOptions().ShowRadar);
    AutoAdminLogin(m_szLastAdminPassword);		
	ServerSetGender(m_GameOptions.Gender > 0);
    m_GameService = R6AbstractGameService(Player.Console.SetGameServiceLinks(self));
    ServerSetUbiID(m_GameService.m_szUserID);
#endif
}
simulated function ClientHideReticule(BOOL bNewReticuleValue)
{
    m_bHideReticule = bNewReticuleValue;
}

function ClientShowWeapon()
{
    if((m_GameOptions.HUDShowFPWeapon == true) || (R6GameReplicationInfo(GameReplicationInfo).m_bFFPWeapon == true))
        ShowWeapon();
}

simulated function bool ShouldDrawWeapon()
{
    if(m_Pawn != none && !m_pawn.IsAlive())
        return false;   // owner is dead, so no 1st person weapon should be drawn.

    if((Level.NetMode != NM_Standalone) && R6GameReplicationInfo(GameReplicationInfo).m_bFFPWeapon)
        return true;    // option was forced by server settings.

    if(!m_GameOptions.HUDShowFPWeapon)
        return false;   // option was set to false by user settings.

    return m_bShowFPWeapon || m_bShowCompleteHUD;
}

exec function ShowWeapon()
{
    m_GameOptions.HUDShowFPWeapon = true;
    m_bShowFPWeapon = true;
    if(Pawn.m_WeaponsCarried[0] != none)
        R6AbstractWeapon(Pawn.m_WeaponsCarried[0]).R6SetReticule(self);
    if(Pawn.m_WeaponsCarried[1] != none)
        R6AbstractWeapon(Pawn.m_WeaponsCarried[1]).R6SetReticule(self);
}

function Set1stWeaponDisplay(BOOL bShowWeapon)
{
    m_bShowFPWeapon = bShowWeapon;
    if(Pawn != none)
    {
        if(Pawn.m_WeaponsCarried[0] != none)
            R6AbstractWeapon(Pawn.m_WeaponsCarried[0]).R6SetReticule(self);
        if(Pawn.m_WeaponsCarried[1] != none)
            R6AbstractWeapon(Pawn.m_WeaponsCarried[1]).R6SetReticule(self);
    }
}

simulated event SetMatchResult(string _UserUbiID, INT iField, INT iValue)
{
#ifndefSPDEMO
    if ((Level.NetMode==NM_DedicatedServer) || (m_GameService == none))
        return;
   
    m_GameService.CallNativeSetMatchResult(_UserUbiID, iField, iValue);
#endif
}

// 
event ClientUpdateLadderStat(string _UserUbiID, int _iKillStat, int _iDeathStat, float fPlayTime)
{
#ifndefSPDEMO
    if ((Level.NetMode==NM_DedicatedServer) || (m_GameService == none) || (PlayerReplicationInfo.m_bClientWillSubmitResult == false))
        return;
    m_GameService.CallNativeSetMatchResult(_UserUbiID, 0, _iKillStat);
    m_GameService.CallNativeSetMatchResult(_UserUbiID, 1, _iDeathStat);
    m_GameService.CallNativeSetMatchResult(_UserUbiID, 2, 0);
    m_GameService.CallNativeSetMatchResult(_UserUbiID, 3, 0);
    m_GameService.CallNativeSetMatchResult(_UserUbiID, 4, fPlayTime);
#endif
}

event ClientNotifySendMatchResults()
{
#ifndefSPDEMO
    local PlayerReplicationInfo aPRI;

    if (bShowLog) log("Received ClientNotifySendMatchResults for player "$self);
    if ((Level.NetMode==NM_DedicatedServer) || (m_GameService == none) || (PlayerReplicationInfo.m_bClientWillSubmitResult == false))
        return;

    m_GameService.NativeSubmitMatchResult();
#endif
}

event ClientNotifySendStartMatch()
{
#ifndefSPDEMO
    m_GameService.m_bClientWaitMatchStartReply = true;
    m_GameService.m_bClientWillSubmitResult=true;
#endif
}

function ServerEndOfRoundDataSent()
{
    local Controller _itController;
    local R6PlayerController _playerController;

    m_bEndOfRoundDataReceived = true;
    PlayerReplicationInfo.m_bClientWillSubmitResult = false;

}

simulated event PostBeginPlay()
{ 
    Super.PostBeginPlay();
    m_fLastUpdateServerCheckTime = Level.TimeSeconds;

	if (Role==ROLE_Authority)
    {
        PlayerReplicationInfo = Spawn(PlayerReplicationInfoClass, Self,,vect(0,0,0),rot(0,0,0));
        InitPlayerReplicationInfo();
        bIsPlayer = true;
        // Get the common voices first person manager
        m_CommonPlayerVoicesMgr = R6CommonRainbowVoices( R6AbstractGameInfo(level.game).GetCommonRainbowPlayerVoicesMgr() );

        if ((Level.NetMode == NM_StandAlone) || (Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag)))
        {
            if (Level.m_sndMissionComplete == none)
            {
                Level.m_sndMissionComplete = m_sndMissionComplete;
                AddSoundBankName("Voices_Control_MissionSuccess");
            }
            AddSoundBankName("Voices_Control_MissionFailed");
        }
    }
    //Let's make sure we display something ;)
    Level.m_bAllow3DRendering = True;
    SetPlanningMode(false);

	m_GameOptions = class'Actor'.static.GetGameOptions();
}

function UpdateTriggerLagInfo()
{
	if ( m_GameOptions != None && ( Level.NetMode == NM_Client || (Pawn != None && Pawn.IsLocallyControlled()) ) )
    {
        m_bWantTriggerLag = m_GameOptions.WantTriggerLag;
        ReplicateTriggerLagInfo(m_bWantTriggerLag);
    }
}

function ReplicateTriggerLagInfo(bool _value)
{
    m_bWantTriggerLag = _value;
}

//once a game is started, this function is called once
simulated function HidePlanningActors( )
{
    local R6AbstractInsertionZone   NavPoint;
    local R6AbstractExtractionZone  ExtZone;
    local R6ReferenceIcons          RefIco;  
    local R6IORotatingDoor          RotDoor;
    local string					szCurrentGameType;
    local bool bInTraining;

    szCurrentGameType = GameReplicationInfo.m_szGameTypeFlagRep;
    
    //Hide the insertion zone
    foreach AllActors( class 'R6AbstractInsertionZone', NavPoint )
    {
        NavPoint.bHidden = true;
    }
    
    //Hide the extraction zone
    foreach AllActors( class 'R6AbstractExtractionZone', ExtZone )
    {
        if(!ExtZone.isAvailableInGameType( szCurrentGameType ))
            ExtZone.bHidden = true;
    }

    if ( Level.NetMode == NM_Standalone )
        bInTraining = Level.Game.IsA('R6TrainingMgr');

    //Delete all the reference icons in the map,
    foreach AllActors( class 'R6ReferenceIcons', RefIco)
    {
        if(RefIco.IsA('R6DoorIcon') || RefIco.IsA('R6DoorLockedIcon'))
            RefIco.Destroy();
        else
        {
            if(!RefIco.IsA('R6ObjectiveIcon') && 
               !(bInTraining && (RefIco.IsA('R6HostageIcon') || RefIco.IsA('R6TerroristIcon') )) &&
               !((Level.NetMode != NM_Standalone) && RefIco.IsA('R6HostageIcon'))
              )
            {
                RefIco.bHidden = true;
                if((R6ActionPointAbstract(RefIco.owner) != none) || RefIco.IsA('R6CameraDirection') || RefIco.IsA('R6ArrowIcon'))
                    RefIco.Destroy();
            }
        }
    }
    //Reset display properties to all doors for in-game map
    foreach AllActors( class 'R6IORotatingDoor', RotDoor)
    {
        RotDoor.m_eDisplayFlag=DF_ShowInBoth;
    }
}

simulated event PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
    
    if  (pawn != none) 
    {
        pawn.controller = self;
        pawn.PostNetBeginPlay();
    }

	UpdateTriggerLagInfo();

#ifdefDEBUG
    // Add the cheat manager in network games
    // WARNING:  Some function of the cheatmanager may cause problem in network game.
    // Use at your own risk! (and remove before final build)
    if( CheatManager == none )
        CheatManager = new CheatClass;
#endif // #ifndef R6CODE
}

function ServerSetUbiID(string _szUBIUserID)
{
    if (PlayerReplicationInfo.m_szUbiUserID=="")
        PlayerReplicationInfo.m_szUbiUserID = _szUBIUserID;
}

function ServerPlayRecordedMsg(string Msg, R6Pawn.EPreRecordedMsgVoices eRainbowVoices)
{
    Level.Game.BroadcastTeam(Self, Msg, 'PreRecMsg');

    if (m_TeamManager == none)
    {
        #ifdefDEBUG log("** In ServerPlayRecordedMsg : m_TeamManager is NULL"); #endif
        return;
    }
    if (m_TeamManager.m_PreRecMsgVoicesMgr == none)
    {
        #ifdefDEBUG log("** In ServerPlayRecordedMsg : m_TeamManager.m_PreRecMsgVoicesMgr is NULL");    #endif
        return;
    }
    if (Pawn.IsAlive())
        m_TeamManager.m_PreRecMsgVoicesMgr.PlayRecordedMsgVoices(R6Pawn(Pawn), eRainbowVoices);
}

event Destroyed()
{
	#ifdefDEBUG if(bShowLog) log(self$" Destroyed() was called.................");	#endif

    if(m_CurrentCircumstantialAction!=none)
        m_CurrentCircumstantialAction.aQueryOwner = none;

	ClearReferences();

    if ( Player!= none && Player.Console != none )
        Player.Console.SetGameServiceLinks(none);

    if(R6AbstractGameInfo(Level.Game)!= none)
        R6AbstractGameInfo(Level.Game).RemoveController(Self);

    Super.Destroyed();
}

function ServerSetGender(bool bIsFemale)
{
	if((PlayerReplicationInfo == none) || (PlayerReplicationInfo.iOperativeID >= 0))
		return;
		
	PlayerReplicationInfo.bIsFemale = bIsFemale;	
	PlayerReplicationInfo.iOperativeID = Level.Game.MPSelectOperativeFace(bIsFemale);
}

//------------------------------------------------------------------
// GetPrefixToMsg
// "(DEAD) Pago "
// "(DEAD) Pago [ALPHA]"
//------------------------------------------------------------------
function string GetPrefixToMsg( PlayerReplicationInfo PRI, name MsgType )
{
    local string szMsg;
    local string szLifeState;
    local string szTeam;
    
    if ( PRI == none )
        return "";

    // IMPORTANT: the same logic order (SPECTATOR, DEAD, ALIVE) is used in 
    //            R6BroadcastHandler::Broadcast

    if ( PRI.bIsSpectator || 
        (PRI.TeamID == INT(ePlayerTeamSelection.PTS_UnSelected) ) || 
         (PRI.TeamID == INT(ePlayerTeamSelection.PTS_Spectator) ) )
    {
        szLifeState = "(" $Localize("Game", "SPECTATOR", "R6GameInfo")$ ") ";
    }
    else if ( PRI.m_iHealth > 1 ) 
    {
        szLifeState = "(" $Localize("Game", "DEAD", "R6GameInfo")$ ") ";
    }

    if ( MsgType == 'TeamSay' && PRI.TeamID == PlayerReplicationInfo.TeamID )
    {
        if (PlayerReplicationInfo.TeamID == INT(ePlayerTeamSelection.PTS_Alpha))
        {
            // if in a team;
            szTeam = " [" $Localize("Game", "GREEN", "R6GameInfo")$ "]";
        }
        else if (PlayerReplicationInfo.TeamID == INT(ePlayerTeamSelection.PTS_Bravo ))
        {
            szTeam = " [" $Localize("Game", "RED", "R6GameInfo")$ "]";
        }
        else
        {
            szTeam = " [" $Localize("Game", "NOTEAM", "R6GameInfo")$ "]";
        }
    }

    szMsg = szLifeState$""$PRI.PlayerName$" "$szTeam;

    return szMsg;
}

//------------------------------------------------------------------
// TeamMessage: inherited
//	
//------------------------------------------------------------------
event TeamMessage( PlayerReplicationInfo PRI, coerce string Msg, name MsgType  )
{
    local R6Pawn    Sender;

    local String	szGroup;
    local String	szID;
	local int		pos;

    // For in-game map
    foreach AllActors(class 'R6Pawn', Sender)
    {
        if(Sender.PlayerReplicationInfo == PRI)
        {
            if(Pawn != none && Pawn.IsFriend(Sender))
                Sender.m_fLastCommunicationTime = 5.0f;
            break;
        }
    }

	if ( MsgType == 'Line' )
	{
		if ( PRI != PlayerReplicationInfo)
		{
			Level.AddEncodedWritableMapStrip(Msg);
			if(Player != none)
			{
				Player.Console.Message( Localize("Game", "MapUpdatedBy", "R6GameInfo")$ " " $PRI.PlayerName, 6.0 );
				if (m_pawn != none)
					m_pawn.PlaySound(m_sndUpdateWritableMap, SLOT_SFX);
			}
			
		}
	}
    else if (MsgType == 'Icon')
    {
		Level.AddWritableMapIcon(Msg);
        if ( PRI != PlayerReplicationInfo && Player != none) // Don't send update message to himself
		{
			Player.Console.Message( Localize("Game", "MapUpdatedBy", "R6GameInfo")$ " " $PRI.PlayerName, 6.0 );
			if (m_pawn != none)
				m_pawn.PlaySound(m_sndUpdateWritableMap, SLOT_SFX);
		}
    }
	else
	{
	    if ( (MsgType == 'Say') || (MsgType == 'TeamSay') )
        {
            Msg = GetPrefixToMsg( PRI, MsgType )$": "$Msg;
        }
        else if (MsgType == 'PreRecMsg')
        {
		    pos = InStr(Msg," ");
		    szGroup = Left(Msg, pos);
		    szID = Right(Msg, Len(Msg) - pos - 1);
            Msg = GetPrefixToMsg( PRI, 'TeamSay' )$": "$Localize(szGroup, szID, "R6RecMessages");
        }
		if(Player != none)
			Player.InteractionMaster.Process_Message( Msg,6.0, Player.LocalInteractions);

	   // AddTextMessage(Msg,class'LocalMessage');
	} 
}


function InitInteractions()
{
    #ifdefDEBUG if(bShowLog) log( "Creating Interactions  Player.InteractionMaster="$Player.InteractionMaster$" m_InteractionMaster="$m_InteractionMaster$" m_InteractionCA="$m_InteractionCA );	#endif

    if( Player != None )
    {
        if ( m_InteractionMaster == none )
            m_InteractionMaster = Player.InteractionMaster;

        // Add interaction to the interaction master
        if ( m_InteractionCA == none )
            m_InteractionCA = R6InteractionCircumstantialAction( m_InteractionMaster.AddInteraction( "R6Engine.R6InteractionCircumstantialAction", Player ));        
        if ( m_InteractionInventory == none )
            m_InteractionInventory = R6InteractionInventoryMnu( m_InteractionMaster.AddInteraction( "R6Engine.R6InteractionInventoryMnu", Player ));
    }
}


function DestroyInteractions()
{
    #ifdefDEBUG if(bShowLog) log( "Destroying Interactions"@ m_InteractionMaster @ m_InteractionCA @ m_InteractionInventory );	#endif

    if( m_InteractionMaster != None )
    {
		if (m_InteractionCA !=None)
		{
			m_InteractionMaster.RemoveInteraction( m_InteractionCA );
			m_InteractionCA = None;			
		}
		if (m_InteractionInventory != None)
		{
			m_InteractionMaster.RemoveInteraction( m_InteractionInventory );
			m_InteractionInventory = None;
		}
    }
}

simulated function SetPlayerStartInfo()
{
//Todo : Find why this was commented out, leave a note here and delete the code.
//Note to coders : When you comment out a complete functions, leave explanatory comments damnit :p
/*
    local R6StartGameInfo       StartGameInfo;
    local INT                   CurrentTeam;   

    StartGameInfo = Player.console.Master.m_StartGameInfo;
    if ((Player == none) || (StartGameInfo == none) || (m_PlayerStartInfo!=none))
        return;

    if  ( ( GameReplicationInfo.m_eGameModeFlag == RGM_DeathmatchMode     )   ||
          ( GameReplicationInfo.m_eGameModeFlag == RGM_TeamDeathMatchMode ) )
        return;

    for(CurrentTeam = 0; CurrentTeam < 3; CurrentTeam++)
    {
        if ((StartGameInfo.m_TeamInfo[CurrentTeam].m_iNumberOfMembers > 0) && 
            (StartGameInfo.m_TeamInfo[CurrentTeam].m_bPlayerTeam) )
        {
            if (m_PlayerStartInfo==none)
            {
                m_PlayerStartInfo = Spawn(class'R6RainbowStartInfo');
            }
            m_PlayerStartInfo.SetOwner(self);
            m_PlayerStartInfo = StartGameInfo.m_TeamInfo[CurrentTeam].m_CharacterInTeam[0];
			

            ServerSetPlayerStartInfo( m_PlayerStartInfo.m_armorName,
                m_PlayerStartInfo.m_WeaponName[0],  m_PlayerStartInfo.m_WeaponName[1], 
                m_PlayerStartInfo.m_BulletType[0],  m_PlayerStartInfo.m_BulletType[1], 
                m_PlayerStartInfo.m_WeaponGadgetName[0], m_PlayerStartInfo.m_WeaponGadgetName[1],
                m_PlayerStartInfo.m_GadgetName[0],  m_PlayerStartInfo.m_GadgetName[1], 
				// 4 march 2002 rbrek - TEMPORARY (until planning is done) - to spawn a Rainbow Team in multiplayer	
				StartGameInfo.m_TeamInfo[CurrentTeam].m_iNumberOfMembers );
            break;
        }
    }
*/
}

function ServerSetPlayerStartInfo(
	string _armorName,
    string _WeaponName0, string _WeaponName1, 
    string _BulletName0, string _BulletName1,
    string _WeaponGadgetName0, string _WeaponGadgetName1,
    string _GadgetName0, string _GadgetName1 )
{
    if (m_PlayerStartInfo==none)
    {
        m_PlayerStartInfo = Spawn(class'R6RainbowStartInfo');
    }
	m_PlayerStartInfo.m_ArmorName = _armorName;
    m_PlayerStartInfo.m_WeaponName[0] = _WeaponName0; m_PlayerStartInfo.m_WeaponName[1] = _WeaponName1;
    m_PlayerStartInfo.m_BulletType[0] = _BulletName0; m_PlayerStartInfo.m_BulletType[1] = _BulletName1;
    m_PlayerStartInfo.m_WeaponGadgetName[0] = _WeaponGadgetName0; m_PlayerStartInfo.m_WeaponGadgetName[1] = _WeaponGadgetName1;
    m_PlayerStartInfo.m_GadgetName[0] = _GadgetName0; m_PlayerStartInfo.m_GadgetName[1] = _GadgetName1;
    if (bShowLog) log(self@"SERVERSETPLAYERSTARTINFO weapons are :"$m_PlayerStartInfo.m_WeaponName[0]$" and "$m_PlayerStartInfo.m_WeaponName[1]);
}

event PostRender( canvas Canvas )
{
    local INT iBlurValue;
	local R6IOSelfDetonatingBomb AIt;//MissionPack1 2 temporary // MPF 1

    if (CheatManager != none)           // network play does not yet support cheatmanager
        R6CheatManager(CheatManager).PostRender( Canvas );

    if( Pawn != none )
    {
        if( Pawn.EngineWeapon != none ) 
        {
            Pawn.EngineWeapon.PostRender(Canvas);
        }

//R6MOTIONBLUR+
        iBlurValue = Pawn.m_fBlurValue + Pawn.m_fDecrementalBlurValue;
        iBlurValue = Clamp(iBlurValue, 0, 235);
        Canvas.SetMotionBlurIntensity(iBlurValue);
//R6MOTIONBLUR-
    }
    else
    {
//R6MOTIONBLUR+
        Canvas.SetMotionBlurIntensity(0);
//R6MOTIONBLUR-
    }

	// MissionPack1 2
	if(!m_bBombSearched)
	{
		foreach AllActors( class 'R6IOSelfDetonatingBomb', AIt )
		{
			m_pSelfDetonatingBomb = AIt;
		}
		if(Level.NetMode == NM_StandAlone) //MPF_Milan_8_4_2003 - added test, only for single player
	    // in multi coop mode, the timers are started by R6MultiPlayerGameInfo - MPF MILAN
		{
	        // in multi coop mode, the timers are started by R6MultiPlayerGameInfo - MPF MILAN
    	    if(m_pSelfDetonatingBomb != none /*&& GameReplicationInfo.m_szGameTypeFlagRep !=RGM_MissionMode*/ && Level.NetMode != NM_Client)

	        {
                foreach AllActors( class 'R6IOSelfDetonatingBomb', AIt )
                {
                    m_pSelfDetonatingBomb = AIt;
                    m_pSelfDetonatingBomb.StartTimer();
                }
            }

    		if(m_pSelfDetonatingBomb == none)
		    {
	    		if(GameReplicationInfo != None && GameReplicationInfo.m_szGameTypeFlagRep == "RGM_CountDownMode")
    			{
	//		    	R6CountDownGame(Level.game).StartTimer();
		    		R6AbstractGameInfo(Level.game).StartTimer();
	    		}
    		}
			
		} //MPF_Milan_8_4_2003 - end test
		m_bBombSearched = true;		
	}
	
	if(m_pSelfDetonatingBomb != none)
	{
		foreach AllActors( class 'R6IOSelfDetonatingBomb', AIt )
		{
			m_pSelfDetonatingBomb = AIt;
			if(m_pSelfDetonatingBomb.m_bIsActivated)
			{
				m_pSelfDetonatingBomb.PostRender(Canvas);
				break;
			}                                                 
		}
		foreach AllActors( class 'R6IOSelfDetonatingBomb', AIt )
		{
			m_pSelfDetonatingBomb = AIt;
			m_pSelfDetonatingBomb.PostRender2(Canvas);
		}
	}
	else if(GameReplicationInfo != None && GameReplicationInfo.m_szGameTypeFlagRep == "RGM_CountDownMode")
	{
		RenderTimeLeft(Canvas);
	}

	// End MissionPack1 2
} 

// --- MissionPack1 2
simulated function RenderTimeLeft(canvas C )
{
	local FLOAT fStrSizeX, fStrSizeY;
	local INT X, Y;
	local string sTime;
//	local int iMinsLeft, iSecsLeft;
	local int iTimeLeft;


	iTimeLeft = int(R6AbstractGameInfo(Level.game).m_fEndingTime - Level.TimeSeconds );

	if(iTimeLeft <0) 
		iTimeLeft = 0;
		
	sTime=  Localize("Game", "TimeLeft", "R6GameInfo") $ " "; //MPF_MIlan_8_25_2003 - was "R6GameMode"
    sTime = sTime $ ConvertIntTimeToString( iTimeLeft, true );

    C.UseVirtualSize(true, 640, 480);
    X = C.HalfClipX;
	Y = C.HalfClipY/8;//MPF_Milan_9_12_2003 - was /16
	C.Font = font'R6Font.Rainbow6_14pt'; 
	
	if ( iTimeLeft > 20 )
		C.SetDrawColor(255,255,255);    // white
	else if ( iTimeLeft > 10 )
		C.SetDrawColor(255,255,0);      // yellow
	else
		C.SetDrawColor(255,0,0);        // red

	C.StrLen( sTime, fStrSizeX, fStrSizeY );
	C.SetPos( X - fStrSizeX/2, Y + 24 );
	C.DrawText( sTime );

} 

// --- End MissionPack1 2


simulated function ServerActionKeyPressed()
{
    SetRequestedCircumstantialAction();
}


simulated function ServerActionKeyReleased()
{
    SetRequestedCircumstantialAction();
}

function ServerNewPing(int iNewPing)
{
    PlayerReplicationInfo.Ping = iNewPing;
}

event Tick(FLOAT fDeltaTime)
{
    local R6AbstractEviLPatchService.PatchState PatchState;

    if (m_bQuitToUpdateServerDisplayed == false)
    {
        if (Level.TimeSeconds - m_fLastUpdateServerCheckTime > 5)
        {
            m_fLastUpdateServerCheckTime = Level.TimeSeconds;
            PatchState = class'R6AbstractEviLPatchService'.static.GetState();
            if (PatchState == PS_RunPatch)
            {
                m_bQuitToUpdateServerDisplayed = true;
                HandleServerMsg(Localize("Options", "PatchStatus_RunPatch", "R6Menu"));
            }
        }
    }

	if(m_pawn != none && pawn != none)
    {
		UpdateCircumstantialAction();
        UpdateReticule(fDeltaTime);

        //MissionPack1
	    if(m_pawn.bInvulnerableBody)// && Role == ROLE_Authority)
		    if( Level.TimeSeconds - m_fStartSurrenderTime > 3)
			    m_pawn.bInvulnerableBody = false;
	    // End MissionPack1

    }
}

simulated event ZoneChange(ZoneInfo NewZone)
{
    local int i;

    if(Level.m_WeatherEmitter == none || Level.m_WeatherEmitter.Emitters.Length == 0 || Viewport(Player) == none)
        return;

    // disable old zone alternate weather emitters
    if(Region.Zone.m_bAlternateEmittersActive)
    {
        for(i=0; i<Region.Zone.m_AlternateWeatherEmitters.Length; i++)
        {
			if (Region.Zone.m_AlternateWeatherEmitters[i] != none)
			{
				Region.Zone.m_AlternateWeatherEmitters[i].Emitters[0].m_iPaused = 1;
				Region.Zone.m_AlternateWeatherEmitters[i].Emitters[0].AllParticlesDead = false;
	        }
        }
        Region.Zone.m_bAlternateEmittersActive = false;
    }

    // enable new zone alternate weather emitters
    if(!NewZone.m_bAlternateEmittersActive)
    {
        for(i=0; i<NewZone.m_AlternateWeatherEmitters.Length; i++)
        {
			if (NewZone.m_AlternateWeatherEmitters[i] != none)
			{
				NewZone.m_AlternateWeatherEmitters[i].Emitters[0].m_iPaused = 0;
				NewZone.m_AlternateWeatherEmitters[i].Emitters[0].AllParticlesDead = false;
	        }
        }
        NewZone.m_bAlternateEmittersActive = true;
    }
}

simulated function UpdateWeatherEmitter()
{
    local int               i;
    local bool              bInDoor;
    local vector            vViewDirection;
    local vector            vWeatherEmitterPos;
    local R6WeatherEmitter  WE;
    local ZoneInfo          WZ;

    if ( Level.m_WeatherEmitter == none )
        return;

    if ( Level.m_WeatherEmitter.Emitters.Length == 0 || Viewport(Player) == none)
        return;

    // if ViewTarget changed, we need to stop all weather emitters.
    if(Level.m_WeatherViewTarget != ViewTarget)
    {
        foreach AllActors(class'R6WeatherEmitter', WE)
        {
            if(WE != Level.m_WeatherEmitter && WE.Emitters.Length != 0)
            {
                WE.Emitters[0].m_iPaused = 1;
                WE.Emitters[0].AllParticlesDead = false;
            }
        }

        Level.m_WeatherViewTarget = ViewTarget;
    }

    // if the pawn is indoor, disable the weather emitter.
    if(ViewTarget.Region.Zone.m_bInDoor)
    {
        // disable outdoor weather emitter
        Level.SetWeatherActive(false);

        // enable alternate weather emitters in case we just switched to that player
        WZ = ViewTarget.Region.Zone;
        if(WZ.m_bAlternateEmittersActive == false)
        {
            for(i=0; i<WZ.m_AlternateWeatherEmitters.Length; i++)
            {
                if ( WZ.m_AlternateWeatherEmitters[i].Emitters.Length != 0 )
                {
                    WZ.m_AlternateWeatherEmitters[i].Emitters[0].m_iPaused = 0;
                    WZ.m_AlternateWeatherEmitters[i].Emitters[0].AllParticlesDead = false;
                }
            }
            WZ.m_bAlternateEmittersActive = true;
        }

        return;
    }
    // if the pawn is outdoor and in a weather volume, disablethe weather emitter.
    else if(ViewTarget.m_bInWeatherVolume > 0)
    {
        Level.SetWeatherActive(false);
    }
    // if the pawn is outdoor, enable and update the weather emitter.
    else if(ViewTarget.m_bInWeatherVolume == 0)
    {
        vWeatherEmitterPos = ViewTarget.Location;
        vViewDirection = vect(1,0,0) >> ViewTarget.Rotation;
        vWeatherEmitterPos.X += 256 * vViewDirection.X;
        vWeatherEmitterPos.Y += 256 * vViewDirection.Y;
        vWeatherEmitterPos.Z += 100; // altitude

        Level.m_WeatherEmitter.SetLocation(vWeatherEmitterPos);
        Level.SetWeatherActive(true);
    }
}

simulated function R6Shake( FLOAT fTime, FLOAT fMaxShake, FLOAT fMaxShakeTime )
{
    m_fShakeTime = fTime;
    m_fMaxShake = fMaxShake;
    m_fMaxShakeTime = fMaxShakeTime;
    m_fCurrentShake = 0;
}

function SetEyeLocation( Pawn pViewTarget, FLOAT fDeltaTime )
{
    local coords cEyesPos;

    cEyesPos = pViewTarget.GetBoneCoords('R6 PonyTail1');

	pViewTarget.m_vEyeLocation = cEyesPos.origin;
 
    if( m_fShakeTime > 0 )
    {
        if( m_fShakeTime > fDeltaTime )
        {
            m_fShakeTime -= fDeltaTime;
            if( m_fCurrentShake>fDeltaTime )
            {
                m_rHitRotation *= (m_fCurrentShake-fDeltaTime)/m_fCurrentShake;
                m_fCurrentShake -= fDeltaTime;
            }
            else
            {
                m_rHitRotation.Pitch = RandRange( -m_fMaxShake, m_fMaxShake );
                m_rHitRotation.Yaw = RandRange( -m_fMaxShake, m_fMaxShake );
                m_rHitRotation.Roll = RandRange( -m_fMaxShake, m_fMaxShake );
                m_fCurrentShake = RandRange(0, m_fMaxShakeTime);
            }
            m_fMaxShake *= (m_fShakeTime-fDeltaTime)/m_fShakeTime;
        }
        else
        {
            m_rHitRotation = rot(0,0,0);
            m_fShakeTime = 0.f;
        }
    }
    else if( m_fHitEffectTime > 0 )
    {
        if(m_fHitEffectTime > fDeltaTime)
        {
            m_rHitRotation *= (m_fHitEffectTime-fDeltaTime)/m_fHitEffectTime;
            m_fHitEffectTime -= fDeltaTime;
        }
        else
        {
            m_rHitRotation = rot(0,0,0);
            m_fHitEffectTime = 0.f;
        }
    }

    if( !pViewTarget.IsAlive() && !IsInState('PenaltyBox') )
        SetRotation(OrthoRotation(cEyesPos.XAxis, -cEyesPos.ZAxis, cEyesPos.YAxis));

    AdjustView(fDeltaTime);
}

event PlayerTick(FLOAT fDeltaTime)
{
    local int _iPingTime;

#ifndefSPDEMO    
    if ( (m_GameService!=none) && 
         (Viewport(Player) != none) && 
         (m_GameService.CallNativeProcessIcmpPing(WindowConsole(Player.Console).szStoreIP, _iPingTime) == true))
    {
        ServerNewPing(_iPingTime);
    }
#endif

//R6MOTIONBLUR+
    if(m_fBlurReturnTime != 0)
    {
        m_fTimedBlurValue -= fDeltaTime * m_iShakeBlurIntensity / m_fBlurReturnTime;
        if(m_fTimedBlurValue <= 0)
        {
            m_fTimedBlurValue = 0;
            m_fBlurReturnTime = 0;
        }

        Blur(m_fTimedBlurValue);
    }
//R6MOTIONBLUR-
    
    if(m_fMilestoneMessageLeft > 0)
    {
        m_fMilestoneMessageLeft -= fDeltaTime;
        if(m_fMilestoneMessageLeft < 0)
        {
            m_fMilestoneMessageLeft = 0;
            m_bDisplayMilestoneMessage = false;
        }
    } 

	if( (GameReplicationInfo != none) && (GameReplicationInfo.m_eCurrectServerState != GameReplicationInfo.RSS_InGameState) )
    {
        if ( m_MenuCommunication != none ) // in single player
            m_MenuCommunication.RefreshReadyButtonStatus();
        m_bReadyToEnterSpectatorMode = false;
    }

	if(m_bAttachCameraToEyes && !bBehindView)
	{
		// update true eye position 
		if(m_pawn != none)
		{
            SetEyeLocation( m_pawn, fDeltaTime );
#ifdefDEBUG
			m_pawn.UpdateBones();
#endif
		}
		else if((viewTarget!=none) && (viewTarget != self))
			SetEyeLocation( R6Pawn(viewTarget), fDeltaTime );
	}

	if((pawn != none) && !bOnlySpectator)
	{ 
		if(PlayerIsFiring() )
			pawn.m_bIsFiringWeapon = bFire;
		else
			pawn.m_bIsFiringWeapon = 0;
	}

    UpdateWeatherEmitter();
    Super.PlayerTick(fDeltaTime);
}

function InitMatineeCamera()
{
	m_bMatineeRunning = true;

	m_BackupTeamLeader = m_TeamManager.m_TeamLeader;
	m_TeamManager.m_TeamLeader = none;

}

function EndMatineeCamera()
{
	m_bMatineeRunning = false;
	m_TeamManager.m_TeamLeader = m_BackupTeamLeader;
}

function DisplayMilestoneMessage(int iWhoReached, INT iMilestoneNumber)
{
    local R6RainbowTeam aRainbowTeam;
    local R6Pawn.ERainbowOtherTeamVoices eVoices;

    aRainbowTeam = R6RainbowTeam(R6AbstractGameInfo(level.game).GetRainbowTeam(iWhoReached));

    if ((!aRainbowTeam.m_bLeaderIsAPlayer) && (aRainbowTeam.m_iMemberCount > 0) && (aRainbowTeam.m_OtherTeamVoicesMgr != none))
    {
        switch(iMilestoneNumber)
        {
            case 1:
                eVoices = ROTV_Objective1;
                break;
            case 2:
                eVoices = ROTV_Objective2;
                break;
            case 3:
                eVoices = ROTV_Objective3;
                break;
            case 4:
                eVoices = ROTV_Objective4;
                break;
            case 5:
                eVoices = ROTV_Objective5;
                break;
            case 6:
                eVoices = ROTV_Objective6;
                break;
            case 7:
                eVoices = ROTV_Objective7;
                break;
            case 8:
                eVoices = ROTV_Objective8;
                break;
            case 9:
                eVoices = ROTV_Objective9;
                break;
        }
        aRainbowTeam.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(aRainbowTeam.m_TeamLeader, eVoices);
    }
    else
    {
        // Localized that message
        m_szMileStoneMessage = Localize("Order","MilestoneReached","R6Menu")$iMilestoneNumber;
        m_bDisplayMilestoneMessage = true;
        m_fMilestoneMessageLeft = m_fMilestoneMessageDuration;
    }

}

// we need to do the appropriate animations for weapons,
simulated event RenderOverlays( canvas Canvas )
{
    if(Pawn != None)
    {
        if (Pawn.EngineWeapon != None)
        {
            Pawn.EngineWeapon.RenderOverlays(Canvas);
        }
    }

    if ( myHUD != None )
    {
        myHUD.RenderOverlays(Canvas);
    }
}

function ReloadWeapon()
{
    if ( Pawn.EngineWeapon == none )
        return; // in training basic, we don't have one

    if(!m_bLockWeaponActions &&
       !m_pawn.m_bPostureTransition &&
       !Pawn.EngineWeapon.IsA('R6Gadget')  &&
	   (m_pawn.m_eEquipWeapon == m_pawn.eEquipWeapon.EQUIP_Armed))
    {
        ToggleHelmetCameraZoom(TRUE);
        m_pawn.ServerSwitchReloadingWeapon(TRUE);
        ServerReloadWeapon();       // tell the server to reload the current weapon
        m_pawn.ReloadWeapon();
   }
}

function ServerReloadWeapon()       // reloads the current weapon
{
    if(Level.NetMode == NM_Standalone || Role == ROLE_Authority)
    {
        m_pawn.ServerSwitchReloadingWeapon(TRUE);
    }
}

///////////////////////////////////////////////////////////////////////////////////////
// GetFacingDirection()
// returns direction faced relative to movement dir
// 0 = forward, 16384 = right, 32768 = back, 49152 = left
// RBrek - 14 Aug 2001 - made a modification so that if player is 
//      strafing and moving forward the facing direction is forward...
///////////////////////////////////////////////////////////////////////////////////////
function int GetFacingDirection()
{
    local vector X,Y,Z, Dir;

    GetAxes(Pawn.Rotation, X,Y,Z);
    Dir = Normal(Pawn.Acceleration);
    if ( (Dir Dot X < 0.25) && (Dir != vect(0,0,0)) )
    {
        // strafing or backing up
        if ( Dir Dot X < -0.25 )
            return 32768;
        else if ( Dir Dot Y > 0 )
            return 16384;
        else
            return 49152;
    }

    return 0;
}

///////////////////////////////////////////////////////////////////////////////////////
// CalcSmoothedRotation()
// used for spectator camera to smooth turning
///////////////////////////////////////////////////////////////////////////////////////
function CalcSmoothedRotation()
{
	local   rotator rCurrent;
	local   INT		iDesiredYaw, iDesiredPitch;	
	local   INT		iOldYaw, iOldPitch;
	local	INT		iMaximum;

	iMaximum = 100000*m_fCurrentDeltaTime;
	rCurrent = rotation;
	
	//-------------------------------------------
	// smooth pitch rotation
	//-------------------------------------------
	iOldPitch = m_iSpectatorPitch;
	iDesiredPitch = rotation.pitch;
	if(iDesiredPitch > 32768)
		iDesiredPitch -= 65536;
	else if(iDesiredPitch < -32768)
		iDesiredPitch += 65536;
	
	if(iOldPitch > 32768)
		iOldPitch -= 65536;
	else if(iOldPitch < -32768)
		iOldPitch += 65536;
	
	if(abs(iDesiredPitch - iOldPitch) < iMaximum)
	{
		m_iSpectatorPitch = iDesiredPitch;
	}
	else
	{
		if(iDesiredPitch > iOldPitch)
			m_iSpectatorPitch = iOldPitch + iMaximum;
		else 
			m_iSpectatorPitch = iOldPitch - iMaximum;
	}
	rCurrent.pitch = m_iSpectatorPitch;
	
	//log(" iMaximum="$iMaximum$" iDesiredPitch="$iDesiredPitch$" iOldPitch="$iOldPitch$" m_fCurrentDeltaTime="$m_fCurrentDeltaTime$" (new) m_iSpectatorPitch="$m_iSpectatorPitch);
	//-------------------------------------------
	// smooth yaw rotation
	//-------------------------------------------
	iOldYaw = m_iSpectatorYaw & 65535;
	iDesiredYaw = rotation.yaw & 65535;
	if(iDesiredYaw < iOldYaw)
	{
		if((iOldYaw - iDesiredYaw) < 32768)
		{			
			//  normal turn left 
			if((iOldYaw - iDesiredYaw) < iMaximum)
				m_iSpectatorYaw = iDesiredYaw;
			else	
				m_iSpectatorYaw = iOldYaw - iMaximum;		
		}
		else
		{
			// wrap around - opposite direction
			iOldYaw -= 65536;
			if((iDesiredYaw - iOldYaw) < iMaximum)
				m_iSpectatorYaw = iDesiredYaw;
			else
				m_iSpectatorYaw = iOldYaw + iMaximum;
		}
	}
	else
	{
		if((iDesiredYaw - iOldYaw) < 32768)
		{
			// normal turn right
			if((iDesiredYaw - iOldYaw) < iMaximum)
				m_iSpectatorYaw = iDesiredYaw;
			else
				m_iSpectatorYaw = iOldYaw + iMaximum;
		}
		else
		{
			// wrap around - opposite direction
			iDesiredYaw -= 65536;
			if((iOldYaw - iDesiredYaw) < iMaximum)
				m_iSpectatorYaw = iDesiredYaw;
			else
				m_iSpectatorYaw = iOldYaw - iMaximum;
		}
	}
	rCurrent.yaw = m_iSpectatorYaw;
	SetRotation(rCurrent);
}

function CalcFirstPersonView( out vector CameraLocation, out rotator CameraRotation )
{
	local rotator	rAdjust;
	local rotator   rPitchOnly;

	if(bOnlySpectator)
	{
		if(R6Pawn(viewTarget).m_bIsPlayer)
		{			
			if(R6Pawn(viewTarget).IsAlive())
				CalcSmoothedRotation();		
		}
		CameraRotation = rotation;
		CameraLocation = ViewTarget.Location + Pawn(ViewTarget).EyePosition();
		return;
	}
// begin - case for death camera (MP)
	else if(pawn == none)
	{
		if(viewTarget != none && viewTarget != self)
		{
			CameraRotation = rotation;
			CameraLocation = R6Pawn(viewTarget).m_vEyeLocation;
		}
		return;
	}
// end - death camera (MP)
	
	// First-person view.
	if(bRotateToDesired)
	{
		CameraRotation = desiredRotation + pawn.m_rRotationOffset + m_rHitRotation;
	}
	else
	{						
		CameraRotation = rotation + pawn.m_rRotationOffset + m_rHitRotation;
	}

	// rbrek 26 nov 2001 - camera is now positioned at the true location of the eyes, based on the location of the 'R6 PonyTail1' bone...	
    if(m_bAttachCameraToEyes)
	{
		CameraLocation = pawn.m_vEyeLocation;   
	}
	else
	{
		CameraLocation = CameraLocation + pawn.EyePosition();
	}
}

function CheckBob(float DeltaTime, float Speed2D, vector Y)
{
	return;
}

// Bobbing is only used for rotation, to bring the weapon down when the character is walking
// All weapons are using only rotation, except pistols, where BobOffset is used
function WeaponBob(float BobDamping, out rotator BobRotation, out vector BobOffset)
{
    return;
}

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist;

#ifdefDEBUG
	// debug...
	if(m_bFixCamera == true)
	{
		CameraLocation = m_vCameraLocation;
		CameraRotation = m_rCameraRotation;
		return;
	}
#endif

	if(bOnlySpectator && ViewTarget != none)
	{
		if(R6Pawn(viewTarget).m_bIsPlayer && bFixedCamera)
			CalcSmoothedRotation();	
		CameraRotation = rotation;
	}
	else if(pawn != none)
	{
		if(bRotateToDesired)
			CameraRotation = desiredRotation + pawn.m_rRotationOffset;
		else
			CameraRotation = Rotation + pawn.m_rRotationOffset;
	}

	View = vect(1,0,0) >> CameraRotation;
	if( Trace( HitLocation, HitNormal, CameraLocation - Dist * vector(CameraRotation), CameraLocation ) != None )
		ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
	else
		ViewDist = Dist;
	CameraLocation -= ViewDist * View; 

	m_vCameraLocation = CameraLocation;
	m_rCameraRotation = CameraRotation;
}

///////////////////////////////////////////////////////////////////////////////////////
// DirectionChanged()
//   rbrek 25 oct 2001 
//   this function determines what the current diagonal direction is and return a bool
//   indicating whether the direction has changed.
///////////////////////////////////////////////////////////////////////////////////////
function bool DirectionChanged()
{
	local	R6Pawn.eStrafeDirection	eSDir;
 
	if(aForward > 0)
	{
		if(aStrafe > 0)
			eSDir = STRAFE_ForwardRight;			
		else
			eSDir = STRAFE_ForwardLeft;			
	}
	else
	{
		if(aStrafe > 0)
			eSDir = STRAFE_BackwardRight;			
		else
			eSDir = STRAFE_BackwardLeft;			
	}

	if(eSDir == m_pawn.m_eStrafeDirection)
		return false;

	m_pawn.m_eStrafeDirection = eSDir;
	return true;
}

///////////////////////////////////////////////////////////////////////////////////////
// AdjustViewPitch()
///////////////////////////////////////////////////////////////////////////////////////
simulated function AdjustViewPitch(out INT iPitch)
{
	iPitch = iPitch & 65535;
    if ((iPitch > 16384) && (iPitch < 49152))
    {
        if (aLookUp > 0) 
        {			
			iPitch = 16384;	// maximum pitch looking up
		}
        else
        {			
			iPitch = 49152;	// minimum pitch looking down
		}
    }
}

///////////////////////////////////////////////////////////////////////////////////////
// AdjustViewYaw()
///////////////////////////////////////////////////////////////////////////////////////
simulated function AdjustViewYaw(out INT iYaw)
{
	iYaw = iYaw & 65535;
    if(m_pawn.m_bIsClimbingLadder)
	{
		if((iYaw > 10923) && (iYaw < 54613))  // 120degree FOV
		{
			if(aTurn > 0)
				iYaw = 10923;
			else
				iYaw = 54613;
		}		
	}

	if(iYaw > 32768)
		iYaw -= 65536;
	else if(iYaw < -32768)
		iYaw += 65536;
}

///////////////////////////////////////////////////////////////////////////////////////
// HandleDiagonalStrafing()
// rbrek - 24 oct 2001
//   if the player is both strafing and moving forward/backward, bone rotation is used improve the appearance of the movement.
//   the entire skeleton (using root bone 'R6') is rotated to match the direction of the diagonal movement, and then the torso 
//   is rotated back to reflect the direction that the player is looking (which remains straight ahead).
//   returns true if bone rotation is done, false otherwise...
///////////////////////////////////////////////////////////////////////////////////////
function HandleDiagonalStrafing()
{
	if((aForward != 0) && (aStrafe != 0))
	{
		// DirectionChanged() must be called (first) in order to update the value of m_eStrafeDirection
		if(DirectionChanged() || !m_pawn.m_bMovingDiagonally)
		{				
			m_pawn.m_bMovingDiagonally = true;
			// the hardcoded value of 6000 will need to be modified if the movement speeds (forward,strafe,backward) change...
			m_pawn.AdjustPawnForDiagonalStrafing();
		}
	}
	else
	{
		// player is no longer moving diagonally, so reset the bone rotation to normal (do this once only)
		if(m_pawn.m_bMovingDiagonally)
			m_pawn.ResetDiagonalStrafing();
	}
}

///////////////////////////////////////////////////////////////////////////////////////
// PassedYawLimit()
// rbrek - 10 april 2002
///////////////////////////////////////////////////////////////////////////////////////
simulated function bool PassedYawLimit(rotator rRotationOffset)
{
	if(m_pawn.m_bIsClimbingLadder)
		return false;
	else
	{
		if(abs(rRotationOffset.yaw) > 0)
			return true;
	}
	return false;
}

//------------------------------------------------------------------
// SetCrouchBlend: set peeking info (single player and multiplayed)
//	
//------------------------------------------------------------------
event SetCrouchBlend( FLOAT fCrouchBlend )
{
    m_pawn.SetCrouchBlend( fCrouchBlend );

    if (level.NetMode != NM_Standalone)
        ServerSetCrouchBlend( fCrouchBlend );
}

function ServerSetCrouchBlend( FLOAT fCrouchBlend )
{
    if ( m_pawn == none )
        return;

    m_pawn.SetCrouchBlend( fCrouchBlend );
}


//------------------------------------------------------------------
// SetPeekingInfo: set peeking info (single player and multiplayed)
//	
//------------------------------------------------------------------
function SetPeekingInfo(R6Pawn.ePeekingMode eMode, FLOAT fPeekingRatio, OPTIONAL bool bPeekLeft)
{
    local BYTE PackedPeekingRatio;
    local FLOAT fNormalizedPeekingRatio;

    if ( m_pawn == none )
        return;

    m_pawn.SetPeekingInfo(eMode, fPeekingRatio, bPeekLeft);

    if(level.NetMode != NM_Standalone)
    {
        fNormalizedPeekingRatio = ((fPeekingRatio - m_pawn.C_fPeekLeftMax) / (m_pawn.C_fPeekRightMax - m_pawn.C_fPeekLeftMax)) * 254.0f;
        PackedPeekingRatio = fNormalizedPeekingRatio;
        if(bPeekLeft)
            ServerSetPeekingInfoLeft(eMode, PackedPeekingRatio);
        else
            ServerSetPeekingInfoRight(eMode, PackedPeekingRatio);
    }
}

//------------------------------------------------------------------
// SetPeekingInfo: set peeking info 
//	
//------------------------------------------------------------------
function ServerSetPeekingInfoLeft(R6Pawn.ePeekingMode eMode, BYTE PackedPeekingRatio)
{
    local FLOAT fPeekingRatio;

    if ( m_pawn == none )
        return;

    fPeekingRatio = PackedPeekingRatio;
    fPeekingRatio = ((fPeekingRatio / 254.0f) * (m_pawn.C_fPeekRightMax - m_pawn.C_fPeekLeftMax)) + m_pawn.C_fPeekLeftMax;
    m_pawn.SetPeekingInfo( eMode, fPeekingRatio, true );
}

function ServerSetPeekingInfoRight(R6Pawn.ePeekingMode eMode, BYTE PackedPeekingRatio)
{
    local FLOAT fPeekingRatio;
    
    if ( m_pawn == none )
        return;

    fPeekingRatio = PackedPeekingRatio;
    fPeekingRatio = ((fPeekingRatio / 254.0f) * (m_pawn.C_fPeekRightMax - m_pawn.C_fPeekLeftMax)) + m_pawn.C_fPeekLeftMax;
    m_pawn.SetPeekingInfo( eMode, fPeekingRatio, false );
}


//------------------------------------------------------------------
// ServerSetBipodRotation: set the int for replication
//	
//------------------------------------------------------------------
function ServerSetBipodRotation( float fRotation )
{
    if(m_pawn != none)
        m_pawn.m_iRepBipodRotationRatio = fRotation / m_pawn.C_iRotationOffsetBiPod * 100;
}

function bool PlayerIsFiring()
{
	if(Pawn.EngineWeapon == none)
		return false;

	if((bFire > 0) && Pawn.EngineWeapon.NumberOfBulletsLeftInClip() > 0)
		return true;

	return false;
}

///////////////////////////////////////////////////////////////////////////////////////
// UpdateRotation()
///////////////////////////////////////////////////////////////////////////////////////
simulated function UpdateRotation(float DeltaTime, float maxPitch)
{
	local rotator   rNewRotation, rViewRotation;
	local rotator	rRotationOffset;
	local bool		bBoneRotationIsDone;
    local float     fOffset;
    local float     fBipodRotationToAdd;
    local R6AbstractWeapon aWeapon;

	if(bCheatFlying)
	{
		Super.UpdateRotation(deltaTime, maxPitch);
		return;
	}

	if ( bInterpolating || ((pawn != none) && pawn.bInterpolating) )
		return;

	if(m_pawn == none)
		return;

    rRotationOffset = pawn.m_rRotationOffset;

    // prevent player from turning when in the process of changing posture (so that animation plays uninterrupted)
	if ( m_pawn.m_bPostureTransition )
		aTurn = 0;

    if ( m_pawn.m_bUsingBipod )
    {
        fBipodRotationToAdd = 32.0 * DeltaTime;
        desiredRotation.yaw = rotation.yaw;

        // if moving, return to zero
        if ( pawn.velocity != vect(0,0,0) )
        {
            fBipodRotationToAdd *= 2000; // return to center quickly
            
            if ( m_pawn.m_fBipodRotation == 0 )
            {
                // perfect! nothing to do
            }
            else if ( m_pawn.m_fBipodRotation > 0 )
            {
                m_pawn.m_fBipodRotation -= fBipodRotationToAdd;
                m_pawn.m_fBipodRotation = FClamp( m_pawn.m_fBipodRotation, 0, m_pawn.m_fBipodRotation );
            }
            else
            {
                m_pawn.m_fBipodRotation += fBipodRotationToAdd;
                m_pawn.m_fBipodRotation = FClamp( m_pawn.m_fBipodRotation, m_pawn.m_fBipodRotation, 0 );
            }
        }
        else
        {
            m_pawn.m_fBipodRotation += fBipodRotationToAdd * aTurn;
        
            if ( m_pawn.m_fBipodRotation > m_pawn.C_iRotationOffsetBiPod )
            {
                m_pawn.m_fBipodRotation = m_pawn.C_iRotationOffsetBiPod;
            }
            else if ( m_pawn.m_fBipodRotation < -m_pawn.C_iRotationOffsetBiPod )
            {
                m_pawn.m_fBipodRotation = -m_pawn.C_iRotationOffsetBiPod;
            }
        }
        ServerSetBipodRotation( m_pawn.m_fBipodRotation );    
    }
    // RBrek - 20 July 2001 - if player is using the fluid movement key, 
    // disable the ability to look using the mouse... (keep yaw and pitch fixed)
    else if( m_bSpecialCrouch > 0 && !m_pawn.m_bIsProne ) // when prone, fluid doesn't work
    {
        aTurn = 0;
        aLookUp = 0;
    }

    //make sure the gadget is following the character
    aWeapon = R6AbstractWeapon(Pawn.EngineWeapon);
    
    rViewRotation = Rotation + rRotationOffset;
	rViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
	if(!Level.m_bInGamePlanningActive)
		rViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
	AdjustViewPitch(rViewRotation.Pitch); 

	//-------------------------------------------------------------------------------------------------
	// PEEKING
    // RBrek - 20 July 2001 - the following serves to tilt the camera when the player is peeking
    //                        This way the player when in first person view, can tell they are peeking 
    rViewRotation.roll = 0;    
    if(!bBehindView && (m_pawn.m_fPeeking != m_pawn.C_fPeekMiddleMax))
    {
		rViewRotation.roll = m_pawn.GetPeekingRatioNorm( m_pawn.m_fPeeking )*2049; 			
    }
	//-------------------------------------------------------------------------------------------------

    rRotationOffset = rViewRotation - rotation;
	AdjustViewYaw(rRotationOffset.yaw);		// center the yaw around zero (- & +)

    if(bRotateToDesired)
	{
		// if the desiredRotation has not yet been reached, allow the physics to perform the rotation...
		desiredRotation.yaw = desiredRotation.yaw & 65535;
		if(rotation.yaw != desiredRotation.yaw)
		{			
			pawn.m_rRotationOffset = rRotationOffset;					
			return;
		}
	}

    bRotateToDesired=false;   

	if((pawn.acceleration != vect(0,0,0) || (aForward != 0) || (aStrafe != 0)) && !m_pawn.m_bIsClimbingLadder)
	{	
        if(m_pawn.m_bIsProne) // when prone, the rotation is blocked to a m_iMaxRotationOffset.
        {
			rRotationOffset.yaw = Clamp(rRotationOffset.yaw, -m_pawn.m_iMaxRotationOffset, m_pawn.m_iMaxRotationOffset);
			if(m_pawn.m_bUsingBipod)
			{
				// is over max limit, set the limit
				//looking up pitch range between 0 and 16384,  max range is 22.5 degrees (5461)
				if((rRotationOffset.Pitch > 5461) && (rRotationOffset.Pitch < 18001))
				{
					rRotationOffset.Pitch = 5461;
				}
				//looking down pitch range between 65536 and 49152, and max is 61349;
				if((rRotationOffset.Pitch < 60075) && (rRotationOffset.Pitch > 49000))
				{
					rRotationOffset.Pitch = 60075;
				}
			}				
			
            // if the rotation offset is not 0 (ie: centered with the pawn)
            // slowly brings back the rotation offset to the center of the pawn 
            if ( rRotationOffset.yaw != 0 )
            {
                desiredRotation.Yaw = m_pawn.Rotation.yaw;
                if ( rRotationOffset.yaw > 0 )
                {
					fOffset = Clamp( rRotationOffset.yaw, 0, MAX_ProneSpeedRotation*DeltaTime ); 
				}
                else
                {
					fOffset = Clamp( rRotationOffset.yaw, -MAX_ProneSpeedRotation*DeltaTime, 0 );
				}
                rRotationOffset.yaw -= fOffset;
                desiredRotation.yaw += fOffset;
            }
        }
        else
        {
		    // player is moving, so reset rRotationOffset yaw to zero, but allow for pitch controlled head movement
		    rRotationOffset.yaw = 0;  

		    // set the rotation, excluding the pitch component... (pitch component should only exist in the rRotationOffset)
		    desiredRotation.Yaw = rViewRotation.yaw;
        }
		desiredRotation.pitch = 0;
		desiredRotation.roll = 0;
		
        HandleDiagonalStrafing();

		if(rotation.yaw != desiredRotation.yaw)
		{
            SetRotation(desiredRotation);  
			bRotateToDesired = true;
		}
		else if(!bBehindView)
		{
			pawn.FaceRotation(desiredRotation, deltatime);
		}

		if(!bBoneRotationIsDone && m_pawn.m_bMovingDiagonally && !m_pawn.m_bIsProne )
		{
			if((m_pawn.m_eStrafeDirection == STRAFE_ForwardRight) || (m_pawn.m_eStrafeDirection == STRAFE_BackwardLeft))
				rRotationOffset.yaw = -6000;
			else
				rRotationOffset.yaw = 6000;
			m_pawn.PawnLook(rRotationOffset,true,true);
			rRotationOffset.yaw = 0;
            bBoneRotationIsDone = true;			
		}

		// rbrek 28 feb 2002 - if the player has a gadget activated, then the weapon should follow the head at all times in order
		//		that the 1st person view and 3rd person view remain consistent.
		if(!m_pawn.m_bMovingDiagonally && (PlayerIsFiring() || m_pawn.GunShouldFollowHead()))
		{
			m_pawn.PawnLook(rRotationOffset,true,true);
			bBoneRotationIsDone = true;
		}
	}
    else if ( m_pawn.m_bIsProne ) // prone: the body doesn't rotate, only the torso.
    {
        rRotationOffset.yaw = Clamp(rRotationOffset.yaw, -m_pawn.m_iMaxRotationOffset, m_pawn.m_iMaxRotationOffset);
        if(m_pawn.m_bUsingBipod)
		{
			//looking up pitch range between 0 and 18000,  Max range is 22.5 degrees (5461)
			if((rRotationOffset.Pitch > 5461) && (rRotationOffset.Pitch < 18001))
			{
				rRotationOffset.Pitch = 5461;
			}
			//looking down pitch range between 65536 and 49152, and max is 61349;
			if((rRotationOffset.Pitch < 60075) && (rRotationOffset.Pitch > 49000))
			{
				rRotationOffset.Pitch = 60075;
			}
		}

		if(PlayerIsFiring())
		{
			// ensure that gun is aiming in same direction as head is looking...
			m_pawn.PawnLook(rRotationOffset,true,false); 
			bBoneRotationIsDone = true;
		}
    }
	else if(aForward == 0 && aStrafe == 0 && m_pawn.m_bMovingDiagonally)
	{
		HandleDiagonalStrafing(); 		
	}
	else if( PassedYawLimit(rRotationOffset) || ( rRotationOffset.yaw != 0 && m_pawn.IsPeeking() ) ) //  if peeking AND doing a rotation
	{		
		// new rotation should only include the change in yaw (turning right/left)
		// any adjustment up or down should only exist in the m_rRotationOffset
		rNewRotation = rotation + rRotationOffset;
		rNewRotation.pitch = 0;
        rNewRotation.roll = 0;

        SetRotation(rNewRotation); 
			
		// perform a true rotation using the new yaw...
		desiredRotation = rViewRotation;
		desiredRotation.pitch = 0;
		desiredRotation.Roll = 0;
		bRotateToDesired = true;

		// reset the yaw to zero, since the rotation we will perform on the pawn now is only right/left not up/down...      
		rRotationOffset.yaw = 0;  
		m_pawn.PawnLook(rRotationOffset,,);
		bBoneRotationIsDone = true;
	}
    
    if(m_bShakeActive == true)
    {
        R6ViewShake(deltaTime, rRotationOffset);
    }
	
    // check if player is moving diagonally (bone rotation may have already been done)
	if(!bBoneRotationIsDone)
	{
        m_pawn.PawnLook(rRotationOffset,,true);  // TODO: remove blend (true) but this causes a problem with diagonal strafing
	}

	ViewFlash(deltaTime);
	rNewRotation = rViewRotation;
    rNewRotation.Roll = 0; 

	if ( !bRotateToDesired && (pawn != none) && (!bFreeCamera || !bBehindView) )
		if(rRotationOffset.yaw == 0.f)
			pawn.FaceRotation(rNewRotation, deltatime);

    pawn.m_rRotationOffset = rRotationOffset;
}

function ResetFluidPeeking()
{
    if ( m_pawn.m_ePeekingMode == PEEK_fluid ) 
    {
        SetPeekingInfo( PEEK_none, m_pawn.C_fPeekMiddleMax ); 
        SetCrouchBlend( 0 );
    }
}

function HandleFluidMovement(float deltaTime)
{
    local FLOAT fCrouchRate;
    local FLOAT fPeekingRate;
    local FLOAT fBlendAlpha;
    
	if(m_pawn == none)
		return;

    if ( m_pawn.m_ePeekingMode == PEEK_full || !m_pawn.canPeek() )
        return;
    
	if((m_bSpecialCrouch > 0) && !m_pawn.m_bIsProne )
    {
        if ( m_pawn.m_ePeekingMode == PEEK_none )
        {
            // reset value of the blend
            if ( pawn.bIsCrouched )
                SetCrouchBlend( 1 );
            else
                SetCrouchBlend( 0 );

            // in fluid posture the pawn cann not have bIsCrouched set to true
            if (pawn.bIsCrouched)
                bDuck = 0;
        }
        fCrouchRate = m_pawn.m_fCrouchBlendRate;  
        fCrouchRate -= (aMouseY*DeltaTime)/m_iFluidMovementSpeed; 
        fCrouchRate = FClamp( fCrouchRate, 0, 1.0 );
        
        fPeekingRate = m_pawn.GetPeekingRatioNorm( m_pawn.m_fPeeking );  
        
        fPeekingRate += (aMouseX*DeltaTime)/m_iFluidMovementSpeed;
        fPeekingRate = FClamp( fPeekingRate, -1, 1 );

        // denormalized the rate
        fPeekingRate *= m_pawn.C_fPeekMiddleMax;
        fPeekingRate += m_pawn.C_fPeekMiddleMax;

        // if crouching 
        fPeekingRate = FClamp( fPeekingRate, m_pawn.C_fPeekLeftMax, m_pawn.C_fPeekRightMax );
        
        // needed for replication
        SetPeekingInfo( PEEK_fluid, fPeekingRate ); 
        
        // update the fluid peeking info now: gives better result
        SetCrouchBlend( fCrouchRate );
    }
}


//---------------------------------------------------------------------------------------//
//                          INPUT exec() functions (controls)                            //
//---------------------------------------------------------------------------------------//
exec function ToggleTeamHold()
{
	if(m_TeamManager == none)
		return;
	
	if(m_TeamManager.m_iMemberCount == 1)
		return;

	if(bOnlySpectator || bCheatFlying)
		return;	

    if(m_TeamManager.m_bTeamIsHoldingPosition && !m_TeamManager.m_Team[1].controller.IsInState('FollowLeader')) 
    {
        #ifdefDEBUG if(bShowLog) log(" ...instruct team to stop holding and to follow leader/player");	#endif
        m_TeamManager.InstructPlayerTeamToFollowLead();
    }
    else
    {
        #ifdefDEBUG if(bShowLog) log(" ...instruct team to hold position and not follow leader/player");	#endif
        m_TeamManager.InstructPlayerTeamToHoldPosition();
    }
}

exec function ToggleAllTeamsHold()
{
    local   R6RainbowTeam       AITeam;

    ToggleTeamHold();
    if(Level.NetMode != NM_Standalone)
        return;

    if(m_bAllTeamsHold)
    {
        m_bAllTeamsHold=false;
        #ifdefDEBUG if(bShowLog) log(" ...instruct AI team to stop holding position and to continue with their planning...");	#endif
        if(R6AbstractGameInfo(level.game) != none)
			R6AbstractGameInfo(level.game).InstructAllTeamsToFollowPlanning();
    }
    else
    {
        m_bAllTeamsHold=true;
        #ifdefDEBUG if(bShowLog) log(" ...instruct AI team to hold current position and to continue with their planning...");	#endif
        if(R6AbstractGameInfo(level.game) != none)
			R6AbstractGameInfo(level.game).InstructAllTeamsToHoldPosition();
    }
}

exec function ToggleSniperControl()
{
    local   R6RainbowTeam   aRainbowTeam;
	local   INT             i;
	local	INT				iNbTeam;

	if(Level.NetMode == NM_Standalone)
	{
		for(i=0; i<3; i++)
		{
    	    aRainbowTeam = R6RainbowTeam(R6AbstractGameInfo(level.game).GetRainbowTeam(i));
            if (aRainbowTeam != none && aRainbowTeam.m_iMemberCount > 0)
            {
				aRainbowTeam.m_bSniperHold = !aRainbowTeam.m_bSniperHold;
				#ifdefDEBUG if(bShowLog) log(aRainbowTeam$"  aRainbowTeam.m_bSniperHold="$aRainbowTeam.m_bSniperHold);	#endif
                iNbTeam++;
            }
        }
        
        if (iNbTeam > 1)
            m_TeamManager.PlaySniperOrder();
	}
}

exec function TeamsStatus()
{
	local R6RainbowTeam aRainbowTeam[3];
	local INT i;
	local INT iNbTeam;

    if (Level.NetMode == NM_Standalone)
    {
        for(i=0; i<3; i++)
        {
    	    aRainbowTeam[i] = R6RainbowTeam(R6AbstractGameInfo(level.game).GetRainbowTeam(i));
            if (aRainbowTeam[i] != none && aRainbowTeam[i].m_iMemberCount > 0)
                iNbTeam++;
        }

        if (iNbTeam > 1)
        {
            m_TeamManager.PlaySoundTeamStatusReport();
            for(i=0; i<3; i++)
		    {
                if ((aRainbowTeam[i] != none) && (m_TeamManager != aRainbowTeam[i]))
                    aRainbowTeam[i].PlaySoundTeamStatusReport();
		    }	
        }
    }
}

exec function GoCodeAlpha()
{
    if (Level.NetMode == NM_StandAlone)
    {
        ServerSendGoCode(GOCODE_Alpha);
    }
}

exec function GoCodeBravo()
{
    if (Level.NetMode == NM_StandAlone)
    {
        ServerSendGoCode(GOCODE_Bravo);
    }
}

exec function GoCodeCharlie()
{
    if (Level.NetMode == NM_StandAlone)
    {
        ServerSendGoCode(GOCODE_Charlie);
    }
}

exec function GoCodeZulu()
{
    ServerSendGoCode(GOCODE_Zulu);
}

function ServerSendGoCode(EGoCode eGo)
{
	local R6RainbowTeam aRainbowTeam;
	local INT i;

    m_TeamManager.PlayGoCode(eGo);
    Player.Console.SendGoCode(eGo);
    if (eGo == GOCODE_Zulu)
    {
        if (Level.NetMode == NM_StandAlone)
        {
            for(i=0; i<3; i++)
		    {
			    aRainbowTeam = R6RainbowTeam(R6AbstractGameInfo(level.game).GetRainbowTeam(i));
                if (aRainbowTeam != none)
                    aRainbowTeam.ReceivedZuluGoCode();
		    }	
        }
        else if (m_TeamManager != none)
        {
            m_TeamManager.ReceivedZuluGoCode();
        }
    }
}

exec function SkipDestination()
{
    if(bOnlySpectator==false)
        m_pawn.GetTeamMgr().m_TeamPlanning.SkipCurrentDestination();
}

exec function NextTeam()
{
	ChangeTeams(true);
}

exec function PreviousTeam()
{
	ChangeTeams(false);
}

exec function RegroupOnMe()
{
	if(m_TeamManager == none)
		return;

	if(bOnlySpectator || bCheatFlying)
		return;	

    if( !m_TeamManager.m_Team[0].IsAlive() )
    {		
		// log if all members are dead, then switch to the other team if there is one...
        if(m_TeamManager.m_iMemberCount > 0)
		{
			// if we are switching to our AI backup in MP
			if(Level.NetMode != NM_Standalone)
				ClientShowWeapon();
			m_TeamManager.SwitchPlayerControlToNextMember();
		}
		else
            ChangeTeams(true);		
    }
	// if team is on ladder, ignore any regroup order...
    else if(!m_TeamManager.m_bTeamIsClimbingLadder)
        m_TeamManager.InstructPlayerTeamToFollowLead();
}

exec function NextMember()
{
    if(m_bCanChangeMember == true)
    {
        Pawn.EngineWeapon.StopFire(false);
        
        ServerNextMember();

        if(Level.NetMode != NM_Standalone)
        {
            m_bCanChangeMember = false;
            SetTimer(1.0, false);
        }
    }
}

exec function PreviousMember()
{
    if(m_bCanChangeMember == true)
    {
        Pawn.EngineWeapon.StopFire(false);

        ServerPreviousMember();

        if(Level.NetMode != NM_Standalone)
        {
            m_bCanChangeMember = false;
            SetTimer(1.0, false);
        }
    }
}

function Timer()
{
    m_bCanChangeMember = true;
}

function ChangeOperative(INT iTeamId, INT iOperativeId)
{
    ServerChangeOperative(iTeamId, iOperativeId);
}

function ServerChangeOperative(INT iTeamId, INT iOperativeId)
{
	R6AbstractGameInfo(level.game).ChangeOperatives(self, iTeamId, iOperativeId);
}

exec function GraduallyOpenDoor()
{
	if(m_pawn == none)
		return;

    if( !m_pawn.m_bIsProne && !m_pawn.m_bChangingWeapon && !m_pawn.m_bReloadingWeapon && !Level.m_bInGamePlanningActive)
		ServerGraduallyOpenDoor(m_bSpeedUpDoor);
}
    
exec function GraduallyCloseDoor()
{
	if(m_pawn == none)
		return;

	if( !m_pawn.m_bIsProne && !m_pawn.m_bChangingWeapon && !m_pawn.m_bReloadingWeapon && !Level.m_bInGamePlanningActive)
		ServerGraduallyCloseDoor(m_bSpeedUpDoor);
}

exec function RaisePosture()
{	
	if(m_pawn == none)
		return;
	
	if(m_bSpecialCrouch > 0)
		return;
	
	// prevent player from raising posture a second time if already in the process of doing so.
	if((m_pawn.m_bPostureTransition && !m_pawn.m_bIsLanding) 
		|| ( m_pawn.m_bIsProne 
		     && (m_Pawn.EngineWeapon != none) 
			 && R6AbstractWeapon(m_Pawn.EngineWeapon).GotBipod() 
			 && m_bLockWeaponActions )
        || ( m_pawn.m_bIsProne &&m_pawn.m_bChangingWeapon ))
		    return;

	if ( m_pawn.m_bIsProne )
	{
		aForward = 0;
		aStrafe = 0;
		aTurn = 0;
		pawn.acceleration = vect(0,0,0);
	}

    if ( m_pawn.m_ePeekingMode == PEEK_fluid )
    {
        // check if can raise
        if ( !m_pawn.AdjustFluidCollisionCylinder(0, true ))
        {
            return; // cannot raise
        }

        m_pawn.AdjustFluidCollisionCylinder(0);
        ResetFluidPeeking();
    }
    

    if(m_bCrawl)
    {
        // prone --> crouched
        m_bCrawl = false;  
		bDuck = 1;

        // stop peeking when doing the posture transition
        if( m_pawn.m_ePeekingMode == PEEK_full )
            SetPeekingInfo( PEEK_none, m_pawn.C_fPeekMiddleMax );
    }
    else if(bDuck == 1)
    {
        // crouched --> upright
        bDuck = 0;  
		R6Pawn(Pawn).CrouchToStand();
    }
}
 
exec function LowerPosture()
{
	if(m_pawn == none)
		return;

	if(m_bSpecialCrouch > 0)
		return;

    if((bDuck == 1) 
		&& (m_Pawn.EngineWeapon != none) 
		&& R6AbstractWeapon(m_Pawn.EngineWeapon).GotBipod() 
		&& m_bLockWeaponActions)
        return;

    if ( m_pawn.m_ePeekingMode == PEEK_fluid )
    {        
        if(bDuck == 0) // will go crouched
        {
            m_pawn.AdjustFluidCollisionCylinder(0.96); // not 1 so the even crouch will be processed
        }
        
        // reset the special crouching...    
        ResetFluidPeeking();
    }

	if(bDuck == 0)
    {
        // upright --> crouched
		bDuck = 1; 
		R6Pawn(Pawn).StandToCrouch();
    }
    else if(!m_bCrawl)
    {
        // crouched --> prone
        if( m_pawn.m_ePeekingMode == PEEK_full )
        {
            SetPeekingInfo( PEEK_none, m_pawn.C_fPeekMiddleMax );
        }
        m_bCrawl = true;   
    }
} 


exec function Zoom()
{
    ToggleHelmetCameraZoom();
}

exec function ToggleAutoAim()
{
    if( Level.NetMode == NM_Standalone )
    {
        m_wAutoAim++;
        if(m_wAutoAim>3)
            m_wAutoAim = 0;
        ClientGameMsg( "", "", "AutoAim" $ m_wAutoAim );

		class'Actor'.static.GetGameOptions().AutoTargetSlider = m_wAutoAim;
    }
    else
        m_wAutoAim = 0;
}

exec function ChangeRateOfFire()
{
    if (Pawn.EngineWeapon != None)
    {
        Pawn.EngineWeapon.SetNextRateOfFire();
    }
}

exec function PrimaryWeapon()
{
    SwitchWeapon(1);
}

exec function SecondaryWeapon()
{
    SwitchWeapon(2);
}

exec function GadgetOne()
{
    SwitchWeapon(3);
}

exec function GadgetTwo()
{
    SwitchWeapon(4);
}

#ifdefDEBUG
exec function ShowMe()
{
	//bShowlog = true;
	log(self$" PLAYERCONTROLLER :	*********  state="$GetStateName()$" viewTarget="$viewTarget$" pawn="$pawn$" m_pawn="$m_pawn);	
	log("						*********  bOnlySpectator="$bOnlySpectator);
	log("						********* GameReplicationInfo="$GameReplicationInfo);
	log("               m_CurrentCircumstantialAction.aQueryTarget="$m_CurrentCircumstantialAction.aQueryTarget);
	log("			--	Player.Console="$Player.Console$" WindowConsole(Player.Console).ConsoleState="$WindowConsole(Player.Console).ConsoleState);
	if(bOnlySpectator)
		log("      SPECTATOR : viewTarget="$viewTarget$" m_eCameraMode="$m_eCameraMode);		

	if(m_pawn != none)
	{
		log("  DOORS : m_pawn.m_Door="$m_pawn.m_Door$" m_pawn.m_Door2="$m_pawn.m_Door2);
		log(" m_bIsClimbingLadder="$m_pawn.m_bIsClimbingLadder$" pawn.physics="$pawn.physics$" m_pawn.m_bIsLanding="$m_pawn.m_bIsLanding);
		log("						***************** m_pawn.m_bWeaponTransition="$m_pawn.m_bWeaponTransition);
		log("						***************** m_pawn.m_bPostureTransition="$m_pawn.m_bPostureTransition);
		log("						***************** m_pawn.m_ePlayerIsUsingHands="$m_pawn.m_ePlayerIsUsingHands);
	}
}
#endif

///////////////////////////////////////////////////////////////////////////////////////
// rbrek 26 oct 2001
// TeamMovementMode()  
//   player can change the current movement mode 
//   cycles through the ROE: SPEED_Blitz, SPEED_Normal, SPEED_Cautious
///////////////////////////////////////////////////////////////////////////////////////
exec function TeamMovementMode()
{
	if(m_TeamManager == none)
		return;

	switch(m_TeamManager.m_eMovementSpeed)
	{
		case SPEED_Blitz:		m_TeamManager.m_eMovementSpeed = SPEED_Normal;		break;
		case SPEED_Normal:		m_TeamManager.m_eMovementSpeed = SPEED_Cautious;	break;
		case SPEED_Cautious:	m_TeamManager.m_eMovementSpeed = SPEED_Blitz;		break;		
	}
}

///////////////////////////////////////////////////////////////////////////////////////
// rbrek 26 oct 2001
// RulesOfEngagement()  
//   player can change the current rule of engagement 
//   cycles through the ROE: MOVE_Assault, MOVE_Infiltrate, MOVE_Recon
///////////////////////////////////////////////////////////////////////////////////////
exec function RulesOfEngagement()
{
	if(m_TeamManager == none)
		return;

	switch(m_TeamManager.m_eMovementMode)
	{
		case MOVE_Assault:		m_TeamManager.m_eMovementMode = MOVE_Infiltrate;	break;
		case MOVE_Infiltrate:	m_TeamManager.m_eMovementMode = MOVE_Recon;			break;
		case MOVE_Recon:		m_TeamManager.m_eMovementMode = MOVE_Assault;		break;		
	}
}

///////////////////////////////////////////////////////////////////////////////////////
// ResetSpecialCrouch() 
// reset the Special Crouch mode:  stop peeking, and return to either upright or crouching,
// depending on which position is closer
///////////////////////////////////////////////////////////////////////////////////////
function ResetSpecialCrouch()
{
    if( m_pawn.m_ePeekingMode != PEEK_fluid )
        return;

    // we are closer to be crouch, go crouch.
    if ( m_pawn.m_fCrouchBlendRate >= 0.5 )
    {
        bDuck = 1;
    }
    else
    {
        // check if we can stand up
        if ( m_pawn.AdjustFluidCollisionCylinder( 0, true ) )
        {
            bDuck = 0; 
        }
        else // failed to stand up, duck
        {
            bDuck = 1;
        }
    }

    if ( bDuck == 1 )
    {
        // not 1.0, so the event Crouch can be processed
        m_pawn.AdjustFluidCollisionCylinder( 0.96 ); 
    }
    else
    {
        m_pawn.AdjustFluidCollisionCylinder( 0 );
    }

    ResetFluidPeeking();
}

exec function PlayFiring()
{
    if ((pawn != None) && (GameReplicationInfo.m_bGameOverRep==false))
    {        
        Pawn.EngineWeapon.Fire(0);
    }
}

exec function PlayAltFiring()
{
    if (Pawn.EngineWeapon != None)
    {
        Pawn.EngineWeapon.AltFire(0);
    }
}


exec function CycleHUDLayer()
{
	R6AbstractHUD(myHUD).CycleHUDLayer();
}

exec function ToggleHelmet()
{
	R6AbstractHUD(myHUD).ToggleHelmet();
}

#ifdefDEBUG
exec function ToggleRestart()
{
    Level.Game.ToggleRestart();
}
#endif


// purely for testing stats page
#ifdefDEBUG
exec function SetFragStat(int iStat)
{
    if ((Level.Game!=none) && (Level.Game.m_bCompilingStats==true) && (PlayerReplicationInfo != none))
    {
        PlayerReplicationInfo.m_iKillCount = iStat;
        PlayerReplicationInfo.m_iRoundKillCount = iStat;
    }
}
#endif

#ifdefDEBUG
exec function SetDeathsStat(int iStat)
{
    if ((Level.Game!=none) && (Level.Game.m_bCompilingStats==true) && (PlayerReplicationInfo != none))
    {
        PlayerReplicationInfo.Deaths = iStat;
    }
}
#endif

#ifdefDEBUG
exec function SetHealthStat(int iStat)
{
    if ((Level.Game!=none) && (Level.Game.m_bCompilingStats==true) && (PlayerReplicationInfo != none))
    {
        PlayerReplicationInfo.m_iHealth = iStat;
    }
}
#endif

#ifdefDEBUG
exec function SetRoundsHitStat(int iStat)
{
    if ((Level.Game!=none) && (Level.Game.m_bCompilingStats==true) && (PlayerReplicationInfo != none))
    {
        PlayerReplicationInfo.m_iRoundsHit = iStat;
    }
}
#endif 

#ifdefDEBUG
exec function SetRoundsFiredStat(int iStat)
{
    if ((Level.Game!=none) && (Level.Game.m_bCompilingStats==true) && (PlayerReplicationInfo != none))
    {
        PlayerReplicationInfo.m_iRoundFired = iStat;
    }
}
#endif

#ifdefDEBUG
exec function SetRoundsPlayedStat(int iStat)
{
    if ((Level.Game!=none) && (Level.Game.m_bCompilingStats==true) && (PlayerReplicationInfo != none))
    {
        PlayerReplicationInfo.m_iRoundsPlayed = iStat;
    }
}
#endif

#ifdefDEBUG
exec function SetRoundsWonStat(int iStat)
{
    if ((Level.Game!=none) && (Level.Game.m_bCompilingStats==true) && (PlayerReplicationInfo != none))
    {
        PlayerReplicationInfo.m_iRoundsWon = iStat;
    }
}
#endif


///////////////////////////////////////////////////////////////////////////////////////
//								 end R6Debug functions
///////////////////////////////////////////////////////////////////////////////////////


//=======================================================================================//

function ChangeTeams(bool bNextTeam)
{
    Pawn.EngineWeapon.StopFire(false);

	ServerChangeTeams(bNextTeam);
}

function ServerChangeTeams(bool bNextTeam)
{
    R6AbstractGameInfo(level.game).ChangeTeams(self, bNextTeam);
}

// this is also the default action when no other action is available

function ServerNextMember()
{
    if(m_TeamManager == none)
		return;

    m_TeamManager.SwitchPlayerControlToNextMember();
}

function ServerPreviousMember()
{
	if(m_TeamManager == none)
		return;

    m_TeamManager.SwitchPlayerControlToPreviousMember();
}

function UpdatePlayerPostureAfterSwitch()
{
	if(pawn.m_bIsProne)
	{
		m_bCrawl = true;  
		bDuck = 1;
	}
	else if(pawn.bIsCrouched)
	{
		bDuck = 1;
		m_bCrawl = false;      
	}
	else
	{
		bDuck = 0;
		m_bCrawl = false;
	}
}

function bool PlayerIsInFrontOfDoubleDoors()
{
	if((m_pawn.m_Door != none) && (m_pawn.m_Door2 != none))
		return true;

	return false;
}

function bool PlayerLookingAtFirstDoor()
{
	local vector vLookDir;
	local vector vCenter;
	local vector vCutOff;
	local vector vResult;
	local R6Door rightDoor, leftDoor;
	local vector vDoor1, vDoor2;

	vDoor1 = normal(m_pawn.m_Door.m_RotatingDoor.m_vCenterOfDoor - (pawn.location + pawn.EyePosition()));
	vDoor2 = normal(m_pawn.m_Door2.m_RotatingDoor.m_vCenterOfDoor - (pawn.location + pawn.EyePosition()));
	vResult = vDoor1 cross vDoor2;
	if(vResult.z > 0)
	{
		rightDoor = m_pawn.m_Door;
		leftDoor = m_pawn.m_Door2;
	}
	else
	{
		rightDoor = m_pawn.m_Door2;
		leftDoor = m_pawn.m_Door;
	}

	vLookDir = vector(pawn.GetViewRotation());
	vCenter = ((leftDoor.m_RotatingDoor.m_vCenterOfDoor + rightDoor.m_RotatingDoor.m_vCenterOfDoor) / 2);
	vCutOff = normal(vCenter - (pawn.location + pawn.EyePosition()));

	vResult = vCutOff cross vLookDir;
	if(vResult.z > 0)
	{
		if(leftDoor == m_pawn.m_Door)
			return true;
		else 
			return false;
	}
	else
	{
		if(rightDoor == m_pawn.m_Door)
			return true;
		else 
			return false;
	}
}

function bool GraduallyControlDoor(out R6Door aDoor)
{
	local bool bIsLookingAtFirstDoor;
	
	bIsLookingAtFirstDoor = true;
	if(m_pawn.m_Door == none)
		return false;

	if(m_pawn.m_Door.m_RotatingDoor == none)
		return false;

	if(m_pawn.m_Door.m_RotatingDoor.m_bIsDoorLocked)
		return false;

	// are there two possible doors to interact with?
	if(PlayerIsInFrontOfDoubleDoors())
	{
		if(m_CurrentCircumstantialAction.aQueryTarget == m_pawn.m_Door.m_RotatingDoor)
			bIsLookingAtFirstDoor = true;
		else if(m_CurrentCircumstantialAction.aQueryTarget == m_pawn.m_Door2.m_RotatingDoor)
			bIsLookingAtFirstDoor = false;
		else
			bIsLookingAtFirstDoor = PlayerLookingAtFirstDoor();	// determine which one the player is looking at
	}

    if (LastDoorUpdateTime == 0)
    {
        LastDoorUpdateTime = Level.TimeSeconds;
    }
    else if ((Level.TimeSeconds - LastDoorUpdateTime) >= 0.5)
    {
		if(bIsLookingAtFirstDoor)
			aDoor = m_pawn.m_door;
		else
			aDoor = m_pawn.m_Door2;
		return true;
    }
	return false;
}

function ServerGraduallyOpenDoor(byte bSpeedUpDoor)
{
    local   INT     speed;
	local	R6Door  aDoor;
	local	bool	bStatus;

	bStatus = GraduallyControlDoor(aDoor);
	if(!bStatus)
		return;

    speed = m_iDoorSpeed; 
    if(bSpeedUpDoor > 0)
        speed = m_iFastDoorSpeed; 

    #ifdefDEBUG if(bShowLog) log(" player pawn is OPENING DOOR!!! ");	#endif
	aDoor.m_RotatingDoor.updateAction(speed, pawn);
}

function ServerGraduallyCloseDoor(byte bSpeedUpDoor)
{
    local   INT     speed;
	local	R6Door  aDoor;
	local	bool	bStatus;
	
	bStatus = GraduallyControlDoor(aDoor);
	if(!bStatus)
		return;

    speed = -m_iDoorSpeed;
    if(bSpeedUpDoor > 0)
        speed = -m_iFastDoorSpeed;  

    #ifdefDEBUG if(bShowLog) log(" player pawn is CLOSING DOOR!!! ");	#endif
	aDoor.m_RotatingDoor.updateAction(speed, pawn);
}

///////////////////////////////////////////////////////////////////////////////////////
// rbrek 27 nov 2001  
// UpdatePlayerPeeking()  
//   new full peeking controls, now there is one button to peek left and one button
//   to peek right.  a peek button must be held down to continue peeking, when the
//	 button is released, the player returns to normal posture.
// note:  using either the peekleft or peekright buttons while in a 
//		  fluid-set position will reset the player's posture.
///////////////////////////////////////////////////////////////////////////////////////
function UpdatePlayerPeeking()
{
    local BOOL bPeekingLeft;
    local BOOL bPeekingRight;

    // if prone and moving
    if ( m_pawn.m_bIsProne && pawn.acceleration != vect(0,0,0) )
    { 
        // stop peeking
        if ( m_pawn.m_ePeekingMode != PEEK_none )
        {
            SetPeekingInfo( PEEK_none, m_pawn.C_fPeekMiddleMax );
        }

        return; // don't peek
    }

    // check if we need to relaunch the peeking
    if (  (m_bPeekLeft  == 1 && m_bOldPeekLeft  == 1) || 
          (m_bPeekRight == 1 && m_bOldPeekRight == 1) )
    {
        // we're not peeking, so need to peek again and wait to finish posture transition
        if ( !m_pawn.IsPeeking() && !m_pawn.m_bPostureTransition )
        {
            // we relaunch the peeking after going from crouch to prone and prone to crouch
            if ( (m_pawn.bIsCrouched     && m_pawn.bWantsToCrouch && m_bCrawl == false) ||
                 (m_pawn.m_bWantsToProne && m_pawn.m_bIsProne ) )
            {
                m_bOldPeekRight = 0;
                m_bOldPeekLeft = 0;
            }     
        }
    }

	// check if peeking state has changed...
	if((m_bOldPeekLeft != m_bPeekLeft) || (m_bOldPeekRight != m_bPeekRight))
	{
        // don't update peeking while changing posture
        if ( m_pawn.m_bPostureTransition )
            return;

        CommonUpdatePeeking(m_bPeekLeft, m_bPeekRight);
		if (level.NetMode != NM_Standalone)
        {
            bPeekingLeft = (m_bPeekLeft != 0);
            bPeekingRight = (m_bPeekRight != 0);
			ServerUpdatePeeking(bPeekingLeft, bPeekingRight);
        }
	}
	m_bOldPeekLeft = m_bPeekLeft;
	m_bOldPeekRight = m_bPeekRight;
} 


function CommonUpdatePeeking(byte bPeekLeftButton, byte bPeekRightButton)
{

    if ( m_pawn.m_ePeekingMode == PEEK_full )
    {
		if(m_pawn.IsPeekingLeft())
		{		
			if(bPeekLeftButton == 0)
            {
                if(bPeekRightButton == 1) // change side
                {
                    SetPeekingInfo( PEEK_full, m_pawn.C_fPeekRightMax );
                }
                else
                {
                    SetPeekingInfo( PEEK_none, m_pawn.C_fPeekMiddleMax );                
                }
            }
		}
		else
		{
			if(bPeekRightButton == 0)
            {
                if(bPeekLeftButton == 1) // change side
                {
                    SetPeekingInfo( PEEK_full, m_pawn.C_fPeekLeftMax, true );
                }
                else // stop peeking right, return to center
                {
                    SetPeekingInfo( PEEK_none, m_pawn.C_fPeekMiddleMax );
                }
            }

		}
    }
	else if ( !(m_pawn.m_ePeekingMode == PEEK_full) && m_pawn.canPeek() )
	{
		if(bPeekLeftButton > 0)
		{
			// start peeking left
			ResetSpecialCrouch();
			SetPeekingInfo( PEEK_full, m_pawn.C_fPeekLeftMax, true );
		}
		else if(bPeekRightButton > 0)
		{
			// start peeking right
			ResetSpecialCrouch();       
			SetPeekingInfo( PEEK_full, m_pawn.C_fPeekRightMax, false );
		}
	}
}

function ServerUpdatePeeking(BOOL bPeekLeft, BOOL bPeekRight)
{
    local BYTE PeekLeftButton;
    local BYTE PeekRightButton;

    if(bPeekLeft) PeekLeftButton = 1;
    if(bPeekRight) PeekRightButton = 1;

    CommonUpdatePeeking(PeekLeftButton, PeekRightButton);
}

function HandleWalking()
{
	if(bOnlySpectator)
		return;

    if(pawn != none)
	    pawn.bIsWalking = (bRun == 0) || (m_pawn.m_eHealth != HEALTH_Healthy);
}


//======================================================================================//
//                              PLAYERCONTROLLER STATES                                 //
//======================================================================================//

//==========================================================//
//					-- state PLAYERFLYING --				//
//==========================================================//
state PlayerFlying
{
ignores SeePlayer, HearNoise, Bump;

	function BeginState()
	{
		// 30 jan 2002 rbrek - align the player's head rotation and body orientation...
		//    so that when we try to move in ghost mode, we move in the direction the pawn's 
		//    head (player) is looking, not the direction the pawn's body was facing when
		//    we entered this state
		if(pawn != none)
		{
			SetRotation(rotation + pawn.m_rRotationOffset);
			pawn.m_rRotationOffset = rot(0,0,0);
			m_pawn.PawnLook(pawn.m_rRotationOffset,,true);
			pawn.SetPhysics(PHYS_Flying);
		}
	}
}

//==========================================================//
//					-- state GAMEENDED --					//
//==========================================================//
state GameEnded
{
}    

//------------------------------------------------------------------
// PenaltyBox: player a has a penalty and he's not allowed to move, fire
//	or do anything until he's killed by the server
//------------------------------------------------------------------
state PenaltyBox
{
    ignores SeePlayer, HearNoise, KilledBy;

    function BeginState()
    {
        // needed for isAlive and to apply game rules correctly (ie: deathmatch) 
        m_pawn.m_eHealth = HEALTH_Incapacitated; 
    }

    // Nothing to do when we are dead
    function PlayFiring() {}
    function AltFiring()  {}
    function PlayerMove(float DeltaTime) {}
    function ServerReStartPlayer() {}
    exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire( optional float F ) {}
    function SwitchWeapon(BYTE F) {}

Begin:
    if ( R6AbstractGameInfo(Level.Game) != none ) // server side apply the penalty
    {
        if ( m_ePenaltyForKillingAPawn == PAWN_Hostage )
        {
            ClientGameMsg( "", "", "PenaltyYouKilledAHostage" );
        }
        else
        {
            ClientGameMsg( "", "", "PenaltyYouKilledATeamMate" );
        }
        
        Sleep(1); // initialize the controller and his pawn. otherwise the pawn won't died correctly      
        R6AbstractGameInfo(Level.Game).ApplyTeamKillerPenalty( pawn );
    }
}

function TKPopUpBox(string _KillerName)
{
    m_MenuCommunication.TKPopUpBox(_KillerName);
}

function ServerTKPopUpDone(BOOL _bApplyTeamKillerPenalty)
{
    // make sure that we are indeed a server
    if ((Level.NetMode == NM_Standalone) || (Level.NetMode == NM_Client))
        return;

    m_bRequestTKPopUp = false;

    if ((_bApplyTeamKillerPenalty==false) || (m_TeamKiller==none))    // if we are not applying penalty, then do nothing
        return;

    m_TeamKiller.m_bHasAPenalty = true;
    m_TeamKiller.m_ePenaltyForKillingAPawn = PAWN_Rainbow;
    m_TeamKiller=none;
}

//==========================================================//
//                  -- state PLAYERWALKING --               //
//==========================================================//
state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

	function PlayerMove(float DeltaTime)
	{
		if(WindowConsole(Player.Console).ConsoleState == 'UWindow')
		{
			if ( Role < ROLE_Authority ) // then save this move and replicate it
				ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
			else
				ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		}
		else
			Super.PlayerMove(DeltaTime);
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{		
		if(pawn == none || m_pawn == none)
			return;
		
		pawn.acceleration = newAccel;
		if ( bPressedJump )
			pawn.DoJump(bUpdating);
		if ( pawn.physics != PHYS_Falling )
		{
			// prevent player movement while changing posture
			if ( m_pawn.m_bPostureTransition && !m_pawn.m_bIsLanding )
			{
				aForward = 0;
				aStrafe = 0;
				aTurn = 0;
				pawn.acceleration = vect(0,0,0);
			}

			// FLUID MOVEMENT control - press and hold the key to set the custom peekandcrouch posture
			//                          double click key to reset posture to a non-blended stance.
			// m_fPostFluidMovementDelay - used to ensure that the doubleclick is not also treated as a regular keystroke.
			if(DoubleClickMove == DCLICK_Forward)
			{
				m_fPostFluidMovementDelay = 0.1;
				ResetSpecialCrouch();
			}
			else if(m_fPostFluidMovementDelay <= 0)
			{
				m_fPostFluidMovementDelay = 0.0;
				HandleFluidMovement(DeltaTime);
			}
			else
			{
				m_fPostFluidMovementDelay -= DeltaTime;
			}

			// CROUCHING 
			if(bDuck == 0)
				pawn.ShouldCrouch(false);
			else if(pawn.bCanCrouch)
				pawn.ShouldCrouch(true);

			// PRONE 	
			if(m_bCrawl)
				pawn.m_bWantsToProne = true;
			else 
				pawn.m_bWantsToProne = false;

			// PEEKING : check the peeking controls and update the player peeking if necessary...
			UpdatePlayerPeeking();

			if(pawn.m_bIsLanding)
				pawn.acceleration = vect(0,0,0);
		}

        //Check reloading Here
        if((m_bReloading == 1) && (!R6GameReplicationInfo(GameReplicationInfo).m_bGameOverRep))
        {
            ReloadWeapon();
        }

	}

    // overwritten: don't reset should crouch
	function BeginState()
	{
		#ifdefDEBUG if(bShowLog) log(self$" Entered state PlayerWalking... Pawn="$Pawn$" pawn.physics="$pawn.physics$" onLadder="$pawn.onLadder$ " isclimbingladder="$m_pawn.m_bIsClimbingLadder$" isLanding="$m_pawn.m_bIsLanding$" m_Ladder="$m_pawn.m_Ladder$" posturetransition="$m_pawn.m_bPostureTransition);	 #endif
		
		m_Pawn = R6Rainbow(Pawn);
		
		if (Pawn == None) // this is to avoid get in stuck in player walking state with no pawn
		{
#ifdefDEBUG
			if (bShowLog)
			{
				log("=========================================================================================");
				log("=========================================================================================");
				log("THIS IS TO AVOID GET IN STUCK IN PLAYER WALKING STATE WITH NO PAWN");
				log("=========================================================================================");
				log("=========================================================================================");
			}
#endif
			GotoState('BaseSpectating');
			return;
		}		

		if(Pawn.Mesh == None)
			Pawn.SetMesh();
		DoubleClickDir = DCLICK_None;
		// r6code: Pawn.ShouldCrouch(false);
		bPressedJump = false;
		if(Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_KarmaRagDoll) 
			Pawn.SetPhysics(PHYS_Walking);
		GroundPitch = 0;
        if(m_GameOptions.HUDShowFPWeapon)
		    ShowWeapon();
	}

    // overwritten: don't reset should crouch
    function EndState()
	{
		#ifdefDEBUG if(bShowLog) log(self$" Exited state PlayerWalking... ");	#endif
		GroundPitch = 0;
		// r6code: if ( Pawn != None )
		//	          Pawn.ShouldCrouch(false);
	}
}

function ServerExecFire( optional float F )
{
	Fire(F);
}

exec function LogSpecialValues()
{
#ifdefDEBUG
    log(" $$$$ START LogSpecialValues $$$$ ");
    
    log("- PlayerController is "$self);
    log("- current PlayerController state is "$ GetStateName());
    log("- Player.console.Master.m_MenuCommunication = "$Player.console.Master.m_MenuCommunication);
    log("- GameReplicationInfo = "$GameReplicationInfo);
    log("- m_MenuCommunication = "$m_MenuCommunication);
    log("- m_MenuCommunication.m_GameRepInfo = "$m_MenuCommunication.m_GameRepInfo);
    log("- bOnlySpectator = "$bOnlySpectator);
    log("- m_bReadyToEnterSpectatorMode = "$m_bReadyToEnterSpectatorMode);
    log("- m_bSpectatorCameraTeamOnly = "$m_bSpectatorCameraTeamOnly);
    log("- m_TeamSelection = "$m_TeamSelection);
    log("- PRI.TeamId = "$PlayerReplicationInfo.TeamID);
    log("- PRI.bIsSpectator =" $PlayerReplicationInfo.bIsSpectator );
    log("- m_bReadyToEnterSpectatorMode = " $m_bReadyToEnterSpectatorMode );
    log("- bOnlySpectator = " $bOnlySpectator );
    
    log(" $$$$ END LogSpecialValues $$$$ ");
#endif
}

#ifdefDEBUG
exec function LogAllPlayerInfo()
{
    local Controller P;

    for (P=Level.ControllerList; P!=None; P=P.NextController )
    {
        if (P.IsA('R6PlayerController'))
        {
            R6PlayerController(P).LogPlayerInfo();
        }
    }
}
#endif

#ifdefDEBUG
exec function LogPlayerInfo()
{
    log("---   START LogPlayerInfo  for "$PlayerReplicationInfo.PlayerName$" ---");

    log("- PlayerController is "$self);
    log("- current PlayerController state is "$ GetStateName());
    log("- bOnlySpectator = "$bOnlySpectator);
    log("- m_bReadyToEnterSpectatorMode = "$m_bReadyToEnterSpectatorMode);
    log("- m_bSpectatorCameraTeamOnly = "$m_bSpectatorCameraTeamOnly);
    log("- m_TeamSelection = "$m_TeamSelection);
    log("- PlayerReplicationInfo.m_bPlayerReady ="$PlayerReplicationInfo.m_bPlayerReady);
    log("- m_bHasAPenalty ="$m_bHasAPenalty);
    log("- m_bPenaltyBox = "$m_bPenaltyBox);
    log("- m_iAdmin = "$m_iAdmin);
    log("- m_iTeamId = "$m_iTeamId);
    log("- PRI.TeamId = "$PlayerReplicationInfo.TeamID);
    log("- bOnlySpectator = "$bOnlySpectator);
    log("- m_fLoginTime = "$m_fLoginTime);
	log("-------------------------------------");
	log("-- PRI.TeamID = "$PlayerReplicationInfo.TeamID);
    log("---   END LogPlayerInfo   ---");
}
#endif

function InitializeMenuCom()
{
    if (
        (GameReplicationInfo == none)||     // if classes are not ready yet in order to init m_MenuCommunication
        (m_MenuCommunication !=none && m_MenuCommunication.m_GameRepInfo!=none)// or it's already initialized
        )
        return;
    
    if (Viewport(Player) != none)
    {
        #ifdefDEBUG if(bShowLog) log(self$" BaseSpectating::Tick Viewport(Player) = "$Viewport(Player));	#endif
        //if(bShowLog) LogSpecialValues();

        m_MenuCommunication = Player.console.Master.m_MenuCommunication;
        if(m_MenuCommunication == none)
            return;
        
        m_MenuCommunication.m_GameRepInfo=GameReplicationInfo;
        m_MenuCommunication.m_PlayerController = self;
        ServerRequestSkins();
        
        #ifdefDEBUG if(bShowLog) log(self$" BaseSpectating::Tick calling "$GameReplicationInfo$".ControllerStarted( "$m_MenuCommunication$" )");	#endif
        //if(bShowLog) LogSpecialValues();
        GameReplicationInfo.ControllerStarted(m_MenuCommunication);
        
        #ifdefDEBUG if(bShowLog) log(self$" BaseSpectating::Tick calling "$m_MenuCommunication$".SelectTeam()");	#endif
        //if(bShowLog) LogSpecialValues();
        m_MenuCommunication.SelectTeam();
        
        if (bOnlySpectator)
        {
            m_MenuCommunication.PlayerSelection(PTS_Spectator);
        }
        
        if ((Level.NetMode != NM_Standalone) && (Level.NetMode != NM_DedicatedServer))
        {
            // just until we get menus working, assume no spectator
            if (m_TeamSelection != PTS_UnSelected)
            {
                ServerTeamRequested(m_TeamSelection);
                if (m_bDeadAfterTeamSel==true)
                {
                    m_bDeadAfterTeamSel = false;
                    GotoState('Dead');
                }
            }
        }    
    }
}

// waiting to start round in MP
auto state BaseSpectating
{
    simulated function BeginState()
    {
        #ifdefDEBUG if(bShowLog) log(self$" BaseSpectating::BeginState() ");	#endif
        //if(bShowLog) LogSpecialValues();
    }

    simulated function EndState()
    {
        InitializeMenuCom();
        #ifdefDEBUG if(bShowLog) log(self$" BaseSpectating::EndState()");	#endif
        //if(bShowLog) LogSpecialValues();
#ifndefSPDEMO
        if ( (Player!=none) && (Viewport(Player)!=none) && (m_GameService == none) && (Player.Console!=none) )
        {
            m_GameService = R6AbstractGameService(Player.Console.SetGameServiceLinks(self));
        }
#endif
    }

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		Acceleration = NewAccel;
		MoveSmooth(Acceleration * DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation,OldRotation, ViewRotation;
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

        aForward = 0;
        aStrafe = 0;
        aUp = 0;
        aTurn = 0;
	
		Acceleration = 0.02 * (aForward*X + aStrafe*Y + aUp*vect(0,0,1));  

        ViewRotation = Rotation;
		SetRotation(ViewRotation);
		OldRotation = Rotation;
        Super.UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DCLICK_None, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, Acceleration, DCLICK_None, OldRotation - Rotation);
	
	}

    function Tick(float DeltaTime)
    {
        InitializeMenuCom();
    }
}

// no movement accepted
state PauseController extends PlayerWalking
{
    ignores SeePlayer, HearNoise, KilledBy;//, SwitchWeapon;
	function BeginState(){}
	function EndState(){}
    exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}

    simulated function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        bFire = 0;
        Super.ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, DeltaRot);
    }
    
    simulated function PlayFiring() {}
    simulated function AltFiring()  {}
    simulated function bool PlayerIsFiring()
    {
        return false;
    }
    exec function Fire(optional float F){}

	function PlayerMove( float DeltaTime )
	{
		// so that player can't move forward/backward until they have finished getting off the ladder
		aForward = 0.f;
		aStrafe = 0.f;	
		R6PlayerMove(deltaTime);
	}

    simulated function Tick(FLOAT fDeltaTime)
    {
        if ((Pawn==none) || (m_bPawnInitialized == true) )
            return;

        m_bPawnInitialized = true;
        Pawn.m_bIsFiringWeapon = 0;
//		if ( Pawn.Mesh == None )
//			Pawn.SetMesh(); 
        Pawn.SetPhysics(PHYS_Walking);
//		GroundPitch = 0;
        if (m_GameOptions.HUDShowFPWeapon)
		    ShowWeapon();

    }
    function VeryShortClientAdjustPosition
    (
	    float TimeStamp, 
	    float NewLocX, 
	    float NewLocY, 
	    float NewLocZ,
	    Actor NewBase
    )
    {
	    local vector Floor;

	    if ( Pawn != None )
		    Floor = Pawn.Floor;
	    
           LongClientAdjustPosition(TimeStamp,'PauseController',PHYS_Walking,NewLocX,NewLocY,NewLocZ,0,0,0,
                NewBase,Floor.X,Floor.Y,Floor.Z);
    }
}


function ServerTeamRequested(R6GameMenuCom.ePlayerTeamSelection eTeamSelected, optional bool bForceSelection)
{
    local string szMessageLocTag;
    local bool   bSameTeam;
    local INT iTeamA;
    local INT iTeamB;
    local INT iMaxPlayerOnTeam;
	local PlayerReplicationInfo PRI;
    local Controller _P;
    local R6PlayerController P;

#ifdefDEBUG
    log("ServerInfo: "$PlayerReplicationInfo.PlayerName$" processing ServerTeamRequest at time "$Level.TimeSeconds);
#endif

    if (!bForceSelection && R6AbstractGameInfo(level.game).IsTeamSelectionLocked())
        return;

    if (GameReplicationInfo.IsInAGameState() && (Pawn != none) && Pawn.IsAlive())
        return;

    for (_P=Level.ControllerList; _P!=None; _P=_P.NextController )
    {
        if (_P.IsA('PlayerController') && (_P.PlayerReplicationInfo != None))
        {
            PRI = _P.PlayerReplicationInfo;
            if(PRI != PlayerReplicationInfo)
            {
                if(PRI.TeamID == INT(ePlayerTeamSelection.PTS_Alpha))
                    iTeamA++;
                else if(PRI.TeamID == INT(ePlayerTeamSelection.PTS_Bravo ))
                    iTeamB++;
            }
        }
    }

//#ifdef R6PUNKBUSTER    
    if (PB_CanPlayerSpawn()==false)
    {
		eTeamSelected = PTS_Spectator;
		ClientPBVersionMismatch();
		if (bShowLog)
			log("PlayerController "$self$" has a PunkBuster version mismatch");
    }
//#endif R6PUNKBUSTER    

    if(eTeamSelected == PTS_AutoSelect)
    {
#ifdefDEBUG
            log("ServerInfo: "$PlayerReplicationInfo.PlayerName$" CLICKED AutoSelect");
#endif

        if ( iTeamA > iTeamB )
            eTeamSelected = PTS_Bravo;    // join bravo team
        else
            eTeamSelected = PTS_Alpha;    // join alpha team
    }
    bSameTeam = (PlayerReplicationInfo.TeamID == eTeamSelected);

#ifdefDEBUG
    if (m_TeamSelection == PTS_Alpha)
        log("ServerInfo: "$PlayerReplicationInfo.PlayerName$" WAS in team PTS_Alpha");
    else if (m_TeamSelection == PTS_Bravo)
        log("ServerInfo: "$PlayerReplicationInfo.PlayerName$" WAS in team PTS_Bravo");
    else if (m_TeamSelection == PTS_Spectator)
        log("ServerInfo: "$PlayerReplicationInfo.PlayerName$" WAS in team PTS_Spectator");
    else
        log("ServerInfo: "$PlayerReplicationInfo.PlayerName$" WAS in unknown team????  eTeamSelected = "$m_TeamSelection);
    
    if (eTeamSelected == PTS_Alpha)
        log("ServerInfo: "$PlayerReplicationInfo.PlayerName$" JOINED team PTS_Alpha");
    else if (eTeamSelected == PTS_Bravo)
        log("ServerInfo: "$PlayerReplicationInfo.PlayerName$" JOINED team PTS_Bravo");
    else if (eTeamSelected == PTS_Spectator)
        log("ServerInfo: "$PlayerReplicationInfo.PlayerName$" JOINED team PTS_Spectator");
    else
        log("ServerInfo: "$PlayerReplicationInfo.PlayerName$" JOINED unknown team????  eTeamSelected = "$eTeamSelected);
#endif


    iMaxPlayerOnTeam = GetMissionDescription().GetMaxNbPlayers(GameReplicationInfo.m_szGameTypeFlagRep);

    if (iMaxPlayerOnTeam <= (iTeamA + iTeamB))
    {
        if ((m_TeamSelection == PTS_Alpha) ||  // if already on a team don't make the player a spectator let them keep their spot
            (m_TeamSelection == PTS_Bravo))
        {
            eTeamSelected = m_TeamSelection;
        }
        else
        {
            eTeamSelected = PTS_Spectator;
        }
        bSameTeam = (PlayerReplicationInfo.TeamID == eTeamSelected);
    }
         
    
    if (!bSameTeam)
    {
        iMaxPlayerOnTeam = GetMissionDescription().GetMaxNbPlayers(GameReplicationInfo.m_szGameTypeFlagRep);
        if (Level.IsGameTypeTeamAdversarial(Level.Game.m_szCurrGameType))
        {
            iMaxPlayerOnTeam = iMaxPlayerOnTeam/2;
        }
        if (((eTeamSelected == PTS_Alpha) && (iTeamA >= iMaxPlayerOnTeam)) || 
           ((eTeamSelected == PTS_Bravo) && (iTeamB >= iMaxPlayerOnTeam)))
        {
            ClientTeamFullMessage();
            return;
        }
    }
        
    m_TeamSelection = eTeamSelected;
    PlayerReplicationInfo.TeamID = eTeamSelected;

    if ((Level.NetMode!=NM_Standalone) && (Level.Game!=none))   // we are on the server
    {
        if (GameReplicationInfo.IsInAGameState())
        {
            PlayerReplicationInfo.m_bJoinedTeamLate=true;
        }
        else
        {
            PlayerReplicationInfo.m_bJoinedTeamLate=false;
        }
        R6AbstractGameInfo(Level.Game).PlayerReadySelected(self);
    }
    #ifdefDEBUG if(bShowLog) log("ServerTeamRequested m_TeamSelection="@PlayerReplicationInfo.TeamID);	#endif

    // broadcast team change
    if(!bSameTeam)
    {
        szMessageLocTag = "ChangedTeamSpectator";
        if (Level.IsGameTypeTeamAdversarial(Level.Game.m_szCurrGameType))
        {
            if(eTeamSelected == PTS_Alpha)
                szMessageLocTag = "ChangedGreenTeam";
            else if(eTeamSelected == PTS_Bravo)
                szMessageLocTag = "ChangedRedTeam";
        }
        else if(eTeamSelected == PTS_Alpha)
        {
            szMessageLocTag = "HasJoinedTheGame";
        }
        
        foreach DynamicActors(class'R6PlayerController', P)
            P.ClientMPMiscMessage(szMessageLocTag, PlayerReplicationInfo.PlayerName);
    }
    
    if (Viewport(Player) != none)
    {
        PlayerTeamSelectionReceived();
    }
}



// returns true if we have not selected a to play or we selected to be a spectator
// i.e. an active spectator (not a passive one like someone who is dead)

simulated event BOOL IsPlayerPassiveSpectator()
{
    return ((m_TeamSelection==PTS_UnSelected) || (m_TeamSelection==PTS_Spectator));
}

event PlayerTeamSelectionReceived()
{
    m_MenuCommunication.RefreshReadyButtonStatus();
}


function EnterSpectatorMode();
function ResetCurrentState();
function ClientGotoState(name NewState, name NewLabel)
{
    #ifdefDEBUG if(bShowLog) log("ClientGotoState received CurrentState = "$GetStateName()$" NewState = "$NewState$" NewLabel = "$NewLabel);	#endif
    //if(bShowLog) LogSpecialValues();

    if ((GetStateName() == 'BaseSpectating') && (NewState == 'Dead'))
    {
        m_bDeadAfterTeamSel=true;
        return;
    }

	if(GetStateName() == NewState)
	{
		ResetCurrentState();
		return;
	}

	if(NewLabel == '')
		GotoState(NewState);
	else
		GotoState(NewState,NewLabel);	
}

exec function Suicide()
{
    if ( R6Pawn(pawn) == none )
        return;

    if ( !m_pawn.IsAlive() )
        return;
    
    if ( GameReplicationInfo == none )
        return;
        
    // MPF_Milan_8_25_2003 - no suicide in Capture The Enemy
	if(GameReplicationInfo.m_szGameTypeFlagRep == "RGM_CaptureTheEnemyAdvMode")
		return;
    // MPF_Milan_8_25_2003
    
    if ( Level.NetMode!=NM_Standalone && GameReplicationInfo.m_eCurrectServerState != GameReplicationInfo.RSS_InGameState )
        return;
    
    if ( GameReplicationInfo.m_bInPostBetweenRoundTime || GameReplicationInfo.m_bGameOverRep )
        return;

    R6Pawn(pawn).ServerSuicidePawn(DEATHMSG_KAMAKAZE);

    if ( Player.Console != none )
        Player.Console.Message( "Commited suicide", 6.0 );
}

state WaitForGameRepInfo
{
	function BeginState()
	{
		#ifdefDEBUG if(bShowLog) log(self$" - Entered State WaitForGameRepInfo ");	#endif
		m_bReadyToEnterSpectatorMode = false;
	}

#ifdefDEBUG 	
    function EndState()
	{
		if(bShowLog) log(self$" - exiting State WaitForGameRepInfo ");
	}
#endif

    // rbrek : add a timeout - do not stay in this state indefinitely
    event Tick(FLOAT fDeltaTime)
	{
		Super.Tick(fDeltaTime);

		if(GameReplicationInfo != none) 
		{	
            InitializeMenuCom();
			if( !m_bReadyToEnterSpectatorMode
				&& (m_TeamSelection == PTS_UnSelected)
				&& (GameReplicationInfo.m_eCurrectServerState == GameReplicationInfo.RSS_InGameState) )
			{
				m_bReadyToEnterSpectatorMode = true;
				SetTimer(5.0, false);
			}
				
			if(m_TeamSelection != PTS_UnSelected)
			{
        		#ifdefDEBUG if(bShowLog) log("  State WaitForGameRepInfo : finished waiting (gotostate dead), GameRepInfo="$GameReplicationInfo$" m_Team="$m_TeamSelection); #endif
				SetTimer(0.0, false);
				GotoState('Dead');
			}
		}
	}

	function Timer()
	{
		#ifdefDEBUG if(bShowLog) log(" TIMER() : State WaitForGameRepInfo : give up waiting!!! set selection to Spectator");	#endif
        SetTimer(0.0, false);
        GotoState('Dead');
	}
}

//==========================================================//
//                      -- state DEAD --                    //
//==========================================================//
state Dead
{
    // Nothing to do when we are dead
    function PlayFiring() {}
    function AltFiring()  {}
    function PlayerMove(float DeltaTime) {}
    function ServerReStartPlayer() {}
    exec function GraduallyOpenDoor() {}
    exec function GraduallyCloseDoor() {}
    exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}


    exec function Fire( optional float F )
    {
        local class<R6Rainbow>      rainbowPawnClass;

		if(Level.NetMode == NM_Standalone)
			return;
		
		if(!m_bReadyToEnterSpectatorMode)
			return;

        ResetBlur();
        m_eCameraMode = CAMERA_FirstPerson;
		
        // TODO: this is just here as a test.  Remove later.
        m_bCameraFirstPerson = false;
        m_bCameraThirdPersonFree = false;
        m_bCameraThirdPersonFixed = false;
        m_bCameraGhost = false;
        m_bFadeToBlack = false;
		m_bSpectatorCameraTeamOnly = false;
        
        if  ((R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode & Level.RDC_CamFirstPerson) > 0)
        {
            m_bCameraFirstPerson = true;
            if (bShowLog) log ("Death Camera Mode = eDCM_FIRSTPERSON");
        }

        if ((R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode & Level.RDC_CamThirdPerson) > 0)
        {
             m_bCameraThirdPersonFixed=true;
             if (bShowLog) log ("Death Camera Mode = eDCM_THIRDPERSON");
        }

        if ((R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode & Level.RDC_CamFreeThirdP) > 0)
        {
            m_bCameraThirdPersonFree = true;
            if (bShowLog) log ("Death Camera Mode = eDCM_FREETHIRDPERSON");
        }

        if ((R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode & Level.RDC_CamGhost) > 0)
        {
            m_bCameraGhost = true;
            if (bShowLog) log ("Death Camera Mode = eDCM_GHOST");
        }
               
        if ((R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode & Level.RDC_CamFadeToBk) > 0)
        {
            m_bFadeToBlack = true;
            if (bShowLog) log ("Death Camera Mode = eDCM_FADETOBLACK");
        }

		if ((R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode & Level.RDC_CamTeamOnly) > 0)
		{
            m_bSpectatorCameraTeamOnly = true;
			if (bShowLog) log ("Spectator Camera is restricted to Team Only m_TeamSelection="$m_TeamSelection);
			
			// disable ghost camera
			m_bCameraGhost = false;
		}

        // We have to had when we have no other partner in the team.
		if(Level.NetMode != NM_Standalone)
		{				
			if(IsPlayerPassiveSpectator() || (m_TeamManager==none) || (m_TeamManager.m_iMemberCount == 0))
			{		
                if(Role<ROLE_Authority) 
					ServerExecFire(F);

                if (Level.NetMode != NM_DedicatedServer)
                {                    
                    if (Pawn != None)
                        Pawn.m_fRemainingGrenadeTime = 0;
                    ClientFadeCommonSound(0.5, 100);
                }

				if (m_bCameraFirstPerson || m_bCameraThirdPersonFixed || m_bCameraThirdPersonFree || m_bCameraGhost)
                    GotoState('CameraPlayer');
                else
                {								
					if(myHUD != none && Viewport(Player) != none)
                    {
						R6AbstractHUD(myHUD).StartFadeToBlack( 0, 100 );
    					R6AbstractHUD(myHUD).ActivateNoDeathCameraMsg( true );
                    }
				}
			}
		}		
    }
    
	simulated function ResetCurrentState()
	{
		#ifdefDEBUG if(bShowLog) log("  ResetCurrentState() was called...");	#endif
		if( m_bSpectatorCameraTeamOnly && ((m_MenuCommunication != none) && (m_TeamSelection == PTS_Spectator)) )
		{
			BeginState();
			return;
		}	
		
		// if we are the client or the player on the non-dedicated server
		if( (Level.NetMode == NM_Client) || ((Level.NetMode == NM_ListenServer) && (Viewport(Player) != none)) )
		{					        
    		// don't display the menu if chose to play as a spectator 
			if((m_MenuCommunication != none) && IsPlayerPassiveSpectator())
			{
				#ifdefDEBUG if(bShowLog) log("  State Dead : set m_bReadyToEnterSpectatorMode = true, call Fire()");	#endif
				m_bReadyToEnterSpectatorMode = true;
				Fire(0);
			}
		}
	}

    simulated function BeginState()
    {
		local bool	bCanEnterSpectator;
/*
        log("================= Dead.BeginState()==========================");
		log(" Level.NetMode = " $ Level.NetMode);
        log(" Viewport(Player) = " $ Viewport(Player));
        log(" GameReplicationInfo == none = " $ GameReplicationInfo == none);
        if (GameReplicationInfo != None)
            log(" GameReplicationInfo.IsInAGameState() = " $ GameReplicationInfo.IsInAGameState());

        log(" m_MenuCommunication = " $ m_MenuCommunication);
        if (Pawn != None)
        {
            log(" Pawn = " $ Pawn);
            log(" Pawn.bPendingDelete = " $ Pawn.bPendingDelete);
        }
        else
            log(" Pawn = None");
        
        log(" m_TeamSelection = " $ m_TeamSelection);
        log(" Level.NetMode = " $ Level.NetMode);
        
        log(" m_bSpectatorCameraTeamOnly = " $ m_bSpectatorCameraTeamOnly);
        log(" Level.IsGameTypeCooperative( GameReplicationInfo.m_szGameTypeFlagRep ) = " $ Level.IsGameTypeCooperative( GameReplicationInfo.m_szGameTypeFlagRep ));
        log(" bCanEnterSpectator = " $ bCanEnterSpectator);
        log(" m_bReadyToEnterSpectatorMode = " $ m_bReadyToEnterSpectatorMode);
        log("=============================================================");
*/        
		if((Level.NetMode != NM_Standalone) && (Viewport(Player) != none) && 
           ((GameReplicationInfo == none) || (m_MenuCommunication == none)) )
		{
            #ifdefDEBUG if(bShowLog)  log("  PROBLEM!!!!!  GameReplicationInfo == none, so GOTOSTATE : WaitForGameRepInfo ");	#endif			
            GotoState('WaitForGameRepInfo');
			return;
		}

		bCanEnterSpectator = true;

		#ifdefDEBUG if(bShowLog) log(self$" Controller is in Dead::BeginState...GameReplicationInfo="$GameReplicationInfo$" m_pawn="$m_pawn$" pawn="$pawn$" bOnlySpectator="$bOnlySpectator);	#endif
        //if(bShowLog) LogSpecialValues();

        // MPDEMO PATCH
        // if called when destroying it, do nothing.
        if(bPendingDelete || (Pawn != none && Pawn.bPendingDelete))
			return;

        if(bDeleteMe || (Pawn != none && Pawn.bDeleteMe))
			return;        
		
		m_bReadyToEnterSpectatorMode = true;		
		if((R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode & Level.RDC_CamTeamOnly) > 0)
			m_bSpectatorCameraTeamOnly = true;
		else
			m_bSpectatorCameraTeamOnly = false;

		// make sure that client enters dead state too (at the same time)	
		if((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer && (Viewport(Player) == none)))
        {
            #ifdefDEBUG if(bShowLog) log(self$" Dead::BeginState() calling ClientGotoState Dead");	#endif
			//if(bShowLog) LogSpecialValues();            
            ClientGotoState('Dead', '');
        }

        Super.BeginState();        

		ClientDisableFirstPersonViewEffects();
        Blur(75);

		// if we are the client or the player on the non-dedicated server
		if ((Level.NetMode == NM_Client) || ( (Level.NetMode == NM_ListenServer) && (Viewport(Player) != none) ))
		{
			// don't display the menu if chose to play as a spectator 
            if ( (m_MenuCommunication != none) && (m_TeamSelection != PTS_Spectator) && (!GameReplicationInfo.IsInAGameState() || Pawn != None))
            {
				if(m_TeamSelection==PTS_UnSelected)
				{
                    #ifdefDEBUG if(bShowLog) log(self$" Dead::BeginState() calling SetStatMenuState( CMS_Initial)");	#endif
                    //if(bShowLog) LogSpecialValues();
                    m_MenuCommunication.SetStatMenuState( CMS_Initial);							
					return;
				}
				else if (!Level.IsGameTypeCooperative( GameReplicationInfo.m_szGameTypeFlagRep ))
                {
                    m_MenuCommunication.SetStatMenuState(CMS_PlayerDead);
                }
				
                #ifdefDEBUG if(bShowLog) log(self$" Dead::BeginState() not calling SetStatMenuState( CMS_Initial) because m_TeamSelection!=PTS_UnSelected");	#endif
                //if(bShowLog) LogSpecialValues();
			}
			else // Not a current player
			{	
				// this player is hosting the server
				if((Level.NetMode == NM_ListenServer) && (Viewport(Player) != none) && (m_TeamSelection != PTS_Spectator))
				{
					if(m_MenuCommunication == none)
                    {
						InitializeMenuCom();
                    }
				}
				else
				{
					#ifdefDEBUG if(bShowLog) log(" go directly into spectator mode...... **** m_TeamSelection=" $ m_TeamSelection);		#endif
					//if(bShowLog) LogSpecialValues();
					
					// make sure that there is no team only restriction
					if(!m_bSpectatorCameraTeamOnly || (m_TeamSelection!=PTS_UnSelected && m_TeamSelection!=PTS_Spectator))
					{
						#ifdefDEBUG if(bShowLog) log(self$" Dead::BeginState() calling Fire() then exit BeginState() m_bReadyToEnterSpectatorMode="$m_bReadyToEnterSpectatorMode);	#endif
						//if(bShowLog) LogSpecialValues();
                        if (GameReplicationInfo.IsInAGameState() && (Pawn == None) && m_TeamSelection!=PTS_UnSelected)
                        {
                            m_MenuCommunication.SetStatMenuState(CMS_PlayerDead);
                            Fire(0);
                        }
                        else
                        {
                            m_MenuCommunication.SetStatMenuState(CMS_Initial);
                        }
						
						return;
					}
					else
					{
						#ifdefDEBUG if (bShowLog) log(" reset flags to false... ");	#endif
						bCanEnterSpectator = false;
						m_bReadyToEnterSpectatorMode = false;
					}
				}
			}
		}   		

        #ifdefDEBUG if(bShowLog) log(self$" Dead::BeginState() calling Fire() then exit BeginState()  m_bReadyToEnterSpectatorMode="$m_bReadyToEnterSpectatorMode);	#endif
        //if(bShowLog) LogSpecialValues();
        // from here the player is dead (not a spectator)
        if( myHUD != none && Viewport(Player) != none )            
        {
            if ( Level.NetMode == NM_Standalone )
            {
                R6AbstractHUD(myHUD).StartFadeToBlack( 5, 80 );     // 5 seconds and 80% black
            }
            else // in multi, we won't see anything
            {
				if(!bCanEnterSpectator)
                {
                    #ifdefDEBUG if(bShowLog) log(self$" Dead::BeginState() sending  NoDeathCamera message");	#endif
                    //if(bShowLog) LogSpecialValues();
				    R6AbstractHUD(myHUD).ActivateNoDeathCameraMsg( true );
                    R6AbstractHUD(myHUD).StartFadeToBlack( 1, 100 );
                }
				else
                {
					R6AbstractHUD(myHUD).StartFadeToBlack( 5, 100 );    // 5 seconds and 100% black
                }
			}


			if(bCanEnterSpectator)
			{

                #ifdefDEBUG if(bShowLog) log(self$" setting 3 second timer this should only be if you were killed");	#endif
                //if(bShowLog) LogSpecialValues();
				m_bReadyToEnterSpectatorMode = false;
				SetTimer(3.0, false);
			} 
        }
    }

	function EnterSpectatorMode()
	{
		if(Level.NetMode != NM_Standalone)			
			Fire(0);
	}

	function EndState()
	{
		if((myHUD != none) && (Viewport(Player) != none))
        {
            R6AbstractHUD(myHUD).StopFadeToBlack();
            R6AbstractHUD(myHUD).ActivateNoDeathCameraMsg( false );
        }
		m_bReadyToEnterSpectatorMode = false;
        ResetBlur();
        SetTimer(0, false);
	}

	function Timer()
	{
		if(PlayerCanSwitchToAIBackup())
		{
			SetTimer(2.0, false);
			return;
		}

        InitializeMenuCom();
		if( m_bSpectatorCameraTeamOnly && ((m_MenuCommunication != none) && (m_TeamSelection == PTS_Spectator)) )
			return;		

		#ifdefDEBUG	if(bShowLog) log(" 3 seconds have passed, we can now permit player to enter spectator mode, display CAB icon too...");	#endif

        m_bReadyToEnterSpectatorMode = true;

        if ( Level.NetMode != NM_Standalone ) // server msg are only in multiplayer
        {
            // send a personal server msg to activate or not the observer mode
            if ( (R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode & Level.RDC_CamFadeToBk) > 0 )
                R6AbstractHUD(myHUD).ActivateNoDeathCameraMsg( true );
            else
            {
                Fire(0);            
                // make sure we are still in the game, and we are not still at the welcome menu...
                if ((GameReplicationInfo != none) 
                     && (GameReplicationInfo.m_eCurrectServerState == GameReplicationInfo.RSS_InGameState)
                     && (m_TeamSelection != PTS_UnSelected) )
                    ClientGameMsg( "", "", "PressFireToGoInObserverMode" );
            }
        }
    }
}

function ClientDisableFirstPersonViewEffects(optional BOOL bChangingPawn)
{
	DisableFirstPersonViewEffects(bChangingPawn);
	m_bLockWeaponActions = false;
}

function DisableFirstPersonViewEffects(optional BOOL bChangingPawn)
{
    local R6AbstractWeapon aWeapon;

	if(Pawn != None)
	{
        if(Pawn.IsLocallyControlled())
        {
	        //deactivate zoom and all vision properties
		    DoZoom(true);
            bZooming = false;
            m_bHelmetCameraOn = false;
            DefaultFOV = default.DefaultFOV;
            DesiredFOV = default.DesiredFOV;
            FOVAngle = default.DesiredFOV;
		    HelmetCameraZoom(1); 
		    R6Pawn(Pawn).ToggleHeatProperties(false, none, none);
		    R6Pawn(Pawn).ToggleNightProperties(false, none, none);
		    R6Pawn(Pawn).ToggleScopeProperties(false, none, none);
            Level.m_bHeartBeatOn = false;

            ResetBlur();

            Level.m_bInGamePlanningActive = false;
            SetPlanningMode( false );
			    
		    if((Level.NetMode == NM_Standalone) || !PlayerCanSwitchToAIBackup())
		    {
                aWeapon = R6AbstractWeapon(Pawn.EngineWeapon);
                if(aWeapon != none)
                {
				    aWeapon.GotoState('');
				    aWeapon.DisableWeaponOrGadget();
                    if(Level.NetMode != NM_DedicatedServer)
                    {
				        aWeapon.RemoveFirstPersonWeapon();
                    }
			    }
		    }
            else
            {
                if(!bChangingPawn)
                {
                    //Hide the weapons.
				    m_bShowFPWeapon = FALSE;
                    m_bHideReticule = TRUE;
                    R6AbstractWeapon(Pawn.m_WeaponsCarried[0]).R6SetReticule(self);
                    R6AbstractWeapon(Pawn.m_WeaponsCarried[1]).R6SetReticule(self);
                }
                else
                {
                    if((m_GameOptions.HUDShowFPWeapon == true) || (R6GameReplicationInfo(GameReplicationInfo).m_bFFPWeapon == true))
                    {
                        m_bShowFPWeapon = TRUE;
                        m_bHideReticule = FALSE;
                        m_bUseFirstPersonWeapon = TRUE;
                        R6AbstractWeapon(Pawn.m_WeaponsCarried[0]).R6SetReticule(self);
                        R6AbstractWeapon(Pawn.m_WeaponsCarried[1]).R6SetReticule(self);
                    }
                }
            }
        }
        Pawn.m_fRemainingGrenadeTime = 0;
	}

	bBehindView = false;
}

state CameraPlayer 
{
    simulated function BeginState()
    {
		local R6RainbowTeam rainbowTeam;

        #ifdefDEBUG if(bShowLog) log(" BeginState() for state CameraPlayer, m_PrevViewTarget="$m_PrevViewTarget);	#endif
		
        PlayerReplicationInfo.bIsSpectator = true;	
		bOnlySpectator=true;		
        if (Pawn != none)
            pawn.bOwnerNoSee = false;
		pawn = none;
		m_pawn = none;
		SetViewTarget(self);		
		Acceleration = vect(0,0,0);
		SetPhysics(PHYS_Flying);		
		m_PrevViewTarget = none;
		
		m_eCameraMode = CAMERA_FirstPerson;
		if(!CameraIsAvailable())
			SelectCameraMode(true);

		// pick the first viewTarget and set up the camera to follow them
		if(Level.NetMode == NM_Standalone)
		{
			rainbowTeam = R6RainbowTeam(R6AbstractGameInfo(Level.Game).GetRainbowTeam(Player.console.master.m_StartGameInfo.m_iTeamStart));
			SetNewViewTarget(rainbowTeam.m_Team[0]);
			if(viewTarget != none)
				SetCameraMode();
		}
		else if(Level.NetMode != NM_Client)
		{
			SpectatorChangeTeams(true); 
			if(viewTarget != none)
				SetCameraMode();
		}
    }

    simulated function EndState()
	{
		#ifdefDEBUG if(bShowLog) log(" EndState() for state CameraPlayer, m_PrevViewTarget="$m_PrevViewTarget);		#endif
        PlayerReplicationInfo.bIsSpectator = false;	
		bOnlySpectator = false;
		bBehindView = false;
		SetViewTarget(self);
	}

	simulated function SetSpectatorRotation()
	{
		local rotator rViewRotation;

		if(viewTarget != none)
		{
			if(!bBehindView)
				SetRotation(ViewTarget.Rotation + R6Pawn(ViewTarget).GetRotationOffset());
			else
			{
				rViewRotation = viewTarget.rotation;
				rViewRotation.Pitch = -6000;
				SetRotation(rViewRotation);
			}
			m_iSpectatorPitch = rotation.pitch;
			m_iSpectatorYaw = rotation.yaw;
		}
	}

	function NextCameraMode()
	{
		switch(m_eCameraMode)
		{
			case CAMERA_FirstPerson :		m_eCameraMode = CAMERA_3rdPersonFixed;	break;
			case CAMERA_3rdPersonFixed :	m_eCameraMode = CAMERA_3rdPersonFree;	break;
			case CAMERA_3rdPersonFree :		m_eCameraMode = CAMERA_Ghost;			break;
			case CAMERA_Ghost :				m_eCameraMode = CAMERA_FirstPerson;		
		}
	}
	
	function PreviousCameraMode()
	{
		switch(m_eCameraMode)
		{
			case CAMERA_FirstPerson :		m_eCameraMode = CAMERA_Ghost;			break;
			case CAMERA_3rdPersonFixed :	m_eCameraMode = CAMERA_FirstPerson;		break;
			case CAMERA_3rdPersonFree :		m_eCameraMode = CAMERA_3rdPersonFixed;	break;
			case CAMERA_Ghost :				m_eCameraMode = CAMERA_3rdPersonFree;		
		}
	}

	function SelectCameraMode(bool bNext)
	{
		if(bNext)
		{
			NextCameraMode();
			while(!CameraIsAvailable())
				NextCameraMode();
		}
		else
		{
			PreviousCameraMode();
			while(!CameraIsAvailable())
				PreviousCameraMode();
		}
	}

	function bool CameraIsAvailable()
	{
		switch(m_eCameraMode)
		{
			case CAMERA_FirstPerson :		
				if(m_bCameraFirstPerson) 
					return true; 
				break;
			case CAMERA_3rdPersonFixed :	
				if(m_bCameraThirdPersonFixed)
					return true;
				break;
			case CAMERA_3rdPersonFree :		
				if(m_bCameraThirdPersonFree)
					return true;	
				break;
			case CAMERA_Ghost :				
				if(m_bCameraGhost)
					return true;
				break;
		}	
		return false;
	}

    exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
       
    exec function Fire( optional float F )
    {
        if(Role<ROLE_Authority) 
            ServerExecFire(F);
	
		if(viewTarget == none)
			return;

		if(Level.NetMode != NM_Client)
		{
			if(F == 0)
				SelectCameraMode(true);
			else
				SelectCameraMode(false);	
			SetCameraMode();
		}
    }

    exec function AltFire( optional float F )
    {
		Fire(1);
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if(m_eCameraMode != CAMERA_Ghost)
			return;

		if(bRun > 0)
			Acceleration = 1.6*NewAccel;
		else
			Acceleration = NewAccel;
		MoveSmooth(Acceleration * DeltaTime);
	}

	simulated function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		local rotator rViewRotation;

		if(m_eCameraMode == CAMERA_Ghost)
		{
			GetAxes(Rotation,X,Y,Z);
			Acceleration = 0.05 * (aForward*X + aStrafe*Y + aUp*vect(0,0,1));  
			UpdateRotation(DeltaTime, 1);
		}
		else
		{
			m_fCurrentDeltaTime = DeltaTime;
			if (bBehindView)
			{		
    			if ( !bFixedCamera )
				{
					GetAxes(Rotation,X,Y,Z);
					// Update view rotation.
					// MP1DEBUG when surrendered, it passes here and if I move the mouse, aTurn!=0
					rViewRotation = rotation;
					rViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
					rViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
					rViewRotation.Pitch = rViewRotation.Pitch & 65535;
					
					if ((rViewRotation.Pitch > 16384) && (rViewRotation.Pitch < 49152))
					{
						if (aLookUp > 0) 
							rViewRotation.Pitch = 16384;
						else
							rViewRotation.Pitch = 49152;
					}
					
					SetRotation(rViewRotation);
				}
				else if ( ViewTarget != none )
				{
					rViewRotation = ViewTarget.Rotation;
					rViewRotation.Pitch = -6000;
	    			SetRotation(rViewRotation);
				}
			}
        
			if(m_bShakeActive == true)
			{
				ViewShake(DeltaTime);
			}
			ViewFlash(DeltaTime);
			Acceleration = vect(0,0,0);
		}

		// MPF1
		if ( class'Actor'.static.GetModMgr().IsMissionPack() )
		{
			// MPF_Milan - Avoid player moving while surrender (with dedicated server)
			
			if(m_pawn != none && m_pawn.m_bIsSurrended)
			{
				pawn.acceleration = vect(0,0,0);
				aForward = 0.f;
				aStrafe = 0.f;	
				aTurn = 0.f;
				bRun = 0;
				//Acceleration = vect(0,0,0);
				//Velocity = vect(0,0,0); // MPF_Milan2 
				pawn.velocity = vect(0,0,0); // MPF_Milan2 
			    ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0)); // MPF_Milan2 - vas ReplicateMove
			}
			else
			// End MPF_Milan
				if ( Role < ROLE_Authority)// MPF_Milan && !m_pawn.m_bIsSurrended) 
			    ReplicateMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
		    else
			    ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
		}
        else
        {
		    if ( Role < ROLE_Authority ) // then save this move and replicate it
		        ReplicateMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
		    else
                ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
        }
	}

	function ServerMove( 
		float TimeStamp, 
		vector Accel, 
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbCrawl,
		int View,
        int iNewRotOffset,
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{
		if(m_eCameraMode != CAMERA_Ghost)
			Accel = vect(0,0,0);
		else
		{			
			if(Accel == vect(0,0,0))
				velocity = vect(0,0,0);

			if(NewbRun)
				Accel = 1.6*Accel;			
		}		
		Super.ServerMove(TimeStamp,	Accel, ClientLoc, false, false,	false, View, iNewRotOffset);
	}
 
    simulated function Tick(FLOAT fDeltaTime)
    {
		local rotator rPitchOffset;

		m_iTeamId = PlayerReplicationInfo.TeamID;
		if(m_eCameraMode == CAMERA_Ghost)
			return;

		// when we choose to join a game as spectator when connecting to server, this spectator may 
		// get into the game before the other players have gotten the chance to connect.  
		// so this spectator may not find a valid viewtarget initially but needs to keep trying.
		if(viewTarget == none || viewTarget == self) // || !Pawn(viewTarget).IsAlive())
		{
			// viewTarget may have disconnected....
			if(Level.NetMode != NM_Client)
			{
				SpectatorChangeTeams(true); 
				if(viewTarget != none && viewTarget != self)
					SetCameraMode();
			}
			return;
		} 

		if (m_bSpectatorCameraTeamOnly && (m_iTeamId == INT(ePlayerTeamSelection.PTS_Alpha) || m_iTeamId == INT(ePlayerTeamSelection.PTS_Bravo))
			&& viewTarget != none && Pawn(viewTarget).m_iTeam != m_iTeamId)
		{
			if(Level.NetMode != NM_Client)
			{
				SpectatorChangeTeams(true); 
				if(viewTarget != none && viewTarget != self)
					SetCameraMode();
			}
			return;
		} 

		if(!bBehindView)
			SetRotation(ViewTarget.Rotation + R6Pawn(ViewTarget).GetRotationOffset());
		else if(bFixedCamera)
			SetRotation(ViewTarget.Rotation);
        
        SetLocation(ViewTarget.Location);
    }

	function SetCameraMode()
    {
		local rotator rViewRotation;
        local actor CamSpot;

		#ifdefDEBUG if(bShowLog) log(" SetCameraMode() : m_eCameraMode="$m_eCameraMode$" m_PrevViewTarget="$m_PrevViewTarget);	#endif
		if(m_eCameraMode != CAMERA_Ghost)
		{
			// set viewTarget to pawn we are following
			if(viewTarget == self)
			{
				if(m_PrevViewTarget == none)
					return;
		        if(Level.NetMode == NM_Standalone)
                    m_TeamManager.SetVoicesMgr(R6AbstractGameInfo(Level.Game), false, true);

				SetNewViewTarget(m_PrevViewTarget);
			}
		}

        switch(m_eCameraMode)
        {
            case CAMERA_FirstPerson: 		
                
				bBehindView = false;
                m_bAttachCameraToEyes = true;
				bCheatFlying = false;					
				SetSpectatorRotation();
									
				DisplayClientMessage();
                #ifdefDEBUG if(bShowLog) log(" viewTarget=["$viewTarget$"] : First Person Camera : "$GetViewTargetName());	#endif

                break;

            case CAMERA_3rdPersonFixed: 

                bBehindView =  true;
                bFixedCamera = true;
				m_bAttachCameraToEyes = true;
				bCheatFlying = false;				
				SetSpectatorRotation();				
					
				DisplayClientMessage();
                #ifdefDEBUG if(bShowLog) log(" viewTarget=["$viewTarget$"] : Third person camera fixed : "$GetViewTargetName());	#endif

                break;

            case CAMERA_3rdPersonFree: 

				bBehindView =  true;
				bFixedCamera = false;	
				m_bAttachCameraToEyes = true;
				bCheatFlying = false;					
				SetSpectatorRotation();
				
				DisplayClientMessage();
				#ifdefDEBUG if(bShowLog) log(" viewTarget=["$viewTarget$"] : Third person camera free : "$GetViewTargetName());	#endif

				break;

			case CAMERA_Ghost: 
                
				// this will only occur on the server
				if(viewTarget != self)
					m_PrevViewTarget = viewTarget;
				SetViewTarget(self);

                if(m_PrevViewTarget == none)
                {
                    CamSpot = Level.GetCamSpot( GameReplicationInfo.m_szGameTypeFlagRep );

                    if(CamSpot != none)
                    {
	    		        SetRotation(CamSpot.Rotation);
				        SetLocation(CamSpot.Location);
                    }
                }
                else
                {
				    // set the camera position appropriately (3rd person) to the previous viewTarget before switching to ghost
				    rViewRotation = m_PrevViewTarget.rotation;
				    rViewRotation.Pitch = -6000;
	    		    SetRotation(rViewRotation);
				    SetLocation(m_PrevViewTarget.location - (CameraDist*R6Pawn(m_PrevViewTarget).default.CollisionRadius)*vector(rotation));
                }

				// reset necessary variables
				bBehindView = false;
				bFixedCamera = false;
				m_bAttachCameraToEyes=false;
				bCheatFlying = true;
		        if(Level.NetMode == NM_Standalone)
                    m_TeamManager.SetVoicesMgr(R6AbstractGameInfo(Level.Game), false, false, m_TeamManager.m_iIDVoicesMgr, true);
                else
    				m_TeamManager = none;

				DisplayClientMessage();
				#ifdefDEBUG if(bShowLog) log(" viewTarget=["$viewTarget$"] : Ghost camera mode");	#endif

				break;
        }
    }

	simulated function ChangeTeams(bool bNextTeam)
	{
		local R6RainbowTeam		rainbowTeam;

		if(Level.NetMode != NM_Standalone)
			return;
		
		if(m_eCameraMode == CAMERA_Ghost)
			return;

		rainbowTeam = R6RainbowTeam(R6AbstractGameInfo(Level.Game).GetNewTeam(m_TeamManager, bNextTeam));
		if(rainbowTeam == none)
			return;

        SetNewViewTarget(rainbowTeam.m_Team[0]);
		DisplayClientMessage();
	}

	function ServerChangeTeams(bool bNextTeam)
	{
		SpectatorChangeTeams(bNextTeam);
	}

	function ValidateCameraTeamId()
	{
		if((m_MenuCommunication != none) && (m_TeamSelection != PTS_Alpha))
			m_iTeamId = INT(ePlayerTeamSelection.PTS_Alpha  );
		else // PTS_Bravo
			m_iTeamId = INT(ePlayerTeamSelection.PTS_Bravo );	
	}

	function SpectatorChangeTeams(bool bNextTeam)
	{
        local R6Rainbow			other, first, last;
	    local bool				bFound;

        if ((Level.Game != none) && !Level.Game.bCanViewOthers)
			return;

		if(m_bSpectatorCameraTeamOnly && (m_iTeamId==0))
			ValidateCameraTeamId();
		
		if(bNextTeam)
		{
			first = none;
			ForEach AllActors( class'R6Rainbow', other )
			{		
				if(other.IsAlive())
				{
					// check if camera is restricted to teammates only
					if(m_bSpectatorCameraTeamOnly && (other.m_iTeam != m_iTeamId))
						continue;

					if ( bFound || (first == None) )
					{
						first = other;
						if ( bFound )
							break;
					}
					if ( other == ViewTarget ) 
						bFound = true;
				}
			}  
			if ( first != none )
				SetNewViewTarget(first);
			else
				return;
		}
		else
		{
			last = none;
			ForEach AllActors( class'R6Rainbow', other )
			{		
				if(other.IsAlive())
				{
					// check if camera is restricted to teammates only
					if(m_bSpectatorCameraTeamOnly && (other.m_iTeam != m_iTeamId))
						continue;
										
					if((other == ViewTarget) && (last != none))
						break;
					last = other;
				}
			}
			if (last != none )
				SetNewViewTarget(last);
			else
				return;
		}	
	}

	event ClientSetNewViewTarget()
	{
		#ifdefDEBUG if(bShowLog) log("  clientSetNewViewTarget() : viewTarget="$viewTarget);	#endif
		if(Level.NetMode != NM_Client)
			return;

		if(viewTarget != self)
			m_PrevViewTarget = viewTarget;

		SetNewViewTarget(ViewTarget);
		if(viewTarget != none)
			SetCameraMode();
	}

	simulated function SetNewViewTarget(actor aViewTarget)
	{
		local	R6Rainbow	    aPawn;
		local   R6RainbowTeam	aOldTeamManager;

		if(m_eCameraMode == CAMERA_Ghost) 
			return;

		#ifdefDEBUG if(bShowLog) log("  SetNewViewTarget() aViewTarget="$aViewTarget);	#endif
		aPawn = R6Rainbow(aViewTarget);
		if(aPawn == none)	return;
		SetViewTarget(aPawn);
		if(aPawn.controller != none)
		{
			aOldTeamManager = m_TeamManager;
            
            if(!aPawn.m_bIsPlayer)
				m_TeamManager = R6RainbowAI(aPawn.controller).m_TeamManager;
			else
				m_TeamManager = R6PlayerController(aPawn.controller).m_TeamManager;
 
            if ((Role == ROLE_Authority) && (aOldTeamManager != none) && (aOldTeamManager != m_TeamManager) && !aOldTeamManager.m_bLeaderIsAPlayer && !m_TeamManager.m_bLeaderIsAPlayer)
            {            
                aOldTeamManager.SetVoicesMgr(R6AbstractGameInfo(Level.Game), false, false, m_TeamManager.m_iIDVoicesMgr);
                m_TeamManager.SetVoicesMgr(R6AbstractGameInfo(Level.Game), false, true);
            }
		}
		SetSpectatorRotation();
		FixFOV();

		if(Level.NetMode == NM_ListenServer && (Viewport(Player) != none))
		{
			// cannot rely on PostNetReceive to call ClientSetNewTarget, since this spectator is the ListenServer
			DisplayClientMessage();
		}
	}

	exec function NextMember()
	{
		local	INT		i;

		// exit if we are in ghost camera
		if(m_eCameraMode == CAMERA_Ghost)
			return;

		if(Level.NetMode == NM_Standalone)
		{
			if(m_TeamManager.m_iMemberCount > 0)
			{
				i = R6Pawn(viewTarget).m_iId + 1;
				if(i >= m_TeamManager.m_iMemberCount)
					i = 0;
				SetViewTarget(m_TeamManager.m_Team[i]);
				DisplayClientMessage();
			}
		}
		else
			ServerChangeTeams(true);
	}

	exec function PreviousMember()
	{
		local	INT		i;

		// exit if we are in ghost camera
		if(m_eCameraMode == CAMERA_Ghost)
			return;

		if(Level.NetMode == NM_Standalone)
		{
			if(m_TeamManager.m_iMemberCount > 0)
			{
				i = R6Pawn(viewTarget).m_iId - 1;
				if(i < 0)	
					i = m_TeamManager.m_iMemberCount - 1;
				SetViewTarget(m_TeamManager.m_Team[i]);
				DisplayClientMessage();
			}
		}
		else
			ServerChangeTeams(false);		
	}

	function string GetViewTargetName()
	{
		local R6Pawn targetPawn;

		if(viewTarget == none)
			return "";

		targetPawn = R6Pawn(viewTarget);
		if(targetPawn == none)
			return "";

		if(targetPawn.m_bIsPlayer)
		{
			if(Level.NetMode == NM_Standalone)
				return targetPawn.m_CharacterName;
			else if(targetPawn.PlayerReplicationInfo != none)
				return targetPawn.PlayerReplicationInfo.PlayerName;
		}
		else
			return targetPawn.m_CharacterName;
	}
	
	function DisplayClientMessage()
	{
		local string	targetName;
		
		if(viewTarget == none)
			return;

		if((Level.NetMode == NM_Client) 
			|| (Level.NetMode == NM_Standalone) 
			|| ((Level.NetMode == NM_ListenServer) && (Viewport(Player) != none))) 
		{
			if(bCheatFlying)
			{				
				ClientMessage(Localize("Game", "GhostCamera", "R6GameInfo"));			
				return;
			}

			targetName = GetViewTargetName();
			if(targetName == "")
				return;

			if(!bBehindView)
				ClientMessage(Localize("Game", "NowViewing", "R6GameInfo") @ targetName @ Localize("Game", "FirstCamera", "R6GameInfo"));
			else if(bFixedCamera)
				ClientMessage(Localize("Game", "NowViewing", "R6GameInfo") @ targetName @ Localize("Game", "FixedThirdCamera", "R6GameInfo"));
			else
				ClientMessage(Localize("Game", "NowViewing", "R6GameInfo") @ targetName @ Localize("Game", "FreeThirdCamera", "R6GameInfo"));
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////////
//                       -- state PLAYERCLIMBOBJECT --               
// in this state, the player will temporarily lose control of the pawn     
///////////////////////////////////////////////////////////////////////////////////////
/* // R6CLIMBABLEOBJECT
state PlayerClimbObject
{
	function BeginState()
	{
		if(m_pawn.bIsCrouched)
			m_pawn.EndKneeDown();
        
        m_pawn.StopAnimating();
		// looks like physics must be set on server as well, server will communicate physics back to client...
		if ( physics != PHYS_RootMotion)  
		{
            aForward = 0;
            aStrafe = 0;
            pawn.velocity = vect(0,0,0);
            pawn.acceleration = vect(0,0,0);
            LockRootMotion(1, false);
			m_pawn.SetNextPendingAction(PENDING_StartClimbingObject);  
		}		
	}

	function PlayerMove(float DeltaTime)
	{
        aForward = 0;
        aStrafe = 0;
		R6PlayerMove(DeltaTime);
    }

    event AnimEnd(int iChannel)
    {
        if(iChannel == 0)
		{
            m_pawn.SetNextPendingAction(PENDING_PostStartClimbingObject);  
			if(pawn.bIsCrouched)
				pawn.SetLocation(pawn.location + vect(0,0,20)); 				
		}
		else if((m_pawn.m_climbObject == none) && (iChannel == m_pawn.C_iBaseBlendAnimChannel))
		{
			m_pawn.m_bPostureTransition = false;
			if(pawn.bIsCrouched)
				m_pawn.BlendKneeOnGround();
			GotoState('PlayerWalking');
		}
    }	
}
*/

// MPF1
 //-------------MissionPack1



function ServerStartSurrenderSequence()
{
	#ifdefDEBUG if(bShowLog) log(pawn$" : ServerStartSurrenderSequence() was called...pawn.physics="$pawn.physics$" GetStateName="$GetStateName());	#endif
	m_bSkipBeginState = false;
	GotoState('PlayerStartSurrenderSequence');
}


///////////////////////////////////////////////////////////////////////////////////////
//                       -- state PlayerStartSurrenderSequence --               
// The player rises up and then switches to PlayerPreBeginSurrending state
///////////////////////////////////////////////////////////////////////////////////////

state PlayerStartSurrenderSequence extends PlayerWalking
{
	// raise the player standing before anything
	function BeginState()
	{
		local SavedMove Next;
		local SavedMove Current;

		if(m_bSkipBeginState)
		{
			m_bSkipBeginState = false;			
			return;
		}

        #ifdefDEBUG if(bShowLog) logX("Enter State"); #endif //MP1DEBUG
        #ifdefDEBUG logX("R6PlayerController::BeginState() [PlayerStartSurrenderSequence] " $ self);  	#endif

		pawn.acceleration = vect(0,0,0);
		aForward = 0.f;
		aStrafe = 0.f;	
		//aTurn = 0.f;
		pawn.velocity = vect(0,0,0); // MPF_Milan2 
		//MPF_Milan_7_8_2003  - deprecated Acceleration =  vect(0,0,0); // MPF_Milan2 
		//MPF_Milan_7_8_2003  - deprecated Velocity = vect(0,0,0);// MPF_Milan2 

		// MPF_Milan_7_8_2003 - reset peeking for moving diagonally
		if(m_pawn.m_bMovingDiagonally)
			m_pawn.ResetDiagonalStrafing();

		bRun = 0;
		m_bPeekLeft = 0;
		m_bPeekRight = 0;

		m_fStartSurrenderTime = Level.TimeSeconds;

        // MPF_Milan - commented		DoZoom(TRUE);
		/* MPF_Milan_7_9_2003 - useless
		// clean out saved moves - MPF_Milan uncommented
		while ( SavedMoves != None )
		{
			Next = SavedMoves.NextMove;
            Current = SavedMoves;
			SavedMoves = Next;
			Current.Destroy();
		}
		if ( PendingMove != None )
		{
            Current = PendingMove;
			PendingMove = None;
			Current.Destroy();
		}
		*/

		if(m_pawn.m_eGrenadeThrow != GRENADE_None)
		{
			#ifdefDEBUG logX("Grenade throw"); #endif // MPF_Milan - debug only
			m_pawn.GrenadeAnimEnd();
		}

		// reset zoom - MPF_Milan
		if(Pawn.IsLocallyControlled()) 
		{ 
			ToggleHelmetCameraZoom(TRUE); 
			DoZoom(true); 
		} 
 
		// reset peek
		ToggleHelmetCameraZoom(TRUE);
		SetPeekingInfo( PEEK_none, m_pawn.C_fPeekMiddleMax );
		ResetFluidPeeking();
		
		if(m_pawn.m_bIsClimbingLadder) 
		{
			// cut & pasted from EndClimbingSetup()
			#ifdefDEBUG if(bShowLog) LogX("surrender: climbing ladder"); #endif //MPF_MIlan - debug only

			pawn.SetPhysics(PHYS_Falling);
			pawn.onLadder = none;
			m_pawn.m_bSlideEnd = false;

			m_pawn.m_bIsClimbingLadder = false;
			m_pawn.m_bPostureTransition = false;
			m_pawn.m_Ladder = none;

			// End cut & paste

			pawn.SetLocation(pawn.location + 25*vector(pawn.rotation));	 
		
			m_pawn.PlayFalling();//MP1_DEBUG
			//GotoState('PlayerWalking'); // temporarily, then it will switch to surrender after the fall
			
		}
		else if(m_bCrawl)
		{
			m_pawn.m_bWantsToProne= false; 
			if(Level.NetMode == NM_Client)			
				m_pawn.ServerSetCrouch(true); 
			m_pawn.bWantsToCrouch = true; 

			RaisePosture(); 
			m_pawn.EndCrawl();
		}
		else if(bDuck != 0)
		{
			// MPF_Milan_9_23_2003 - bug fix for "crouch" icon on HUD during surrender after crouching
			if(Level.NetMode == NM_Client)			
				m_pawn.ServerSetCrouch(false); 
			else
				m_pawn.ClientSetCrouch(false); 
			m_pawn.bWantsToCrouch = false; 
			// End MPF_Milan_9_23_2003 									
			m_pawn.m_bPostureTransition = false;
			RaisePosture(); 
//			m_pawn.EndCrouch(0);
			if(m_pawn.m_bReloadingWeapon || m_pawn.m_bChangingWeapon)
			{
				GotoState('PlayerFinishReloadingBeforeSurrender');
			}
			else 
			{
                #ifdefDEBUG log("R6PlayerController::BeginState() [PlayerStartSurrenderSequence] Called state Change to [PlayerPreBeginSurrending] 1"); #endif
				GotoState('PlayerPreBeginSurrending');
			}
		} 
		else if(m_pawn.m_bReloadingWeapon || m_pawn.m_bChangingWeapon)
		{
            #ifdefDEBUG log("R6PlayerController::BeginState() [PlayerStartSurrenderSequence] Called state Change to [PlayerFinishReloadingBeforeSurrender]");  	#endif

			GotoState('PlayerFinishReloadingBeforeSurrender');
		}
		else if(pawn.physics != PHYS_Falling)
		{
            #ifdefDEBUG log("R6PlayerController::BeginState() [PlayerStartSurrenderSequence] Called state Change to [PlayerPreBeginSurrending] 2");   #endif
			GotoState('PlayerPreBeginSurrending');
		}
	}

    function EndState()
	{
			// MPF_Milan_9_23_2003 - bug fix for "crouch" icon on HUD during surrender after crouching
			if(Level.NetMode == NM_Client)			
				m_pawn.ServerSetCrouch(false); 
			else
				m_pawn.ClientSetCrouch(false); 
			m_pawn.bWantsToCrouch = false; 
			// End MPF_Milan_9_23_2003 									
			#ifdefDEBUG if(bShowLog) logX("Exit state"); #endif //MP1DEBUG
	}

	event Tick(float fDiffTime)
	{
		// log("PlayerStartSurrenderSequence:Tick() physics="$pawn.physics$" isLanding="$pawn.m_bIsLanding$" m_bPostureTransition="$m_pawn.m_bPostureTransition);
		if(Role == ROLE_Authority && pawn.physics != PHYS_Falling && !pawn.m_bIsLanding && !m_bCrawl && bDuck ==0)
		{
            #ifdefDEBUG log("R6PlayerController::Tick() [PlayerStartSurrenderSequence] Called state Change to [PlayerPreBeginSurrending] 1");   #endif
			GotoState('PlayerPreBeginSurrending');
			ClientGotoState('PlayerPreBeginSurrending', '');
		}

	}

	// MPF_Milan - 
	function PlayerMove( float DeltaTime )
	{	
		#ifdefDEBUG logX("PlayerStartSurrenderSequence: PlayerMove() called"); #endif //MP1DEBUG

		// MPF_Milan2 
		if(pawn.physics != PHYS_Falling) 
		{
            pawn.acceleration = vect(0,0,0);
			pawn.velocity = vect(0,0,0); 
		    // Acceleration =  vect(0,0,0); 
            // Velocity = vect(0,0,0);
		}

		// End MPF_Milan2 
		aForward = 0.f;
		aStrafe = 0.f;	
		aTurn = 0.f;
		bRun = 0;
		m_bPeekLeft = 0;
		m_bPeekRight = 0;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
	}
	// End MPF_Milan 

    function PlayFiring() {}
    function AltFiring()  {}
    function ServerReStartPlayer() {}
	// no chit chat while surrended/arrested
	exec function Say( string Msg ) {}
	exec function TeamSay( string Msg ) {}

    // exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire( optional float F ) {}

	event AnimEnd(int iChannel)
	{
		#ifdefDEBUG if(bShowLog) logX("PlayerstartSurrenderSequence: AnimEnd(), channel="$iChannel$" bDuck="$bDuck$" m_bCrawl="$m_bCrawl$" bIsCrouched="$m_pawn.bIsCrouched$" m_bIsProne="$m_pawn.m_bIsProne$" ReloadingWeapon="$m_pawn.m_bReloadingWeapon ); #endif //MP1DEBUG 

		if(iChannel == m_pawn.C_iBaseBlendAnimChannel && bDuck !=0) 
		{
				m_pawn.m_bPostureTransition = false;
				RaisePosture();
				if(m_pawn.m_bReloadingWeapon || m_pawn.m_bChangingWeapon)
				{
					GotoState('PlayerFinishReloadingBeforeSurrender');
                }
				else
				{
                    #ifdefDEBUG log("R6PlayerController::AnimEnd() [PlayerStartSurrenderSequence] Called state Change to [PlayerPreBeginSurrending]");   #endif
					GotoState('PlayerPreBeginSurrending');
                }
		}
		else m_pawn.AnimEnd(iChannel);
	}
	
	function VeryShortClientAdjustPosition
	(
		float TimeStamp, 
		float NewLocX, 
		float NewLocY, 
		float NewLocZ,
		Actor NewBase
	)
	{
		local vector Floor;

		if ( Pawn != None )
			Floor = Pawn.Floor;
		
		// #ifdef R6CODE
		// rbrek 17 feb 2002 - added a safe guard, somehow the server invokes this function call on a client whose pawn is not in PHYS_Walking...
		//					   (i.e. when player is trying to get on ladder and is in PHYS_RootMotion -	this should never happen???  TOFIX)
		if(pawn.physics != PHYS_Walking)
			return;
		// #endif
		m_bSkipBeginState = true;

		LongClientAdjustPosition(TimeStamp,'PlayerStartSurrenderSequence',PHYS_Walking,NewLocX,NewLocY,NewLocZ,0,0,0,NewBase,
			Floor.X,Floor.Y,Floor.Z);

		m_bSkipBeginState = false;
	}



}

///////////////////////////////////////////////////////////////////////////////////////
//                       -- state PlayerFinishReloadingBeforeSurrender --               
// The player finishes to reload his weapon and then switches to PlayerPreBeginSurrending state
///////////////////////////////////////////////////////////////////////////////////////

state PlayerFinishReloadingBeforeSurrender  
{
	function BeginState()
	{
        #ifdefDEBUG if(bShowLog) logX("Enter State"); #endif //MP1DEBUG
		#ifdefDEBUG if(bShowLog) logX("R6PlayerController::BeginState() [PlayerFinishReloadingBeforeSurrender] " $ self); #endif //MP1DEBUG 
	}

	event AnimEnd(int iChannel)
	{
		#ifdefDEBUG if(bShowLog) log(" **********ANIMEND: PlayerFinishReloadingBeforeSurrender() channel="$iChannel$" rightanimchannel="$m_pawn.C_iWeaponRightAnimChannel); #endif

		m_pawn.AnimEnd(iChannel);

		if(iChannel == m_pawn.C_iWeaponRightAnimChannel )
		{
			//m_bWeaponTransition = false;	

			GoToState('PlayerPreBeginSurrending');
		}
	}
    function PlayFiring() {}
    function AltFiring()  {}
    function ServerReStartPlayer() {}
	// no chit chat while surrended/arrested
	exec function Say( string Msg ) {}
	exec function TeamSay( string Msg ) {}

//    exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire( optional float F ) {}
		function ServerMove( 
		float TimeStamp, 
		vector Accel, 
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbCrawl,
		int View,
        int iNewRotOffset,
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{}

	// MPF_MilanX
	function PlayerMove( float DeltaTime )
	{	
		pawn.acceleration = vect(0,0,0);
		aForward = 0.f;
		aStrafe = 0.f;
		aTurn = 0.f;

		bRun = 0;
		m_bPeekLeft = 0;
		m_bPeekRight = 0;
		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
	}
	// End MPF_Milan
}

/*
function ClientPreBeginSurrending()
{
	#ifdefDEBUG if(bShowLog) log(pawn$" : ClientPreBeginSurrending() was called...pawn.physics="$pawn.physics$" GetStateName="$GetStateName());	#endif 
	m_bSkipBeginState = false;
	GotoState('PlayerPreBeginSurrending');
}
*/

///////////////////////////////////////////////////////////////////////////////////////
//                       -- state PlayerPreBeginSurrending --               
// The player put his weapon avay and then stwitches to PlayerStartSurrending state
///////////////////////////////////////////////////////////////////////////////////////

state PlayerPreBeginSurrending  extends CameraPlayer
{
	function BeginState()
	{
        local R6AbstractWeapon aWeapon;

		local rotator newRot; // MPF_Milan_7_8_2003 - see below

        #ifdefDEBUG if(bshowlog) log(m_pawn$" has entered state PlayerPreBeginSurrending ...pawn.physics="$pawn.physics$" Pawn.EngineWeapon="$Pawn.EngineWeapon); #endif
		#ifdefDEBUG if(bShowLog) logX("R6PlayerController::BeginState() [PlayerPreBeginSurrending] " $ self); #endif

        // toggle 3rd person view, camera free
        if(Pawn.IsLocallyControlled() && m_eCameraMode==CAMERA_FirstPerson && Level.NetMode != NM_DedicatedServer)			
        {
			// MPF_Milan_7_8_2003 patch to fix the roll of the camera in case of the player peeking
//			pawn.m_rRotationOffset.roll = 0;
			newRot.pitch = ViewTarget.Rotation.pitch;
			newRot.yaw = ViewTarget.Rotation.yaw;
			newRot.roll = 0;
			ViewTarget.SetRotation(newRot);

			// end MPF_Milan_7_8_2003

            DoZoom(true);
            bZooming = false;
            m_bHelmetCameraOn = false;
            DefaultFOV = default.DefaultFOV;
            DesiredFOV = default.DesiredFOV;
            FOVAngle = default.DesiredFOV;
            HelmetCameraZoom(1); 
            R6Pawn(Pawn).ToggleHeatProperties(false, none, none);
            R6Pawn(Pawn).ToggleNightProperties(false, none, none);
            R6Pawn(Pawn).ToggleScopeProperties(false, none, none);
            Level.m_bHeartBeatOn = false;

            //ResetBlur();

            Level.m_bInGamePlanningActive = false;
            SetPlanningMode( false );

            m_eCameraMode = CAMERA_3rdPersonFree;
            if(!CameraIsAvailable())
	            SelectCameraMode(true);
            SetCameraMode();
        }
		
		Pawn.m_fRemainingGrenadeTime = 0;
		// make sure engineweapon is valid, and that player is not equipped with a grenade weapon that has no grenades left
		if(m_Pawn.EngineWeapon != none && !((Pawn.EngineWeapon.IsA('R6GrenadeWeapon') || Pawn.EngineWeapon.IsA('R6HBSSAJammerGadget')) && !Pawn.EngineWeapon.HasAmmo())) //MPF_Milan - managing also S.A. Jammer like grenades
		{
			if (m_pawn.m_bIsFiringWeapon != 0)
			{
				m_pawn.EngineWeapon.ServerStopFire();
			}

			if( !m_pawn.EngineWeapon.IsInState('PutWeaponDown'))
			{	// start the weapondown animation, wait in this state until it's ended
				m_Pawn.EngineWeapon.GotoState('PutWeaponDown');
				if(Level.NetMode != NM_Client)			
					m_pawn.SetNextPendingAction(PENDING_SecureWeapon);

				//m_pawn.RainbowSecureWeapon();
			}
			else
			{
				m_bSkipBeginState = false;

        		#ifdefDEBUG if(bShowLog) log("R6PlayerController::BeginState() [PlayerPreBeginSurrending] Called state Change to [PlayerStartSurrending] 1"); #endif
				GotoState('PlayerStartSurrending');
				//if(Level.NetMode == NM_Client) //MPF_Milan_7_1_2003 -  commented again
				//	ServerStartSurrending(); // MPF_Milan_7_1_2003 -  commented again
			}	
		}
		else
		{
			m_bSkipBeginState = false;
       		#ifdefDEBUG if(bShowLog) log("R6PlayerController::BeginState() [PlayerPreBeginSurrending] Called state Change to [PlayerStartSurrending] 2"); #endif
			GotoState('PlayerStartSurrending');
			//if(Level.NetMode == NM_Client) // MPF_Milan_7_1_2003 -  commented again
			//    ServerStartSurrending(); // MPF_Milan_7_1_2003 -  commented again
		}

	}

	function EndState()
	{
    	#ifdefDEBUG if(bShowLog) log(m_pawn$" has exited state PlayerPreBeginSurrending ... ");		#endif 
		m_pawn.m_bWeaponTransition = false;
	}

    function PlayFiring() {}
    function AltFiring()  {}
    function ServerReStartPlayer() {}
	// no chit chat while surrended/arrested
	exec function Say( string Msg ) {}
	exec function TeamSay( string Msg ) {}

    exec function Fire( optional float F ) {}

	event AnimEnd(int iChannel)
    {
		#ifdefDEBUG if(bShowLog) logX("R6PlayerController::AnimEnd() [PlayerPreBeginSurrending] chan="$iChannel$" watch="$m_pawn.C_iWeaponRightAnimChannel);	#endif 

		if((iChannel == m_pawn.C_iWeaponRightAnimChannel) /*&& MPF_Milan - Level.NetMode != NM_DedicatedServer*/ )
		{			
			m_bSkipBeginState = false;
			GotoState('PlayerStartSurrending');
			//if(Level.NetMode == NM_Client) // MPF_Milan_7_1_2003 -  commented again
			//    ServerStartSurrending(); // MPF_Milan_7_1_2003 -  commented again
		}
		else
			m_pawn.AnimEnd(iChannel);
	}

	function SwitchWeapon (BYTE F )
	{
		// do nothing, prevent player from trying to switch to another weapon
	}

	// MPF_Milan - removed overriding of PlayerMove

	// MPF_Milan_7_1_2003 - override forbidden functions
	exec function PreviousMember(){	}
	exec function NextMember(){	}
	simulated function ChangeTeams(bool bNextTeam) {}
	function ServerChangeTeams(bool bNextTeam){	}
	function ValidateCameraTeamId()	{}
	function SpectatorChangeTeams(bool bNextTeam){	}

	event ClientSetNewViewTarget(){	}
	simulated function SetNewViewTarget(actor aViewTarget)	{}	
	// End MPF_Milan_7_1_2003 
}

// MPF_Milan - function ServerStartSurrending uncommented (needed for dedicated servers)
/*
function ServerStartSurrending()
{
	#ifdefDEBUG if(bShowLog) log(pawn$" : ServerStartSurrending() was called...pawn.physics="$pawn.physics$" GetStateName="$GetStateName());	#endif 
	m_bSkipBeginState = false;
	GotoState('PlayerStartSurrending');
}
*/

///////////////////////////////////////////////////////////////////////////////////////
//                       -- state PlayerStartSurrending --               
// in this state, the player will temporarily lose control of the pawn     
///////////////////////////////////////////////////////////////////////////////////////

state PlayerStartSurrending  extends CameraPlayer
{
	function BeginState()
	{
		#ifdefDEBUG if(bShowLog) log(pawn$" has entered state PlayerStartSurrending ...pawn.physics="$pawn.physics$" Pawn.EngineWeapon="$Pawn.EngineWeapon); #endif
        #ifdefDEBUG if(bShowLog) logX("R6PlayerController::BeginState() [PlayerStartSurrending] " $ self); #endif
        

		if(m_bSkipBeginState)
		{
			m_bSkipBeginState = false;			
			return;
		}
		
		if(Level.NetMode != NM_Client)			
		    m_pawn.SetNextPendingAction(PENDING_StartSurrender);

		//m_pawn.PlayStartSurrender();// MPF_Milan_7_1_2003 -  commented 
	}

	function EndState()
	{
    	#ifdefDEBUG if(bShowLog) log(pawn$" has exited state PlayerStartSurrending ... "); #endif 
		m_pawn.m_bPostureTransition = false;
		m_pawn.m_bPawnSpecificAnimInProgress = false; // MPF_Milan2
	}

	event AnimEnd(int iChannel)
    {
    	#ifdefDEBUG if(bShowLog) logX("R6PlayerController::AnimEnd() [PlayerStartSurrending] chan="$iChannel$" watch="$m_pawn.C_iPawnSpecificChannel);	 #endif 
		

	    if(iChannel == m_pawn.C_iPawnSpecificChannel) // MPF_Milan2 - changed channel (from Base channel)
        {	
            // MPF_Milan m_pawn.PlaySurrender(); - commented
			//if(Level.NetMode == NM_Client) // MPF_Milan_7_1_2003 -  commented again
			//    ServerStartSurrended();// MPF_Milan_7_1_2003 -  commented again
			GotoState('PlayerSurrended'); 
        }	
    	// MPF_Milan_10_6_2003 - anti bug by an exhausted developer, for lag and firing weapon while surrendering
    	// (there should be a conflict in the pawn-specific animation channel)
		else if(Level.TimeSeconds - m_fStartSurrenderTime > 2)
		{
			m_pawn.EngineWeapon.ServerStopFire(); //anti-bug (to force stop infinite looping sound)
			GotoState('PlayerSurrended');
        }	
    	// End MPF_Milan_10_6_2003 
	}

	function SwitchWeapon (BYTE F )
	{
		// do nothing, prevent player from trying to switch to another weapon
	}

    function PlayFiring() {}
    function AltFiring()  {}
    function ServerReStartPlayer() {}
    // exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire( optional float F ) {}

	// no chit chat while surrended/arrested
	exec function Say( string Msg ) {}
	exec function TeamSay( string Msg ) {}

	// MPF_Milan - removed overriding of PlayerMove
	// MPF_Milan_7_1_2003 - override forbidden functions
	exec function PreviousMember(){	}
	exec function NextMember(){	}
	simulated function ChangeTeams(bool bNextTeam) {}
	function ServerChangeTeams(bool bNextTeam){	}
	function ValidateCameraTeamId()	{}
	function SpectatorChangeTeams(bool bNextTeam){	}
	event ClientSetNewViewTarget(){	}
	simulated function SetNewViewTarget(actor aViewTarget)	{}	
	// End MPF_Milan_7_1_2003 
}


function ServerStartSurrended()
{
	#ifdefDEBUG if(bShowLog) log(pawn$" : ServerStartSurrended() was called...pawn.physics="$pawn.physics$" GetStateName="$GetStateName());	 #endif 
	m_bSkipBeginState = false;
	GotoState('PlayerSurrended');
}

///////////////////////////////////////////////////////////////////////////////////////
//                       -- state PlayerSurrended --               
//       the player is waiting to be handcuffed or for the timer to expire
///////////////////////////////////////////////////////////////////////////////////////

state PlayerSurrended  extends CameraPlayer
{
	function BeginState()
	{
		#ifdefDEBUG if(bShowLog) log(pawn$" has entered state PlayerSurrended ...pawn.physics="$pawn.physics$" Pawn.EngineWeapon="$Pawn.EngineWeapon);	#endif
   		#ifdefDEBUG if(bShowLog) logX("R6PlayerController::BeginState() [PlayerSurrended] " $ self); #endif

        //MPF_Milan_7_1_2003 	m_pawn.m_bSurrenderWait = true;
		m_pawn.bInvulnerablebody = false;

		if(Level.NetMode != NM_Client)			
		    m_pawn.SetNextPendingAction(PENDING_Surrender);
  		//m_pawn.PlaySurrender();
	}

	event AnimEnd(int iChannel)
    {
		#ifdefDEBUG if(bShowLog) logX("R6PlayerController::AnimEnd() [PlayerSurrended] chan="$iChannel$" watch="$m_pawn.C_iPawnSpecificChannel);	 #endif

	    if(iChannel == m_pawn.C_iPawnSpecificChannel)
        {	
		    //Breathing loop, not done in PlayWaiting() cause playing in C_iPawnSpecificChannel to avoid blending of layers 14 and 15
		    //We allow ourself a double call to PlaySurrender (locally and comming through the server) because we want to make absolutly
		    //sure that the rainbow never stops playing SurrenderWaitBreathe even when lag is involved and calls from the server could be
		    //delayed.  Besides, due to the nature of the animation involved, breaking a currently playing breath to start a new one is
		    //realy not important. If the rainbow ever stop playing that animation (other than chainning to other surrendering animations, 
		    //his arms will drop momentarily and we'll see glitches.  Given the current code and even with this double call, lapsing in the
		    //animation could if not on the server or the surrendering client (ie, when on another client watching the surrendering 
		    //rainbow).  It would be good to fix that at some point before release.  This could be acheived by synchronizing the states
		    //of all the pawns on all machines.
		    
		    if(Level.NetMode != NM_Client)			
		        m_pawn.SetNextPendingAction(PENDING_Surrender);
		    //m_pawn.PlaySurrender(); //End MPF_Milan_7_1_2003 
        }	
	}

	function EndState()
	{
		#ifdefDEBUG if(bShowLog) log(pawn$" has exited state PlayerSurrended ... ");		#endif 
		//MPF_Milan_7_1_2003 m_pawn.m_bSurrenderWait = false;
		m_pawn.m_bPawnSpecificAnimInProgress = false; // MPF_Milan2
	}

    function PlayFiring() {}
    function AltFiring()  {}
    function ServerReStartPlayer() {}
    exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire( optional float F ) {}

	// no chit chat while surrended/arrested
	exec function Say( string Msg ) {}
	exec function TeamSay( string Msg ) {}

	function SwitchWeapon (BYTE F )
	{
		// do nothing, prevent player from trying to switch to another weapon
	}

	event Tick(FLOAT fDeltaTime)
	{
		//#ifdefDEBUG	log("R6PlayerController::Tick (PlayerSurrended) TimeSeconds="$Level.TimeSeconds$" | m_fStartSurrenderTime="$m_fStartSurrenderTime$" | m_bIsUnderArrest="$m_pawn.m_bIsUnderArrest$" | m_bIsBeingArrestedOrFreed="$m_pawn.m_bIsBeingArrestedOrFreed); #endif
		if (Role == ROLE_Authority && ( Level.TimeSeconds - m_fStartSurrenderTime > 10) && !m_pawn.m_bIsUnderArrest &&!m_pawn.m_bIsBeingArrestedOrFreed) // MPF_Milan - Server only
		{
			// become active again, nobody has captured me
	
			m_bSkipBeginState = false;
			m_pawn.m_eHealth = HEALTH_Healthy;
			m_pawn.m_bIsSurrended = false;
			//MPF_Milan_9_23_2003 if(Level.NetMode == NM_DedicatedServer) //MPF_Milan_7_1_2003  - only called by dedicated server for client
			if(Role == Role_Authority) //MPF_Milan_9_23_2003
				ClientEndSurrended();
			
    		#ifdefDEBUG if(bShowLog) log("R6PlayerController::Tick() [PlayerSurrended] Called state Change to [PlayerEndSurrended] (TIMER ENDED)"); #endif
            
			GotoState('PlayerEndSurrended');
		}
		else if(m_pawn.m_bIsBeingArrestedOrFreed)
		{
    		#ifdefDEBUG if(bShowLog) log("R6PlayerController::Tick() [PlayerSurrended] Called state Change to [PlayerStartArrest]"); #endif
			GotoState('PlayerStartArrest');
		}
	}

	// MPF_Milan - removed overriding of PlayerMove


	// MPF_Milan_7_1_2003 - override forbidden functions
	exec function PreviousMember(){	}
	exec function NextMember(){	}
	simulated function ChangeTeams(bool bNextTeam) {}
	function ServerChangeTeams(bool bNextTeam){	}
	function ValidateCameraTeamId()	{}
	function SpectatorChangeTeams(bool bNextTeam){	}
	event ClientSetNewViewTarget(){	}
	simulated function SetNewViewTarget(actor aViewTarget)	{}	
	// End MPF_Milan_7_1_2003 
	
}

function ClientEndSurrended() //MPF_Milan2 - renamed to ClientEndSurrended, was ServerEndSurrended()
{
	#ifdefDEBUG if(bShowLog) logX("ClientEndSurrended() was called...pawn="$pawn$" pawn.physics="$pawn.physics$" GetStateName="$GetStateName());	#endif 
	m_bSkipBeginState = false;
	m_pawn.m_eHealth = HEALTH_Healthy;
	m_pawn.m_bIsSurrended = false;
	GotoState('PlayerEndSurrended');
}


///////////////////////////////////////////////////////////////////////////////////////
//						  --  state PlayerEndSurrended  -- 
//       Player wasn't handcuffed and is now free to resume play MissionPack1
///////////////////////////////////////////////////////////////////////////////////////

state PlayerEndSurrended  extends CameraPlayer
{
	function BeginState()
	{	
		#ifdefDEBUG if(bShowLog) log(pawn$" has entered state PlayerEndSurrended - BeginState() : bIsWalking="$pawn.bIsWalking$" m_pawn.m_Ladder="$m_pawn.m_Ladder$" pawn.physics="$pawn.physics); #endif
   		#ifdefDEBUG if(bShowLog) logX("R6PlayerController::BeginState() [PlayerEndSurrended] " $ self); #endif

		if(m_bSkipBeginState)
		{
			m_bSkipBeginState = false;
			return;
		}

		m_fStartSurrenderTime = Level.TimeSeconds;
		m_pawn.bInvulnerableBody = true;

		if(Level.NetMode != NM_Client) 
			m_pawn.SetNextPendingAction(PENDING_EndSurrender);  
		//m_pawn.PlayEndSurrender();MPF_Milan_7_1_2003 -  commented
	}

	function EndState()
	{
		#ifdefDEBUG if(bShowLog) log(pawn$" has exited state PlayerEndSurrended : pawn.physics="$pawn.physics);	#endif 

		EndSurrenderSetUp();

		if(Pawn.IsLocallyControlled() && m_eCameraMode==CAMERA_3rdPersonFree)			
		{
			m_eCameraMode = CAMERA_FirstPerson;
			if(!CameraIsAvailable())
				SelectCameraMode(true);
			SetCameraMode();
		}

		m_pawn.m_bPawnSpecificAnimInProgress = false; // MPF_Milan2

		if(m_Pawn.EngineWeapon != none && !((Pawn.EngineWeapon.IsA('R6GrenadeWeapon') || Pawn.EngineWeapon.IsA('R6HBSSAJammerGadget')) && !Pawn.EngineWeapon.HasAmmo())) // MPF_MilanX
		{
			#ifdefDEBUG if(bShowLog) log("PlayerEndSurrended:BringWeaponUp");		#endif 

			// if it's a grenade, we must do this to prevent the pin to reappear detached from grenade  
			// (when the player was surrended while launching a grenade) MPF_MilanX
			if(Pawn.EngineWeapon.IsA('R6GrenadeWeapon') || Pawn.EngineWeapon.IsA('R6HBSSAJammerGadget')) 
				WeaponUpState();

			Pawn.EngineWeapon.GotoState('BringWeaponUp');

            if(Level.NetMode != NM_Client)
			    m_pawn.SetNextPendingAction(PENDING_EquipWeapon); 
		}

	}

	event AnimEnd(int iChannel)
    {
		#ifdefDEBUG if(bShowLog) logX("R6PlayerController::AnimEnd() [PlayerEndSurrended] chan="$iChannel$" watch="$m_pawn.C_iPawnSpecificChannel);		#endif 

		if(iChannel == m_pawn.C_iPawnSpecificChannel) // MPF_Milan2 - changed to specific channel
		{
            if(Level.NetMode != NM_Client) 
                m_pawn.SetNextPendingAction(PENDING_PostEndSurrender);  
            //m_pawn.PlayPostEndSurrender(); MPF_Milan_7_1_2003 -  commented 

       		#ifdefDEBUG if(bShowLog) log("R6PlayerController::AnimEnd() [PlayerEndSurrended] Called state Change to [PlayerWalking]"); #endif
            GotoState('PlayerWalking');
	    }
    }	

	function EndSurrenderSetUp()
	{
		m_pawn.m_bPostureTransition = false;
		if(Role == ROLE_Authority)
		{
			m_fStartSurrenderTime = Level.TimeSeconds;
		}
	}

	function SwitchWeapon (BYTE F )
	{
		// do nothing, prevent player from trying to switch to another weapon
	}

    function PlayFiring() {}
    function AltFiring()  {}
    function ServerReStartPlayer() {}
    //exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire( optional float F ) {}

	// no chit chat while surrended/arrested
	exec function Say( string Msg ) {}
	exec function TeamSay( string Msg ) {}

	// MPF_Milan - removed overriding of PlayerMove
	function ValidateCameraTeamId()	{}

	// MPF_Milan_7_1_2003 - override forbidden functions
	exec function PreviousMember(){	}
	exec function NextMember(){	}
	simulated function ChangeTeams(bool bNextTeam) {}
	function ServerChangeTeams(bool bNextTeam){	}
	function SpectatorChangeTeams(bool bNextTeam){	}
	event ClientSetNewViewTarget(){	}
	simulated function SetNewViewTarget(actor aViewTarget)	{}	
	// End MPF_Milan_7_1_2003 

}


///////////////////////////////////////////////////////////////////////////////////////
//                     -- state PLAYERSECURERAINBOW --               
///////////////////////////////////////////////////////////////////////////////////////

state PlayerSecureRainbow //extends PlayerWalking
{
	function BeginState()
	{
		#ifdefDEBUG if(bShowLog) log(pawn$" has entered state PlayerSecureRainbow ... m_PlayerCurrentCA="$m_PlayerCurrentCA); #endif
        #ifdefDEBUG if(bShowLog) logX("R6PlayerController::BeginState() [PlayerSecureRainbow] " $ self); #endif
        
		// to avoid the surrender to end its surrender state on his own while being captured
		if(m_PlayerCurrentCA.aQueryTarget != none)
			R6PlayerController(R6Rainbow(m_PlayerCurrentCA.aQueryTarget).Controller).m_fStartSurrenderTime = Level.TimeSeconds;

		if(m_Pawn.EngineWeapon != none)
		{
			if(Pawn.IsLocallyControlled())
			{
                ToggleHelmetCameraZoom(TRUE);
                DoZoom(true);
                bZooming = false;
                m_bHelmetCameraOn = false;
                DefaultFOV = default.DefaultFOV;
                DesiredFOV = default.DesiredFOV;
                FOVAngle = default.DesiredFOV;
                HelmetCameraZoom(1); 
                R6Pawn(Pawn).ToggleHeatProperties(false, none, none);
                R6Pawn(Pawn).ToggleNightProperties(false, none, none);
                R6Pawn(Pawn).ToggleScopeProperties(false, none, none);
                Level.m_bHeartBeatOn = false;

                //ResetBlur();

                Level.m_bInGamePlanningActive = false;
                SetPlanningMode( false );
			}

			Pawn.EngineWeapon.GotoState('PutWeaponDown');

			if(Level.NetMode != NM_Client)			
				m_pawn.SetNextPendingAction(PENDING_SecureWeapon);

			//m_pawn.RainbowSecureWeapon();		MPF_Milan_7_1_2003 -  commented 
		}

		SetPeekingInfo( PEEK_none, m_pawn.C_fPeekMiddleMax );
		ResetFluidPeeking();
	}

	function EndState()
	{
	    local R6AbstractGameInfo pGameInfo; // MPF_Milan_7_15_2003 
		local string arrestorName;// MPF_Milan_7_15_2003 

		#ifdefDEBUG if(bShowLog) log(pawn$" has exited state PlayerSecureRainbow ");	#endif 
		
		// if action was not completed, reset Rainbow to surrendered state...
		if(m_iPlayerCAProgress < 100)
		{		
		    #ifdefDEBUG if(bShowLog) log(pawn$" has INTERRUPTED state PlayerSecureRainbow: target_m_bIssurrended="$R6Rainbow(m_PlayerCurrentCA.aQueryTarget).m_bIsSurrended$" m_bIsSecuringRainbow="$m_bIsSecuringRainbow);	 #endif 
			
			m_pawn.R6ResetAnimBlendParams(m_pawn.C_iBaseBlendAnimChannel);	
//			if (Role == ROLE_Authority)
//			{
				if(m_bIsSecuringRainbow && R6Rainbow(m_PlayerCurrentCA.aQueryTarget).m_bIsSurrended) 
					R6Rainbow(m_PlayerCurrentCA.aQueryTarget).ResetArrest();				
//			}

		}
		else
		{
			if(Level.NetMode != NM_Client)
			{
				if(m_bIsSecuringRainbow)
				{
					R6Rainbow(m_PlayerCurrentCA.aQueryTarget).m_bIsBeingArrestedOrFreed = false;
				// arrest the rainbow only if he's still in surrender state (he may change state on his own after 10 sec)
					if(R6Rainbow(m_PlayerCurrentCA.aQueryTarget).m_bIsSurrended) 
					{
						R6Rainbow(m_PlayerCurrentCA.aQueryTarget).m_bIsUnderArrest = true;
//						if ( Level.NetMode != NM_Client ) already checked in the outer test
						R6AbstractGameInfo(Level.Game).PawnSecure( R6Rainbow(m_PlayerCurrentCA.aQueryTarget)) ;
						// MPF_Milan_7_15_2003 - update statistics (moved here from R6Surrender() )
						
						// increment arrestor's frag counts
						// if(m_pawn.IsEnemy(pOther))
							m_pawn.IncrementFragCount();
						
						if(m_pawn.PlayerReplicationInfo != none)
							arrestorName = m_pawn.PlayerReplicationInfo.PlayerName;
						else
							arrestorName = m_pawn.m_CharacterName; // Was copied in UnPossessed()

						// increment arrested's number of deaths
						
						pGameInfo = R6AbstractGameInfo(Level.Game);
						if ( pGameInfo != none )
						{
							// compile stats only when we have adversaries
							if ((pGameInfo.m_bCompilingStats==true || (pGameInfo.m_bGameOver && pGameInfo.m_bGameOverButAllowDeath)))
							{ 
								if (R6Pawn(m_PlayerCurrentCA.aQueryTarget).PlayerReplicationInfo != none)
								{
									R6Pawn(m_PlayerCurrentCA.aQueryTarget).PlayerReplicationInfo.m_szKillersName = arrestorName;
									R6Pawn(m_PlayerCurrentCA.aQueryTarget).PlayerReplicationInfo.Deaths += 1.f;
									if ( !R6Pawn(m_PlayerCurrentCA.aQueryTarget).m_bSuicided && 
									  R6Pawn(m_PlayerCurrentCA.aQueryTarget).m_KilledBy != none && 
									  R6Pawn(m_PlayerCurrentCA.aQueryTarget).m_KilledBy.Controller != none && 
									  R6Pawn(m_PlayerCurrentCA.aQueryTarget).m_KilledBy.Controller.PlayerReplicationInfo!=none )
										R6Pawn(m_PlayerCurrentCA.aQueryTarget).m_KilledBy.Controller.PlayerReplicationInfo.Score += 1.f;
								}
								/*
								else
								{
									P = R6PlayerController(GetHumanLeaderForAIPawn());
									if (P!=none)
									{
										P.PlayerReplicationInfo.Deaths += 1.f;
									}
								}*/
							}

							//pGameInfo.PawnKilled( self );
						}

						// End MPF_Milan_7_15_2003 


					}
				
				}
				else // is rescuing rainbow
					R6PlayerController(R6Rainbow(m_PlayerCurrentCA.aQueryTarget).Controller).DispatchOrder(m_PlayerCurrentCA.iPlayerActionID, m_pawn);
			}
		}

		m_iPlayerCAProgress = 0;
		m_pawn.m_bPostureTransition = false;		
		if(!m_pawn.m_bIsSurrended)
		{
			//Bring up weapon only if I'm not exiting because I've been shot and I'm surrendering
			m_pawn.m_ePlayerIsUsingHands = HANDS_None;
			if(m_Pawn.EngineWeapon != none)
			{
				Pawn.EngineWeapon.GotoState('BringWeaponUp');
				if(Level.NetMode != NM_Client)
					m_pawn.SetNextPendingAction(PENDING_EquipWeapon);
				m_pawn.RainbowEquipWeapon();
			}
		}
		
	}

	function PlayerMove( float fDeltaTime )
	{	
		aForward = 0.f;
		aStrafe = 0.f;
		aMouseX = 0.f;
		aMouseY = 0.f;
		aTurn = 0.f;

		m_bPeekLeft = 0;
		m_bPeekRight = 0;

		global.PlayerMove(fDeltaTime);		
	}

	event AnimEnd(int iChannel)
    {
		if(iChannel == m_pawn.C_iBaseBlendAnimChannel && m_pawn.m_bPostureTransition)
		{
			if(bShowLog) log("SecureRainbow: AnimEnd, END Secure/Free rainbow animation, switch playerwalking");
			m_pawn.m_bPostureTransition = false;
			m_pawn.AnimBlendToAlpha(m_pawn.C_iBaseBlendAnimChannel, 0.0, 0.5);
			m_iPlayerCAProgress = 100;
			// we want ClientActionProgressDone() to be called only if we are a dedicated server, otherwise, it will be called on ourself
            if(Level.NetMode == NM_DedicatedServer)
                ClientActionProgressDone();

			if(m_InteractionCA != none)
				m_InteractionCA.ActionProgressDone();

			if(Level.NetMode != NM_Client)
				GotoState('PlayerWalking');
		}
		else if ((iChannel == m_pawn.C_iWeaponRightAnimChannel) && (m_pawn.m_eEquipWeapon == m_pawn.eEquipWeapon.EQUIP_NoWeapon))
		{
			if(bShowLog) log("SecureRainbow: AnimEnd, start Secure/Free rainbow animation");
			m_pawn.m_bWeaponTransition = false;	
			m_pawn.m_bPostureTransition = false;
			m_pawn.PlaySecureTerrorist();	

			m_PlayerCurrentCA.aQueryTarget.R6CircumstantialActionProgressStart(m_PlayerCurrentCA);
			m_bIsSecuringRainbow = (m_PlayerCurrentCA.iPlayerActionID == m_pawn.eRainbowCircumstantialAction.CAR_Secure);

			if(bShowLog) log("SecureRainbow: AnimEnd, start Secure/Free rainbow animation. CircAction="$m_PlayerCurrentCA.iPlayerActionID$" m_bIsSecuringRainbow="$m_bIsSecuringRainbow );

			if(Level.NetMode != NM_Client) 
			{
				m_pawn.SetNextPendingAction(PENDING_SecureTerrorist);
				if(m_PlayerCurrentCA.iPlayerActionID == m_pawn.eRainbowCircumstantialAction.CAR_Secure)
				{
					R6PlayerController(R6Rainbow(m_PlayerCurrentCA.aQueryTarget).Controller).DispatchOrder(m_PlayerCurrentCA.iPlayerActionID, m_pawn);
				}
			}
		}
	}

	event Tick(FLOAT fDeltaTime)
	{
		if((m_Pawn.EngineWeapon != none) && (m_pawn.m_eEquipWeapon != m_pawn.eEquipWeapon.EQUIP_NoWeapon))
			return;

		if(!m_pawn.m_bPostureTransition)
			return;

        if (Role == ROLE_Authority)
			m_iPlayerCAProgress = m_PlayerCurrentCA.aQueryTarget.R6GetCircumstantialActionProgress( m_playerCurrentCA, m_pawn );		
	}
}

//============================================================================
// DispatchOrder - 
//============================================================================
function DispatchOrder( INT iOrder, R6Pawn pSource )
{
    #ifdefDEBUG if(bShowLog) logX( "DispatchOrder: " $ iOrder @ pSource.Name ); #endif

    switch( iOrder )
    {
        case m_pawn.eRainbowCircumstantialAction.CAR_Secure:
            SecureRainbow( pSource );
            break;
        case m_pawn.eRainbowCircumstantialAction.CAR_Free:
            FreeRainbow( pSource );
            break;

        default:
            assert( false ); // unknow eRainbowCircumstantialAction
    }
}

function SecureRainbow( R6Pawn pOther )
{ 
    // pOther = the capturer, self = the arrested
/* MPF_7_15_2003 deprecated
	local string myName;
	local string arrestorName;
*/
    #ifdefDEBUG if(bShowLog) logX( "SecureRainbow("$pOther$")" ); #endif
	
	m_pawn.m_bIsBeingArrestedOrFreed = true;
	m_pInteractingRainbow = pOther;

}


function FreeRainbow( R6Pawn pOther )
{ 
    // pOther = the Rescuer, self = the arrested
    #ifdefDEBUG if(bShowLog) logX( "FreeRainbow("$pOther$")" ); #endif
	m_pInteractingRainbow = pOther;

	m_pawn.SetFree();
}


///////////////////////////////////////////////////////////////////////////////////////
//                     -- state PlayerStartArrest --               
///////////////////////////////////////////////////////////////////////////////////////

state PlayerStartArrest extends CameraPlayer
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE");  #endif
        #ifdefDEBUG if(bShowLog) logX("R6PlayerController::BeginState() [PlayerStartArrest] " $ self); #endif

		if(m_bSkipBeginState)
		{
			m_bSkipBeginState = false;
			return;
		}

        // R6AbstractGameInfo(Level.Game).PawnSecure( m_pawn );
		if(Level.NetMode != NM_Client)
			m_pawn.SetNextPendingAction( PENDING_Arrest );
		//m_pawn.PlayArrest(); // MPF_Milan_7_1_2003 commented

    }
    
	function EndState()
    {
       #ifdefDEBUG if (bShowLog) logX ( "Exit STATE"); #endif

		m_pawn.m_bIsBeingArrestedOrFreed = false;
        m_pawn.m_bPawnSpecificAnimInProgress = false; // MPF_Milan2
	}

	function PlayFiring() {}
    function AltFiring()  {}
    function ServerReStartPlayer() {}
    exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire( optional float F ) {}
	// no chit chat while surrended/arrested
	exec function Say( string Msg ) {}
	exec function TeamSay( string Msg ) {}

	function SwitchWeapon (BYTE F )
	{
		// do nothing, prevent player from trying to switch to another weapon
	}

	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
	event AnimEnd(int iChannel)
    {
		local name anim;
		local float fFrame;
		local float fRate;
		#ifdefDEBUG if(bShowLog) log(" **********ANIMEND: PlayerStartArrest() channel="$iChannel$" anim="$anim);	#endif

		if(iChannel == m_pawn.C_iPawnSpecificChannel) 
		{
		    pawn.GetAnimParams(m_pawn.C_iPawnSpecificChannel, anim, fFrame, fRate);	
		    if(anim=='SurrenderToKneel')
		    { // Arrest anim done, play ArrestKneel
                if(Level.NetMode != NM_Client)
                    m_pawn.SetNextPendingAction( PENDING_ArrestKneel );
			}
        else
            GotoState('PlayerArrested');
        }
	}

	// MPF_Milan_7_1_2003 - override forbidden functions
	exec function PreviousMember(){	}
	exec function NextMember(){	}
	simulated function ChangeTeams(bool bNextTeam) {}
	function ServerChangeTeams(bool bNextTeam){	}
	function ValidateCameraTeamId()	{}
	function SpectatorChangeTeams(bool bNextTeam){	}
	event ClientSetNewViewTarget(){	}
	simulated function SetNewViewTarget(actor aViewTarget)	{}	
	// End MPF_Milan_7_1_2003 
}

///////////////////////////////////////////////////////////////////////////////////////
//                     -- state PlayerArrested --               
///////////////////////////////////////////////////////////////////////////////////////

state PlayerArrested extends CameraPlayer
{
    function BeginState()
    {
		local string myName;
		local string arrestorName;

        #ifdefDEBUG if(bShowLog) logX ( "Enter STATE"); #endif
        #ifdefDEBUG if(bShowLog) logX("R6PlayerController::BeginState() [PlayerArrested] " $ self); #endif

		if(m_bSkipBeginState)
		{
			m_bSkipBeginState = false;
			return;
		}

	    if(m_pawn.PlayerReplicationInfo != none)
	        myName = m_pawn.PlayerReplicationInfo.PlayerName;
	    else
			myName = m_pawn.m_CharacterName; // Was copied in UnPossessed()

		if(m_pInteractingRainbow != none)
		{
			if(m_pInteractingRainbow.PlayerReplicationInfo != none)
		        arrestorName = m_pInteractingRainbow.PlayerReplicationInfo.PlayerName;
			else
				arrestorName = m_pInteractingRainbow.m_CharacterName; // Was copied in UnPossessed()

            #ifdefDEBUG if(bshowlog) logX("DeathTextMessage: arrestorName="$arrestorName$" myName="$myName$" message="$Localize("MPMiscMessages", "PlayerArrestedPlayer", "ASGameMode"));  #endif
			myHUD.AddDeathTextMessage(arrestorName$" "$ Localize("MPMiscMessages", "PlayerArrestedPlayer", "ASGameMode")$" "$myName, class'LocalMessage');
		}

		//MPF_Milan - commented m_pawn.PlayArrestWaiting();

		// MPF_Milan_7_1_2003
		if(Level.NetMode != NM_Client)			
			m_pawn.SetNextPendingAction(PENDING_ArrestWaiting);
		// End MPF_Milan_7_1_2003

    }
    
	function EndState()
    {
	    //MPF_Milan_7_1_2003 	m_Pawn.m_bArrestWait = false;
		m_pawn.m_bPawnSpecificAnimInProgress = false; // MPF_Milan2

		#ifdefDEBUG if (bShowLog) logX ( "Exit STATE"); #endif
	}

	function PlayFiring() {}
    function AltFiring()  {}
    function ServerReStartPlayer() {}
    exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire( optional float F ) {}
	// no chit chat while surrended/arrested
	exec function Say( string Msg ) {}
	exec function TeamSay( string Msg ) {}
	function SwitchWeapon (BYTE F )
	{
		// do nothing, prevent player from trying to switch to another weapon
	}

	event AnimEnd(int iChannel)
    {
		#ifdefDEBUG if(bShowLog) log(" **********ANIMEND: PlayerArrested");	#endif

		// MPF_Milan - executed at the end of PENDING_ArrestKneel
		//MPF_Milan_7_1_2003 		m_Pawn.m_bArrestWait = true;
		if(iChannel == m_pawn.C_iPawnSpecificChannel) //MPF_Milan_7_1_2003 added if() test
		{
			if(Level.NetMode != NM_Client)
				m_pawn.SetNextPendingAction(PENDING_ArrestWaiting);
			//m_pawn.PlayArrestWaiting();
			m_pawn.SetCollision(true, false, false);
		}
		// End MPF_Milan 
        //MPF_Milan_7_1_2003 commented	m_Pawn.AnimEnd(iChannel);
	}

	// MPF_Milan_7_1_2003 - override forbidden functions
	exec function PreviousMember(){	}
	exec function NextMember(){	}
	simulated function ChangeTeams(bool bNextTeam) {}
	function ServerChangeTeams(bool bNextTeam){	}
	function ValidateCameraTeamId()	{}
	function SpectatorChangeTeams(bool bNextTeam){	}
	event ClientSetNewViewTarget(){	}
	simulated function SetNewViewTarget(actor aViewTarget)	{}	
	// End MPF_Milan_7_1_2003 
}

state PlayerSetFree  extends CameraPlayer
{
    function BeginState()
    {
		local string myName;
		local string rescuerName;
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif


		//m_pawn.m_eHealth=HEALTH_Healthy;

		if(Pawn.IsLocallyControlled() && m_eCameraMode==CAMERA_3rdPersonFree)			
		{
			m_eCameraMode = CAMERA_FirstPerson;

			if(!CameraIsAvailable())
				SelectCameraMode(true);
			SetCameraMode();
		}

		if(m_bSkipBeginState)
		{
			m_bSkipBeginState = false;
			return;
		}
	
		m_pawn.m_bIsUnderArrest = false;
		m_pawn.m_bIsSurrended = false;
		//MPF_Milan_7_1_2003 m_pawn.m_bSurrenderWait = false;
		m_fStartSurrenderTime = Level.TimeSeconds;
		m_pawn.bInvulnerableBody = true;

		if ( Level.NetMode != NM_Client )
			R6AbstractGameInfo(Level.Game).PawnSecure( m_pawn) ;

		if(Level.NetMode != NM_Client)
			m_pawn.SetNextPendingAction( PENDING_EndArrest ); // MPF_Milan_7_1_2003 was PENDING_SetFree
		//m_pawn.PlaySetFree(); MPF_Milan_7_1_2003 commented
		m_pawn.SetCollision(true, true, true);

	    if(m_pawn.PlayerReplicationInfo != none)
	        myName = m_pawn.PlayerReplicationInfo.PlayerName;
	    else
			myName = m_pawn.m_CharacterName; // Was copied in UnPossessed()
		if(m_pInteractingRainbow != none)
		{
			if(m_pInteractingRainbow.PlayerReplicationInfo != none)
		        rescuerName = m_pInteractingRainbow.PlayerReplicationInfo.PlayerName;
			else
				rescuerName = m_pInteractingRainbow.m_CharacterName; // Was copied in UnPossessed()

			myHUD.AddDeathTextMessage(myName$" "$ Localize("MPMiscMessages", "PlayerRescued", "ASGameMode")$" "$rescuerName, class'LocalMessage');
		}



    }
    
	function PlayFiring() {}
    function AltFiring()  {}
    function ServerReStartPlayer() {}
	// no chit chat while surrended/arrested
	exec function Say( string Msg ) {}
	exec function TeamSay( string Msg ) {}
    exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire( optional float F ) {}

	function EndState()
	{
		#ifdefDEBUG if(bShowLog) log(pawn$" has exited state PlayerSetFree : pawn.physics="$pawn.physics);	#endif 
        
		if(m_Pawn.EngineWeapon != none && !((Pawn.EngineWeapon.IsA('R6GrenadeWeapon') || Pawn.EngineWeapon.IsA('R6HBSSAJammerGadget')) && !Pawn.EngineWeapon.HasAmmo())) // MPF_Milan - treat S.A. Jammer as a grenade
		{
			#ifdefDEBUG if(bShowLog) log("PlayersetFree:BringWeaponUp");	#endif
			// MPF_Milan_7_1_2003 
			if(Pawn.EngineWeapon.IsA('R6GrenadeWeapon') || Pawn.EngineWeapon.IsA('R6HBSSAJammerGadget')) 
				WeaponUpState();
			// End MPF_Milan_7_1_2003

			if(Level.NetMode != NM_Client)
				Pawn.EngineWeapon.GotoState('BringWeaponUp');

            if(Level.NetMode != NM_Client)
			    m_pawn.SetNextPendingAction(PENDING_EquipWeapon); 
            // m_pawn.RainbowEquipWeapon();
		}

		m_fStartSurrenderTime = Level.TimeSeconds; // MPF_Milan_7_1_2003 - moved outside of the above test
		m_pawn.m_bPawnSpecificAnimInProgress = false; // MPF_Milan2
		m_pawn.m_bIsBeingArrestedOrFreed = false; // MPF_Milan - bug fix
        m_pawn.m_bPostureTransition = false; // MPF_Milan_7_1_2003

	}

	// MPF_Milan_7_1_2003 - AnimEnd rewritten , added second animation
	event AnimEnd(int iChannel)
    {
		local name anim;
		local float fFrame;
		local float fRate;
		#ifdefDEBUG if(bShowLog) log(" **********ANIMEND: PlayerSetFree() channel="$iChannel$" m_pawn.C_iBaseBlendAnimChannel="$m_pawn.C_iBaseBlendAnimChannel);	#endif

		if(iChannel == m_pawn.C_iPawnSpecificChannel) 
		{
			pawn.GetAnimParams(m_pawn.C_iPawnSpecificChannel, anim, fFrame, fRate);	
			if(anim=='KneelArrest')
			{ // EndArrest anim done, play SetFree
				if(Level.NetMode != NM_Client)
					m_pawn.SetNextPendingAction( PENDING_SetFree );
			}
			else
			{
				if(Level.NetMode != NM_Client) 
					m_pawn.SetNextPendingAction(PENDING_PostEndSurrender);  // same as EndSurrended
			    GotoState('PlayerWalking');
	        }
        }	
    }	



	function SwitchWeapon (BYTE F )
	{
		// do nothing, prevent player from trying to switch to another weapon
	}
	// MPF_Milan_7_1_2003 - removed override of PlayerMove
	// MPF_Milan_7_1_2003 - override forbidden functions
	exec function PreviousMember(){	}
	exec function NextMember(){	}
	simulated function ChangeTeams(bool bNextTeam) {}
	function ServerChangeTeams(bool bNextTeam){	}
	function ValidateCameraTeamId()	{}
	function SpectatorChangeTeams(bool bNextTeam){	}
	event ClientSetNewViewTarget(){	}
	simulated function SetNewViewTarget(actor aViewTarget)	{}	
	// End MPF_Milan_7_1_2003 
Begin:
    #ifdefDEBUG if (bShowLog) logX ( "Enter SetFree"); #endif
}


///-------------------End MissionPack1


simulated function R6PlayerMove(float DeltaTime)
{
	local vector X,Y,Z, NewAccel;
	local eDoubleClickDir DoubleClickMove;
	local rotator OldRotation, ViewRotation;
	local float Speed2D;
	local bool	bSaveJump;

	if(pawn != none)
		GetAxes(Pawn.Rotation,X,Y,Z);

	// Update acceleration.
	NewAccel = aForward*X + aStrafe*Y; 
	NewAccel.Z = 0;
    DoubleClickMove = getPlayerInput().CheckForDoubleClickMove(DeltaTime);
	
	GroundPitch = 0;	
	if(pawn != none)
	{
		ViewRotation = pawn.rotation;  

		// Update rotation.		
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);
	}
	
	if ( Role < ROLE_Authority ) // then save this move and replicate it
		ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
	else
		ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
}


///////////////////////////////////////////////////////////////////////////////////////
//                     -- state PLAYERACTIONPROGRESS --               
///////////////////////////////////////////////////////////////////////////////////////
//function ServerPlayerActionProgress(R6CircumstantialActionQuery newActionQuery)
function ServerPlayerActionProgress()
{	
    m_PlayerCurrentCA = m_RequestedCircumstantialAction;
	if(m_PlayerCurrentCA.aQueryTarget.IsA('R6Terrorist'))
		GotoState('PlayerSecureTerrorist');
//---MissionPack1 // MPF1
	else if( class'Actor'.static.GetModMgr().IsMissionPack() &&
             m_PlayerCurrentCA.aQueryTarget.IsA('R6Rainbow'))
	{
		if(bShowLog) log("Log "$self$"  I'm going to secure rainbow : "$m_PlayerCurrentCA.aQueryTarget);
		GotoState('PlayerSecureRainbow');
	}
//---------------
	else
		GotoState('PlayerActionProgress');
}

function ClientActionProgressDone()
{
    m_InteractionCA.ActionProgressDone();
}

function ServerActionProgressStop()
{
	m_RequestedCircumstantialAction.aQueryTarget.R6CircumstantialActionCancel();
    m_iPlayerCAProgress = 0;
    // MPF1
    if( class'Actor'.static.GetModMgr().IsMissionPack() )
    {
       if(m_pawn.IsAlive() /*MissionPack1*/ && !m_pawn.m_bIsSurrended)
          GotoState('PlayerWalking');               
    }
    else
    {
       if(m_pawn.IsAlive())
          GotoState('PlayerWalking');               
    }

    if(m_InteractionCA != none)
		m_InteractionCA.ActionProgressStop();
}

state PlayerActionProgress extends PlayerWalking
{
    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) log(pawn$" has entered state PlayerActionProgress...");	#endif
		m_bHideReticule = true;
		m_bDisplayActionProgress = true;
        if ((Level.NetMode != NM_Standalone) && (Role==ROLE_Authority) && m_playerCurrentCA.aQueryTarget.IsA('R6IOBomb'))
        {
            if (!R6IOObject(m_playerCurrentCA.aQueryTarget).m_bIsActivated)
                m_TeamManager.m_MultiCommonVoicesMgr.PlayMultiCommonVoices(m_pawn, MCV_ActivatingBomb);
            else
                m_TeamManager.m_MultiCommonVoicesMgr.PlayMultiCommonVoices(m_pawn, MCV_DeactivatingBomb);
        }

		if(m_Pawn.EngineWeapon != none)
		{
			ToggleHelmetCameraZoom(TRUE);
			m_Pawn.EngineWeapon.GotoState('PutWeaponDown');
			if(Level.NetMode != NM_Client)
				m_pawn.SetNextPendingAction(PENDING_SecureWeapon);
		}
		else
			StartProgressAction();

		pawn.acceleration = vect(0,0,0);
    }
    
	function LongClientAdjustPosition
	(
		float TimeStamp, 
		name newState, 
		EPhysics newPhysics,
		float NewLocX, 
		float NewLocY, 
		float NewLocZ, 
		float NewVelX, 
		float NewVelY, 
		float NewVelZ,
		Actor NewBase,
		float NewFloorX,
		float NewFloorY,
		float NewFloorZ
	)
	{
		Super.LongClientAdjustPosition(TimeStamp, 'PlayerActionProgress', newPhysics, NewLocX, NewLocY, NewLocZ, NewVelX, NewVelY, NewVelZ, NewBase, NewFloorX, NewFloorY, NewFloorZ);
	}

    function PlayerMove( float fDeltaTime )
	{	
		aForward = 0.f;
		aStrafe = 0.f;
		aMouseX = 0.f;
		aMouseY = 0.f; 
		aTurn = 0.f;
		global.PlayerMove(fDeltaTime);		
	}

	function StartProgressAction()
	{
		// start progress here instead... after securing weapon...
	    m_PlayerCurrentCA.aQueryTarget.R6CircumstantialActionProgressStart(m_PlayerCurrentCA);
		if(m_RequestedCircumstantialAction.aQueryTarget.IsA('R6IOObject'))
		{				
			m_pawn.m_bInteractingWithDevice = true;
			m_pawn.m_eDeviceAnim = R6IOObject(m_RequestedCircumstantialAction.aQueryTarget).m_eAnimToPlay;	
			if(Level.NetMode != NM_Client)
				m_pawn.SetNextPendingAction(PENDING_InteractWithDevice);
		}	
		else if(m_RequestedCircumstantialAction.aQueryTarget.IsA('R6IORotatingDoor'))
		{
			m_pawn.m_bIsLockPicking = true;
			if(Level.NetMode != NM_Client)
				m_pawn.SetNextPendingAction(PENDING_LockPickDoor);
		}
	}

    event AnimEnd(int iChannel)
    {
		// wait for weapon to be secured before starting the action
		if ((iChannel == m_pawn.C_iWeaponRightAnimChannel) && (m_pawn.m_eEquipWeapon == m_pawn.eEquipWeapon.EQUIP_NoWeapon)) 
		{
			m_pawn.m_bWeaponTransition = false;	
			StartProgressAction();			
		}
	}

	function EndState()
	{
		#ifdefDEBUG if(bShowLog) log(pawn$" will exit state PlayerActionProgress...");	#endif
		m_bDisplayActionProgress = false;
        if(m_pawn != none)
		{
			m_pawn.m_bPostureTransition = false;
			m_pawn.m_bIsLockPicking = false;
			m_pawn.m_bInteractingWithDevice = false;	

            // bring weapon up
			m_pawn.m_ePlayerIsUsingHands = HANDS_None;			
			if(m_Pawn.EngineWeapon != none && !m_pawn.m_bIsSurrended) // for S.A. Jammer, avoid bringing it up again if surrending while installing it, MPF_MilanX
			{
				m_Pawn.EngineWeapon.GotoState('BringWeaponUp');
                if(Level.NetMode != NM_Client)
                    m_pawn.SetNextPendingAction(PENDING_EquipWeapon); 
			}

            if (Role == ROLE_Authority && !m_pawn.IsAlive() && m_iPlayerCAProgress < 105)
            {
            	m_RequestedCircumstantialAction.aQueryTarget.R6CircumstantialActionCancel();
            }
		}
		m_iPlayerCAProgress = 0;
	}

    event Tick(FLOAT fDeltaTime)
    {
		if((m_Pawn.EngineWeapon != none) && (m_pawn.m_eEquipWeapon != m_pawn.eEquipWeapon.EQUIP_NoWeapon))
			return;

		if(!m_pawn.m_bIsLockPicking && !m_pawn.m_bInteractingWithDevice)
			return;

        if (Role == ROLE_Authority)
        {
            // If the action is done
            if ( m_PlayerCurrentCA == none )
			    m_iPlayerCAProgress = 0; 
            else if ( m_PlayerCurrentCA.aQueryTarget == none ) // on a reset...
                m_iPlayerCAProgress = 0; 
            else
                m_iPlayerCAProgress = m_PlayerCurrentCA.aQueryTarget.R6GetCircumstantialActionProgress( m_playerCurrentCA, m_pawn );		
                

            if( m_iPlayerCAProgress >= 105 )
            {
                m_iPlayerCAProgress = 0;
				// we want ClientActionProgressDone() to be called only if we are a dedicated server, otherwise, it will be called on ourself
                if(Level.NetMode != NM_Standalone && Level.NetMode != NM_Client)
					ClientActionProgressDone();

				if(m_InteractionCA != none)
					m_InteractionCA.ActionProgressDone();    

				GotoState('PlayerWalking');
            }
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////
//                     -- state PLAYERSECURETERRORIST --               
///////////////////////////////////////////////////////////////////////////////////////
state PlayerSecureTerrorist extends PlayerWalking
{
	function BeginState()
	{
		#ifdefDEBUG if(bShowLog) log(pawn$" has entered state PlayerSecureTerrorist ... m_PlayerCurrentCA="$m_PlayerCurrentCA);		#endif
		m_bHideReticule = true;
		m_bDisplayActionProgress = true;
		if(m_Pawn.EngineWeapon != none)
		{
			ToggleHelmetCameraZoom(TRUE);
			Pawn.EngineWeapon.GotoState('PutWeaponDown');
			if(Level.NetMode != NM_Client)			
				m_pawn.SetNextPendingAction(PENDING_SecureWeapon);
			//m_pawn.RainbowSecureWeapon(); MPF_Milan_7_1_2003
		}
		SetPeekingInfo( PEEK_none, m_pawn.C_fPeekMiddleMax );
		ResetFluidPeeking();
	}

	function EndState()
	{
		#ifdefDEBUG if(bShowLog) log(pawn$" has exited state PlayerSecureTerrorist ");	#endif
		m_bDisplayActionProgress = false;
		// if action was not completed, reset terrorist to surrendered state...
		if(m_iPlayerCAProgress < 100)
		{		
			m_pawn.R6ResetAnimBlendParams(m_pawn.C_iBaseBlendAnimChannel);	
			if (Role == ROLE_Authority)
				R6Terrorist(m_PlayerCurrentCA.aQueryTarget).ResetArrest();
		}		
		m_pawn.m_bPostureTransition = false;		
		m_iPlayerCAProgress = 0;
		m_pawn.m_ePlayerIsUsingHands = HANDS_None;
		if(m_Pawn.EngineWeapon != none)
		{
			Pawn.EngineWeapon.GotoState('BringWeaponUp');
			if(Level.NetMode != NM_Client)
				m_pawn.SetNextPendingAction(PENDING_EquipWeapon);
			//m_pawn.RainbowEquipWeapon(); MPF_Milan_7_1_2003 commented
		}	
	}

	function PlayerMove( float fDeltaTime )
	{	
		aForward = 0.f;
		aStrafe = 0.f;
		aMouseX = 0.f;
		aMouseY = 0.f;
		aTurn = 0.f;

		m_bPeekLeft = 0;
		m_bPeekRight = 0;

		global.PlayerMove(fDeltaTime);		
	}

	function LongClientAdjustPosition
	(
		float TimeStamp, 
		name newState, 
		EPhysics newPhysics,
		float NewLocX, 
		float NewLocY, 
		float NewLocZ, 
		float NewVelX, 
		float NewVelY, 
		float NewVelZ,
		Actor NewBase,
		float NewFloorX,
		float NewFloorY,
		float NewFloorZ
	)
	{
		Super.LongClientAdjustPosition(TimeStamp, 'PlayerSecureTerrorist', newPhysics, NewLocX, NewLocY, NewLocZ, NewVelX, NewVelY, NewVelZ, NewBase, NewFloorX, NewFloorY, NewFloorZ);
	}

	event AnimEnd(int iChannel)
    {
		if(iChannel == m_pawn.C_iBaseBlendAnimChannel && m_pawn.m_bPostureTransition)
		{
			m_pawn.m_bPostureTransition = false;
			m_pawn.AnimBlendToAlpha(m_pawn.C_iBaseBlendAnimChannel, 0.0, 0.5);
			m_iPlayerCAProgress = 100;
			// we want ClientActionProgressDone() to be called only if we are a dedicated server, otherwise, it will be called on ourself
            if(Level.NetMode == NM_DedicatedServer)
                ClientActionProgressDone();

			if(m_InteractionCA != none)
				m_InteractionCA.ActionProgressDone();
            GotoState('PlayerWalking');	
		}
		else if ((iChannel == m_pawn.C_iWeaponRightAnimChannel) && (m_pawn.m_eEquipWeapon == m_pawn.eEquipWeapon.EQUIP_NoWeapon)) 
		{
			m_pawn.m_bWeaponTransition = false;	
			m_pawn.m_bPostureTransition = false;
			m_pawn.PlaySecureTerrorist();	
			m_PlayerCurrentCA.aQueryTarget.R6CircumstantialActionProgressStart(m_PlayerCurrentCA);
			if(Level.NetMode != NM_Client) 
			{
				m_pawn.SetNextPendingAction(PENDING_SecureTerrorist);
				R6Terrorist(m_PlayerCurrentCA.aQueryTarget).m_controller.DispatchOrder(m_PlayerCurrentCA.iPlayerActionID, m_pawn);
			}
		}
	}

	event Tick(FLOAT fDeltaTime)
	{
		if((m_Pawn.EngineWeapon != none) && (m_pawn.m_eEquipWeapon != m_pawn.eEquipWeapon.EQUIP_NoWeapon))
			return;

		if(!m_pawn.m_bPostureTransition)
			return;

        if (Role == ROLE_Authority)
			m_iPlayerCAProgress = m_PlayerCurrentCA.aQueryTarget.R6GetCircumstantialActionProgress( m_playerCurrentCA, m_pawn );		
	}
}

///////////////////////////////////////////////////////////////////////////////////////
//                     -- state SETEXPLOSIVE --               
///////////////////////////////////////////////////////////////////////////////////////
state PlayerSetExplosive extends PlayerWalking
{
	function PlayerMove( float fDeltaTime )
	{	
		aForward = 0.f;
		aStrafe = 0.f;
		aMouseX = 0.f;
		aMouseY = 0.f;
		aTurn = 0.f;
		global.PlayerMove(fDeltaTime);		
	}

	function BeginState()
	{
		#ifdefDEBUG if(bShowLog) log(pawn$" Entering state PlayerSetExplosive... ");	#endif
		pawn.acceleration = vect(0,0,0);
		m_iPlayerCAProgress = 0;
        m_bPlacedExplosive = false;
	}

	function EndState()
	{
		#ifdefDEBUG if(bShowLog) log(pawn$" Exiting state PlayerSetExplosive... ");		#endif
		m_iPlayerCAProgress = 0;
		m_pawn.m_bPostureTransition = false;
	}

	event AnimEnd(int iChannel)
    {
		if(iChannel == m_pawn.C_iBaseBlendAnimChannel)
		{
			if(m_pawn.IsAlive())
                GotoState('PlayerWalking');
        }
	}

	function INT GetActionProgress()
	{
		local name  anim;
		local FLOAT fFrame,fRate;
		
		pawn.GetAnimParams(m_pawn.C_iBaseBlendAnimChannel, anim, fFrame, fRate);	
		Clamp(fFrame, 0.f, 100.f);

		return fFrame*110;
	}

	event Tick(FLOAT fDeltaTime)
	{		
		m_iPlayerCAProgress = GetActionProgress();
        if(m_iPlayerCAProgress > 75)
            m_bPlacedExplosive = true;
	}
}

///////////////////////////////////////////////////////////////////////////////////////
//                     -- state PREBEGINCLIMBINGLADDER --               
///////////////////////////////////////////////////////////////////////////////////////
state PreBeginClimbingLadder
{
	function BeginState()
	{
		#ifdefDEBUG if(bShowLog) log(pawn$" has entered state PreBeginClimbingLadder ...pawn.physics="$pawn.physics$" Pawn.EngineWeapon="$Pawn.EngineWeapon);	#endif
		ToggleHelmetCameraZoom(TRUE);

		// make sure player is standing and not peeking
		RaisePosture();
		SetPeekingInfo( PEEK_none, m_pawn.C_fPeekMiddleMax );
		ResetFluidPeeking();

		// make sure engineweapon is valid, and that player is not equipped with a grenade weapon that has no grenades left
		if(Pawn.EngineWeapon != none && !(Pawn.EngineWeapon.IsA('R6GrenadeWeapon') && !Pawn.EngineWeapon.HasAmmo()) )
		{
			DoZoom(TRUE);
			Pawn.EngineWeapon.GotoState('PutWeaponDown');
			if(Level.NetMode != NM_Client)			
				m_pawn.SetNextPendingAction(PENDING_SecureWeapon);
			m_pawn.RainbowSecureWeapon();
		}
		else
		{
			m_bSkipBeginState = false;
			GotoState('PlayerBeginClimbingLadder');
			if(Level.NetMode == NM_Client)
				ServerStartClimbingLadder();
		}

		if(Level.NetMode != NM_Client)
		{
			if(m_pawn.m_Ladder == none || m_pawn.onLadder == none)
				ExtractMissingLadderInformation();
			R6LadderVolume(m_pawn.onLadder).EnableCollisions(m_pawn.m_Ladder);
		}
	}

	function EndState()
	{
		#ifdefDEBUG if(bShowLog) log(pawn$" has exited state PreBeginClimbingLadder ... ");		#endif
		m_pawn.m_bWeaponTransition = false;
	}

    function PlayFiring() {}
    function AltFiring()  {}
    function ServerReStartPlayer() {}
    exec function ToggleHelmetCameraZoom(optional BOOL bTurnOff){}
    exec function Fire( optional float F ) {}

	event AnimEnd(int iChannel)
    {
		if(Level.NetMode != NM_DedicatedServer && (iChannel == m_pawn.C_iWeaponRightAnimChannel))
		{			
			m_bSkipBeginState = false;
			GotoState('PlayerBeginClimbingLadder');
			if(Level.NetMode == NM_Client)
				ServerStartClimbingLadder();
		}
		else
			m_pawn.AnimEnd(iChannel);
	}

	function SwitchWeapon (BYTE F )
	{
		// do nothing, prevent player from trying to switch to another weapon
	}

	function PlayerMove( float DeltaTime )
	{	
		pawn.acceleration = vect(0,0,0);
		aForward = 0.f;
		aStrafe = 0.f;	
		aTurn = 0.f;

		bRun = 0;
		m_bPeekLeft = 0;
		m_bPeekRight = 0;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
	}
}

function ServerStartClimbingLadder()
{
	#ifdefDEBUG if(bShowLog) log(pawn$" : ServerStartClimbingLadder() was called...pawn.physics="$pawn.physics$" GetStateName="$GetStateName());	#endif
	m_bSkipBeginState = false;
	GotoState('PlayerBeginClimbingLadder');
}

function ExtractMissingLadderInformation()
{
	if((m_pawn.m_Ladder == none) && (pawn.onLadder != none))
	{
		m_pawn.m_Ladder = R6Ladder(m_pawn.LocateLadderActor(pawn.onLadder));
		#ifdefDEBUG if(bShowLog) log(" **** ExtractMissingLadderInformation() : m_pawn.m_Ladder="$m_pawn.m_Ladder);		#endif
		return;
	}

	if((pawn.onLadder == none) && (m_pawn.m_Ladder != none))
	{
		pawn.onLadder = m_pawn.m_Ladder.myLadder;
		#ifdefDEBUG if(bShowLog) log(" **** ExtractMissingLadderInformation() : pawn.onLadder="$pawn.onLadder);		#endif
	}
}

///////////////////////////////////////////////////////////////////////////////////////
//						  --  state PLAYERBEGINCLIMBINGLADDER  -- 
//  rbrek - 12 dec 2001 
//  playercontroller state for beginning to climb a ladder.
//  animations use root motion physics (PHYS_RootMotion)
///////////////////////////////////////////////////////////////////////////////////////
state PlayerBeginClimbingLadder
{
	function BeginState()
	{		
		#ifdefDEBUG if(bShowLog) log(pawn$" has entered state PlayerBeginClimbingLadder - pawn.physics="$pawn.physics$" pawn.onLadder="$pawn.onLadder$" m_pawn.m_Ladder="$m_pawn.m_Ladder);		#endif

		if(m_pawn.m_Ladder == none || m_pawn.onLadder == none)
			ExtractMissingLadderInformation();
		
		// orient pawn directly toward ladder...
		if(m_pawn.m_Ladder.m_bIsTopOfLadder)
			pawn.SetRotation(pawn.onLadder.LadderList.Rotation + rot(0,32768,0));
		else
			pawn.SetRotation(pawn.onLadder.LadderList.Rotation );

		if(m_bSkipBeginState)
		{
			m_bSkipBeginState = false;			
			return;
		}

		// inform team that player/leader is climbing a ladder
		if(m_TeamManager != none)
			m_TeamManager.TeamLeaderIsClimbingLadder();  

		m_bHideReticule = true;
		m_pawn.m_bIsClimbingLadder = true;

		// looks like physics must be set on server as well, server will communicate physics back to client...
		pawn.LockRootMotion(1, true);		
		if(Level.NetMode != NM_Client)	
			m_pawn.SetNextPendingAction(PENDING_StartClimbingLadder);  
		m_pawn.PlayStartClimbing();

		// orient pawn directly toward ladder...
		if(m_pawn.m_Ladder.m_bIsTopOfLadder)
			pawn.SetRotation(pawn.onLadder.LadderList.Rotation + rot(0,32768,0));
		else
			pawn.SetRotation(pawn.onLadder.LadderList.Rotation);		
	} 

	function EndState()
	{
		#ifdefDEBUG if(bShowLog) log(pawn$" has exited state PlayerBeginClimbingLadder : EndState() pawn.physics="$pawn.physics);	#endif

		// for multiplayer mainly - make sure that pawn rotation is correct
		if(m_pawn.onLadder != none)
		{
			if(pawn.rotation != pawn.onladder.LadderList.rotation)
				pawn.SetRotation(pawn.onLadder.LadderList.rotation);

			if(Level.NetMode != NM_Client)
				R6LadderVolume(m_pawn.onLadder).DisableCollisions(m_pawn.m_Ladder);
		}
		m_pawn.m_bPostureTransition = false;
	}

	event AnimEnd(int iChannel)
    {
        if(iChannel == 0)
        {	
			// need to shift the collision cylinder forward, because at the end of the start 
			// ladder animation, the root bone is now shifted forward...					
			if(Level.NetMode != NM_Client)	
				m_pawn.SetNextPendingAction(PENDING_PostStartClimbingLadder); 

			m_pawn.PlayPostStartLadder();
            pawn.SetRotation(pawn.onLadder.LadderList.Rotation);
            SetRotation(pawn.onLadder.LadderList.Rotation);
			
			GotoState('PlayerClimbing'); 
        }		
    }	

	function PlayerMove( float DeltaTime )
	{	
		aForward = 0.f;
		aStrafe = 0.f;
		aTurn = 0.f;
		R6PlayerMove(deltaTime);		
	}
}

//==========================================================//
//				-- state PLAYERCLIMBING --					//
//==========================================================//
state PlayerClimbing
{
ignores SeePlayer, HearNoise, Bump;

	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		return false;
	}

	function PlayerMove( float DeltaTime )
	{
		if(!m_bLockWeaponActions && m_pawn.EngineWeapon != none)
			m_pawn.EngineWeapon.GotoState('PutWeaponDown');

		if(WindowConsole(Player.Console).ConsoleState == 'UWindow')
		{
			if ( Role < ROLE_Authority ) // then save this move and replicate it
				ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
			else
				ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		}
		else
			Super.PlayerMove(DeltaTime);
	}
}

///////////////////////////////////////////////////////////////////////////////////////
//						  --  state PLAYERENDCLIMBINGLADDER  -- 
//  rbrek - 12 dec 2001 
//  playercontroller state for ending a ladder climb (also used for ending a ladder slide)
//  animations use root motion physics (PHYS_RootMotion)
///////////////////////////////////////////////////////////////////////////////////////
state PlayerEndClimbingLadder
{
	function BeginState()
	{	
		#ifdefDEBUG if(bShowLog) log(pawn$" has entered state PlayerEndClimbingLadder - BeginState() : bIsWalking="$pawn.bIsWalking$" m_pawn.m_Ladder="$m_pawn.m_Ladder$" pawn.physics="$pawn.physics);		#endif
		if(m_bSkipBeginState)
		{
			m_bSkipBeginState = false;
			return;
		}
		
		if(m_pawn.m_Ladder.m_bIsTopOfLadder || !m_pawn.EndOfLadderSlide()) 
		{
			pawn.LockRootMotion(1, true);
			if(Level.NetMode != NM_Client) 
				m_pawn.SetNextPendingAction(PENDING_EndClimbingLadder);  
			m_pawn.PlayEndClimbing();
		}
		else
		{
			if(Level.NetMode != NM_Client) 
				m_pawn.SetNextPendingAction(PENDING_EndClimbingLadder); 
			m_pawn.PlayEndClimbing();
		}
	}

	function EndState()
	{
		#ifdefDEBUG if(bShowLog) log(pawn$" has exited state PlayerEndClimbingLadder : pawn.physics="$pawn.physics);	#endif
		m_pawn.m_bSlideEnd = false;

		// safety....
		if(m_pawn.m_bIsClimbingLadder)
		{
			#ifdefDEBUG if(bShowLog) log("  SPECIAL CASE : PlayerController's state was changed prematurely... reset necessary variables ");	#endif
			EndClimbingSetUp();
		}

        if ( class'Actor'.static.GetModMgr().IsMissionPack() )
        {
		    if(/*MissionPack1*/ !m_pawn.m_bIsSurrended && /*End MissionPack1*/m_Pawn.EngineWeapon != none && !(Pawn.EngineWeapon.IsA('R6GrenadeWeapon') && !Pawn.EngineWeapon.HasAmmo()))
            {
		        Pawn.EngineWeapon.GotoState('BringWeaponUp');
                if(Level.NetMode != NM_Client)
			        m_pawn.SetNextPendingAction(PENDING_EquipWeapon); 
            }
        }
        else
        {
		   if(m_Pawn.EngineWeapon != none && !(Pawn.EngineWeapon.IsA('R6GrenadeWeapon') && !Pawn.EngineWeapon.HasAmmo()))
		   {
			    Pawn.EngineWeapon.GotoState('BringWeaponUp');
                if(Level.NetMode != NM_Client)
			        m_pawn.SetNextPendingAction(PENDING_EquipWeapon); 
		   }
        }
	}

	event AnimEnd(int iChannel)
    {
		// todo : remove check for C_iBaseBlendAnimChannel now that sliding uses channel 0
        if((iChannel == 0) || (iChannel == m_pawn.C_iBaseBlendAnimChannel))
        {	 
			if(iChannel == 0)
			{
				if(m_pawn.m_Ladder.m_bIsTopOfLadder)
				{
					if(Level.NetMode != NM_Client) 
						m_pawn.SetNextPendingAction(PENDING_PostEndClimbingLadder);  
					m_pawn.PlayPostEndLadder();
					pawn.SetLocation(pawn.location + 20*vector(pawn.rotation));    // adjustment for root bone displacement...
				}
				else if(!m_pawn.m_bSlideEnd)
				{
					if(Level.NetMode != NM_Client) 
						m_pawn.SetNextPendingAction(PENDING_PostEndClimbingLadder);  
					m_pawn.PlayPostEndLadder();
					pawn.SetLocation(pawn.location + 25*vector(pawn.rotation));	 
				} 
			}

			EndClimbingSetUp();
			GotoState('PlayerWalking');
        } 
    }	

	function EndClimbingSetUp()
	{
		pawn.SetPhysics(PHYS_Walking);
		pawn.onLadder = none;

		m_pawn.m_bIsClimbingLadder = false;
		m_pawn.m_bPostureTransition = false;

		if(m_TeamManager != none)
			m_TeamManager.MemberFinishedClimbingLadder(m_pawn);
	}

	function PlayerMove( float DeltaTime )
	{
		// so that player can't move forward/backward until they have finished getting off the ladder
		aForward = 0.f;
		aStrafe = 0.f;
		aTurn = 0.f;
		R6PlayerMove(deltaTime);
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//R6MOTIONBLUR
simulated function ResetBlur()
{
	local Canvas C;
    m_fBlurReturnTime = 0;
	C = Class'actor'.static.GetCanvas();
	if(C != none)
		C.SetMotionBlurIntensity(0);
}

// 0 is no blur, 100 is full blur
function Blur(INT iValue)
{
    if(Pawn != none)
    {
        iValue = Clamp(iValue, 0, 100);
        Pawn.m_fBlurValue = iValue * 2.35;
    }
}

//END R6MOTIONBLUR

// set the zoom level of the camera on the helmet
function HelmetCameraZoom( FLOAT fZoomLevel )
{
    // set the zoom level
    DefaultFOV = default.DesiredFOV / fZoomLevel;
    DesiredFOV = DefaultFOV;

    // camera is on if != 1
    m_bHelmetCameraOn = fZoomLevel != 1;
    
    if(Level.NetMode == NM_Client)
        ServerSetHelmetParams(fZoomLevel, m_bScopeZoom);
}

function ServerSetHelmetParams( FLOAT fZoomLevel, BOOL bScopeZoom )
{
    // if the player is dead or inactive do nothing
	if ( m_pawn != none && !m_pawn.IsAlive() )
        return;        
    m_bHelmetCameraOn = (fZoomLevel != 1);
    if(fZoomLevel > 2.0)
        m_bSniperMode = m_bHelmetCameraOn;
    m_bScopeZoom=bScopeZoom;
}

function ToggleHelmetCameraZoom(optional BOOL bTurnOff)
{
	if((bTurnOff==FALSE) && m_bLockWeaponActions)
		return;
    
    if((Pawn.EngineWeapon != none) && (Pawn.EngineWeapon.HasScope() == TRUE) && (m_bSniperMode == false) && (bTurnOff == FALSE))
    {
        Pawn.EngineWeapon.GotoState('ZoomIn');
    }
    else
    {
        DoZoom(bTurnOff);
    }       
}
    
function DoZoom(optional BOOL bTurnOff)
{
    if(Pawn==none || Pawn.EngineWeapon==none)
        return;

    if ( m_bHelmetCameraOn )
    {
        if((Pawn.EngineWeapon.IsSniperRifle() == TRUE) && (m_bScopeZoom == FALSE) && (bTurnOff == FALSE))
        {
            m_bScopeZoom=TRUE;
			Pawn.EngineWeapon.WeaponZoomSound(false);
            HelmetCameraZoom( Pawn.EngineWeapon.m_fMaxZoom );
            //Values are set here to remove the parameters of R6WeaponShake.
            m_Pawn.m_fWeaponJump = Pawn.EngineWeapon.GetWeaponJump() / 2;
            m_Pawn.m_fZoomJumpReturn = 0.2;
        }
        else
        {
            // zoom out of the camera on the rainbow's helmet
            if(Pawn.EngineWeapon.HasScope() == TRUE)
            {
                Pawn.EngineWeapon.GotoState('ZoomOut');
                m_bScopeZoom=FALSE;
            }
            m_bSniperMode = FALSE;
            m_bUseFirstPersonWeapon=TRUE;

            R6Pawn(Pawn).ToggleScopeVision();
            HelmetCameraZoom( 1.0 );    // call this after having set m_bScopeZoom.
            //Values are set here to remove the parameters of R6WeaponShake.
            m_Pawn.m_fWeaponJump = Pawn.EngineWeapon.GetWeaponJump();
            m_Pawn.m_fZoomJumpReturn = 1.0;
        }
    }
    else
    {
        if(bTurnOff == TRUE)
        {
            return;
        }

        R6Pawn(Pawn).ToggleScopeVision();

        if(Pawn.EngineWeapon.IsSniperRifle() == TRUE)
        {
            //3.5 then 10 x for Sniper Rifles
            HelmetCameraZoom( 3.5 );
            m_bUseFirstPersonWeapon=FALSE;
            m_bSniperMode = TRUE;
            //Values are set here to remove the parameters of R6WeaponShake.
            m_Pawn.m_fWeaponJump = Pawn.EngineWeapon.GetWeaponJump() / 1.5;
            m_Pawn.m_fZoomJumpReturn = 0.5;
        }
        else
        {
            if(Pawn.EngineWeapon.m_ScopeTexture != none)
            {
                m_bSniperMode = TRUE;
                m_bUseFirstPersonWeapon=FALSE;
                //Values are set here to remove the parameters of R6WeaponShake.
                m_Pawn.m_fWeaponJump = Pawn.EngineWeapon.GetWeaponJump() / 1.5;
                m_Pawn.m_fZoomJumpReturn = 0.5;
            }
            // zoom in of the camera on the rainbow's helmet
            HelmetCameraZoom( Pawn.EngineWeapon.m_fMaxZoom );
        }
    }
}

event FLOAT GetZoomMultiplyFactor(FLOAT fWeaponMaxZoom)
{
    if((Pawn != none) && Pawn.EngineWeapon.IsSniperRifle() == TRUE)
    {
        if(m_bHelmetCameraOn == TRUE)
        {
            if(m_bScopeZoom == TRUE)
            {
                return fWeaponMaxZoom * 0.5; 
            }
            else
            {
                return fWeaponMaxZoom * 0.25; 
            }
        }
    }
    else if(m_bHelmetCameraOn == TRUE)
    {
        return fWeaponMaxZoom * 0.5; 
    }
    return 1.0;
}

function ShakeView( float fWaveTime, float fRollMax, vector vImpactDirection, float fRollSpeed, vector vPositionOffset, float fReturnTime)
{
//  Member variables of the PlayerController class
//var float MaxShakeRoll;       // max magnitude to roll camera in deg
//var vector MaxShakeOffset;    // Roll direction (pitch and Roll Only)
//var float ShakeRollRate;      // Roll speed. in any direction
//var vector ShakeOffsetRate;   // Movement cuased by the Shake, if any
//var vector ShakeOffset;       // ?
//var float ShakeRollTime;      // Wave Time
//var vector ShakeOffsetTime;   // Time for the offset time
    local vector vRotationX;
    local vector vRotationY;
    local vector vRotationZ;
    local FLOAT  fCosValue;
    local FLOAT  fCosValueRoll;
    local FLOAT  fAngle;
    local INT    iPitchOrientation;
    local INT    iRollOrientation;

    if(vImpactDirection.X == 0 && vImpactDirection.Y == 0)
        return;

    //Change time for KO vision (wave movement of the camera with blur).
    ShakeRollTime = fWaveTime + m_pawn.m_fStunShakeTime;
    
    if(m_fShakeReturnTime < fReturnTime)
    {
        m_fShakeReturnTime = fReturnTime;
    }

    //Keep the highest roll value in MaxShakeRoll
    if(MaxShakeRoll < fRollMax)
    {
        MaxShakeRoll = fRollMax;
    }

    //***************************************************
    //Get the angle between the two vectors 

    //Get the character direction, in XY only
    GetAxes(rotation, vRotationX, vRotationY, vRotationZ);
    vRotationX.Z = 0;
    vRotationX = Normal(vRotationX);
    vRotationY.Z = 0;
    vRotationY = Normal(vRotationY);

    //The Z value is not used for the bullet directoin
    MaxShakeOffset = -vImpactDirection;
    MaxShakeOffset.Z = 0;
    MaxShakeOffset = Normal(MaxShakeOffset);

    //Keep the orientation of pitch and Roll
    iPitchOrientation = 1.0;
    fCosValue = MaxShakeOffset dot vRotationX;
    if(fCosValue < 0) iPitchOrientation = -1.0;
    
    iRollOrientation = 1.0;
    fCosValueRoll = MaxShakeOffset dot vRotationY;
    if(fCosValueRoll > 0) iRollOrientation = -1.0;

    MaxShakeOffset.X = fCosValue*fCosValue * iPitchOrientation;
    MaxShakeOffset.Z = (1.0-abs(MaxShakeOffset.X)) * iRollOrientation;

    // Roll speed in any direciton.  # degrees per seconds
    ShakeRollRate = fRollSpeed;

    //Movement caused by the Shake, Not used Yet!!!.
    ShakeOffsetRate = vPositionOffset;
}

function CancelShake()
{
    ShakeRollTime = 0;
    ShakeRollRate = 0;
    MaxShakeRoll = 0;
    m_fShakeReturnTime = 0;
    ShakeOffsetRate = vect(0,0,0);
    m_vNewReturnValue = vect(0,0,0);
}

function ResetPlayerVisualEffects()
{
	// turn off the zoom.
	ToggleHelmetCameraZoom(TRUE);      

	// turn off night vision if it is activated
	if(m_pawn != none && m_pawn.m_bActivateNightVision)
		m_pawn.ToggleNightVision();

	CancelShake();
	ResetBlur();
}

function R6ViewShake(float fDeltaTime, out rotator rRotationOffset)
{
    local rotator   rOriginalFiringDirection;
    local INT       iYawDifference;
    local FLOAT     fJumpByStance;
    local FLOAT     fStanceDeltaTime;

    //Change values with time here
    if(ShakeRollTime > 0)
    {
        ShakeRollTime -= fDeltaTime;
        if(ShakeRollTime < 0)
        {
            ShakeRollTime = 0;
        }
    }

    if((MaxShakeRoll != 0) &&
        abs(m_rTotalShake.Pitch) < MaxShakeRoll &&
        abs(m_rTotalShake.Yaw) < MaxShakeRoll &&
        abs(m_rTotalShake.Roll) < MaxShakeRoll)
    {
        //Keep the total pich caused by the shake
        m_rCurrentShakeRotation.Pitch = ShakeRollRate * fDeltaTime * MaxShakeOffset.X;
        m_rTotalShake.Pitch += m_rCurrentShakeRotation.Pitch;
        
        m_rCurrentShakeRotation.Yaw = ShakeRollRate * fDeltaTime * MaxShakeOffset.Y;
        m_rTotalShake.Yaw += m_rCurrentShakeRotation.Yaw;

        m_rCurrentShakeRotation.Roll = ShakeRollRate * fDeltaTime * MaxShakeOffset.Z;
        m_rTotalShake.Roll += m_rCurrentShakeRotation.Roll;

    }
    else if(ShakeRollTime != 0)
    {
        //Keep shaking beacause time is not over.

        //Change the Roll, yaw and pitch direction to a random value
        MaxShakeOffset.X = FRand();
        MaxShakeOffset.Y = FRand();
        MaxShakeOffset.Z = FRand();

        if(abs(m_rTotalShake.Pitch) >= MaxShakeRoll)
        {
            //Pitch will go on the opposite direction
            if(m_rTotalShake.pitch > 0)
            {
                m_rTotalShake.pitch = MaxShakeRoll - 1;
                MaxShakeOffset.X = -MaxShakeOffset.X;
            }
            else
            {
                m_rTotalShake.pitch = -MaxShakeRoll + 1;
            }
        }
        else
        {
            // Pitch will go in random direction 
            if(FRand() < 0.5)
            {
                MaxShakeOffset.X = -MaxShakeOffset.X;
            }
        }

        if(abs(m_rTotalShake.Yaw) >= MaxShakeRoll)
        {
            //Pitch will go on the opposite direction
            if(m_rTotalShake.Yaw > 0)
            {
                m_rTotalShake.Yaw = MaxShakeRoll - 1;
                MaxShakeOffset.Y = -MaxShakeOffset.Y;
            }
            else
            {
                m_rTotalShake.Yaw = -MaxShakeRoll + 1;
            }
        }
        else
        {
            // Pitch will go in random direction 
            if(FRand() < 0.5)
            {
                MaxShakeOffset.Y = -MaxShakeOffset.Y;
            }
        }

        if(abs(m_rTotalShake.Roll) >= MaxShakeRoll)
        {
            //Roll will go in opposite direction
            if(m_rTotalShake.Roll > 0)
            {
                m_rTotalShake.Roll = MaxShakeRoll - 1;
                MaxShakeOffset.Z = -MaxShakeOffset.Z;
            }
            else
            {
                m_rTotalShake.Roll = -MaxShakeRoll + 1;
            }
        }
        else //
        {
            //Roll will go in random direction
            if(FRand() < 0.5)
            {
                MaxShakeOffset.Z = -MaxShakeOffset.Z;
            }
        }
        //apply the new changes
        m_rCurrentShakeRotation.Pitch = ShakeRollRate * fDeltaTime * MaxShakeOffset.X;
        m_rTotalShake.pitch += m_rCurrentShakeRotation.Pitch;

        m_rCurrentShakeRotation.Yaw = ShakeRollRate * fDeltaTime * MaxShakeOffset.Y;
        m_rTotalShake.Yaw += m_rCurrentShakeRotation.Yaw;

        m_rCurrentShakeRotation.Roll = ShakeRollRate * fDeltaTime * MaxShakeOffset.Z;
        m_rTotalShake.Roll += m_rCurrentShakeRotation.Roll;
    }
    else
    {
        if(MaxShakeRoll != 0)
        {
            //Set the parameters to return to the original position using ShakeReturnTime
            MaxShakeRoll = 0;
            MaxShakeOffset.X = -m_rTotalShake.pitch / m_fShakeReturnTime;
            MaxShakeOffset.Y = -m_rTotalShake.Yaw / m_fShakeReturnTime;
            MaxShakeOffset.Z = -m_rTotalShake.Roll / m_fShakeReturnTime;
        }
        
        if(m_fShakeReturnTime <= 0)
        {
            //Shake is over or there's no shake at all.
            m_rCurrentShakeRotation.Pitch = 0;
            m_rCurrentShakeRotation.Yaw   = 0;
            m_rCurrentShakeRotation.Roll  = 0;
            
            m_rTotalShake.pitch= 0;
            m_rTotalShake.Yaw  = 0;
            m_rTotalShake.Roll = 0;
        }
        else
        {
            m_fShakeReturnTime -= fDeltaTime;
            //Here the Rotation is returning to it's original position.
            m_rCurrentShakeRotation.Pitch = fDeltaTime * MaxShakeOffset.X;
            m_rCurrentShakeRotation.Yaw = fDeltaTime * MaxShakeOffset.Y;
            m_rCurrentShakeRotation.Roll  = fDeltaTime * MaxShakeOffset.Z;
        }
    }

    //Shake from firing
    if(m_vNewReturnValue != vect(0,0,0))
    {
        //Shake caused by the last Bullet
        if(m_rLastBulletDirection != Rot(0,0,0))
        {
            fJumpByStance = -1 * m_Pawn.m_fWeaponJump * m_pawn.GetStanceJumpModifier();

            //designers tweak modifs
            fJumpByStance *= m_fDesignerJumpFactor;

            //Shake by the weapon jump, once per bullet
            m_rCurrentShakeRotation.Pitch = fJumpByStance * 50.0;
            if(m_rCurrentShakeRotation.Pitch > -250)
                m_rCurrentShakeRotation.Pitch = -250;

        //Please set the minimum right/left jump to the base accuracy of the MP5PDW and the maximum to the walk fast accuracy of the AK-74. Thanks.
            //m_rLastBulletDirection is set in R6Weapons::GetFiringDirection
            if(m_rLastBulletDirection.Yaw < 0)
            {
                m_rCurrentShakeRotation.Yaw = Clamp(m_rLastBulletDirection.Yaw, -1570, -140);
            }
            else
            {
                m_rCurrentShakeRotation.Yaw = Clamp(m_rLastBulletDirection.Yaw, 140, 1570);
            }

            //Set the Return values
            m_vNewReturnValue.X = m_rCurrentShakeRotation.Pitch;
            m_vNewReturnValue.Y = m_rCurrentShakeRotation.Yaw;

            if(abs(m_vNewReturnValue.X) > abs(m_vNewReturnValue.Y))
            {
                m_iPitchReturn = m_iReturnSpeed;
                m_iYawReturn = abs(m_vNewReturnValue.Y) * m_iReturnSpeed / abs(m_vNewReturnValue.X);
            }
            else
            {
                m_iPitchReturn = abs(m_vNewReturnValue.X * m_iReturnSpeed / m_vNewReturnValue.Y);
                m_iYawReturn = m_iReturnSpeed;
            }
           
            //Designer tweak values
            m_iPitchReturn *= m_fDesignerSpeedFactor;
            m_iYawReturn *= m_fDesignerSpeedFactor;

            if(m_vNewReturnValue.Y > 0)
                m_iYawReturn *= -1;

            //cancel the last bullet
            m_rLastBulletDirection = Rot(0,0,0);
            m_vNewReturnValue.Z = 0.0;
        }        
        else //Returning to the original position
        {
            //To simplify the code;
            fStanceDeltaTime = m_pawn.GetStanceReticuleModifier() * m_Pawn.m_fZoomJumpReturn * fDeltaTime;
            
            if(abs(m_vNewReturnValue.X) > m_iPitchReturn * fStanceDeltaTime)
            {
                m_vNewReturnValue.X += m_iPitchReturn * fStanceDeltaTime;
                m_rCurrentShakeRotation.Pitch += m_iPitchReturn * fStanceDeltaTime;

                m_vNewReturnValue.Y += m_iYawReturn * fStanceDeltaTime;
                m_rCurrentShakeRotation.Yaw += m_iYawReturn * fStanceDeltaTime;
            }
            else
            {
                m_rCurrentShakeRotation.Pitch -= m_vNewReturnValue.X;
                m_vNewReturnValue = vect(0,0,0);
            }
        }
    }

    //Change rotation Here
    rRotationOffset -= m_rCurrentShakeRotation;

    if(rRotationOffset.Pitch > 16384 && rRotationOffset.Pitch < 32000)
    {
        rRotationOffset.Pitch = 16384;
    }
}

//Force the client to set unlock weapon to false.
simulated function ClientForceUnlockWeapon()
{
    m_bLockWeaponActions = false;
}


function ResetCameraShake()
{
    m_vNewReturnValue = vect(0,0,0);
}

//R6ClientWeaponShake()
//Function called on client to shake view.
//Only R6WeaponShake() should call R6ClientWeaponShake()
private function R6ClientWeaponShake()
{
    // m_vNewReturnValue.Z is used to create a shake when firing bullets
    m_vNewReturnValue.Z = 1.0;
}

/* R6WeaponShake()
Call this function to shake the player's view when firing a weapon
*/
function R6WeaponShake()
{
	R6ClientWeaponShake();
}

simulated function R6DamageAttitudeTo(Pawn other, eKillResult eKillResultFromTable, eStunResult eStunFromTable, vector vBulletMomentum)
{
    if((eKillResultFromTable != KR_Killed) && (eKillResultFromTable != KR_Incapacitate))
    {
        //Player has been hit do the reticle knock
        if(eStunFromTable == SR_None)
        {
            if (bShowLog) log("Hit");
            m_iShakeBlurIntensity = m_stImpactHit.iBlurIntensity;
            m_fBlurReturnTime = m_stImpactHit.fReturnTime;
        }
        else if(eStunFromTable == SR_Stunned)
        {
            if (bShowLog) log("Stunned");
            m_iShakeBlurIntensity = m_stImpactStun.iBlurIntensity;
            m_fBlurReturnTime = m_stImpactStun.fReturnTime;
        }
        else if(eStunFromTable == SR_Dazed)
        {
            if (bShowLog) log("Dazed");
            m_iShakeBlurIntensity = m_stImpactDazed.iBlurIntensity;
            m_fBlurReturnTime = m_stImpactDazed.fReturnTime;
        }
        else if(eStunFromTable == SR_KnockedOut)
        {
            if (bShowLog) log("KO");
            m_iShakeBlurIntensity = m_stImpactKO.iBlurIntensity;
            m_fBlurReturnTime = m_stImpactKO.fReturnTime;
        }
        m_fTimedBlurValue = m_iShakeBlurIntensity;
    }
} 

//------------------------------------------------------------------
// NotifyLanded
//	
//------------------------------------------------------------------
event bool NotifyLanded(vector HitNormal)
{
    return false; // false: to update the client
}

// make camera fall
function PawnDied()
{
    #ifdefDEBUG if(bShowLog) log(self$"  PawnDied() ...");	#endif
    StopZoom();
    
	if(pawn != none)
	{
		if(Level.Game.m_bGameStarted)
			Pawn.EngineWeapon.StopFire(true);
		Pawn.RemoteRole = ROLE_SimulatedProxy;
		m_iTeamId = pawn.m_iTeam;

#ifdefDEBUG log("*** PawnDied PlayDeathMusic for"@ Self);	#endif

        // Play the dead music in all game mode once on two
        m_bPlayDeathMusic = !m_bPlayDeathMusic;
        if (m_bPlayDeathMusic)
        {
            ClientPlayMusic(m_sndDeathMusic);
        }
    
        Pawn.m_fRemainingGrenadeTime = 0;
        ClientFadeCommonSound(5, 0);
    }

	ClientDisableFirstPersonViewEffects();	

	if(!PlayerCanSwitchToAIBackup())
	{
		if(pawn != none)
		{
			SetLocation(Pawn.Location);
			Pawn.UnPossessed();
		}
	}

    //disable the camera movement.
    #ifdefDEBUG if(bShowLog) log(self$" PawnDied() going to state dead ");	#endif
    //if(bShowLog) LogSpecialValues();

    GotoState('Dead');
}

function bool PlayerCanSwitchToAIBackup()
{
	if(Level.NetMode == NM_Standalone)
	{
		// make sure there is at least one other Rainbow left...
		if(R6AbstractGameInfo(Level.Game).RainbowOperativesStillAlive())
			return true;
		else
			return false;
	}

	if(!R6GameReplicationInfo(GameReplicationInfo).m_bAIBkp)
		return false;

	if(m_TeamManager == none)
		return false;

	if(m_TeamManager.m_iMemberCount == 0)
		return false;

	return true;
}

simulated function ClientFadeSound(FLOAT fTime, INT iVolume, ESoundSlot eSlot)
{
    if (Viewport(Player) != none)
        FadeSound(fTime, iVolume, eSlot);
}

simulated function ClientFadeCommonSound(FLOAT fTime, INT iVolume)
{
    if (Viewport(Player) != none)
    {
        FadeSound(fTime, iVolume, SLOT_Ambient);
        FadeSound(fTime, iVolume, SLOT_Guns);
        FadeSound(fTime, iVolume, SLOT_SFX);
        FadeSound(fTime, iVolume, SLOT_GrenadeEffect);
        FadeSound(fTime, iVolume, SLOT_Talk);
        FadeSound(fTime, iVolume, SLOT_HeadSet);
        FadeSound(fTime, iVolume, SLOT_Instruction);
        FadeSound(fTime, iVolume, SLOT_StartingSound);
    }
}

function SwitchWeapon (BYTE F )
{
    local R6EngineWeapon newWeapon;

    if (bShowLog) log("IN: SwitchWeapon() to "$F @ m_bLockWeaponActions @ m_pawn.m_bWeaponTransition);

	if(m_pawn == none)
		return;

    if (!m_bLockWeaponActions &&
        !m_pawn.m_bPostureTransition &&
        (!R6GameReplicationInfo(GameReplicationInfo).m_bGameOverRep))
    {
        newWeapon = m_pawn.GetWeaponInGroup(F);
        if((newWeapon != none) && (newWeapon != Pawn.EngineWeapon))
        {
            if (!newWeapon.CanSwitchToWeapon())
				return;
            m_pawn.m_bChangingWeapon=TRUE;
			m_pawn.m_iCurrentWeapon = F;
			ToggleHelmetCameraZoom(TRUE);
            if (!(Level.NetMode == NM_Standalone) && !(Level.NetMode == NM_ListenServer))
                m_pawn.GetWeapon(R6AbstractWeapon(newWeapon));
			ServerSwitchWeapon(newWeapon, F);
            if ((bBehindView == FALSE) || (Level.NetMode != NM_Standalone ))
            {
                Pawn.EngineWeapon.GotoState('DiscardWeapon');
            }
        }
    }        
//    #ifdefDEBUG if(bshowlog) log("OUT: SwitchWeapon() to "$F); #endif
}       

simulated function ServerSwitchWeapon(R6EngineWeapon newWeapon, BYTE u8CurrentWeapon)
{
    Pawn.R6MakeNoise( SNDTYPE_Equipping );
    
    if (bShowLog) log("IN: ServerSwitchWeapon() - CurrentWeapon: " $ Pawn.EngineWeapon $ " - NewWeapon: "$newWeapon);

    m_pawn.m_bChangingWeapon=TRUE;
    m_pawn.GetWeapon(R6AbstractWeapon(newWeapon));
    m_pawn.m_ePlayerIsUsingHands = HANDS_None;
    m_pawn.PlayWeaponAnimation();
	m_pawn.m_iCurrentWeapon = u8CurrentWeapon;
    if (m_pawn.m_SoundRepInfo != none)
        m_pawn.m_SoundRepInfo.m_CurrentWeapon = u8CurrentWeapon - 1;

//    if (bShowLog) log("OUT: ServerSwitchWeapon() - CurrentWeapon: " $ Pawn.EngineWeapon $ " - NewWeapon: " $ newWeapon);
}

function WeaponUpState()
{
    if (bShowLog) log("IN: WeaponUpState() : "$Pawn.EngineWeapon$" : "$Pawn.PendingWeapon);
	if(Pawn.PendingWeapon == none)
		return;

    Pawn.PendingWeapon.m_bPawnIsWalking = Pawn.EngineWeapon.m_bPawnIsWalking;    
	Pawn.EngineWeapon = Pawn.PendingWeapon;
    if(Pawn.EngineWeapon.IsInState('RaiseWeapon'))
    {
        Pawn.EngineWeapon.BeginState();
    }
    else
    {
        Pawn.EngineWeapon.GotoState('RaiseWeapon');
    }

    if (bShowLog) log("OUT: ClientWeaponUpState()");
}

function ServerWeaponUpAnimDone()
{
	if(m_pawn == none)
		return;

    if(m_pawn.m_bUsingBipod)
    {
        m_pawn.m_ePlayerIsUsingHands = HANDS_Both;
    }
    m_pawn.m_bChangingWeapon = FALSE;
}

simulated function BOOL TeamMemberHasGrenadeType( R6AbstractWeapon.eWeaponGrenadeType grenadeType )
{
    return (m_TeamManager.FindRainbowWithGrenadeType(grenadeType, true) != None);
}

///////////////////////////////////////////////////////////////////////////////
// SetRequestedCircumstantialAction()
// rbrek 22 jan 2002 
//   Set the current object being pointed to as the requested one so that even 
//    if player immediately changes focus, the correct action is done. 
///////////////////////////////////////////////////////////////////////////////
function SetRequestedCircumstantialAction()
{
	m_RequestedCircumstantialAction = m_CurrentCircumstantialAction;
	m_vRequestedLocation = m_vDefaultLocation;
}

function bool CanIssueTeamOrder()
{
	if( (m_TeamManager == none) 
		|| (m_TeamManager.m_iMemberCount <= 1) 
		|| m_TeamManager.m_bTeamIsClimbingLadder 
		|| Level.m_bInGamePlanningActive)
		return false;

	return true;
}

///////////////////////////////////////////////////////////////////////////////
// DEFAULT CIRCUMSTANTIAL ACTIONS
// R6QueryCircumstantialAction()
///////////////////////////////////////////////////////////////////////////////
event R6QueryCircumstantialAction( FLOAT fDistance, Out R6AbstractCircumstantialActionQuery Query, PlayerController playerController )
{
    local BOOL bIsOpen;

    Query.iHasAction = 1;  

	if(bOnlySpectator)
	{
        Query.iInRange = 1;
        Query.textureIcon = Texture'R6ActionIcons.Spectator';
		Query.iPlayerActionID      = eDefaultCircumstantialAction.PCA_None;
		Query.iTeamActionID        = eDefaultCircumstantialAction.PCA_None;
        
		Query.iTeamActionIDList[0] = eDefaultCircumstantialAction.PCA_None;
		Query.iTeamActionIDList[1] = eDefaultCircumstantialAction.PCA_None;
		Query.iTeamActionIDList[2] = eDefaultCircumstantialAction.PCA_None;
		Query.iTeamActionIDList[3] = eDefaultCircumstantialAction.PCA_None;
		return;
	}
	
	if((m_TeamManager == none) || (m_TeamManager.m_iMemberCount <= 1) || m_bPreventTeamMemberUse)
    {
        Query.iHasAction = 0;
		return;
    }

	if( fDistance < m_fCircumstantialActionRange )            
    {
        Query.iInRange = 1;
        Query.textureIcon = Texture'R6ActionIcons.RegroupOnMe';
    }
    else
    {
        Query.iInRange = 0;
        Query.textureIcon = Texture'R6ActionIcons.TeamMoveTo';
    }

    Query.iPlayerActionID      = eDefaultCircumstantialAction.PCA_TeamRegroup;
    Query.iTeamActionID        = eDefaultCircumstantialAction.PCA_TeamMoveTo;
        
    Query.iTeamActionIDList[0] = eDefaultCircumstantialAction.PCA_TeamMoveTo;
    Query.iTeamActionIDList[1] = eDefaultCircumstantialAction.PCA_MoveAndGrenade;
    Query.iTeamActionIDList[2] = eDefaultCircumstantialAction.PCA_None;
    Query.iTeamActionIDList[3] = eDefaultCircumstantialAction.PCA_None;

	R6FillSubAction( Query, 0, eDefaultCircumstantialAction.PCA_None );
	R6FillGrenadeSubAction( Query, 1 );
	R6FillSubAction( Query, 2, eDefaultCircumstantialAction.PCA_None );
	R6FillSubAction( Query, 3, eDefaultCircumstantialAction.PCA_None );
}   

function R6FillGrenadeSubAction( Out R6AbstractCircumstantialActionQuery Query, INT iSubMenu )
{
    local INT i;
    local INT j;

    if (R6ActionCanBeExecuted(eDefaultCircumstantialAction.PCA_GrenadeFrag, self))
    {
        Query.iTeamSubActionsIDList[iSubMenu*4 + i] = eDefaultCircumstantialAction.PCA_GrenadeFrag;
        i++;
    }

    if (R6ActionCanBeExecuted(eDefaultCircumstantialAction.PCA_GrenadeGas, self))
    {
        Query.iTeamSubActionsIDList[iSubMenu*4 + i] = eDefaultCircumstantialAction.PCA_GrenadeGas;
        i++;
    }

    if (R6ActionCanBeExecuted(eDefaultCircumstantialAction.PCA_GrenadeFlash, self))
    {
        Query.iTeamSubActionsIDList[iSubMenu*4 + i] = eDefaultCircumstantialAction.PCA_GrenadeFlash;
        i++;
    }

    if (R6ActionCanBeExecuted(eDefaultCircumstantialAction.PCA_GrenadeSmoke, self))
    {
        Query.iTeamSubActionsIDList[iSubMenu*4 + i] = eDefaultCircumstantialAction.PCA_GrenadeSmoke;
		i++;
    }

    for( j = i; j < 4; j++)
    {
        Query.iTeamSubActionsIDList[iSubMenu*4 + j] = eDefaultCircumstantialAction.PCA_None;
    }

} 


simulated function BOOL R6ActionCanBeExecuted( INT iAction, PlayerController PlayerController )
{
    if (iAction == eDefaultCircumstantialAction.PCA_None)
        return false;
    
    switch(iAction)
    {
    case eDefaultCircumstantialAction.PCA_GrenadeFrag:
        return m_TeamManager.HaveRainbowWithGrenadeType(GT_GrenadeFrag);
        break;
    case eDefaultCircumstantialAction.PCA_GrenadeGas:
        return m_TeamManager.HaveRainbowWithGrenadeType(GT_GrenadeGas);
        break;
    case eDefaultCircumstantialAction.PCA_GrenadeFlash:
        return m_TeamManager.HaveRainbowWithGrenadeType(GT_GrenadeFlash);
        break;
    case eDefaultCircumstantialAction.PCA_GrenadeSmoke:
        return m_TeamManager.HaveRainbowWithGrenadeType(GT_GrenadeSmoke);
        break;
    }

    return true;
}

///////////////////////////////////////////////////////////////////////////////
// DEFAULT CIRCUMSTANTIAL ACTIONS
// R6GetCircumstantialActionString()
///////////////////////////////////////////////////////////////////////////////
simulated function string R6GetCircumstantialActionString(INT iAction)
{
    switch(iAction)
    {		
        case eDefaultCircumstantialAction.PCA_TeamRegroup:		return Localize("RDVOrder", "Order_Regroup", "R6Menu");
        case eDefaultCircumstantialAction.PCA_TeamMoveTo:       return Localize("RDVOrder", "Order_TeamMoveTo", "R6Menu");
        case eDefaultCircumstantialAction.PCA_MoveAndGrenade:   return Localize("RDVOrder", "Order_MoveGrenade", "R6Menu");
		case eDefaultCircumstantialAction.PCA_GrenadeFrag:		return Localize("RDVOrder", "Order_FragGrenade", "R6Menu");
		case eDefaultCircumstantialAction.PCA_GrenadeGas:		return Localize("RDVOrder", "Order_GasGrenade", "R6Menu"); 
		case eDefaultCircumstantialAction.PCA_GrenadeFlash:		return Localize("RDVOrder", "Order_FlashGrenade", "R6Menu");
		case eDefaultCircumstantialAction.PCA_GrenadeSmoke:		return Localize("RDVOrder", "Order_SmokeGrenade", "R6Menu");
    }
    return "";
}

function DoDbgLogActor( Actor anActor )
{
    if ( R6Pawn( anActor ) != none )
    {
        if (CheatManager != none)
            R6CheatManager(CheatManager).LogR6Pawn( R6Pawn( anActor ) );
    }
    else
    {
        anActor.dbgLogActor( false );
    }

    if ( Level.NetMode == NM_Client )
    {
        ServerDbgLogActor( anActor );
    }   
}

function ServerDbgLogActor( Actor anActor )
{
    local R6Pawn p;

    p = R6Pawn( anActor );

    if ( p != none )
    {
        if (CheatManager != none)           // network play does not yet support cheatmanager
        {
            if(p.m_ePawnType == PAWN_Terrorist )
                R6CheatManager(CheatManager).LogTerro( R6Terrorist(p) );
            else
                R6CheatManager(CheatManager).LogR6Pawn( p );
        }
    }
    else
        anActor.dbgLogActor( false );
}

exec function LogPawn()
{
    DoLogPawn();
    if (Level.NetMode!=NM_Standalone)
    {
        ServerLogPawn();
    }   
}

function DoLogPawn()
{
    if (CheatManager != none)           // network play does not yet support cheatmanager
        R6CheatManager(CheatManager).LogR6Pawn( m_pawn );
}

function ServerLogPawn()
{
    DoLogPawn();
}

function DoLogActors()
{
    local actor ActorIterator;
    log("--- Actor List Begin ---");
    foreach AllActors(class 'actor', ActorIterator)
    {
        log(" Actor:"@ActorIterator);
    }
    log("--- Actor List End ---");
}

function ServerLogActors()
{
    DoLogActors();
//    ConsoleCommand("obj list class=object");
}

function PossessInit(Pawn aPawn)
{
    SetRotation(aPawn.Rotation);
    aPawn.PossessedBy(self);
    Pawn = aPawn;
   	m_pawn = R6Rainbow(Pawn);
    m_pawn.SetFriendlyFire();

    if (((Level.NetMode != NM_Standalone) && (Level.NetMode != NM_ListenServer)))
        Pawn.RemoteRole = ROLE_AutonomousProxy;
    else
        Pawn.RemoteRole = RemoteRole;
}

function Possess(Pawn aPawn)
{
	#ifdefDEBUG if(bShowLog) log(" Possess() is called.... aPawn="$aPawn);	#endif

    if ( bOnlySpectator )
        return;

	PossessInit(aPawn);	
    Pawn.bStasis = false;
    Restart();
}

function UnPossess()
{
	Super.UnPossess();
	m_pawn = none;
}

function ServerBroadcast( PlayerController Sender, coerce string Msg, optional name Type )
{
	Level.Game.BroadcastTeam( Sender, Msg, Type );
}

function ServerMove
(
	float TimeStamp, 
	vector InAccel, 
	vector ClientLoc,
	bool NewbRun,
	bool NewbDuck,
	bool NewbCrawl, 
//	eDoubleClickDir DoubleClickMove, 
//	byte ClientRoll, 
	int View,
// #ifdef R6PlayerMovements
    int iNewRotOffset,
// #endif R6PlayerMovements
	optional byte OldTimeDelta,
	optional int OldAccel
)
{
    Super.ServerMove(TimeStamp, InAccel, ClientLoc,NewbRun,NewbDuck,NewbCrawl,
                    View,iNewRotOffset,OldTimeDelta,OldAccel);
}

function ServerPlayerPref(PlayerPrefInfo newPlayerPrefs)
{
    m_PlayerPrefs = newPlayerPrefs;
    PawnClass = class<Pawn>(DynamicLoadObject(m_PlayerPrefs.m_ArmorName, class'Class'));
}

// this will search all actors on client with m_bLogNetTraffic set to true
// and will toggle the server's version to true as well

function ServerNetLogActor(actor InActor)
{
    InActor.m_bLogNetTraffic = true;
}

function ServerLogBandWidth(bool bLogBandWidth)
{
    Level.m_bLogBandWidth = bLogBandWidth;
}

function ServerSetPlayerReadyStatus(BOOL _bPlayerReady)
{
    PlayerReplicationInfo.m_bPlayerReady = _bPlayerReady;
#ifdefDEBUG
        log("ServerInfo: Player "$PlayerReplicationInfo.PlayerName$" set ready status = "$_bPlayerReady$" at time = "$Level.TimeSeconds);
#endif
}

function PlaySoundAffectedByGrenade(R6Pawn.EGrenadeType eType)
{
    switch(eType)
    {
        case GTYPE_TearGas:
            m_CommonPlayerVoicesMgr.PlayCommonRainbowVoices(m_pawn, CRV_EntersGas);
            break;
        case GTYPE_Smoke:
            m_CommonPlayerVoicesMgr.PlayCommonRainbowVoices(m_pawn, CRV_EntersSmoke);
            break;
    }
}

event ClientPlayVoices(R6SoundReplicationInfo aAudioRepInfo, Sound sndPlayVoice,  ESoundSlot eSlotUse, INT iPriority, optional BOOL bWaitToFinishSound, optional FLOAT fTime)
{
    
    if (aAudioRepInfo == none && eSlotUse != SLOT_HeadSet && eSlotUse != SLOT_Speak)
    {
        #ifdefDEBUG logSnd("In function ClientPlayVoices for the controller" @ Self @ "aAudioRepInfo is NULL  RETURN"); #endif
        return;
    }


    if (aAudioRepInfo != none && aAudioRepInfo.m_PawnOwner != none)
    {
        aAudioRepInfo.m_PawnOwner.SetAudioInfo();
        aAudioRepInfo.m_PawnOwner.m_fLastCommunicationTime = 5.0f;
    }

    PlayVoicesPriority(aAudioRepInfo, sndPlayVoice, eSlotUse, iPriority, bWaitToFinishSound, fTime);
}

function PlaySoundActionCompleted(R6Pawn.eDeviceAnimToPlay eAnimToPlay)
{
    if (Level.NetMode != NM_Standalone)
    {
        switch(eAnimToPlay)
        {
            case BA_Keypad:
                m_TeamManager.m_MultiCoopPlayerVoicesMgr.PlayRainbowTeamVoices(m_pawn, RTV_SecurityDeactivated);
                break;
            case BA_PlantDevice:
                m_TeamManager.m_MultiCoopPlayerVoicesMgr.PlayRainbowTeamVoices(m_pawn, RTV_BugActivated);
                break;
            case BA_Keyboard:
                m_TeamManager.m_MultiCoopPlayerVoicesMgr.PlayRainbowTeamVoices(m_pawn, RTV_ComputerHacked);
                break;
            case BA_ArmBomb:
                m_TeamManager.m_MultiCommonVoicesMgr.PlayMultiCommonVoices(m_pawn, MCV_BombActivated);
                break;
            case BA_DisarmBomb:
                m_TeamManager.m_MultiCommonVoicesMgr.PlayMultiCommonVoices(m_pawn, MCV_BombDeactivated);
                break;
        }
    }
}

function PlaySoundInflictedDamage(Pawn DeadPawn)
{
    switch(R6Pawn(DeadPawn).m_ePawnType)
    {
        case PAWN_Terrorist:
            m_CommonPlayerVoicesMgr.PlayCommonRainbowVoices(m_pawn, CRV_TerroristDown);
            break;
        case PAWN_Hostage:
            if (m_TeamManager.m_iMemberCount > 1)
                m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_TeamManager.m_Team[1], RMV_RainbowHitHostage); 
            break;
    }
}

function PlaySoundCurrentAction(Pawn.ERainbowTeamVoices eVoices)
{
    if (Role == ROLE_Authority) 
    {
        if (Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag))
        {
            m_TeamManager.m_MultiCoopPlayerVoicesMgr.PlayRainbowTeamVoices(m_pawn, eVoices);
        }
        else if (eVoices == RTV_HostageSecured)
        {
            m_TeamManager.m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_pawn, RPV_HostageSecured);
        }
    }
}

function PlaySoundDamage(Pawn instigatedBy)
{
    m_CommonPlayerVoicesMgr.PlayCommonRainbowVoices(m_pawn, CRV_TakeWound);
    switch(m_pawn.m_eHealth)
    {
        case HEALTH_Incapacitated:
        case HEALTH_Dead:
            m_CommonPlayerVoicesMgr.PlayCommonRainbowVoices(m_pawn, CRV_GoesDown);
            if ((m_TeamManager.m_iMemberCount > 0) && (m_TeamManager.m_MemberVoicesMgr != none))
                m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_TeamManager.m_Team[0], RMV_MemberDown);

            break; 
    }
}


/* *************************************** */
/* **** MULTIPLAYER CONSOLE COMMANDS ***** */
/* **************   BEGIN   ************** */
/* *************************************** */

// Basic Command
exec function MapList()
{
    local R6GameReplicationInfo _GRI;
    local int iIterator;
    local string szMapId;
    local string szMapName;
	local string szLocGameType;
	local string szGameType;
	local string szMapLoc;

    _GRI = R6GameReplicationInfo(GameReplicationInfo);

    szMapId = Localize("Game", "MapId", "R6GameInfo");
    szMapName = Localize("Game", "MapName", "R6GameInfo");
    szLocGameType = Localize("Game", "GameType", "R6GameInfo");

    for ( iIterator = 0; (iIterator < _GRI.m_MapLength) && (_GRI.m_mapArray[iIterator]!=""); iIterator++ )
    {
        szGameType = _GRI.Level.GetGameTypeFromClassName(_GRI.m_gameModeArray[iIterator]);
        szMapLoc = _GRI.Level.GetMapNameLocalisation(_GRI.m_mapArray[iIterator]);
        class'Actor'.static.AddMessageToConsole(szMapId$": "$iIterator + 1$
            " "$szMapName$": "$szMapLoc$
            " "$szLocGameType$": "$ _GRI.Level.GetGameNameLocalization(szGameType),
            myHUD.m_ServerMessagesColor);
    }
}

// Admin Command
exec function Map(int iGotoMapId, string explanation)
{
    local R6GameReplicationInfo _GRI;
    local string szMapLoc;
    iGotoMapId--;

    _GRI = R6GameReplicationInfo(GameReplicationInfo);

    if (iGotoMapId >= _GRI.m_MapLength ||
        iGotoMapId < 0 || 
        _GRI.m_mapArray[iGotoMapId]=="")
    {
        class'Actor'.static.AddMessageToConsole(Localize("Game", "BadMapId", "R6GameInfo"), myHUD.m_ServerMessagesColor);
        return;
    }

    szMapLoc = _GRI.Level.GetMapNameLocalisation(_GRI.m_mapArray[iGotoMapId]);
    class'Actor'.static.AddMessageToConsole(Localize("Game", "RequestingMap", "R6GameInfo")$": "$szMapLoc, myHUD.m_ServerMessagesColor);
    ServerMap(iGotoMapId, explanation);
}

function ServerMap(int iGotoMapId, string explanation)
{
    local R6GameReplicationInfo _GRI;
    local R6PlayerController _playerController;
    local string _mapName;
    local string _PlayerName;

    _GRI = R6GameReplicationInfo(GameReplicationInfo);
    if ((CheckAuthority(Authority_Admin) == false) || (iGotoMapId >= _GRI.m_MapLength))
    {
        ClientNoAuthority();
        return; // give a message that player needs admin authority
    }

    _mapName = _GRI.Level.GetMapNameLocalisation(_GRI.m_mapArray[iGotoMapId]);

    // Broadcast explanation
    _PlayerName = PlayerReplicationInfo.PlayerName;
    foreach AllActors(class'R6PlayerController', _playerController )
    {
        _playerController.ClientServerMap(_PlayerName, _mapName, explanation);
    }

    R6AbstractGameInfo(Level.Game).EndGameAndJumpToMapID( iGotoMapId);
}

// Basic Command
exec function VoteNextMap()
{
    ProcessVoteNextRequest();
}

simulated function ProcessVoteNextRequest()
{
    if ((Level.NetMode == NM_Client) ||
        (Level.NetMode == NM_Standalone))
    {
        ClientNoAuthority();
        return;
    }

    if ((m_fLastVoteTime>0) && (Level.TimeSeconds < m_fLastVoteTime + K_KickFreqTime ))
    {
        if (bShowLog) log("Next possible NextMap request time is "$m_fLastVoteTime+K_KickFreqTime$" current time is "$Level.TimeSeconds);
        ClientCantRequestChangeMapYet();
        return;
    }

    if (R6AbstractGameInfo(Level.Game).ProcessChangeMapVote(PlayerReplicationInfo.PlayerName) == false)
    {
        ClientVoteInProgress(); // a vote is already in progress
    }
    else
    {
        m_fLastVoteTime = Level.TimeSeconds;
    }
}

// Basic Command
exec function PlayerList()
{
    local PlayerReplicationInfo _PRI;
    local string szId;
    local string szName;

    szId = Localize("Game", "Id", "R6GameInfo");
    szName = Localize("Game", "Name", "R6GameInfo");

    foreach AllActors( class 'PlayerReplicationInfo', _PRI )
    {
        class'Actor'.static.AddMessageToConsole(szId$": "$_PRI.PlayerID$" "$szName$": "$_PRI.PlayerName, myHUD.m_ServerMessagesColor);
    }
}

// this function is sent and executed directly to the server.
// Basic Command
exec function VoteKick( string szKickName )
{
    ProcessVoteKickRequest(R6PlayerController(FindPlayer(szKickName, false)));
}

exec function VoteKickID( string szKickName )
{
    ProcessVoteKickRequest(R6PlayerController(FindPlayer(szKickName, true)));
}

simulated function ProcessVoteKickRequest(R6PlayerController _PlayerController)
{
    if ((Level.NetMode == NM_Client) || 
        (Level.NetMode == NM_Standalone))
    {
        ClientNoAuthority();
        return;
    }

    if ((m_fLastVoteTime>0) && (Level.TimeSeconds < m_fLastVoteTime + K_KickFreqTime ))
    {
        if (bShowLog) log("Next possible votekick request time is "$m_fLastVoteTime+K_KickFreqTime$" current time is "$Level.TimeSeconds);
        ClientCantRequestKickYet();
        return;
    }

    if (bShowLog) log("<<KICK>> "$self$": calling StartVoteKick on "$_PlayerController.PlayerReplicationInfo.PlayerName);

    if (_PlayerController!=none)
    {
        // we don't want to kick the player of a listen server
        if (Viewport(_PlayerController.Player)!=none)
        {
            ClientNoAuthority();
            return;
        }

        // if the player we want to kick is an admin, then we have no authority
        if (_PlayerController.CheckAuthority(Authority_Admin) == true) 
        {
            ClientNoKickAdmin();
            return;
        }

        if (R6AbstractGameInfo(Level.Game).ProcessKickVote(_playerController, PlayerReplicationInfo.PlayerName) == false)
        {
            ClientVoteInProgress(); // a vote is already in progress
        }
        else
        {
            m_fLastVoteTime = Level.TimeSeconds;
        }
    }
    else
    {
        ClientKickBadId();        // process bad name ID
    }
}

// Basic Command
exec function Vote(INT _bVoteResult)
{
    local Controller _itController;
    local R6PlayerController _playerController;
    local string _PlayerNameOne;
    local string _PlayerNameTwo;
    local int _iForKickVotes;
    local int _iAgainstKickVotes;
    local int _iTotalPlayers;
	local R6ServerInfo pServerInfo;
    local bool _VoteSpamCheckOk;

    if (R6AbstractGameInfo(Level.Game).m_fEndVoteTime == 0)
        return; // no vote in progress

    if ((_bVoteResult<=K_MinVote) || (_bVoteResult>=K_MaxVote))
        return; // spoiled ballot, return

    if (bShowLog) 
    {
        switch(_bVoteResult)
        {
            case K_VotedYes:
                if (R6AbstractGameInfo(Level.Game).m_PlayerKick == none)
                    log(self $" set vote yes to change Map ");
                else
                    log(self $" set vote yes to kick "$ R6AbstractGameInfo(Level.Game).m_PlayerKick.PlayerReplicationInfo.PlayerName);
                break;
            case K_VotedNo:
                if (R6AbstractGameInfo(Level.Game).m_PlayerKick == none)
                    log(self $" set vote no to change Map ");
                else
                    log(self $" set vote no to kick "$ R6AbstractGameInfo(Level.Game).m_PlayerKick.PlayerReplicationInfo.PlayerName);
                break;
            default:
                if (R6AbstractGameInfo(Level.Game).m_PlayerKick == none)
                    log(self $" how did we get here? Set invalid  vote "$ _bVoteResult $" to change Map ");
                else
                    log(self $" how did we get here? Set invalid  vote "$ _bVoteResult $" to kick "$ R6AbstractGameInfo(Level.Game).m_PlayerKick.PlayerReplicationInfo.PlayerName);
                break;
        }
    }

    m_iVoteResult=_bVoteResult;
    pServerInfo = class'Actor'.static.GetServerOptions();

    _PlayerNameOne = PlayerReplicationInfo.PlayerName;
    _PlayerNameTwo = R6AbstractGameInfo(Level.Game).m_PlayerKick.PlayerReplicationInfo.PlayerName;

    //If this variable is set to true, this vote cast isn't spam and you can broadcast it
    _VoteSpamCheckOk = m_fLastVoteEmoteTimeStamp + pServerInfo.VoteBroadcastMaxFrequency <= Level.TimeSeconds;
    
    // lets check to see if we can end the vote session early
    for (_itController=Level.ControllerList; _itController!=None; _itController=_itController.NextController )
    {
        _playerController = R6PlayerController(_itController);
        if (_playerController!=none)
        {
            _iTotalPlayers++;
            switch(_playerController.m_iVoteResult)
            {
            case K_VotedYes:
                _iForKickVotes++;
                break;
            case K_VotedNo:
                _iAgainstKickVotes++;
                break;
            }
  
            //Spam filtering IF
            if (_VoteSpamCheckOk)
            {
                _playerController.ClientPlayerVoteMessage(_PlayerNameOne, m_iVoteResult, _PlayerNameTwo);
            }
        }
    }

    if (_VoteSpamCheckOk)
    {
        m_fLastVoteEmoteTimeStamp = Level.TimeSeconds;
    }
    else
    {
        //This code gets executed when the _VoteSpamCheck variable prevented the message to be sent to everyone
        //to prevent spamming.  If the message wasn't to anyone, then send it only to the voting player.
        
        ClientPlayerVoteMessage(_PlayerNameOne, m_iVoteResult, _PlayerNameTwo);
    }
                    
    // a decision can be made now, so let's end the vote session
    if ((float(_iAgainstKickVotes) >= float(_iTotalPlayers)/2) || (float(_iForKickVotes) > float(_iTotalPlayers)/2))
        R6AbstractGameInfo(Level.Game).m_fEndVoteTime = Level.TimeSeconds;
}

// allows the client to exit gracefully
function ClientBanned()
{
    Player.Console.R6ConnectionFailed("BannedIP");
}


function ClientKickedOut()
{
    Player.Console.R6ConnectionFailed("YouWereKicked");
}

// Basic Command

function AutoAdminLogin(string _Password)
{
    if ( (Viewport(Player)!=none) ||
         ( Level.m_ServerSettings.UseAdminPassword && 
         (_Password == Level.m_ServerSettings.AdminPassword)) )
    {
        m_iAdmin = Authority_Admin;
    }
}

exec function AdminLogin(string _Password)
{
    m_szLastAdminPassword = _Password;  // save last used password
    SaveConfig();
    ServerAdminLogin(_Password);
}

function ServerAdminLogin(string _Password)
{
    if ( (Viewport(Player)!=none) ||
         ( Level.m_ServerSettings.UseAdminPassword && 
         (_Password == Level.m_ServerSettings.AdminPassword)) )
    {
        m_iAdmin = Authority_Admin;
        ClientAdminLogin(true);
        if (bShowLog) log(PlayerReplicationInfo.PlayerName$" logged in as an Administrator");
    }
    else
        ClientAdminLogin(false);
}

function ClientAdminLogin(bool _loginRes)
{
    if (_loginRes == true)
    {
        m_iAdmin = Authority_Admin;
        Player.InteractionMaster.Process_Message(
                Localize("Game", "AdminSuccess", "R6GameInfo"), 7.0, Player.LocalInteractions);    
    }
    else
    {
		m_iAdmin = Authority_None;
        Player.InteractionMaster.Process_Message(
                Localize("Game", "AdminFailure", "R6GameInfo"), 7.0, Player.LocalInteractions);    
    }
}

// Admin Command
exec function LockServer(BOOL _bFlagSetting, optional string _NewPassword)
{
    if (Console(Player.Console).m_bStartedByGSClient == true)
    {
        Player.Console.Message(Localize("Errors", "DisabledCommand", "R6Engine"), 6.0);
        return;
    }

    if (CheckAuthority(Authority_Admin) == false)
    {
        ClientNoAuthority();
        return; // give a message that player needs admin authority
    }
    if(Len(_NewPassword) > 16)
    {
        ClientPasswordTooLong();
        return; // give a message that password is too long
    }

    if (_bFlagSetting==true)
    {
        if (_NewPassword == "")
        {
            ClientPasswordMessage(GPR_MissingPasswd);
        }
        else
        {
            ClientPasswordMessage(GPR_PasswdSet);
            Level.Game.SetGamePassword(_NewPassword);
        }
    }
    else
    {
        ClientPasswordMessage(GPR_PasswdCleared);
        Level.Game.SetGamePassword("");
    }
}

function ClientPasswordMessage(eGamePasswordRes iMessageType)
{
    switch (iMessageType)
    {
    case GPR_MissingPasswd:
        AddMessageToConsole(Localize("Game", "GamePasswordMissing", "R6GameInfo"), myHUD.m_ServerMessagesColor);
        break;
    case GPR_PasswdSet:
        AddMessageToConsole(Localize("Game", "GamePasswordSet", "R6GameInfo"), myHUD.m_ServerMessagesColor);
        break;
    case GPR_PasswdCleared:
        AddMessageToConsole(Localize("Game", "GamePasswordCleared", "R6GameInfo"), myHUD.m_ServerMessagesColor);
        break;
    }
}


exec function NewPassword(string _NewPassword)
{
    local R6PlayerController _playerController;
    local string _PlayerName;
    if (CheckAuthority(Authority_Admin) == false)
    {
        ClientNoAuthority();
        return; // give a message that player needs admin authority
    }

    if(Len(_NewPassword) > 16)
    {
        ClientPasswordTooLong();
        return; // give a message that password is too long
    }

    Level.m_ServerSettings.AdminPassword = _NewPassword;
    Level.m_ServerSettings.SaveConfig();
    _PlayerName = PlayerReplicationInfo.PlayerName;
    if (bShowLog) log(_PlayerName$" changed password to "$_NewPassword);

    foreach AllActors(class'R6PlayerController', _playerController )
    {
        _playerController.ClientNewPassword(_PlayerName);
    }
}


function BOOL CheckAuthority(int _LevelNeeded)
{
    if ( Level.NetMode==NM_Standalone )
        return false; // we don't want to allow map, restartround 

    // either logged in
    // player on listen server does not need to log in
    return ( (m_iAdmin>=_LevelNeeded) || ((Level.NetMode==NM_ListenServer) && (Viewport(Player)!=none)) );
}

// this is executed on the server
// Admin Command
exec function Kick( string szKickName )
{
    ProcessKickRequest(R6PlayerController(FindPlayer(szKickName, false)));
}

exec function KickId( string szKickName )
{
    ProcessKickRequest(R6PlayerController(FindPlayer(szKickName, true)));
}

exec function Ban( string szKickName )
{
    local R6PlayerController PC;

    PC = R6PlayerController(FindPlayer(szKickName, false));
    
    ProcessKickRequest(PC, true);
}

exec function BanId( string szKickName )
{
    local R6PlayerController PC;
    PC = R6PlayerController(FindPlayer(szKickName, true));
    ProcessKickRequest(PC, true);
}

function ClientNoBanMatches()
{
    local int iPos;
    AddMessageToConsole(Localize("Game", "NoBanMatchFound", "R6GameInfo"), myHUD.m_ServerMessagesColor);

    for (iPos=0; iPos<K_MaxBanPageSize; iPos++)
    {
        m_BanPage.szBanID[iPos] = "";
    }
    m_iBanPage=0;
    m_szBanSearch="";
}

function ClientPlayerUnbanned()
{
    AddMessageToConsole(Localize("Game", "PlayerUnBanned", "R6GameInfo"), myHUD.m_ServerMessagesColor);
}

//#ifdef R6PUNKBUSTER
function ClientPBVersionMismatch()
{
    AddMessageToConsole(Localize("Game", "PBVersionMismatch", "R6GameInfo"), myHUD.m_ServerMessagesColor);
}
//#endif R6PUNKBUSTER

function ClientBanMatches(STBanPage banPage, string _BanPrefix)
{
    local int iPos;

    m_BanPage = banPage;
    m_szBanSearch = _BanPrefix;

    for (iPos=0; iPos<K_MaxBanPageSize; iPos++)
    {
        if (m_BanPage.szBanID[iPos] == "")
            break;
        AddMessageToConsole(iPos$"> "$m_BanPage.szBanID[iPos], myHUD.m_ServerMessagesColor);
    }
    m_iBanPage++;
}

exec function UnBanPos(int iPosition)
{
    local int iPos;

    if (CheckAuthority(Authority_Admin) == false)
    {
        ClientNoAuthority();
        return; // give a message that player needs admin authority
    }

    if (m_BanPage.szBanID[iPosition]=="")
    {
        AddMessageToConsole(Localize("Game", "NoBannedInPos", "R6GameInfo"), myHUD.m_ServerMessagesColor);
        return;
    }

    UnBan(m_BanPage.szBanID[iPosition]);
    for (iPos=0; iPos<K_MaxBanPageSize; iPos++)
    {
        m_BanPage.szBanID[iPos] = "";
    }
    m_iBanPage=0;
    m_szBanSearch="";
}

exec function BanList(string szPrefixBanID)
{
    if (CheckAuthority(Authority_Admin) == false)
    {
        ClientNoAuthority();
        return; // give a message that player needs admin authority
    }

    m_iBanPage=0;
    m_szBanSearch=szPrefixBanID;
    ServerBanList(m_iBanPage, szPrefixBanID);
}

exec function NextBanList()
{
    if (CheckAuthority(Authority_Admin) == false)
    {
        ClientNoAuthority();
        return; // give a message that player needs admin authority
    }

    if (m_iBanPage==0)
        AddMessageToConsole(Localize("Game", "BanListFirst", "R6GameInfo"), myHUD.m_ServerMessagesColor);
    else
        ServerBanList(m_iBanPage, m_szBanSearch);
}

function ServerBanList(int _iPageNumber, string szPrefixBanID )
{
    local int i;
    local int iMatchesFound;
    local int iPosFound;
    local STBanPage BanPage;

    if (CheckAuthority(Authority_Admin) == false)
    {
        ClientNoAuthority();
        return; // give a message that player needs admin authority
    }

    i=-1;
    // skip to the required section
    while (_iPageNumber>0)
    {
//        log(_iPageNumber$" left to skip");
        iMatchesFound = 0;
        do
        {
            i++;
            i = Level.Game.AccessControl.NextMatchingID(szPrefixBanID, i);
            if (i>=0)
                iMatchesFound++;
        }
        until ((iMatchesFound == K_MaxBanPageSize) || (i==-1));

        if (i==-1)
        {
            ClientNoBanMatches();
            return;
        }
        _iPageNumber--;
    }

    iMatchesFound = 0;
    do
    {
        i++;
        i = Level.Game.AccessControl.NextMatchingID(szPrefixBanID, i);
        if (i>=0)
        {
//            log(iMatchesFound$"> "$Level.Game.AccessControl.Banned[i]);
            BanPage.szBanID[iMatchesFound++] = Level.Game.AccessControl.Banned[i];
        }
    }
    until ((iMatchesFound == K_MaxBanPageSize) ||(i == -1));

    if (iMatchesFound>0)
        ClientBanMatches(BanPage, szPrefixBanID);
    else
        ClientNoBanMatches();
}

//client to server
exec function UnBan(string szPrefixBanID)
{
    local int _iMatchesFound;
    if (CheckAuthority(Authority_Admin) == false)
    {
        ClientNoAuthority();
        return; // give a message that player needs admin authority
    }

    _iMatchesFound = Level.Game.AccessControl.RemoveBan(szPrefixBanID);
    if (_iMatchesFound == 0)
    {
        ClientNoBanMatches();
        // send admin message that no match was found
    }
    else if (_iMatchesFound == 1)
    {
        // send admin message that id was unbanned
        ClientPlayerUnbanned();

    }
    else
    {
        // send admin message that multiple hits were found
        BanList(szPrefixBanID);
    }
}

exec function Admin( string CommandLine )
{
	local string Result;

    if (CheckAuthority(Authority_Admin) == false)
    {
        ClientNoAuthority();
        log("Admin command <<"$CommandLine$">> issued by:"$GetPlayerNetworkAddress()$" ignored");
        return; // give a message that player needs admin authority
    }

	Result = ConsoleCommand( CommandLine );
    log("Admin command <<"$CommandLine$">> issued by:"$GetPlayerNetworkAddress() $" accepted");
	if( Result!="" )
    {
        log("Admin command returned <<"$Result$">>");
		ClientMessage( Result );
     }
}


simulated function ProcessKickRequest(R6PlayerController _PlayerController, OPTIONAL BOOL bBan)
{
    local R6PlayerController _pcIterator;
    local string _AdminName, _KickeeName;

    if (CheckAuthority(Authority_Admin) == false)
    {
        ClientNoAuthority();
        return; // give a message that player needs admin authority
    }

    if (_PlayerController==none)
    {
        ClientKickBadId();        // process bad name ID
        return;
    }

    // we don't want to kick the player of a listen server, doing so
    // will make the game end
    // and we don't want to kick other admins

    if ((Viewport(_PlayerController.Player)!=none) ||
        (_PlayerController.CheckAuthority(Authority_Admin)==true))
    {
        ClientNoKickAdmin();
        return;
    }
    
    // we have the authority to kick whoever we want
    if (bShowLog) log("<AdminKick> "$PlayerReplicationInfo.PlayerName$
        " kicked "$_PlayerController.PlayerReplicationInfo.PlayerName$" from server");

    _AdminName = PlayerReplicationInfo.PlayerName;
    _KickeeName = _PlayerController.PlayerReplicationInfo.PlayerName;

    foreach AllActors(class'R6PlayerController', _pcIterator )
    {
        if (bBan)
        {
            //Message for Banning
            _pcIterator.ClientAdminBanOff(_AdminName, _KickeeName);
        }
        else
        {
            //Message for simple Kicking
            _pcIterator.ClientAdminKickOff(_AdminName, _KickeeName);
        }
    }

#ifdefDEBUG
    log("ServerInfo: Disconnect client "$_PlayerController.PlayerReplicationInfo.PlayerName$" Kicked off server by request at time "$Level.TimeSeconds);
#endif
    if (bBan)
    {
        // Put PlayerIP in the IPPolicies as access denied
        Level.Game.AccessControl.KickBan(_KickeeName);
        _PlayerController.ClientBanned();
    }
    else
        _PlayerController.ClientKickedOut();

    _PlayerController.SpecialDestroy();
}


// Admin Command
exec function LoadServer(string FileName)
{
    local R6PlayerController _playerController;
    
    if (CheckAuthority(Authority_Admin) == false)
    {
        ClientNoAuthority();
        return; // give a message that player needs admin authority
    }
    ConsoleCommand("INGAMELOADSERVER "$FileName);
}

//=================================================================================
// INTERACTION WITH MENU FOR SERVER SETTINGS
//=================================================================================
function ServerPausePreGameRoundTime()
{
    m_bInAnOptionsPage = CheckAuthority(Authority_Admin);
    if (m_bInAnOptionsPage == true)
    {
        R6AbstractGameInfo(level.game).PauseCountDown();
    }
}

function ServerUnPausePreGameRoundTime()
{
    if (m_bInAnOptionsPage == true)
    {
        m_bInAnOptionsPage = false;
        R6AbstractGameInfo(level.game).UnPauseCountDown();
    }
}


function ServerStartChangingInfo()
{
    if (CheckAuthority(Authority_Admin) == false)
    {
        ClientNoAuthority();
        ClientServerChangingInfo(false);
        return;
    }

	if ((R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo != self) && (R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo != none))
	{
		// Send client a message, that some one else already is modifying Serverinfo
        ClientServerChangingInfo(false);
        return;
	}

	R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo = self;
    if (bShowLog) log("ServerStartChangingInfo: Setting m_pCurPlayerCtrlMdfSrvInfo = "$R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo);
    ClientServerChangingInfo(true);
}

function ClientServerChangingInfo(bool _bCanChangeOptions)
{
    m_MenuCommunication.SetClientServerSettings(_bCanChangeOptions);
}

//=======================================
// SendSettingsAndRestartServer: This save new settings and restart the server
//=======================================
function SendSettingsAndRestartServer( BOOL _bRestrictionKitChange, BOOL _bChangeWasMade)
{
	local R6ServerInfo pServerInfo;

	if (R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo != self)
	{
		// Send client a message, that some one else already is modifying Serverinfo
		return;
	}

	pServerInfo = class'Actor'.static.GetServerOptions();

	if (_bChangeWasMade)
	{
		pServerInfo.SaveConfig(class'Actor'.static.GetModMgr().getServerIni());
		pServerInfo.m_ServerMapList.SaveConfig(class'Actor'.static.GetModMgr().getServerIni());

		if (!_bRestrictionKitChange)
        {
#ifdefDebug
            log("Restarting server because admin "$PlayerReplicationInfo.PlayerName$" changed server options");
#endif
            pServerInfo.RestartServer();
        }
        else
        {
            R6AbstractGameInfo(Level.Game).UpdateRepResArrays();
            R6AbstractGameInfo(Level.Game).BroadcastGameMsg( "", PlayerReplicationInfo.PlayerName, "RestOption");
        }
    }
	else
    {
        R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo = none;
//		pServerInfo = Level.m_ServerSettings; // keep the original data srv
	}

//	R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo = none;
}

exec function LogRest()
{
    local INT                   i;
    local R6GameReplicationInfo _GRI;  // avoid casting all the time

#ifdefDebug
    _GRI = R6GameReplicationInfo(GameReplicationInfo);
    log("Shotgun rest start");
    for (i=0; i < ArrayCount(_GRI.m_szShotGunRes); i++)
    {
        log("       m_szShotGunRes["$i$"] = "$_GRI.m_szShotGunRes[i]);
    }
    log("Shotgun rest end");
#endif
}

//===========================================================================================
// ServerNewGeneralSettings: This set the new settings of the server, values are store in R6ServerInfo unique instance
//							 return true if a value was change
//===========================================================================================
function BOOL ServerNewGeneralSettings(UWindowBase.EButtonName _eButName, optional BOOL _bNewValue, optional INT _iNewValue)
{
	local R6ServerInfo pServerInfo;
	local BOOL         bValueChange;

	if (R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo != self) 
	{
		// Send client a message, that some one else already is modifying Serverinfo
		return false;
	}

    pServerInfo = class'Actor'.static.GetServerOptions();

	bValueChange = true;

	switch(_eButName)
	{
		case EBN_RoundPerMatch:
		case EBN_RoundPerMission:
			pServerInfo.RoundsPerMatch = _iNewValue;
			break;
		case EBN_RoundTime:
			pServerInfo.RoundTime = _iNewValue;
			break;
		case EBN_NB_Players:
			pServerInfo.MaxPlayers = _iNewValue;
			break;
		case EBN_BombTimer:
			pServerInfo.BombTime = _iNewValue;
			break;
		case EBN_TimeBetRound:
			pServerInfo.BetweenRoundTime = _iNewValue;
			break;
		case EBN_NB_of_Terro:
			pServerInfo.NbTerro = _iNewValue;
			break;
//		case EBN_PublicServer:
//			pServerInfo. =
//			break;
//		case EBN_DedicatedServer:
//			pServerInfo. =
//			break;
		case EBN_FriendlyFire:
			pServerInfo.FriendlyFire = _bNewValue;
			break;
		case EBN_AllowTeamNames:
			pServerInfo.ShowNames = _bNewValue;
			break;
		case EBN_AutoBalTeam:
			pServerInfo.Autobalance = _bNewValue;
			break;
//#ifdefR6PUNKBUSTER
		case EBN_PunkBuster:
			break;
//#endif
		case EBN_TKPenalty:
			pServerInfo.TeamKillerPenalty = _bNewValue;
			break;
		case EBN_AllowRadar:
			pServerInfo.AllowRadar = _bNewValue;
			break;
		case EBN_RotateMap:
			pServerInfo.RotateMap = _bNewValue;
			break;
		case EBN_AIBkp:
			pServerInfo.AIBkp = _bNewValue;
			break;
		case EBN_ForceFPersonWp:
			pServerInfo.ForceFPersonWeapon = _bNewValue;
			break;
		case EBN_DiffLevel:
			pServerInfo.DiffLevel = _iNewValue;
			break;
		case EBN_CamFirstPerson:
			pServerInfo.CamFirstPerson = _bNewValue;
			break;
		case EBN_CamThirdPerson:
			pServerInfo.CamThirdPerson = _bNewValue;
			break;
		case EBN_CamFreeThirdP:
			pServerInfo.CamFreeThirdP = _bNewValue;
			break;
		case EBN_CamGhost:
			pServerInfo.CamGhost = _bNewValue;
			break;
		case EBN_CamFadeToBk:
			pServerInfo.CamFadeToBlack = _bNewValue;
			break;
		case EBN_CamTeamOnly:
			pServerInfo.CamTeamOnly = _bNewValue;			
			break;
		case EBN_None:
		default:
			bValueChange = false;
			break;
	}

	return bValueChange;
}

//===========================================================================================
// ServerNewMapsListSettings: This set the new map list settings of the server, values are store in R6ServerInfo unique instance
//===========================================================================================
function ServerNewMapListSettings(int iMapIndex, optional INT iUpdateGameType, optional string _GameType, optional string _Map, optional INT _iLastItem)
{
	local R6ServerInfo pServerInfo;
	local INT		   i, iArrayCount;
	local BOOL         bValueChange;

	if (R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo != self) 
	{
		// Send client a message, that some one else already is modifying Serverinfo
		return;
	}

    pServerInfo = class'Actor'.static.GetServerOptions();

	if (_iLastItem != 0)
	{
		iArrayCount = ArrayCount(pServerInfo.m_ServerMapList.Maps);
		for ( i = _iLastItem; i < iArrayCount; i++)
		{
			pServerInfo.m_ServerMapList.GameType[i] = "";
			pServerInfo.m_ServerMapList.Maps[i]		= "";
		}

		return;
	}

	switch(iUpdateGameType)
	{
		case 1:
			pServerInfo.m_ServerMapList.Maps[iMapIndex] = _Map;
			break;
		case 2:
			pServerInfo.m_ServerMapList.GameType[iMapIndex] = _GameType;
			break;
		default:
			pServerInfo.m_ServerMapList.GameType[iMapIndex] = _GameType;
			pServerInfo.m_ServerMapList.Maps[iMapIndex]		= _Map;
			break;
	}
}

//===========================================================================================
// ServerNewKitRestSettings: This set the kit rest settings of the server, values are store in R6ServerInfo unique instance
//							  return true if a value was change
//===========================================================================================
function ServerNewKitRestSettings( UWindowBase.ERestKitID _eKitRestID, BOOL _bRemoveRest, optional class _pANewClassValue, optional string _szNewValue)
{
	local R6ServerInfo pServerInfo;
	local BOOL         bValueChange;

	if (R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo != self) 
	{
		// Send client a message, that some one else already is modifying Serverinfo
		return;
	}

    pServerInfo = class'Actor'.static.GetServerOptions();

	switch(_eKitRestID)
	{
		case ERestKit_SubMachineGuns:
			SetRestKitWithAClass( _bRemoveRest, _pANewClassValue, pServerInfo.RestrictedSubMachineGuns);
			break;
		case ERestKit_Shotguns:
			SetRestKitWithAClass( _bRemoveRest, _pANewClassValue, pServerInfo.RestrictedShotGuns);
			break;
		case ERestKit_AssaultRifle:
			SetRestKitWithAClass( _bRemoveRest, _pANewClassValue, pServerInfo.RestrictedAssultRifles);
			break;
		case ERestKit_MachineGuns:
			SetRestKitWithAClass( _bRemoveRest, _pANewClassValue, pServerInfo.RestrictedMachineGuns);
			break;
		case ERestKit_SniperRifle:
			SetRestKitWithAClass( _bRemoveRest, _pANewClassValue, pServerInfo.RestrictedSniperRifles);
			break;
		case ERestKit_Pistol:
			SetRestKitWithAClass( _bRemoveRest, _pANewClassValue, pServerInfo.RestrictedPistols);
			break;
		case ERestKit_MachinePistol:
			SetRestKitWithAClass( _bRemoveRest, _pANewClassValue, pServerInfo.RestrictedMachinePistols);
			break;
		case ERestKit_PriWpnGadget:
			SetRestKitWithAsz( _bRemoveRest, _szNewValue, pServerInfo.RestrictedPrimary);
			break;
		case ERestKit_SecWpnGadget:
			SetRestKitWithAsz( _bRemoveRest, _szNewValue, pServerInfo.RestrictedSecondary);
			break;
		case ERestKit_MiscGadget:
			SetRestKitWithAsz( _bRemoveRest, _szNewValue, pServerInfo.RestrictedMiscGadgets);
			break;
	}
}

function SetRestKitWithAClass( BOOL _bRemoveRest, class _pANewClassValue, out array<class> _pARestKit)
{
	local INT i;
	if (_bRemoveRest)
	{
		for(i = 0; i < _pARestKit.Length; i++)
		{
			if (_pARestKit[i] == _pANewClassValue)
			{
				_pARestKit.remove( i, 1);
			}
		}
	}
	else
		_pARestKit[_pARestKit.Length] = _pANewClassValue; // put the value at the end
}

function SetRestKitWithAsz( BOOL _bRemoveRest, string _szNewValue, out array<string> _szARestKit)
{
	local INT i;
	if (_bRemoveRest)
	{
		for(i = 0; i < _szARestKit.Length; i++)
		{
			if (_szARestKit[i] == _szNewValue)
			{
				_szARestKit.remove( i, 1);
			}
		}
	}
	else
		_szARestKit[_szARestKit.Length] = _szNewValue; // put the value at the end
}

//=============================================================================================
// endif interaction with menu for server settings
//=============================================================================================

exec function RestartMatch(string explanation)
{
    local R6PlayerController _playerController;
    local string _AdminName;
        
    if (CheckAuthority(Authority_Admin) == false)
    {
        ClientNoAuthority();
        return; // give a message that player needs admin authority
    }

    _AdminName = PlayerReplicationInfo.PlayerName;

    DisableFirstPersonViewEffects();
    foreach AllActors(class'R6PlayerController', _playerController )
    {
        _playerController.ClientDisableFirstPersonViewEffects();
        _playerController.ClientRestartMatchMsg(_AdminName, explanation);
    }

    Level.Game.AbortScoreSubmission();
    Level.Game.RestartGame();
}

// Admin Command
exec function RestartRound(string explanation)
{
    local R6PlayerController _playerController;
    local string _AdminName;
    
    if (CheckAuthority(Authority_Admin) == false)
    {
        ClientNoAuthority();
        return; // give a message that player needs admin authority
    }

    _AdminName = PlayerReplicationInfo.PlayerName;

    DisableFirstPersonViewEffects();
    foreach AllActors(class'R6PlayerController', _playerController )
    {
        _playerController.ClientDisableFirstPersonViewEffects();
        _playerController.ClientRestartRoundMsg(_AdminName, explanation);
    }

    Level.Game.AbortScoreSubmission();
    R6AbstractGameInfo(level.game).AdminResetRound();
    R6AbstractGameInfo(level.game).ResetRound();
    R6AbstractGameInfo(level.game).ResetPenalty();
}

#ifdefDebug
exec function LogVoteInfo()
{
    R6AbstractGameInfo(level.game).LogVoteInfo();
}
#endif

//====
// Server Broadcasted messages
//====
function ClientTeamFullMessage()
{
    HandleServerMsg( Localize("MPMiscMessages", "TeamIsFull", "R6GameInfo"));
}

function ClientServerMap(string _szPlayerName, string szNewMapname, string explanation)
{
    HandleServerMsg(_szPlayerName$ " " $Localize("Game", "AdminSwitchMap", "R6GameInfo")$ " " $szNewMapname);
    if (explanation != "")
    {
        HandleServerMsg(explanation);
    }
}

function ClientKickBadId()
{
    HandleServerMsg( Localize("Game", "BadNameOrId", "R6GameInfo"));
}

function ClientNextMapVoteMessage(string szRequestingPlayer)
{
    if (bShowLog) log("ClientMextMapVoteMessage displaying: "$szRequestingPlayer $ ": " $ Localize("Game", "LetsChangeMap", "R6GameInfo"));
    m_MenuCommunication.ActiveVoteMenu(true, "");
    HandleServerMsg(szRequestingPlayer $ ": " $ Localize("Game", "LetsChangeMap", "R6GameInfo"));
}

function ClientKickVoteMessage(PlayerReplicationInfo PRIKickPlayer, string szRequestingPlayer)
{
    if (bShowLog) log("ClientKickVoteMessage displaying: "$szRequestingPlayer $ ": " $ Localize("Game", "LetsKickOut", "R6GameInfo") @ PRIKickPlayer.PlayerName);
    m_MenuCommunication.ActiveVoteMenu(true, PRIKickPlayer.PlayerName);
    HandleServerMsg(szRequestingPlayer $ ": " $ Localize("Game", "LetsKickOut", "R6GameInfo") @ PRIKickPlayer.PlayerName);
}

function ClientPlayerVoteMessage(string _playerOne, int iResult, string _playerTwo)
{
    local string szVoteMessage;
    switch (iResult)
    {
    case K_VotedYes:
        if (_playerTwo != "")
            szVoteMessage = _playerOne@Localize("Game", "YesVoteKick", "R6GameInfo")@_playerTwo;
        else
            szVoteMessage = _playerOne@Localize("Game", "YesVoteChangeMap", "R6GameInfo");
        break;
    case K_VotedNo:
        if (_playerTwo != "")
            szVoteMessage = _playerOne@Localize("Game", "NoVoteKick", "R6GameInfo")@_playerTwo;
        else
            szVoteMessage = _playerOne@Localize("Game", "NoVoteChangeMap", "R6GameInfo");
        break;
    default:
        return;
    }
    Player.InteractionMaster.Process_Message(szVoteMessage, 7.0, Player.LocalInteractions);
}


function ClientVoteResult(bool VoteResult, optional string _PlayerName)
{
    local string _stringOne;
    local string _stringTwo;

    if (_PlayerName != "")
    {
        if (VoteResult)
        {
            _stringOne = Localize("Game", "KickVotePassOne", "R6GameInfo");
            _stringTwo = Localize("Game", "KickVotePassTwo", "R6GameInfo");
        }
        else
        {
            _stringOne = Localize("Game", "KickVoteFailOne", "R6GameInfo");
            _stringTwo = Localize("Game", "KickVoteFailTwo", "R6GameInfo");
        }

        HandleServerMsg(_stringOne$" "$_PlayerName$" "$_stringTwo);
    }
    else
    {
        if (VoteResult)
            _stringOne = Localize("Game", "ChangeMapVotePass", "R6GameInfo");
        else
            _stringOne = Localize("Game", "ChangeMapVoteFailed", "R6GameInfo");

        HandleServerMsg(_stringOne);
    }
    m_MenuCommunication.ActiveVoteMenu(false);
}

event ClientVoteSessionAbort(string _PlayerName)
{
    HandleServerMsg(_PlayerName@Localize("Game", "LeftTheServerVoteAborted", "R6GameInfo"));
    m_MenuCommunication.ActiveVoteMenu(false);
}

function ClientNewPassword(string _AdminName)
{
    HandleServerMsg(_AdminName $": "$Localize("Game", "AdminPasswordChange", "R6GameInfo"));
}

function ClientPasswordTooLong()
{
    HandleServerMsg(Localize("Game", "PasswordTooLong", "R6GameInfo"));
}

function ClientNoAuthority()
{
    HandleServerMsg(Localize("Game", "NoAuthority", "R6GameInfo"));
}

function ClientVoteInProgress()
{
    HandleServerMsg(Localize("Game", "VoteInProgress", "R6GameInfo"));
}

function ClientCantRequestChangeMapYet()
{
    HandleServerMsg(Localize("Game", "CantRequestChangeMapYet", "R6GameInfo"));
}

function ClientCantRequestKickYet()
{
    HandleServerMsg(Localize("Game", "CantRequestKickYet", "R6GameInfo"));
}

function ClientNoKickAdmin()
{
    HandleServerMsg(Localize("Game", "CantKickAdmin", "R6GameInfo"));
}

function ClientAdminKickOff(string _AdminName, string _KickedName)
{
    HandleServerMsg(_KickedName$" "$Localize("Game", "AdminKickOff", "R6GameInfo")$" "$_AdminName);
}

function ClientAdminBanOff(string _AdminName, string _KickedName)
{
    HandleServerMsg(_KickedName$" "$Localize("Game", "AdminBanOff", "R6GameInfo")$" "$_AdminName);
}

function ClientVoteChangeMap(string _AdminName)
{
    HandleServerMsg(_AdminName$" "$Localize("Game", "VoteChangeMap", "R6GameInfo"));
}

function ClientRestartRoundMsg(string _AdminName, string explanation)
{
    HandleServerMsg(_AdminName$" "$Localize("Game", "RestartsTheRound", "R6GameInfo"));
    if (explanation != "")
    {
        HandleServerMsg(explanation);
    }

    //Make sure the checkbox isn't checked since we restart and everyone resets to not-ready.
    m_MenuCommunication.SetPlayerReadyStatus(false);
}

function ClientRestartMatchMsg(string _AdminName, string explanation)
{
    HandleServerMsg(_AdminName$" "$Localize("Game", "RestartsTheMatch", "R6GameInfo"));
    if (explanation != "")
    {
        HandleServerMsg(explanation);
    }

    m_MenuCommunication.SetPlayerReadyStatus(false);
}

//------------------------------------------------------------------
// ClientResetGameMsg
//	
//------------------------------------------------------------------
function ClientResetGameMsg()
{
    local int i;

    for ( i=0; i<myHUD.c_iTextServerMessagesMax; i++ )
    {
        myHUD.TextServerMessages[i] = "";
        myHUD.MessageServerLife[i]  = 0;
    }
}

//------------------------------------------------------------------
// ClientGameTypeDescription: display the short game type description
//	
//------------------------------------------------------------------
function ClientGameTypeDescription( string szGameTypeFlag )
{
    local string szObjective;

    if ( PlayerReplicationInfo.TeamID == INT(ePlayerTeamSelection.PTS_Bravo ) )
    {
        szObjective = Level.GetRedShortDescription( szGameTypeFlag );
        if ( szObjective != "" )
            HandleServerMsg( szObjective );
    }
    else
    {
        szObjective = Level.GetGreenShortDescription( szGameTypeFlag );
        if ( szObjective != "" )
            HandleServerMsg( szObjective );
    }
}

//------------------------------------------------------------------
// Dispatch game msg: Default RavenShield and MissionObjective
//	
//------------------------------------------------------------------
function ClientMissionObjMsg( string szLocFile, string szPreMsg, string szMsgID, optional Sound sndSound, OPTIONAL int iLifeTime )
{
    if ( szLocFile == "" )
        szLocFile = Level.m_szMissionObjLocalization;

    SetGameMsg( szLocFile, szPreMsg, szMsgID, sndSound, iLifeTime);
}

function ClientGameMsg( string szLocFile, string szPreMsg, string szMsgID, optional Sound sndSound, OPTIONAL int iLifeTime )
{
    if ( szLocFile == "" )
        szLocFile = "R6GameInfo";

    SetGameMsg( szLocFile, szPreMsg, szMsgID, sndSound, iLifeTime );
}

//------------------------------------------------------------------
// SetGameMsg
//	the server broadcast game msg to client
//------------------------------------------------------------------
function SetGameMsg( string szLocalization, string szPreMsg, string szMsgID, optional Sound sndSound, OPTIONAL int iLifeTime )
{
    if ( szPreMsg != "" && szMsgID != "" )     // both string
    {
        HandleServerMsg( szPreMsg$ " " $Localize("Game", szMsgID, szLocalization), iLifeTime );
    }
    else if ( szPreMsg != "" && szMsgID == "" ) // only premsg
    {
        HandleServerMsg( szPreMsg, iLifeTime );
    }
    else if ( szMsgID != "" )                   // only msg
    {
        HandleServerMsg( Localize("Game", szMsgID, szLocalization), iLifeTime );
    }
    else                                        // empty
    {
        HandleServerMsg( "", iLifeTime );
    }

	// Play the game status sound
    
    if ( sndSound != none)
		ClientPlayVoices(none, sndSound, SLOT_Speak, 5, true, 1);
#ifdefDEBUG
    else
        LogSnd("No Sound in ClientGameMsg for message" @ Localize("Game", szMsgID, szLocalization) );
#endif
}

/* *************************************** */
/* **** MULTIPLAYER CONSOLE COMMANDS ***** */
/* ***************   END   *************** */
/* *************************************** */

#ifdefDEBUG // Cheat can be unlocked only in debug
exec function UnlockCheat()
{
    R6CheatManager(CheatManager).m_bUnlockAllCheat = true;
    ServerUnlockCheat();
}
function ServerUnlockCheat()
{
    R6CheatManager(CheatManager).m_bUnlockAllCheat = true;
}
#endif

function ServerGhost( Pawn aPawn )
{
    if(CheatManager!=none)
        R6CheatManager(CheatManager).DoGhost( aPawn);
}

function ServerCompleteMission()
{
    if(CheatManager!=none)
        R6CheatManager(CheatManager).DoCompleteMission();
}

function ServerAbortMission()
{
    if(CheatManager!=none)
        R6CheatManager(CheatManager).DoAbortMission();
}

function ServerWalk( Pawn aPawn )
{
    if(CheatManager!=none)
        R6CheatManager(CheatManager).DoWalk( aPawn );
}

function ServerPlayerInvisible( bool bIsVisible )
{
    if(CheatManager!=none)
        R6CheatManager(CheatManager).DoPlayerInvisible( bIsVisible );
}

function ClientTeamIsDead()
{
    if (m_MenuCommunication!=none)
    {
        m_MenuCommunication.SetStatMenuState(CMS_PlayerDead);
    }
}

//------------------------------------------------------------------
// ServerRequestSkins
//	Client request the skin on the server
//------------------------------------------------------------------
simulated function ServerRequestSkins()
{
	local class<R6Rainbow> TempGreenClass, TempRedClass;
	if ( Level.NetMode != NM_Client )
	{
		if(Level.GreenTeamPawnClass != "none")
			TempGreenClass = class<R6Rainbow>(DynamicLoadObject(Level.GreenTeamPawnClass, class'Class'));
		if(TempGreenClass != none)
		{
			R6AbstractGameInfo(Level.Game).Find2DTexture(Level.GreenTeamPawnClass, Level.GreenMenuSkin, Level.GreenMenuRegion);
		}
		if(Level.RedTeamPawnClass != "none")
			TempRedClass = class<R6Rainbow>(DynamicLoadObject(Level.RedTeamPawnClass, class'Class'));
		if(TempRedClass != none)
		{
			R6AbstractGameInfo(Level.Game).Find2DTexture(Level.RedTeamPawnClass, Level.RedMenuSkin, Level.RedMenuRegion);
		}
		ClientSetMultiplayerSkins( Level.GreenTeamPawnClass, Level.RedTeamPawnClass, Level.GreenMenuSkin, Level.GreenMenuRegion, Level.RedMenuSkin, Level.RedMenuRegion);
	}
}

//------------------------------------------------------------------
// ClientSetMultiplayerSkins
//	Server set the skin on the client
//------------------------------------------------------------------
simulated function ClientSetMultiplayerSkins( string g, string r, 
											 Material GreenMenuSkin, Object.Region GreenMenuRegion, 
											 Material RedMenuSkin, Object.Region RedMenuRegion)
{
	local class<Pawn> TempGreenClass;
	local class<Pawn> TempRedClass;

	Level.GreenTeamPawnClass = g;
	Level.RedTeamPawnClass   = r;

	if(Level.NetMode == NM_Client)
	{
		if(Level.GreenTeamPawnClass != "none")
			TempGreenClass = class<Pawn>(DynamicLoadObject(Level.GreenTeamPawnClass, class'Class'));
		if(TempGreenClass != none)
		{
			Level.GreenTeamSkin = TempGreenClass.default.Skins[0];
			Level.GreenHeadSkin = TempGreenClass.default.Skins[1];
			Level.GreenGogglesSkin = TempGreenClass.default.Skins[2];
			Level.GreenHandSkin = TempGreenClass.default.Skins[5];
			Level.GreenMesh = TempGreenClass.default.Mesh;
			Level.GreenHelmet = TempGreenClass.default.m_HelmetClass;
			if(Level.GreenHelmet != none)
			{
				Level.GreenHelmetMesh = Level.GreenHelmet.default.StaticMesh;
				Level.GreenHelmetSkin = Level.GreenHelmet.default.Skins[0];
			}
		}

		if(Level.RedTeamPawnClass != "none")
			TempRedClass = class<Pawn>(DynamicLoadObject(Level.RedTeamPawnClass, class'Class'));
		if(TempRedClass != none)
		{
			Level.RedTeamSkin = TempRedClass.default.Skins[0];
			Level.RedHeadSkin = TempRedClass.default.Skins[1];
			Level.RedGogglesSkin = TempRedClass.default.Skins[2];
			Level.RedHandSkin = TempRedClass.default.Skins[5];
			Level.RedMesh = TempRedClass.default.Mesh;
			Level.RedHelmet = TempRedClass.default.m_HelmetClass;
			if(TempRedClass.default.m_HelmetClass != none)
			{
				Level.RedHelmetMesh = Level.RedHelmet.default.StaticMesh;
				Level.RedHelmetSkin = Level.RedHelmet.default.Skins[0];
			}
		}
	}

	Level.GreenMenuSkin = GreenMenuSkin;
	Level.GreenMenuRegion = GreenMenuRegion;
	Level.RedMenuSkin = RedMenuSkin;
	Level.RedMenuRegion = RedMenuRegion;
}


function ClientStopFadeToBlack()
{
    if((myHUD != none) && (Viewport(Player) != none))
    {
        R6AbstractHUD(myHUD).StopFadeToBlack();
    }
}

function addToOxygenLevel(float f);

function CountDownPopUpBox()
{
    if (m_MenuCommunication!=none)
        m_MenuCommunication.CountDownPopUpBox();
}

function CountDownPopUpBoxDone()
{
    if (m_MenuCommunication!=none)
        m_MenuCommunication.CountDownPopUpBoxDone();
}

exec function MyID()
{
    Player.Console.Message( m_GameService.MyID(), 6.0 );
}

function ClientChatDisabledMsg(INT iTimeRem)
{
	ClientMessage(Localize("Game", "ChatDisabledMessage1", "R6GameInfo") @ iTimeRem @ Localize("Game", "ChatDisabledMessage2", "R6GameInfo"));
}

function ClientChatAbuseMsg(INT iChatLockDuration)
{
	ClientMessage(Localize("Game", "AbuseDetectedMessage1", "R6GameInfo") @ iChatLockDuration @ Localize("Game", "AbuseDetectedMessage2", "R6GameInfo"));
}

// Send a message to all players.
exec function Say( string Msg )
{
	//R6CODE
	local R6ServerInfo pServerInfo;

    if(Msg == "" || Level.NetMode == NM_Standalone)
        return;

    pServerInfo = class'Actor'.static.GetServerOptions();

	//Note : This code assumes that the related variables are reseted simultaneously with "Level.TimeSeconds"

	//Check for no Spamming
	if(m_fPreviousBroadCastTimeStamp <= (Level.TimeSeconds - pServerInfo.SpamThreshold)) 
	{
		//Check for ChatLock inactive
		if(Level.TimeSeconds >= m_fEndOfChatLockTime) 
		{
			//Legit Broadcast
			m_fPreviousBroadCastTimeStamp = m_fLastBroadCastTimeStamp;
			m_fLastBroadCastTimeStamp = Level.TimeSeconds;
			Level.Game.Broadcast(self, Msg , 'Say');
		}
		else //ChatLock active
		{
			ClientChatDisabledMsg(m_fEndOfChatLockTime - Level.TimeSeconds);
		}
	}
	else //Spam detected
	{
		//Engage ChatLock
		m_fEndOfChatLockTime = Level.TimeSeconds + pServerInfo.ChatLockDuration;
		m_fPreviousBroadCastTimeStamp = -99.0;
		m_fLastBroadCastTimeStamp = -99.0;
		
		//DEBUG
		ClientChatAbuseMsg(pServerInfo.ChatLockDuration);
	}
}

exec function TeamSay( string Msg )
{
	//R6CODE
	local R6ServerInfo pServerInfo;

    if(Msg == "" || Level.NetMode == NM_Standalone)
        return;

    pServerInfo = class'Actor'.static.GetServerOptions();

	//Note : This code assumes that the related variables are reseted simultaneously with "Level.TimeSeconds"

	//Check for no Spamming
	if(m_fPreviousBroadCastTimeStamp <= (Level.TimeSeconds - pServerInfo.SpamThreshold)) 
	{
		//Check for ChatLock inactive
		if(Level.TimeSeconds >= m_fEndOfChatLockTime) 
		{
			//Legit Broadcast
			m_fPreviousBroadCastTimeStamp = m_fLastBroadCastTimeStamp;
			m_fLastBroadCastTimeStamp = Level.TimeSeconds;
			Level.Game.BroadcastTeam(self, Msg, 'TeamSay');
		}
		else //ChatLock active
		{
			ClientChatDisabledMsg(m_fEndOfChatLockTime - Level.TimeSeconds);
		}
	}
	else //Spam detected
	{
		//Engage ChatLock
		m_fEndOfChatLockTime = Level.TimeSeconds + pServerInfo.ChatLockDuration;
		m_fPreviousBroadCastTimeStamp = -99.0;
		m_fLastBroadCastTimeStamp = -99.0;
		
		ClientChatAbuseMsg(pServerInfo.ChatLockDuration);
	}
}

event string GetLocalPlayerIp()
{
    return WindowConsole(Player.Console).szStoreIP;
}

exec function HideWeapon()
{
    if(R6GameReplicationInfo(GameReplicationInfo).m_bFFPWeapon == false)
    {
        m_GameOptions.HUDShowFPWeapon = false;
        m_bShowFPWeapon = false;
        R6AbstractWeapon(Pawn.m_WeaponsCarried[0]).R6SetReticule(self);
        R6AbstractWeapon(Pawn.m_WeaponsCarried[1]).R6SetReticule(self);
    }
}

defaultproperties
{
     m_iDoorSpeed=20
     m_iFastDoorSpeed=100
     m_iFluidMovementSpeed=900
     m_iSpeedLevels(0)=7500
     m_iSpeedLevels(1)=15500
     m_iSpeedLevels(2)=23500
     m_iReturnSpeed=3000
     m_bShowFPWeapon=True
     m_bShakeActive=True
     m_bUseFirstPersonWeapon=True
     m_bAttachCameraToEyes=True
     m_bCameraGhost=True
     m_bCameraFirstPerson=True
     m_bCameraThirdPersonFixed=True
     m_bCameraThirdPersonFree=True
     m_bFadeToBlack=True
     m_bSpectatorCameraTeamOnly=True
     m_bCanChangeMember=True
     m_fTeamMoveToDistance=6000.000000
     m_fDesignerSpeedFactor=1.000000
     m_fDesignerJumpFactor=1.000000
     m_fMilestoneMessageDuration=2.000000
     LastDoorUpdateTime=1.000000
     m_sndUpdateWritableMap=Sound'Common_Multiplayer.Play_DrawingTool_Receive'
     m_sndDeathMusic=Sound'Music.Play_themes_Death'
     m_sndMissionComplete=Sound'Voices_Control_MissionSuccess.Play_Control_MissionCompleted'
     m_stImpactHit=(iBlurIntensity=10,fRollMax=300.000000,fRollSpeed=5000.000000,fReturnTime=0.250000)
     m_stImpactStun=(iBlurIntensity=20,fRollMax=500.000000,fRollSpeed=5000.000000,fReturnTime=0.300000)
     m_stImpactDazed=(iBlurIntensity=40,fRollMax=1000.000000,fRollSpeed=7500.000000,fReturnTime=0.400000)
     m_stImpactKO=(iBlurIntensity=75,fWaveTime=2.000000,fRollMax=1500.000000,fRollSpeed=8000.000000,fReturnTime=0.500000)
     m_SpectatorColor=(B=255,G=255,R=255,A=210)
     m_szLastAdminPassword="111"
     EnemyTurnSpeed=100000
     DesiredFOV=90.000000
     DefaultFOV=90.000000
     CheatClass=Class'R6Engine.R6CheatManager'
     InputClass=Class'R6Engine.R6PlayerInput'
     m_bFirstTimeInZone=True
}
