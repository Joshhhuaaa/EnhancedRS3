//=============================================================================
//  R6GameInfo.uc : This is class where all the Rainbow game rules will be defined.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/20 * Created by Rima Brek
//    2001/05/25 * Joel Tremblay added the heat textures initialisation
//    2001/07/31 * Chaouky Garram added the game mode and the TeamInfo
//============================================================================//
class R6GameInfo extends R6AbstractGameInfo
    native;

#exec OBJ LOAD FILE=..\Textures\Inventory_t.utx

import class R6NoiseMgr;

//var             R6RainbowTeam           m_RainbowTeam[3];     // TeamAI for blue team (player's & AI led team)
//var             R6RainbowTeam         m_RainbowPlayerTeam;   // assigned to the above team that the player is leading...

var             byte                    R6DefaultWeaponInput;

var             R6CommonRainbowVoices       m_CommonRainbowPlayerVoicesMgr;
var             R6CommonRainbowVoices       m_CommonRainbowMemberVoicesMgr;
var             R6RainbowPlayerVoices       m_RainbowPlayerVoicesMgr;
var             R6RainbowMemberVoices       m_RainbowMemberVoicesMgr;
var             Array<R6RainbowOtherTeamVoices> m_RainbowOtherTeamVoicesMgr;
var             Array<R6MultiCoopVoices>    m_MultiCoopPlayerVoicesMgr;
var             R6MultiCoopVoices           m_MultiCoopMemberVoicesMgr;
var             R6PreRecordedMsgVoices      m_PreRecordedMsgVoicesMgr;
var             R6MultiCommonVoices         m_MultiCommonVoicesMgr;


var             Array<R6TerroristVoices>    m_TerroristVoicesMgr;
var             Array<R6HostageVoices>      m_HostageVoicesMaleMgr;
var             Array<R6HostageVoices>      m_HostageVoicesFemaleMgr;
var             Array<R6Terrorist>          m_listAllTerrorists;

var(Debug)      BOOL                    bShowLog;
var             INT                     m_iCurrentID;
var				INT						m_iMaxOperatives; // max of operatives available for a mission in single player
var             UWindowRootWindow.eGameWidgetID           m_eEndGameWidgetID;
var NavigationPoint LastStartSpot;          // last place any player started from

const CMaxRainbowAI =  6;
var				Array<R6RainbowAI>			m_RainbowAIBackup;

//#ifdef R6Cheat
var bool bNoRestart;    //AK: this is a cheat
//#endif

var bool m_bServerAllowRadarRep;  // replicated bool 
var bool m_bRepAllowRadarOption;
var bool m_bIsRadarAllowed;       // in some game type, the radar can't be used (ie: deathmatch)
var bool m_bIsWritableMapAllowed; // in some game type, the writablemap can't be used (ie: deathmatch)
var bool m_bUsingPlayerCampaign;  //A game mode with this set to true allows saving through a player campaign
var bool m_bUsingCampaignBriefing; //A game mode with this set to true allows having sweeney and clark briefing
var bool m_bUnlockAllDoors;         // a game mode can forces to unlock all doors

var             FLOAT           m_fRoundStartTime;   // this is the time that the round will start at
var             FLOAT           m_fRoundEndTime;
var             FLOAT           m_fPausedAtTime;    // count down paused at time


// used in conjunction with the admin Map command
var bool m_bJumpingMaps;
var int m_iJumpMapIndex;

// Variables used to hold information passed via the command line options string
var string m_szMessageOfDay;    // Message of the day passed as comand line argument
var string m_szSvrName;         // Server name passed as comand line argument

var INT    m_iRoundsPerMatch;   // number of rounds in each match/map
//var FLOAT  m_fMapTimeLimit;     // Time limit per map (seconds)
var INT    m_iDeathCameraMode;  // Camera Mode used when plyer dead
var array<string>   m_mapList;      // List of maps in multi player mode
var array<string>   m_gameModeList; // list of game modes used in multi player mode
var INT    m_iSubMachineGunsResMask;
var INT    m_iShotGunResMask;       // Primary weapon: Shotguns restricted
var INT    m_iAssRifleResMask;      // Primary weapon: Assault rifles restricted
var INT    m_iMachGunResMask;       // Primary weapon: Machine Guns restricted
var INT    m_iSnipRifleResMask;     // Primary weapon: Sniper rifles restricted
var INT    m_iPistolResMask;        // Secondary weapon: Pistols restricted
var INT    m_iMachPistolResMask;    // Secondary weapon: Machine pistols restricted
var INT    m_iGadgPrimaryResMask;     // Gadget: primary weapon restricted
var INT    m_iGadgSecondaryResMask;  // Gadget: secondary restricted
var INT    m_iGadgMiscResMask;        // Gadget: misceleaneous restricted

var FLOAT  m_fBombTime;
var FLOAT  m_fInGameStartTime;

// These variables can be set in the menus, but the results are not yet 
// integrated in the game.
// *** and there's some in r6AbstractGameInfo
var BOOL   m_bAutoBalance;
var BOOL   m_bTKPenalty;
var BOOL   m_bPWSubMachGunRes;    // Primary weapon: Sub machine guns restricted
var BOOL   m_bPWShotGunRes;       // Primary weapon: Shotguns restricted
var BOOL   m_bPWAssRifleRes;      // Primary weapon: Assault rifles restricted
var BOOL   m_bPWMachGunRes;       // Primary weapon: Machine Guns restricted
var BOOL   m_bPWSnipRifleRes;     // Primary weapon: Sniper rifles restricted
var BOOL   m_bSWPistolRes;        // Secondary weapon: Pistols restricted
var BOOL   m_bSWMachPistolRes;    // Secondary weapon: Machine pistols restricted
var BOOL   m_bGadgPrimaryRes;     // Gadget: primary weapon restricted
var BOOL   m_bGadgSecondayRes;    // Gadget: secondary restricted
var BOOL   m_bGadgMiscRes;        // Gadget: misceleaneous restricted
var BOOL   m_bShowNames;		  // show the name of players (enemies or not)
var BOOL   m_bFFPWeapon;          // Force first person weapons
var BOOL   m_bAdminPasswordReq;   // Administration password required
var BOOL   m_bAIBkp;			  // AI backup
var BOOL   m_bRotateMap;		  // in coop, rotate map automatically if it's true
var BOOL   m_bFadeStarted;        // in single player before the DebriefingWidget stat the fade
var byte   m_bCurrentFemaleId;
var byte   m_bCurrentMaleId;
var byte   m_bRainbowFaces[30]; 

#ifndefSPDEMO
var R6GSServers m_GameService;      // Manages servers from game service
var R6GSServers m_PersistantGameService;
#endif

var INT    m_iNbOfRestart;
var INT    m_iIDVoicesMgr;
var INT    m_iUbiComGameMode;

var bool   m_bFeedbackHostageKilled;
var bool   m_bFeedbackHostageExtracted;
var bool   m_bStopPostBetweenRoundCountdown;

var Material DefaultFaceTexture;
var Plane    DefaultFaceCoords;
var class<HUD> m_HudClass;

const CMaxPlayers   =  16;      // the absolut maximum number of players that we allow
const CMaxCoOpPlayers =  8;
const K_InGamePauseTime   = 5;    // how long do we want to pause for loading the pawns

native(2010) final function bool SetController(PlayerController pController, Player pPlayer);
native(1504) final function GetSystemUserName(OUT string szUserName );
native(1502) final function NativeLogout(PlayerController Exiting);
native(1240) final function InitScoreSubmission(BOOL _bStatsSetting);
native(1241) final function SubmissionSrvRoundStart();
native(1242) final function BOOL SubmissionNotifySendStartMatch();
native(1243) final function SubmissionSrvRoundFinish();
native(1244) final function LogoutUpdatePlayersCtrlInfo(Controller Exiting);
native(1245) final function BOOL SubmissionUpdateLadderStat();

function SetUdpBeacon(InternetInfo _udpBeacon)
{
#ifndefSPDEMO
    m_UdpBeacon = UdpBeacon(_udpBeacon);
#endif
}

function GetNbHumanPlayerInTeam( OUT int iAlphaNb, OUT int iBravoNb );

simulated function FirstPassReset()
{
    local int i;

    // reset missiob mgr (remove referenced to actor)
    if ( m_missionMgr != none )
    {
        for ( i = 0; i < m_missionMgr.m_aMissionObjectives.Length; ++i )
            m_missionMgr.m_aMissionObjectives[i].Reset();

        m_missionMgr.SetMissionObjStatus( eMissionObjStatus_none );
    }
    ResetRepMissionObjectives();
       
    m_listAllTerrorists.Remove( 0, m_listAllTerrorists.Length );
	
	if(m_RainbowAIBackup.Length > 0)
		m_RainbowAIBackup.Remove( 0, m_RainbowAIBackup.Length ); 
}


function R6AbstractInsertionZone GetAStartSpot()
{
	local R6AbstractInsertionZone aZone;

    foreach AllActors( class'R6AbstractInsertionZone', aZone )
    {
        if (aZone.IsAvailableInGameType( m_szGameTypeFlag ))
        {
            return aZone;
        }
    }
    return none;
}




function Object GetRainbowTeam(INT eTeamName)
{
    return R6GameReplicationInfo(GameReplicationInfo).m_RainbowTeam[eTeamName];
}

function SetRainbowTeam(INT eTeamName, R6RainbowTeam newTeam)
{
    R6GameReplicationInfo(GameReplicationInfo).m_RainbowTeam[eTeamName] = newTeam;
}

// AK: yes we are using this function. 01/Feb/2002
//function AcceptInventory(pawn PlayerPawn)
simulated event AcceptInventory(pawn PlayerPawn)
{
    local PlayerController.PlayerPrefInfo m_PlayerPrefs;
    local R6Pawn aPawn;
    local R6Rainbow aRainbow;
    local string szSecWeapon, caps_szSecGadget;

    aPawn = R6Pawn(PlayerPawn);

    if ((aPawn != none) && (aPawn.EngineWeapon == None))
    {
        m_PlayerPrefs = PlayerController(aPawn.Controller).m_PlayerPrefs;

        if (!IsPrimaryWeaponRestrictedToPawn( aPawn ) &&
            (m_PlayerPrefs.m_WeaponName1 != "") &&
            !IsPrimaryWeaponRestricted(m_PlayerPrefs.m_WeaponName1))
        {
            if(bShowLog)log("NOW GIVING "$m_PlayerPrefs.m_WeaponName1  $" to "$ aPawn.Controller);
            if ( (m_PlayerPrefs.m_WeaponGadgetName1 != "") &&
                IsPrimaryGadgetRestricted(m_PlayerPrefs.m_WeaponGadgetName1))
            {
                aPawn.ServerGivesWeaponToClient(m_PlayerPrefs.m_WeaponName1, 1, m_PlayerPrefs.m_BulletType1);
            }
            else
            {
                aPawn.ServerGivesWeaponToClient(m_PlayerPrefs.m_WeaponName1, 1,
                    m_PlayerPrefs.m_BulletType1,  m_PlayerPrefs.m_WeaponGadgetName1);
            }
			
			if(bShowLog) log("AcceptInventory PrimaryWeapon ="@ m_PlayerPrefs.m_WeaponName1);
        }

        if ( !IsSecondaryWeaponRestrictedToPawn( aPawn ) &&
            (m_PlayerPrefs.m_WeaponName2 != "") )
        {

            if( IsSecondaryWeaponRestricted(m_PlayerPrefs.m_WeaponName2) )
                szSecWeapon = "R63rdWeapons.NormalPistol92FS";  // Default weapon is NormalPistol92FS
            else
                szSecWeapon = m_PlayerPrefs.m_WeaponName2;

            if(bShowLog) log("NOW GIVING "$szSecWeapon  $" to "$ aPawn.Controller);
            if ((m_PlayerPrefs.m_WeaponGadgetName2 != "") &&
                IsSecondaryGadgetRestricted(m_PlayerPrefs.m_WeaponGadgetName2))
            {
		        aPawn.ServerGivesWeaponToClient(szSecWeapon, 2, m_PlayerPrefs.m_BulletType2);
            }
            else
            {
                aPawn.ServerGivesWeaponToClient(szSecWeapon, 2, 
                    m_PlayerPrefs.m_BulletType2,  m_PlayerPrefs.m_WeaponGadgetName2);
            }
			if(bShowLog) log("AcceptInventory SecondaryWeapon = "$ szSecWeapon);
        }

        // MPF1
        if ( !IsTertiaryWeaponRestrictedToPawn( aPawn ) &&
            (m_PlayerPrefs.m_GadgetName1 != "") &&
             !IsTertiaryWeaponRestricted(m_PlayerPrefs.m_GadgetName1) &&
             !IsTertiaryWeaponRestrictedForGameplay(aPawn,m_PlayerPrefs.m_GadgetName1)
           )
        {
            if(bShowLog) log(" AND "$ m_PlayerPrefs.m_GadgetName1 $"  (gadget 1)");
		    aPawn.ServerGivesWeaponToClient(m_PlayerPrefs.m_GadgetName1, 3);
			if(bShowLog) log("AcceptInventory GadgetOne = " $ m_PlayerPrefs.m_GadgetName1);
        }

        // MPF1
        if ( !IsTertiaryWeaponRestrictedToPawn( aPawn ) &&
            (m_PlayerPrefs.m_GadgetName2 != "") &&
             !IsTertiaryWeaponRestricted(m_PlayerPrefs.m_GadgetName2) &&
             !IsTertiaryWeaponRestrictedForGameplay(aPawn,m_PlayerPrefs.m_GadgetName2)
           )
        {
            if(bShowLog) log(" AND "$ m_PlayerPrefs.m_GadgetName2 $"  (gadget 2)");
            caps_szSecGadget = caps(m_PlayerPrefs.m_GadgetName2);
            if( (caps_szSecGadget != "PRIMARYMAGS") && 
                (caps_szSecGadget != "SECONDARYMAGS" ) &&
                (caps_szSecGadget == caps(m_PlayerPrefs.m_GadgetName1)))
    		    aPawn.ServerGivesWeaponToClient("DoubleGadget", 4);
            else
                aPawn.ServerGivesWeaponToClient(m_PlayerPrefs.m_GadgetName2, 4);
			if(bShowLog) log("AcceptInventory GadgetTwo = " $ m_PlayerPrefs.m_GadgetName2);
        }


        aRainbow = R6Rainbow(PlayerPawn);
        if (aRainbow != none)
        {
            aRainbow.m_szPrimaryWeapon = m_PlayerPrefs.m_WeaponName1;
            aRainbow.m_szSecondaryWeapon = szSecWeapon;
            aRainbow.m_szPrimaryItem = m_PlayerPrefs.m_GadgetName1;
            aRainbow.m_szSecondaryItem = m_PlayerPrefs.m_GadgetName2;
        }

        if ( Level.NetMode == NM_ListenServer )
        {
            aPawn.ReceivedWeapons();
        }
    }
}

//------------------------------------------------------------------
// IsPrimaryWeaponRestrictedToPawn
//	
//------------------------------------------------------------------
function bool IsPrimaryWeaponRestrictedToPawn( Pawn aPawn )
{
    return false;
}

//------------------------------------------------------------------
// IsSecondaryWeaponRestrictedToPawn
//	
//------------------------------------------------------------------
function bool IsSecondaryWeaponRestrictedToPawn( Pawn aPawn )
{
    return false;
}

//------------------------------------------------------------------
// IsTertiaryWeaponRestrictedToPawn
//	
//------------------------------------------------------------------
function bool IsTertiaryWeaponRestrictedToPawn( Pawn aPawn )
{
    return false;
}

// MPF1
///////////////Begin MissionPack1
///////////////////////////
function bool IsTertiaryWeaponRestrictedForGamePlay(Pawn aPawn, string szWeaponName)
{
	return false;
}
///////////////End MissionPack1
///////////////////////////


function bool IsPrimaryWeaponRestricted(string szWeaponName)
{
	local class<R6AbstractWeapon> WeaponClass;
    local R6GameReplicationInfo _GRI;
    local string WeaponClassNameId;
    
    _GRI = R6GameReplicationInfo(GameReplicationInfo);

	if (InStr(szWeaponName, "PrimaryWeaponNone") != -1)
		return true; // if we not have a primary weapon, the szWeaponName is R6DescPrimaryWeaponNone

    WeaponClass = class<R6AbstractWeapon>(DynamicLoadObject(szWeaponName, class'Class'));
    WeaponClassNameId = WeaponClass.default.m_NameId;

    if (IsInResArray(WeaponClassNameId, _GRI.m_szSubMachineGunsRes) ||
        IsInResArray(WeaponClassNameId, _GRI.m_szShotGunRes)        ||
        IsInResArray(WeaponClassNameId, _GRI.m_szAssRifleRes)       ||
        IsInResArray(WeaponClassNameId, _GRI.m_szMachGunRes)        ||
        IsInResArray(WeaponClassNameId, _GRI.m_szSnipRifleRes))
    {
        if (bShowLog) log(szWeaponName$" is restricted and will not be spawned");
        return true;
    }
    return false;
}


function bool IsPrimaryGadgetRestricted(string szWeaponGadgetName)
{
    local int i;
    local R6GameReplicationInfo _GRI;
	local class<R6AbstractGadget> WeaponGadgetClass;
    local string RequestedGadget;
    
	if (szWeaponGadgetName == "")
		return true; // if we not have a gadget, the szWeaponName is empty

    WeaponGadgetClass = class<R6AbstractGadget>(DynamicLoadObject(szWeaponGadgetName, class'Class'));
    RequestedGadget = WeaponGadgetClass.default.m_NameId;

    _GRI = R6GameReplicationInfo(GameReplicationInfo);

    if (IsInResArray(RequestedGadget, _GRI.m_szGadgPrimaryRes))
    {
        return true;
    }
    return false;
}

function bool IsSecondaryGadgetRestricted(string szWeaponGadgetName)
{
    local int i;
    local R6GameReplicationInfo _GRI;
	local class<R6AbstractGadget> WeaponGadgetClass;
    local string RequestedGadget;
    
#ifdefDEBUG
	if (bShowLog) log("IsSecondaryGadgetRestricted szWeaponGadgetName: "@szWeaponGadgetName);
#endif

	if (szWeaponGadgetName == "")
		return true; // if we not have a gadget, the szWeaponName is empty

    WeaponGadgetClass = class<R6AbstractGadget>(DynamicLoadObject(szWeaponGadgetName, class'Class'));
    RequestedGadget = WeaponGadgetClass.default.m_NameId;

    _GRI = R6GameReplicationInfo(GameReplicationInfo);
    if (IsInResArray(RequestedGadget, _GRI.m_szGadgSecondayRes))
    {
        if (bShowLog) log(szWeaponGadgetName$" is restricted and will not be spawned");
        return true;
    }
    return false;
}

function bool IsSecondaryWeaponRestricted(string szWeaponName)
{
    local int i;
    local R6GameReplicationInfo _GRI;
	local class<R6AbstractWeapon> WeaponClass;
    local string RequestedWeapon;
    local   class<R6SecondaryWeaponDescription> SecondaryWeaponClass;

    _GRI = R6GameReplicationInfo(GameReplicationInfo);

#ifdefDEBUG
	if (bShowLog) log("IsSecondaryWeaponRestricted szWeaponName: "@szWeaponName);
#endif

    WeaponClass = class<R6AbstractWeapon>(DynamicLoadObject(szWeaponName, class'Class'));
    RequestedWeapon = WeaponClass.default.m_NameId;

    if (IsInResArray(RequestedWeapon, _GRI.m_szPistolRes) ||
        IsInResArray(RequestedWeapon, _GRI.m_szMachPistolRes))
    {
        if (bShowLog) log(szWeaponName$" is restricted and will not be spawned");
        return true;
    }
    return false;
}

// granades, frags, flashbangs, HB sensors etc
function bool IsTertiaryWeaponRestricted(string szWeaponName)
{
    local int i;
    local R6GameReplicationInfo _GRI;
	local class<R6AbstractWeapon> WeaponClass;
    local string RequestedWeapon;
    local   class<R6SecondaryWeaponDescription> SecondaryWeaponClass;
    local   class<R6GadgetDescription>          _GadgetClass;

    _GRI = R6GameReplicationInfo(GameReplicationInfo);

#ifdefDEBUG
	if (bShowLog) log("IsTertiaryWeaponRestricted szWeaponName: "@szWeaponName);
#endif

	if (szWeaponName == "")
		return true; // if we not have a gadget, the szWeaponName is empty

	if (class<R6AbstractWeapon>(FindObject( szWeaponName, class'Class')) != None)
	{
    WeaponClass = class<R6AbstractWeapon>(DynamicLoadObject(szWeaponName, class'Class'));
	if(WeaponClass == none)
		return false;

    RequestedWeapon = WeaponClass.default.m_NameId;
	}
	else
	{
		RequestedWeapon = szWeaponName;
	}

    if (IsInResArray(RequestedWeapon, _GRI.m_szGadgMiscRes))
    {
        if (bShowLog) log(szWeaponName$" is restricted and will not be spawned");
        return true;
    }
    return false;
}

function bool IsInResArray(string szWeaponNameId, string RestrictionArray[32])
{
    local int i;

    for( i = 0; (i < arraycount(RestrictionArray)) && (RestrictionArray[i] != ""); i++ )
    {
        if (RestrictionArray[i] ~= szWeaponNameId) // test not case sensitive!!!
        {
            if (bShowLog) log(szWeaponNameId$" is restricted and will not be spawned");
            return true;
        }
    }
    return false;
}

//============================================================================
// PostBeginPlay - 
//============================================================================
function PostBeginPlay()
{
    local R6DeploymentZone      pZone;
    local INT                   i;
    local BOOL                  bFound;

    local array<string>                         AGadgetNameID;
    local R6ServerInfo  pServerOptions;

#ifdefSPDEMO
    if ( !(m_szGameTypeFlag == "RGM_PracticeMode" ||
           m_szGameTypeFlag == "RGM_TerroristHuntMode" ||
		   m_szGameTypeFlag == "RGM_HostageRescueMode" ||
           m_szGameTypeFlag == "RGM_LoneWolfMode") ) 

    {
        // wrong game mode, crash baby, crash!
        while( true )
            i++;
    }
#endif
    
#ifdefMPDEMO
    if ( !(m_szGameTypeFlag == "RGM_DeathmatchMode"    ||
           m_szGameTypeFlag == "RGM_TeamDeathmatchMode" ||
		   m_szGameTypeFlag == "RGM_EscortAdvMode") ) 
    {
        // wrong game mode, crash baby, crash!
        while( true )
            i++;
    }

#endif

    Super.PostBeginPlay();

	pServerOptions = class'Actor'.static.GetServerOptions();
    Level.m_ServerSettings = pServerOptions;

    CreateMissionObjectiveMgr();
	m_missionMgr.m_bEnableCheckForErrors = false;
    InitObjectives();
    
    if( Level.NetMode != NM_Standalone )
    {
		R6GameReplicationInfo(GameReplicationInfo).m_iMapIndex = GetCurrentMapNum();
    }
    R6GameReplicationInfo(GameReplicationInfo).m_szGameTypeFlagRep=m_szGameTypeFlag;	
    R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode = m_iDeathCameraMode;

    // Set the server name
#ifndefSPDEMO
    if ( ( Level.NetMode == NM_DedicatedServer ) || ( Level.NetMode == NM_ListenServer ) )
    {
        bPauseable = False; //pausing in multiplayer causes the client to crash

        m_szSvrName = left( pServerOptions.ServerName, m_GameService.GetMaxUbiServerNameSize() );
        if ( m_szSvrName != "" )
            GameReplicationInfo.ServerName = m_szSvrName;
    }
#endif

    // Set misc information
//    R6GameReplicationInfo(GameReplicationInfo).m_fTimeMap       = m_fMapTimeLimit;
    R6GameReplicationInfo(GameReplicationInfo).m_iRoundsPerMatch = m_iRoundsPerMatch;
	R6GameReplicationInfo(GameReplicationInfo).m_iDiffLevel		= m_iDiffLevel;
	R6GameReplicationInfo(GameReplicationInfo).m_iNbOfTerro		= m_iNbOfTerroristToSpawn;
    R6GameReplicationInfo(GameReplicationInfo).m_fTimeBetRounds = m_fTimeBetRounds;
    R6GameReplicationInfo(GameReplicationInfo).m_bPasswordReq   = AccessControl.GamePasswordNeeded();
    R6GameReplicationInfo(GameReplicationInfo).m_bFriendlyFire  = m_bFriendlyFire;
    R6GameReplicationInfo(GameReplicationInfo).m_bAutoBalance   = m_bAutoBalance;
    R6GameReplicationInfo(GameReplicationInfo).m_bMenuTKPenaltySetting = m_bTKPenalty;
    m_bTKPenalty = (m_bTKPenalty && Level.IsGameTypeTeamAdversarial(m_szGameTypeFlag));
    R6GameReplicationInfo(GameReplicationInfo).m_bTKPenalty     = m_bTKPenalty;
    R6GameReplicationInfo(GameReplicationInfo).m_bShowNames     = m_bShowNames;
    R6GameReplicationInfo(GameReplicationInfo).m_MaxPlayers     = MaxPlayers;
    R6GameReplicationInfo(GameReplicationInfo).m_fBombTime      = m_fBombTime;
    R6GameReplicationInfo(GameReplicationInfo).m_bInternetSvr   = m_bInternetSvr;
    R6GameReplicationInfo(GameReplicationInfo).m_bFFPWeapon     = m_bFFPWeapon;
    R6GameReplicationInfo(GameReplicationInfo).m_bAIBkp			= m_bAIBkp;
    R6GameReplicationInfo(GameReplicationInfo).m_bRotateMap		= m_bRotateMap;
    R6GameReplicationInfo(GameReplicationInfo).m_bAdminPasswordReq = m_bAdminPasswordReq;
    R6GameReplicationInfo(GameReplicationInfo).m_bDedicatedSvr  = ( Level.NetMode == NM_DedicatedServer );
    // WritableMap
    R6GameReplicationInfo(GameReplicationInfo).m_bIsWritableMapAllowed = m_bIsWritableMapAllowed;
//#ifdefR6PUNKBUSTER
	R6GameReplicationInfo(GameReplicationInfo).m_bPunkBuster	= IsPBServerEnabled();
//#endif

    // Add the sound bank for the DrawingTools
    if (m_bIsWritableMapAllowed)
        AddSoundBankName("Common_Multiplayer");

    // Needed to reset message flooding
    SetTimer(2.0f, true);

    for ( i = 0; i < R6GameReplicationInfo(GameReplicationInfo).m_MapLength; i++ )
    {
        if ( i < m_mapList.length )
            R6GameReplicationInfo(GameReplicationInfo).m_mapArray[i] = m_mapList[i];
        else
            R6GameReplicationInfo(GameReplicationInfo).m_mapArray[i] = "";

        if ( i < m_gameModeList.length )
            R6GameReplicationInfo(GameReplicationInfo).m_gameModeArray[i] = m_gameModeList[i];
        else
            R6GameReplicationInfo(GameReplicationInfo).m_gameModeArray[i] = "";
    }    

    UpdateRepResArrays();

#ifndefSPDEMO
    if (Level.NetMode == NM_DedicatedServer)
    {
        m_PersistantGameService = m_GameService;
    }
    else if (Level.NetMode == NM_ListenServer)
    {
        m_PersistantGameService = R6Console(class'Actor'.static.GetCanvas().Viewport.Console).m_GameService;
    }
#endif
}

function UpdateRepResArrays()
{
    local class<R6SubGunDescription>            SubGunClass;
    local class<R6ShotgunDescription>           ShotGunClass;
    local class<R6AssaultDescription>           AssaultRifleClass;
    local class<R6LMGDescription>               MachGunClass;
    local class<R6SniperDescription>            SniperRifleClass;
    local class<R6PistolsDescription>           PistolClass;
    local class<R6MachinePistolsDescription>    MachPistolClass;
    local class<R6WeaponGadgetDescription>      PriGadgClass;
    local class<R6WeaponGadgetDescription>      SecGadgClass;
    local class<R6GadgetDescription>            MiscGadgClass;
    local R6ServerInfo  pServerOptions;
    local INT                   i;
    local R6GameReplicationInfo _GRI;  // avoid casting all the time

    pServerOptions = Level.m_ServerSettings;

    _GRI = R6GameReplicationInfo(GameReplicationInfo);
    if (Level.NetMode != NM_Standalone)
    {
    //Insert All sub machine guns
        for ( i = 0; i < ArrayCount(_GRI.m_szSubMachineGunsRes); i++ )
        {
            _GRI.m_szSubMachineGunsRes[i] = "";
        }

        for (i=0; i < pServerOptions.RestrictedSubMachineGuns.length; i++)
        {
            SubGunClass = class<R6SubGunDescription>(DynamicLoadObject(""$pServerOptions.RestrictedSubMachineGuns[i], class'Class'));
            _GRI.m_szSubMachineGunsRes[i] = SubGunClass.Default.m_NameID;
        }


    //Insert All Shotgun restrictions 
        for ( i = 0; i < ArrayCount(_GRI.m_szShotGunRes); i++ )
        {
            _GRI.m_szShotGunRes[i] = "";
        }

        for (i=0; i < pServerOptions.RestrictedShotGuns.length; i++)
        {
            ShotGunClass = class<R6ShotgunDescription>(DynamicLoadObject(""$pServerOptions.RestrictedShotGuns[i], class'Class'));
            _GRI.m_szShotGunRes[i] = ShotGunClass.Default.m_NameID;    //pServerOptions.RestrictedShotGuns[i];
        }

    //Insert All Assault rifle restrictions
        for ( i = 0; i < ArrayCount(_GRI.m_szAssRifleRes); i++ )
        {
            _GRI.m_szAssRifleRes[i] = "";
        }
        
        for (i=0; i < pServerOptions.RestrictedAssultRifles.length; i++)
        {
            AssaultRifleClass = class<R6AssaultDescription>(DynamicLoadObject(""$pServerOptions.RestrictedAssultRifles[i], class'Class'));
            _GRI.m_szAssRifleRes[i] = AssaultRifleClass.Default.m_NameID;   //pServerOptions.RestrictedAssultRifles[i];
        }
        
    //Insert All Machine Gun restrictions
        for ( i = 0; i < ArrayCount(_GRI.m_szMachGunRes); i++ )
        {
            _GRI.m_szMachGunRes[i] = "";
        }

        for (i=0; i < pServerOptions.RestrictedMachineGuns.length; i++)
        {
            MachGunClass = class<R6LMGDescription>(DynamicLoadObject(""$pServerOptions.RestrictedMachineGuns[i], class'Class'));
            _GRI.m_szMachGunRes[i] = MachGunClass.Default.m_NameID;   //pServerOptions.RestrictedMachineGuns[i];
        }

    //Insert All Sniper rifle restrictions
        for ( i = 0; i < ArrayCount(_GRI.m_szSnipRifleRes); i++ )
        {
            _GRI.m_szSnipRifleRes[i] = "";
        }

        for (i=0; i < pServerOptions.RestrictedSniperRifles.length; i++)
        {
            SniperRifleClass = class<R6SniperDescription>(DynamicLoadObject(""$pServerOptions.RestrictedSniperRifles[i], class'Class'));
            _GRI.m_szSnipRifleRes[i] = SniperRifleClass.Default.m_NameID;   //pServerOptions.RestrictedSniperRifles[i];
        }

    //Insert All Pistol restrictions
        for ( i = 0; i < ArrayCount(_GRI.m_szPistolRes); i++ )
        {
            _GRI.m_szPistolRes[i] = "";
        }
        
        for (i=0; i < pServerOptions.RestrictedPistols.length; i++)
        {
            PistolClass = class<R6PistolsDescription>(DynamicLoadObject(""$pServerOptions.RestrictedPistols[i], class'Class'));
            _GRI.m_szPistolRes[i] = PistolClass.Default.m_NameID;   //pServerOptions.RestrictedPistols[i];
        }

    //Insert All Machine Pistol restrictions
        for ( i = 0; i < ArrayCount(_GRI.m_szMachPistolRes); i++ )
        {
            _GRI.m_szMachPistolRes[i] = "";
        }

        for (i=0; i < pServerOptions.RestrictedMachinePistols.length; i++)
        {
            MachPistolClass = class<R6MachinePistolsDescription>(DynamicLoadObject(""$pServerOptions.RestrictedMachinePistols[i], class'Class'));
            _GRI.m_szMachPistolRes[i] = MachPistolClass.Default.m_NameID;   //pServerOptions.RestrictedMachinePistols[i];
        }

    //Insert All Primary Weapon gadget restrictions
        for ( i = 0; i < ArrayCount(_GRI.m_szGadgPrimaryRes); i++ )
        {
            _GRI.m_szGadgPrimaryRes[i] = "";
        }

        for (i=0; i < pServerOptions.RestrictedPrimary.length; i++)
        {
            _GRI.m_szGadgPrimaryRes[i] = pServerOptions.RestrictedPrimary[i];
        }
        
    //Insert All Secondary Weapon gadget restrictions
        for ( i = 0; i < ArrayCount(_GRI.m_szGadgSecondayRes); i++ )
        {
            _GRI.m_szGadgSecondayRes[i] = "";
        }

        for (i=0; i < pServerOptions.RestrictedSecondary.length; i++)
        {
            _GRI.m_szGadgSecondayRes[i] = pServerOptions.RestrictedSecondary[i];
        }

    //Insert All Miscellaneous gadget restrictions
        for ( i = 0; i < ArrayCount(_GRI.m_szGadgMiscRes); i++ )
        {
            _GRI.m_szGadgMiscRes[i] = "";
        }

        for (i=0; i < pServerOptions.RestrictedMiscGadgets.length; i++)
        {
            _GRI.m_szGadgMiscRes[i] = pServerOptions.RestrictedMiscGadgets[i];
        }
    }
}

//============================================================================
// InitGame -  Initialize the game.
// The GameInfo's InitGame() function is called before any other scripts (including 
// PreBeginPlay() ), and is used by the GameInfo to initialize parameters and spawn 
// its helper classes.
// Warning: this is called before actors' PreBeginPlay.
//  restriction kit is taken care of in PostBeginPlay
//============================================================================
event InitGame( string Options, out string Error )
{
    local string         InOpt;         // Specific option extracted from option list
    local MapList        myList;        // Map list to cycle through
    local class<MapList> ML;            // Map list class
    local string         KeyName;       // Key name used in command line argument list (map0...map31)
    local INT            iCounter;      // Counter
    local R6ServerInfo  pServerOptions;
    
    pServerOptions = class'Actor'.static.GetServerOptions();
    if (pServerOptions == none)
    {
        pServerOptions = new class'R6ServerInfo';
    }
    pServerOptions.m_GameInfo = self;

    m_szGameOptions = Options;          // Store options for beacon to use

    Super.InitGame(  Options, Error );
    if (pServerOptions.m_ServerMapList==none)
    {
        myList = spawn(class'Engine.R6MapList');
        pServerOptions.m_ServerMapList=R6MapList(myList);
    }
    else
    {
        myList = pServerOptions.m_ServerMapList;
    }

    if ( BroadcastHandler == none )
    {
        log( "failed to create BroadcastHandlerClass="$BroadcastHandlerClass$ "  BroadcastHandler="$BroadcastHandler);
    }

    //-------------------------------------------------------------------------------
    // Extract information form the command line string and store in member variables
    //-------------------------------------------------------------------------------

    // Password

    if ( pServerOptions.UsePassword && pServerOptions.GamePassword != "" )
        AccessControl.SetGamePassWord( pServerOptions.GamePassword );

    // Maximum number of players

    MaxPlayers = Min(16,pServerOptions.MaxPlayers);

    // Message of the day
    m_szMessageOfDay = pServerOptions.MOTD;


    // Server name
    m_szSvrName = pServerOptions.ServerName;

    // Public Server
    m_bInternetSvr = pServerOptions.InternetServer;


    // Round time
    Level.m_fTimeLimit = pServerOptions.RoundTime;

    // Number of rounds per match
    m_iRoundsPerMatch = pServerOptions.RoundsPerMatch;

    // Time between rounds
    m_fTimeBetRounds = pServerOptions.BetweenRoundTime;

    // Bomb time
    m_fBombTime = pServerOptions.BombTime;

    // Friendly Fire
    m_bFriendlyFire = pServerOptions.FriendlyFire;
    
    // Auto balance teams
    m_bAutoBalance = pServerOptions.Autobalance;

    m_bAdminPasswordReq = pServerOptions.UseAdminPassword;

    // Force first person weapons
    m_bFFPWeapon = pServerOptions.ForceFPersonWeapon;

    // T.K. penalty
    m_bTKPenalty = pServerOptions.TeamKillerPenalty;

	// Show names
	m_bShowNames = pServerOptions.ShowNames;

	// AI BKP
	m_bAIBkp = pServerOptions.AIBkp;

	// Difficulty Level
    if( Level.NetMode == NM_Standalone )
    {
        if ( isA( 'R6TrainingMgr') )
            m_iDiffLevel = 1; // forces rookie when training so we see the key to press
        else
            m_iDiffLevel = class'Actor'.static.GetCanvas().Viewport.Console.Master.m_StartGameInfo.m_DifficultyLevel;
    }
    else
	    m_iDiffLevel = pServerOptions.DiffLevel;

    m_bRepAllowRadarOption = pServerOptions.AllowRadar;
    // radar restricted by game type
    if (m_bIsRadarAllowed)
    {
        m_bServerAllowRadarRep = m_bRepAllowRadarOption;
    }
    else
    {
        m_bServerAllowRadarRep = false;
    }
    if(bShowLog)log( "RADAR: m_bIsRadarAllowed =" $m_bIsRadarAllowed$ " pServerOptions.AllowRadar=" $pServerOptions.AllowRadar$ " m_bServerAllowRadarRep=" $m_bServerAllowRadarRep );

    // Map list and game mode list
    m_mapList.Remove(0, m_mapList.length);
    m_gameModeList.Remove(0, m_gameModeList.length);
    
    for ( iCounter = 0; iCounter < arraycount(myList.Maps); iCounter++ )
    {
        // Force initialization of Game Type data array.
        Level.PreBeginPlay();

        if ( iCounter == GetCurrentMapNum() )
            m_szCurrGameType = Level.GetGameTypeFromClassName( R6MapList(myList).GameType[iCounter] );

        // Also store list in game info so that it can be replicated
        // and then displayed in the in-game menus
        m_mapList[iCounter]        = myList.Maps[iCounter];
        m_gameModeList[iCounter]   = R6MapList(myList).GameType[iCounter];
    }

    // Number of terrorists
	m_iNbOfTerroristToSpawn = pServerOptions.NbTerro;

    // Death Camera Mode
    m_iDeathCameraMode = 0;
    if (pServerOptions.CamFirstPerson)
        m_iDeathCameraMode = Level.RDC_CamFirstPerson;

    if (pServerOptions.CamThirdPerson)
        m_iDeathCameraMode = m_iDeathCameraMode | Level.RDC_CamThirdPerson;

    if (pServerOptions.CamFreeThirdP)
        m_iDeathCameraMode = m_iDeathCameraMode | Level.RDC_CamFreeThirdP;

    if (pServerOptions.CamGhost)
        m_iDeathCameraMode = m_iDeathCameraMode | Level.RDC_CamGhost;

    if (pServerOptions.CamTeamOnly)
    {
        // if it's NOT ((and adversarial OR Squad) AND it's not a team adv) (ie: so it's a pure deathmatch)
        if ( !((Level.IsGameTypeAdversarial(m_szCurrGameType) || Level.IsGameTypeSquad(m_szCurrGameType) )
              && !Level.IsGameTypeTeamAdversarial( m_szCurrGameType ))
            )
        {
            m_iDeathCameraMode = m_iDeathCameraMode | Level.RDC_CamTeamOnly;
        }
    }

    // fade to black overwrites any other camera modes
    if (pServerOptions.CamFadeToBlack)
        m_iDeathCameraMode = Level.RDC_CamFadeToBk;

	// Rotate Map
    if ( Level.IsGameTypeCooperative(m_szGameTypeFlag) )
        m_bRotateMap = pServerOptions.RotateMap;
    else
        m_bRotateMap = false;
}

function SetGamePassword(string szPasswd)
{
    Super.SetGamePassword(szPasswd);
    m_GameService.NativeUpdateServer();
}

function CreateBackupRainbowAI()
{
	local R6RainbowAI	rainbowAI;
	local INT			i;
    local R6ModMgr      pModManager;

    if( Level.NetMode == NM_Standalone )
		return;

    pModManager = class'Actor'.static.GetModMgr();
	// spawn the maximum number of Rainbow AI controllers
	for(i=0; i<CMaxRainbowAI; i++)
	{
		rainbowAI = R6RainbowAI(spawn(pModManager.GetDefaultRainbowAI()));
		rainbowAI.bStasis = true;
		m_RainbowAIBackup[m_RainbowAIBackup.Length] = rainbowAI;
	}
}

//============================================================================
// GetRainbowAIFromTable 
//============================================================================
function actor GetRainbowAIFromTable()
{
	local R6RainbowAI	rainbowAI;
	local INT			i;

	if(Level.NetMode == NM_Standalone || Level.NetMode == NM_Client)
		return none;

	if(m_RainbowAIBackup.Length == 0)
		return none;

	rainbowAI = m_RainbowAIBackup[0];
	rainbowAI.bStasis = false;
	m_RainbowAIBackup.Remove(0,1); 

	return rainbowAI;
}

//============================================================================
// DeployRainbowTeam 
//  spawn a Rainbow Team in multiplayer 
//============================================================================
function DeployRainbowTeam(PlayerController newPlayer)
{
    local R6RainbowTeam newTeam;
    local INT			iMembers, iActiveTotal, iActiveGreen;
    local R6RainbowStartInfo info;

    if ( Level.NetMode != NM_Standalone )
    {
        if ( bShowLog ) log( "DeployRainbowTeam newPlayer=" $newPlayer$ " iNbOfRainbowAIToSpawn=" $GetNbOfRainbowAIToSpawn( newPlayer ) );

        newTeam = Spawn( class'R6RainbowTeam');
        newTeam.SetOwner(newPlayer);

		// determine the number of AI backup for each player depending on the size of the team
        // and if the player is not in the penalty box
		if ( m_bAIBkp && !(R6PlayerController(newPlayer).m_bPenaltyBox) && Level.IsGameTypeCooperative(m_szGameTypeFlag) )
		{
            GetNbHumanPlayerInTeam(iActiveTotal, iActiveGreen);
            iActiveTotal += iActiveGreen;

			switch(iActiveTotal)
			{
				case 1:	
				case 2: iMembers = 4;	/* 3 AI backup */ break;
				case 3: iMembers = 2;	/* 1 AI backup */ break;
				case 4: iMembers = 2;	/* 1 AI backup */ break;
				default:
					iMembers = 1;
			}
		}

        SetRainbowTeam(0, newTeam);

	    info = Spawn(class'R6RainbowStartInfo');

	    if ( newPlayer.PlayerReplicationInfo != none )
            info.m_CharacterName    = newPlayer.PlayerReplicationInfo.PlayerName;
    
        info.m_ArmorName            = "" $newPlayer.PawnClass;
        if(!IsPrimaryWeaponRestricted(newPlayer.m_PlayerPrefs.m_WeaponName1))
	        info.m_WeaponName[0]        = newPlayer.m_PlayerPrefs.m_WeaponName1;
        if(!IsSecondaryWeaponRestricted(newPlayer.m_PlayerPrefs.m_WeaponName2))
    	    info.m_WeaponName[1]        = newPlayer.m_PlayerPrefs.m_WeaponName2;
        else
            info.m_WeaponName[1]        = "R63rdWeapons.NormalPistol92FS";
        info.m_BulletType[0]        = newPlayer.m_PlayerPrefs.m_BulletType1;
        info.m_BulletType[1]        = newPlayer.m_PlayerPrefs.m_BulletType2;
        if(!IsPrimaryGadgetRestricted(newPlayer.m_PlayerPrefs.m_WeaponGadgetName1))
            info.m_WeaponGadgetName[0]  = newPlayer.m_PlayerPrefs.m_WeaponGadgetName1;
        if(!IsSecondaryGadgetRestricted(newPlayer.m_PlayerPrefs.m_WeaponGadgetName2))
            info.m_WeaponGadgetName[1]  = newPlayer.m_PlayerPrefs.m_WeaponGadgetName2;
	    if(!IsTertiaryWeaponRestricted(newPlayer.m_PlayerPrefs.m_GadgetName1))
            info.m_GadgetName[0]		= newPlayer.m_PlayerPrefs.m_GadgetName1;
        if(!IsTertiaryWeaponRestricted(newPlayer.m_PlayerPrefs.m_GadgetName2))
	        info.m_GadgetName[1]		= newPlayer.m_PlayerPrefs.m_GadgetName2;
	    info.m_iOperativeID			= R6Rainbow(newPlayer.pawn).m_iOperativeID;
	    info.m_bIsMale				= !newPlayer.pawn.bIsFemale;
	    info.m_iHealth              = 0;
        info.m_FaceTexture          = DefaultFaceTexture;
        info.m_FaceCoords           = DefaultFaceCoords;


		newTeam.CreateMPPlayerTeam( newPlayer, info, iMembers, PlayerStart(newPlayer.startSpot)); 
        newTeam.SetMultiVoicesMgr(Self, R6Pawn(newPlayer.Pawn).m_iTeam, iMembers);
        ServerSendBankToLoad();
        R6PlayerController(newPlayer).m_TeamManager = newTeam;
#ifdefDebug    
        log("DeployRainbowTeam calling SetMemberTeamID of "$newPlayer.PlayerReplicationInfo.PlayerName$
            " new TeamID=" $R6Pawn(newPlayer.Pawn).m_iTeam$
            " current is "$newPlayer.PlayerReplicationInfo.TeamID );
#endif
        newTeam.SetMemberTeamID( R6Pawn(newPlayer.Pawn).m_iTeam );
    }
}

//============================================================================
// PlayerController Login
//============================================================================
event PlayerController Login
(
    string Portal,
    string Options,
    out string Error
)
{
    local NavigationPoint StartSpot;
    local PlayerController NewPlayer;
    local Pawn      TestPawn;
    local string          InName, InPassword, InChecksum, InClass;
    local byte            InTeam;
    local int i;
    local Actor A;
    local INT iSpawnPointNum;
    local rotator rStartSpotRot;

	
    // Find a start spot.
    StartSpot = R6FindPlayerStart( None, iSpawnPointNum, Portal );

    if( StartSpot == None )
    {
        Error=Localize("MPMiscMessages", "FailedPlaceMessage", "R6GameInfo");
        return None;
    }
    
    if (( PlayerControllerClass == None ) && (Level.NetMode == NM_Standalone))
    {
        PlayerControllerClass = class<PlayerController>(DynamicLoadObject(PlayerControllerClassName, class'Class'));
        log(PlayerControllerClass@PlayerControllerClassName);
    }

    rStartSpotRot = StartSpot.Rotation;
    rStartSpotRot.Roll = 0;
    NewPlayer = spawn(PlayerControllerClass,,,StartSpot.Location,rStartSpotRot);
    NewPlayer.StartSpot = StartSpot;
    
    // Handle spawn failure.
    if( NewPlayer == None )
    {
        log("Couldn't spawn player controller of class "$PlayerControllerClass);
        Error=Localize("MPMiscMessages", "FailedSpawnMessage", "R6GameInfo");
        return None;
    }

//  NewPlayer.StartSpot = StartSpot;

    // Init player's name
    if( InName=="" )
        InName=DefaultPlayerName;
    if( Level.NetMode!=NM_Standalone || ((NewPlayer.PlayerReplicationInfo != none) && (NewPlayer.PlayerReplicationInfo.PlayerName==DefaultPlayerName)))
        ChangeName( NewPlayer, InName, false );

    // Init player's replication info
    NewPlayer.GameReplicationInfo = GameReplicationInfo;

    NewPlayer.GotoState('Spectating');


    // Set the player's ID.  If the player has a Replication Info
    if(NewPlayer.PlayerReplicationInfo != none)
    {
        NewPlayer.PlayerReplicationInfo.PlayerID = CurrentID++;
    }

    // set the player's skin
//  NewPlayer.SkinName = ParseOption ( Options, "Skin"    );
//  NewPlayer.FaceName = ParseOption ( Options, "Face"    );

    if ((Level.NetMode!=NM_Standalone)&&(InClass == ""))
    {
        InClass = ParseOption( Options, "Class" );
    }
   
    if ( InClass != "" )
    {
        NewPlayer.PawnClass = class<Pawn>(DynamicLoadObject(InClass, class'Class'));
    }

    // Log it.
    if ( StatLog != None )
        StatLog.LogPlayerConnect(NewPlayer);
    NewPlayer.ReceivedSecretChecksum = !(InChecksum ~= "NoChecksum");

    NumPlayers++;

    bRestartLevel = false;  // let player spawn once in levels that must be restarted after every death
    StartMatch();
    NotifyMatchStart();
    bRestartLevel = Default.bRestartLevel;
    m_Player = newPlayer;
    if (bShowLog) log(" ********  Login() is called....playerCont = "$newPlayer$"  and pawn = "$newPlayer.pawn);
    return newPlayer;
}

event PreLogOut(PlayerController ExitingPlayer)
{
    Logout(ExitingPlayer);
}

// remove this player's AI Backup if there are any
function RemoveAIBackup(R6PlayerController _playerController)
{
	local INT iMember;
	local INT iMemberCount;

	if(_playerController.m_TeamManager == none)
		return;
	
	for(iMember=1; iMember < 4; iMember++)
	{
		if(_playerController.m_TeamManager.m_Team[iMember] != none)
		{
			_playerController.m_TeamManager.m_Team[iMember].Destroy();
			_playerController.m_TeamManager.m_Team[iMember] = none;
		}
	}
	_playerController.m_TeamManager.m_iMemberCount = 0;
}

function Logout( Controller Exiting )
{
#ifndefSPDEMO
	local bool bMessage;
    local Controller P;
    local R6PlayerController _playerController;
    local R6PlayerController _iterController;
    local INT iAlphaNb, iBravoNb;

    m_GameService.NativeUpdateServer();
	bMessage = true;
    _playerController = R6PlayerController(Exiting);
    if (_playerController == none)
        return;

    if (_playerController.m_PreLogOut==true)
    {
        return; // we already handled this
    }
    
    _playerController.m_PreLogOut=true;
    
    if ( _playerController.bOnlySpectator )
    {
        bMessage = false;
    }
    else
    {
        if ( bShowLog ) log( Exiting$ "Player has quit the game " $Exiting.pawn$ ": suicide" ); 
        
		if(m_bAIBkp && Level.IsGameTypeCooperative(m_szGameTypeFlag))
			RemoveAIBackup(_playerController);

		if ( (Exiting.pawn != none) && R6Pawn( Exiting.pawn ).isAlive() )
        {
            if ( !bChangeLevels )
                R6Pawn( Exiting.pawn ).ServerSuicidePawn(DEATHMSG_CONNECTIONLOST);
        }
    }
    NumPlayers--;

    if ((Level.NetMode==NM_DedicatedServer) || (Level.NetMode==NM_ListenServer))
    {
        GetNbHumanPlayerInTeam( iAlphaNb, iBravoNb );
        if ( _playerController.m_TeamSelection == PTS_Alpha )
        {
            iAlphaNb--;
        }
        if ( Level.IsGameTypeCooperative( m_szGameTypeFlag ) )
        {
            SetCompilingStats( iAlphaNb > 0 );
            SetRoundRestartedByJoinFlag(iAlphaNb == 0);
        }
        LogoutUpdatePlayersCtrlInfo(Exiting);

        // vote session has been ended prematurely
        if (Exiting == m_PlayerKick)
        {
            m_PlayerKick=none;
            m_VoteInstigatorName="";
            m_fEndVoteTime=0;
        }
        
// do we really want to RestartGame when we no longer has active players?
//        if (iPlayerCount==0)
//        {
//            RestartGame();
//        }

        if( bMessage )
	    	BroadcastLocalizedMessage(GameMessageClass, 4, Exiting.PlayerReplicationInfo);
    }
	if ( StatLog != None )
		StatLog.LogPlayerDisconnect(Exiting);
#endif //SPDEMO    
}

//============================================================================
// BOOL SpawnNumberToNavPoint - 
//============================================================================
function BOOL SpawnNumberToNavPoint(int _iSpawnNumber, out NavigationPoint _StartNavPoint)
{
    local R6AbstractInsertionZone NavPoint;
    local Controller OtherPlayer;
    local float NextDist;
    
    foreach AllActors( class 'R6AbstractInsertionZone', NavPoint )
    {
        if ( (NavPoint.m_iInsertionNumber == _iSpawnNumber) &&
             (NavPoint.isAvailableInGameType( m_szGameTypeFlag ) )) 
        {

            for ( OtherPlayer=Level.ControllerList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextController)  
            {
                if ( 
                     OtherPlayer.bIsPlayer && 
                     (OtherPlayer.Pawn != None) &&
                     ( OtherPlayer.Pawn.Region.Zone == NavPoint.Region.Zone )
                   )
                {
                    NextDist = VSize(OtherPlayer.Pawn.Location - NavPoint.Location);
                    if ( NextDist < OtherPlayer.Pawn.CollisionRadius + OtherPlayer.Pawn.CollisionHeight )
                    {
                        log("SPAWNNUMBERTONAVPOINT: Player"@OtherPlayer.Pawn@"is in the way");
                        return false;       // there is a pawn here,  return false
                    }
                }
            }

            _StartNavPoint = NavPoint;
            return true;
        }
    }
    return false;
}

//============================================================================
// NavigationPoint R6FindPlayerStart - 
//============================================================================
function NavigationPoint R6FindPlayerStart( Controller Player, optional INT SpawnPointNumber, optional string incomingName )
{
    local NavigationPoint NavPoint;
    local PlayerStart _tempStart;
    local PlayerStart _checkStarts;

    if(bShowLog) log(self@": R6FindPlayerStart for"@Player@"Name is"@incomingName@" spawn number is"@SpawnPointNumber);

    return FindPlayerStart(Player, SpawnPointNumber);
}

//============================================================================
// NavigationPoint FindPlayerStart - 
//============================================================================
function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
    local R6AbstractInsertionZone NavPoint, BestStart;
    local PlayerStart _tempStart;
    local float BestRating, NewRating;
    local PlayerStart _checkStarts;
    local string szGameType;
    
    szGameType = R6AbstractGameInfo(Level.Game).m_szGameTypeFlag;

    if(bShowLog) log(self@": R6GameInfo FindPlayerStart for"@Player@"Name is"@incomingName@"Spawn num"@inTeam);

    // in MP, if a controller was spawned then we want to spawn the pawn at the same location
//    if ((Player != none) && (Player.StartSpot != none))
//    {
//      if(bShowLog) log(self@": R6GameInfo FindPlayerStart saved startpot is"@Player.StartSpot);
//        return Player.StartSpot;
//    }

    // The following can be useful for adverserial game modes
    foreach AllActors(class 'PlayerStart', _checkStarts)
    {
        if(bShowLog) log("Found PlayerStart"@_checkStarts);
        if (!_checkStarts.IsA('R6AbstractInsertionZone'))
        {
            _tempStart=_checkStarts;
            if (!_checkStarts.IsA('MP2FreeBackupInsertionZone'))
                log("WARNING - Please make sure that the PlayerStart "$_checkStarts$" is replaced with an R6InsertionZone type instead");
        }
    }

    /////////////////////////////////////////////////////////   
    foreach AllActors( class 'R6AbstractInsertionZone', NavPoint )
    {
        if ( !NavPoint.isAvailableInGameType( m_szGameTypeFlag ) )
        {
            continue;
        }

        NewRating = RatePlayerStart(NavPoint,InTeam,Player);

        if ( NewRating > BestRating )
        {
            BestRating = NewRating;
            BestStart = NavPoint;
        }
    }
    
    if ( BestStart == none )
    {
        log("WARNING - NO R6INSERTIONZONE FOUND - WARNING");            
        log("WARNING - Make sure you are using R6InsertionZone instead of PlayerStart");
        LastStartSpot = _checkStarts;
        return _tempStart;    // return this for now
    }

    if (BestStart != none)
    {
        LastStartSpot = BestStart;
    }
    return BestStart;
}

//============================================================================
// float RatePlayerStart - 
//============================================================================
function float RatePlayerStart(NavigationPoint NavPoint, byte Team, Controller Player)
{
    local R6AbstractInsertionZone _startPoint;

    local float Score, NextDist;
    local Controller OtherPlayer;

    _startPoint = R6AbstractInsertionZone(NavPoint);

    if (_startPoint == none)
        return 0;
    
    //assess candidate
    Score = 16000000;
    
    if ( !_startPoint.isAvailableInGameType( m_szGameTypeFlag ) )
    {
        Score -= 1000000;
    }
    
    Score += 10000 * FRand(); //randomize


    if (_startPoint.m_iInsertionNumber == Team)
    {
        Score += 40000;
    }
    else
    {
        Score -= 1000000;
    }


    for ( OtherPlayer=Level.ControllerList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextController)  
    {
        if ( OtherPlayer.bIsPlayer && (OtherPlayer.Pawn != None) )
        {
            if ( OtherPlayer.Pawn.Region.Zone == _startPoint.Region.Zone )
            {
                Score -= 1500;
                NextDist = VSize(OtherPlayer.Pawn.Location - _startPoint.Location);
                if ( NextDist < OtherPlayer.Pawn.CollisionRadius + OtherPlayer.Pawn.CollisionHeight )
                {
                    Score -= 1000000.0;
                }
                else if ( (NextDist < 3000) && FastTrace(_startPoint.Location, OtherPlayer.Pawn.Location) )
                {
                    Score -= (10000.0 - NextDist);
                }
                else if ( Level.Game.NumPlayers + Level.Game.NumBots == 2 )
                {
                    Score += 2 * VSize(OtherPlayer.Pawn.Location - _startPoint.Location);
                    if ( FastTrace(_startPoint.Location, OtherPlayer.Pawn.Location) )
                    {
                        Score -= 10000;
                    }
                }
            }
            if (OtherPlayer.bIsPlayer && (OtherPlayer.StartSpot == _startPoint) )
            {
                Score -= 1000000.0;
            }
        }
        
    }
    return Score;
}

//============================================================================
// bool Stats_getPlayerInfo - 
//============================================================================
function bool Stats_getPlayerInfo( OUT string sz, R6Pawn pPawn, PlayerReplicationInfo pInfo )
{
    local string szHealth;
    local int iKills;
    if ( pInfo == none )
    {
        sz = "";
        return false;
    }

    if ( pPawn != none )
    {
        if      ( pPawn.m_eHealth == HEALTH_Healthy ) {  szHealth = "healthy"; }
        else if ( pPawn.m_eHealth == HEALTH_Wounded ) {  szHealth = "wounded"; }
        else                                          {  szHealth = "dead";    }

        iKills = pInfo.m_iKillCount;
    }
    else
    {
        szHealth = "unknow";
    }

    // "Bob Binette kills: 0 (deaths: 0) status: dead
    sz = "" $pInfo.PlayerName$ " kills: "$iKills$ " (deaths: "$int(pInfo.Deaths)$") status : "$szHealth;

    return true;
}

//============================================================================
// RestartPlayer - 
//============================================================================
function RestartPlayer( Controller aPlayer )    
{
    local NavigationPoint startSpot;
    local int iStartPos;
    local class<Pawn> DefaultPlayerClass;
    local rotator rStartingPointRot;

    if( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
        return;

    if( R6PlayerController(aPlayer)!=none && R6PlayerController(aPlayer).m_TeamSelection == PTS_Bravo)
    {
        iStartPos=1;
    }
    else
    {
        iStartPos=0;
    }

    startSpot = FindPlayerStart(aPlayer, iStartPos);
    if( startSpot == None )
    {
        log(" Player start not found!!!");
        return;
    }

    rStartingPointRot = StartSpot.Rotation;
    rStartingPointRot.Roll = 0;
    
    R6SetPawnClassInMultiPlayer(aPlayer);   // this should set the pawn class to that based on gear menu or team selection
    if ( aPlayer.PawnClass != None )
    {
        if (R6PlayerController(aPlayer).m_TeamSelection == PTS_Bravo)
            aPlayer.PawnClass.default.m_iDefaultTeam = c_iTeamNumBravo;
        else
            aPlayer.PawnClass.default.m_iDefaultTeam = c_iTeamNumAlpha;
        aPlayer.Pawn = Spawn(aPlayer.PawnClass,,,StartSpot.Location,rStartingPointRot);
    }


    if( aPlayer.Pawn==None )
    {
        aPlayer.PawnClass = GetDefaultPlayerClass();
        aPlayer.Pawn = Spawn(aPlayer.PawnClass,,,StartSpot.Location,rStartingPointRot,true);
    }
    if ( aPlayer.Pawn == None )
    {
        log("Couldn't spawn player of type "$aPlayer.PawnClass$" at "$StartSpot);
        aPlayer.GotoState('Dead');
        return;
    }

    aPlayer.StartSpot = StartSpot;

    aPlayer.PreviousPawnClass = aPlayer.Pawn.Class;

    aPlayer.Possess(aPlayer.Pawn);
    aPlayer.PawnClass = aPlayer.Pawn.Class;

    aPlayer.PlayTeleportEffect(true, true);
    aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);

    TriggerEvent( StartSpot.Event, StartSpot, aPlayer.Pawn);

    R6Pawn(aPlayer.Pawn).m_iUniqueID = m_iCurrentID;
    m_iCurrentID++;
}
//------------------------------------------------------------------
// R6SetPawnClassInMultiPlayer
//	
//------------------------------------------------------------------
function R6SetPawnClassInMultiPlayer(Controller _PlayerController)
{
    local class<Pawn> CurrentPawnClass;
    local R6ModMgr pModManager;

	// not a server, return
	if ( !(Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer) )
	{
		return;
	}

	if (R6PlayerController(_PlayerController).m_TeamSelection == PTS_Bravo)
	{
		CurrentPawnClass = class<Pawn>(DynamicLoadObject(Level.RedTeamPawnClass, class'Class'));

		if ( CurrentPawnClass == none )
			CurrentPawnClass = class<Pawn>(DynamicLoadObject(Level.default.RedTeamPawnClass, class'Class'));
	}
	else
	{
		CurrentPawnClass = class<Pawn>(DynamicLoadObject(Level.GreenTeamPawnClass, class'Class'));

		if ( CurrentPawnClass == none )
			CurrentPawnClass = class<Pawn>(DynamicLoadObject(Level.default.GreenTeamPawnClass, class'Class'));
	}

    // the mod picks the pawn class matching the selected uniform's armor type
    pModManager = class'Actor'.static.GetModMgr();
    R6PlayerController(_PlayerController).PawnClass = pModManager.GetDefaultRainbowPawn(class<R6Pawn>(CurrentPawnClass).default.m_eArmorType);
}
function Find2DTexture(string TeamClass, out Material MenuTexture, out Object.Region TextureRegion)
{
	local class<R6ArmorDescription>  DescriptionClass;  
	local bool bTeamFound;
	local INT i;
	local R6Mod	pCurrentMod;
	local R6ModMgr pModManager;

	pModManager = class'Actor'.static.GetModMgr();
	pCurrentMod = pModManager.m_pCurrentMod;
	for (i = 0; i < pCurrentMod.m_aDescriptionPackage.Length; i++)
	{
		DescriptionClass = class<R6ArmorDescription>(GetFirstPackageClass(pCurrentMod.m_aDescriptionPackage[i]$".u", class'R6ArmorDescription'));
		while(DescriptionClass != none)
		{
			if(DescriptionClass.Default.m_ClassName == TeamClass)
			{
				bTeamFound = true;
				MenuTexture    = DescriptionClass.Default.m_2DMenuTexture;
				TextureRegion  = DescriptionClass.Default.m_2dMenuRegion;    
				DescriptionClass = none;
			}
			else
				DescriptionClass = class<R6ArmorDescription>(GetNextClass());
		}
	}

	if((bTeamFound == false) && (pModManager.m_pCurrentMod.m_bUseCustomOperatives == true))
	{
		for(i=0; i<pModManager.GetPackageMgr().m_aPackageList.Length; i++)
		{
			DescriptionClass = class<R6ArmorDescription>(pModManager.GetPackageMgr().GetFirstClassFromPackage(i, class'R6ArmorDescription' ));
			while( DescriptionClass != none )
			{
				if(DescriptionClass.Default.m_ClassName == TeamClass)
				{
					MenuTexture    = DescriptionClass.Default.m_2DMenuTexture;
					TextureRegion  = DescriptionClass.Default.m_2dMenuRegion;    
					DescriptionClass = none;
					i=pModManager.GetPackageMgr().m_aPackageList.Length;
				}
				else
					DescriptionClass = class<R6ArmorDescription>(GetNextClass());
			}
		}
	}
}

function LoadPlanningInTraining();

//============================================================================
// PostLogin - 
//============================================================================
event PostLogin( PlayerController NewPlayer )
{
    local R6FileManagerPlanning   pFileManager;
    Super.PostLogin(NewPlayer);

    if(NewPlayer.IsA('R6PlanningCtrl'))
    {
        R6PlanningCtrl(NewPlayer).SetPlanningInfo();
    }

    if (Level.NetMode==NM_Standalone) //single player stuff
    {
		// if you're in training map, just return
        if (NewPlayer.Player.console.master.m_StartGameInfo.m_GameMode == "R6Game.R6TrainingMgr")
        {
            LoadPlanningInTraining();
        	R6Console(NewPlayer.Player.console).StartR6Game();
			return;
        }

		if(NewPlayer.Player.console.master.m_StartGameInfo.m_ReloadPlanning == true)
		{
			pFileManager = new(None) class'R6FileManagerPlanning';
			pFileManager.LoadPlanning("Backup", "Backup", "Backup", "", "Backup.pln", NewPlayer.Player.console.master.m_StartGameInfo);
			NewPlayer.Player.console.master.m_StartGameInfo.m_ReloadPlanning = false;

			if(NewPlayer.Player.console.master.m_StartGameInfo.m_SkipPlanningPhase == false)
				R6PlanningCtrl(NewPlayer).InitNewPlanning(pFileManager.m_iCurrentTeam);
		}

        //Skip main menu when restarting mission, or GotoGame cheat
        if(NewPlayer.Player.console.master.m_StartGameInfo.m_SkipPlanningPhase == true)
        {
            R6Console(NewPlayer.Player.console).StartR6Game();
            NewPlayer.Player.console.master.m_StartGameInfo.m_SkipPlanningPhase = false;
        }
        else
        {
            SetPlanningMode(TRUE);
        }
        
        
    }
    if (Level.NetMode!=NM_Standalone) // only do this in a multiplayer game
    {
        if (m_HudClass != none)
            NewPlayer.ClientSetHUD(m_HudClass ,none); //Second is scoreboard???
        else
            NewPlayer.ClientSetHUD(class'Actor'.static.GetModMgr().GetDefaultHUD() ,none);
    }
}

//============================================================================
// DeployCharacters - 
//============================================================================
function DeployCharacters(PlayerController ControlledByPlayer)
{
    local R6StartGameInfo       StartGameInfo;
    local INT                   CurrentTeam;
    local Player                CurrentPlayer;
    local interaction           CurrentConsole;
    local R6DeploymentZone      pZone;
//    local R6InsertionZone       InsertionZone;
    local R6ActionPoint         pActionPoint;
    local R6Terrorist           pTerrorist;
    local INT                   iSoundNb;
	local R6ModMgr pModManager;

    assert( Level.NetMode == NM_Standalone );
    
    //Keep the console	
    CurrentPlayer = ControlledByPlayer.Player;
    CurrentConsole = ControlledByPlayer.Player.console;

    //Destroy the original Controller (The Planning Controller), and the Planning pawn to free some memory;
    if ( ControlledByPlayer.Pawn != none )
    {
        ControlledByPlayer.Pawn.SetCollision(false,false,false);
        ControlledByPlayer.Pawn.SetPhysics(PHYS_None);
        ControlledByPlayer.Pawn.Destroy();    
    }
    ControlledByPlayer.Destroy();    
    ControlledByPlayer=none;

    //Get the start info
    StartGameInfo = CurrentConsole.master.m_StartGameInfo;    

    // Create Player
	pModManager = class'Actor'.static.GetModMgr();
	if(pModManager.m_pCurrentMod.m_PlayerCtrlToSpawn != "")
		ControlledByPlayer = spawn(class<PlayerController>(DynamicLoadObject(pModManager.m_pCurrentMod.m_PlayerCtrlToSpawn, class'Class')),,, Location);
	else
		ControlledByPlayer = spawn(class'R6Engine.R6PlayerController',,, Location);
    
    //Load Rainbow Team
    for(CurrentTeam = 0; CurrentTeam < 3; CurrentTeam++)
    {
        if(StartGameInfo.m_TeamInfo[CurrentTeam].m_iNumberOfMembers > 0)       // check if this team has any member.
        {
            //Reset the Milestone here.
            StartGameInfo.m_TeamInfo[CurrentTeam].m_pPlanning.ResetID();
            CreateRainbowTeam(CurrentTeam, StartGameInfo.m_TeamInfo[CurrentTeam], StartGameInfo.m_bIsPlaying, StartGameInfo.m_iTeamStart, ControlledByPlayer);
        }
    }

    //Set the Player.
    if(StartGameInfo.m_bIsPlaying)
    {
        ControlledByPlayer = PlayerController(R6RainbowTeam(GetRainbowTeam(StartGameInfo.m_iTeamStart)).m_TeamLeader.Controller);
        SetController( ControlledByPlayer, CurrentPlayer );
    }
    else
	{
        // then we must be in spectator mode
        ControlledByPlayer.SetLocation(R6RainbowTeam(GetRainbowTeam(StartGameInfo.m_iTeamStart)).m_TeamLeader.location);
        ControlledByPlayer.m_CurrentAmbianceObject = R6RainbowTeam(GetRainbowTeam(StartGameInfo.m_iTeamStart)).m_TeamLeader.Region.Zone;
        m_Player = ControlledByPlayer;
		m_Player.GameReplicationInfo = GameReplicationInfo;
		m_Player.bOnlySpectator = true;             
		SetController(ControlledByPlayer, CurrentPlayer);                
		m_Player.GotoState('CameraPlayer'); 
    }
    
    //Set the TeamManager for teams with no member.
    for(CurrentTeam = 0; CurrentTeam < 3; CurrentTeam++)
    {
        if(StartGameInfo.m_TeamInfo[CurrentTeam].m_iNumberOfMembers == 0)
        {
            StartGameInfo.m_TeamInfo[CurrentTeam].m_pPlanning.m_pTeamManager = R6RainbowTeam(GetRainbowTeam(StartGameInfo.m_iTeamStart));
        }
    }
    
	//Hide the Action Points
    foreach AllActors( class'R6ActionPoint', pActionPoint)
    {
        pActionPoint.SetDrawType(DT_None);
        pActionPoint.bHidden = true;
        //All the action icons will be deleted.
        if(pActionPoint.m_pActionIcon != none)
        {
            pActionPoint.m_pActionIcon = none;
        }
    }

    if (Level.NetMode==NM_Standalone) //single player stuff
    {
        //Reset the display to normal
        SetPlanningMode(FALSE);
    }
}

//============================================================================
// CreateRainbowTeam - 
//============================================================================
function CreateRainbowTeam(int NewTeamNumber, R6TeamStartInfo TeamInfo, BOOL bIsPlaying, INT iTeamStart, PlayerController aRainbowPC)
{
    local NavigationPoint       StartingPoint;
    local R6RainbowTeam         newTeam;

    newTeam = Spawn(class'R6RainbowTeam');

    TeamInfo.m_pPlanning.m_pTeamManager = newTeam;
    newTeam.m_TeamPlanning = TeamInfo.m_pPlanning;

    if(newTeam.m_TeamPlanning.GetNbActionPoint() != 0)
    {
        //Reset points orientation for In-Game display in the HUD and set to the first node.
        newTeam.m_TeamPlanning.ResetPointsOrientation();
    }

    // Find the insertion zone assigned to this team
    if(TeamInfo.m_pPlanning.m_NodeList.Length > 0 || TeamInfo.m_pPlanning.m_iStartingPointNumber!=0)
    {
        StartingPoint = FindTeamInsertionZone( TeamInfo.m_pPlanning.m_iStartingPointNumber );
    }
    else
    {
        StartingPoint = FindTeamInsertionZone( -1 );
    }
   
    if( StartingPoint == none )
    {
        if(bShowLog) Warn( "Couldn't find insertion zone #"$ TeamInfo.m_pPlanning.m_iStartingPointNumber $" Finding Insertion #0 or player start" );
        
        StartingPoint = FindTeamInsertionZone( 0 );
        if( StartingPoint == none )
        {
            FindPlayerStart(m_Player);
        }
    }
    
    SetRainbowTeam(NewTeamNumber, newTeam);


    if((NewTeamNumber == iTeamStart) && bIsPlaying)
    {
        newTeam.CreatePlayerTeam( TeamInfo, StartingPoint, aRainbowPC);
        //m_RainbowPlayerTeam = newTeam;
        //R6GameReplicationInfo(GameReplicationInfo).m_RainbowPlayerTeam = newTeam;
        R6PlayerController(m_Player).m_TeamManager = newTeam;
        newTeam.SetVoicesMgr(Self, true, true, m_iIDVoicesMgr);
    }
    else
    {
        newTeam.CreateAITeam( TeamInfo, StartingPoint);
        newTeam.SetVoicesMgr(Self, false, NewTeamNumber == iTeamStart, m_iIDVoicesMgr);
        
        if ((NewTeamNumber != iTeamStart) && (GetGameOptions().SndQuality == 1))
            m_iIDVoicesMgr++;
    }
    
    newTeam.m_iRainbowTeamName = NewTeamNumber;
}

//============================================================================
// R6InsertionZone FindTeamInsertionZone - 
//============================================================================
function R6InsertionZone FindTeamInsertionZone( INT iSpawningPointNumber )
{
    local INT             iCurrentZoneNumber;
    local R6InsertionZone anInsertionZone;
    local R6InsertionZone pSelectedInsertionZone;

    iCurrentZoneNumber = MaxInt;
    pSelectedInsertionZone = none;

    foreach AllActors( class 'R6InsertionZone', anInsertionZone )
    {
        if(iSpawningPointNumber == -1) //No planning
        {
            if(anInsertionZone.IsAvailableInGameType(R6AbstractGameInfo(Level.Game).m_szGameTypeFlag) && (anInsertionZone.m_iInsertionNumber < iCurrentZoneNumber))
            {
                iCurrentZoneNumber = anInsertionZone.m_iInsertionNumber;
                pSelectedInsertionZone = anInsertionZone;
            }
        }
        else if(( anInsertionZone.m_iInsertionNumber == iSpawningPointNumber ) && (anInsertionZone.IsAvailableInGameType(R6AbstractGameInfo(Level.Game).m_szGameTypeFlag)))
        {
            return anInsertionZone;
        }
    }

    return pSelectedInsertionZone;
}

//============================================================================
// bool RainbowOperativesStillAlive - 
//============================================================================
function bool RainbowOperativesStillAlive()
{
	local R6GameReplicationInfo repInfo;
	
	repInfo = R6GameReplicationInfo(GameReplicationInfo);

	if((repInfo.m_RainbowTeam[0] != none) && (repInfo.m_RainbowTeam[0].m_iMemberCount > 0))
		return true;

	if((repInfo.m_RainbowTeam[1] != none) && (repInfo.m_RainbowTeam[1].m_iMemberCount > 0))
		return true;
	
	if((repInfo.m_RainbowTeam[2] != none) && (repInfo.m_RainbowTeam[2].m_iMemberCount > 0))
		return true;

	return false;
}

//------------------------------------------------------------------
// IsARainbowAlive (slower version!)
// - different from RainbowOperativesStillAlive 
// - can't look the iMemberCount because of an order of execution problem
//------------------------------------------------------------------
function bool IsARainbowAlive()
{
    local R6GameReplicationInfo gInfo;
    local int                   iTeam, iRainbow;

    gInfo = R6GameReplicationInfo(GameReplicationInfo);

    // look if there's a rainbow alive.
    iTeam = 0;
    while ( iTeam < ArrayCount(gInfo.m_RainbowTeam) && gInfo.m_RainbowTeam[iTeam] != none )
    {
        for( iRainbow = 0; iRainbow < gInfo.m_RainbowTeam[iTeam].m_iMemberCount; ++iRainbow )
        {
            if ( gInfo.m_RainbowTeam[iTeam].m_Team[iRainbow].isAlive() )
                return true;
        }

        ++iTeam;
    }

    return false;
}

//============================================================================
// Actor GetNewTeam - 
//============================================================================
function Actor GetNewTeam(Actor aCurrentTeam, optional bool bNextTeam)
{
    local   R6RainbowTeam   aRainbowTeam[3];
    local   R6RainbowTeam   aNewTeam;
	local   INT             i, iCurrentTeam, iNewTeam;
	
	if(aCurrentTeam == none)
		return none;

    aRainbowTeam[0] = R6RainbowTeam(GetRainbowTeam(0));
    aRainbowTeam[1] = R6RainbowTeam(GetRainbowTeam(1));
    aRainbowTeam[2] = R6RainbowTeam(GetRainbowTeam(2));

    // For trainning, sometimes prevent switching team
    if( aRainbowTeam[1]!=none && aRainbowTeam[1].m_bPreventUsingTeam )
        aRainbowTeam[1] = none;
    if( aRainbowTeam[2]!=none && aRainbowTeam[2].m_bPreventUsingTeam )
        aRainbowTeam[2] = none;
   
    // if there is only one team.... cannot change teams...
    if((aRainbowTeam[1]==none) && (aRainbowTeam[2]==none))
        return none;
    
    if(aRainbowTeam[2]==none)
    {
        if(aCurrentTeam == aRainbowTeam[0])
            aNewTeam = aRainbowTeam[1]; 
        else
            aNewTeam = aRainbowTeam[0];

        if(aNewTeam.m_iMemberCount == 0)
            return none;
    }
    else
    {
        for(i=0; i<3; i++)
        {
            if(aRainbowTeam[i] == aCurrentTeam)
            {
                iCurrentTeam = i;
                break;
            }
        }
            
        // check if there are any members left alive in the team before switching to it...  
        iNewTeam = iCurrentTeam;
        do {
            if(bNextTeam)
                iNewTeam++;
            else
                iNewTeam--;
            if(iNewTeam == -1) iNewTeam = 2;
            if(iNewTeam == 3)  iNewTeam = 0;
        } until ((aRainbowTeam[iNewTeam]!=none && aRainbowTeam[iNewTeam].m_iMemberCount != 0) || (aRainbowTeam[iNewTeam] == aCurrentTeam))

        // check if there are no other teams to switch to (back to original team)
        if(aRainbowTeam[iNewTeam] == aCurrentTeam)
            return none;

        // set team to switch to
        aNewTeam = aRainbowTeam[iNewTeam];
    }

	return aNewTeam;
}

//============================================================================
// ChangeOperatives - 
//============================================================================
function ChangeOperatives(PlayerController inPlayerController, INT iTeamId, INT iOperativeId)
{
	local	R6RainbowTeam	aNewTeam;
	local	R6PlayerController	aPlayerController;

	aPlayerController = R6PlayerController(inPlayerController);

    if (Level.NetMode != NM_Standalone)
        aNewTeam = aPlayerController.m_TeamManager;
    else
	    aNewTeam = R6RainbowTeam(GetRainbowTeam(iTeamId));

	if(aPlayerController.bOnlySpectator)
	{
		if(aPlayerController.m_eCameraMode == CAMERA_Ghost)
			return;
		
		// switch to the desired team
		while(aPlayerController.m_TeamManager != aNewTeam)
			aPlayerController.ChangeTeams(true);

		// switch to the desired operative
		while(R6Pawn(aPlayerController.viewTarget).m_iId != iOperativeId)
			aPlayerController.NextMember();
		
		return;
	}

	if(aPlayerController.m_TeamManager == aNewTeam)
	{
		// player requested switching to an operative in his own team
		aPlayerController.m_TeamManager.SwapPlayerControlWithTeamMate(iOperativeId);
	}
	else
	{
		// player requested switching to an operative in another team
		aNewTeam.AssignNewTeamLeader(iOperativeId);
		ChangeTeams(inPlayerController,, aNewTeam);
	}	
}

//============================================================================
// ChangeTeams - 
//============================================================================
function ChangeTeams(PlayerController inPlayerController, optional bool bNextTeam, optional Actor newRainbowTeam)
{
    local   R6PawnReplicationInfo  aPawnRepInfo;
    local   R6PlayerController  aPC;
    local   R6RainbowAI         tempAIController;
    local   R6RainbowTeam       aCurrentTeam, aNewTeam;
	local	bool			    bPlayerDied;

    aPC = R6PlayerController(inPlayerController);

	// this is a single player only feature; it is not possible to change teams in multiplayer
	if(Level.NetMode != NM_Standalone)
		return;

	if(aPC.pawn == none)
		return;
	
	bPlayerDied = !aPC.pawn.IsAlive();

    aCurrentTeam = aPC.m_TeamManager;
	if(newRainbowTeam == none)
		aNewTeam = R6RainbowTeam(GetNewTeam(aCurrentTeam, bNextTeam));
	else
		aNewTeam = R6RainbowTeam(newRainbowTeam);

	if(aCurrentTeam == none || aNewTeam == none)
		return;

    if(bPlayerDied)
        aPC.ClientFadeCommonSound(0.5, 100);

    // inform the team manager of the original team that the player has left
    aCurrentTeam.PlayerHasAbandonedTeam();

    // turn off the zoom
    aPC.ResetPlayerVisualEffects();
    aPC.m_bLockWeaponActions = false;

    // remove the lead's AI controller and associate the playercontroller to it
    tempAIController = R6RainbowAI(aNewTeam.m_TeamLeader.controller);   
    
    // change the controller who contain the sound to the right controller
    aPawnRepInfo = tempAIController.m_PawnRepInfo;
    tempAIController.m_PawnRepInfo = aPC.m_PawnRepInfo;
    tempAIController.m_PawnRepInfo.m_ControllerOwner = tempAIController;
    aPC.m_PawnRepInfo = aPawnRepInfo;
    aPC.m_PawnRepInfo.m_ControllerOwner = aPC;
    aPC.m_CurrentAmbianceObject = tempAIController.Pawn.Region.Zone;
    aPC.m_TeamManager = aNewTeam;

    if(!bPlayerDied)
		aCurrentTeam.m_TeamLeader.UnPossessed();
    
	//aNewTeam.m_TeamLeader.UnPossessed();
    aNewTeam.AssociatePlayerAndPawn(aPC, aNewTeam.m_TeamLeader);
    aNewTeam.m_bLeaderIsAPlayer = true;
    aNewTeam.m_TeamLeader.m_bIsPlayer = true;
	aNewTeam.SetPlayerControllerState(aPC);
	aNewTeam.InstructPlayerTeamToFollowLead();

    aCurrentTeam.m_bLeaderIsAPlayer = false;  

    // reassociate the controller for the leader of the abandoned team    
    if(bPlayerDied)
	{
		tempAIController.Destroy();
	}
	else
	{
		aCurrentTeam.m_TeamLeader.m_bIsPlayer = false;
		aCurrentTeam.m_TeamLeader.controller = tempAIController;        
		aCurrentTeam.m_TeamLeader.controller.Possess(aCurrentTeam.m_TeamLeader);
		tempAIController.m_TeamManager =  aCurrentTeam;
		tempAIController.StopMoving();

		aCurrentTeam.SetAILeadControllerState();
		if(aPC.m_bAllTeamsHold)
			aCurrentTeam.AITeamHoldPosition();		
	}
    
	// reset position of head
	aCurrentTeam.m_TeamLeader.PawnLook(rot(0,0,0),,);		
    aCurrentTeam.UpdateFirstPersonWeaponMemory(aCurrentTeam.m_TeamLeader, aNewTeam.m_TeamLeader);
    aCurrentTeam.UpdatePlayerWeapon(aNewTeam.m_TeamLeader);

    if(aNewTeam.m_TeamLeader.m_bPawnIsReloading == true)
    {
        aNewTeam.m_TeamLeader.ServerSwitchReloadingWeapon(false);
        aNewTeam.m_TeamLeader.m_bPawnIsReloading=false;
        aNewTeam.m_TeamLeader.GotoState('');
        aNewTeam.m_TeamLeader.PlayWeaponAnimation();
    }

    aCurrentTeam.SetVoicesMgr(Self, false, false, aNewTeam.m_iIDVoicesMgr);
    aNewTeam.SetVoicesMgr(Self, true, true);
	aNewTeam.UpdateTeamGrenadeStatus();
	if(aNewTeam.m_iMemberCount == 1 && aNewTeam.m_iMembersLost > 0)
		aNewTeam.SetTeamState(TS_Retired);

    aPC.UpdatePlayerPostureAfterSwitch();
}

//============================================================================
// InstructAllTeamsToHoldPosition - 
//============================================================================
function InstructAllTeamsToHoldPosition()
{
    local   R6RainbowTeam   aRainbowTeam[3];
	local	INT				i;
	local	INT				iNbTeam;

    for(i=0; i<3; i++)
    {
        aRainbowTeam[i] = R6RainbowTeam(GetRainbowTeam(i));
        if (aRainbowTeam[i] != none && aRainbowTeam[i].m_iMemberCount > 0)
            iNbTeam++;
    }

	for(i=0; i<3; i++)
	{
		if(aRainbowTeam[i] != none)
		{
			if(aRainbowTeam[i].m_bLeaderIsAPlayer)
				aRainbowTeam[i].InstructPlayerTeamToHoldPosition(iNbTeam>1);
			else
				aRainbowTeam[i].AITeamHoldPosition();

			aRainbowTeam[i].m_bAllTeamsHold = true;
		}
	}
}

//============================================================================
// InstructAllTeamsToFollowPlanning - 
//============================================================================
function InstructAllTeamsToFollowPlanning()
{
    local   R6RainbowTeam   aRainbowTeam[3];
	local	INT				i;
	local	INT				iNbTeam;

    for(i=0; i<3; i++)
    {
        aRainbowTeam[i] = R6RainbowTeam(GetRainbowTeam(i));
        if (aRainbowTeam[i] != none && aRainbowTeam[i].m_iMemberCount > 0)
            iNbTeam++;
    }

    for(i=0; i<3; i++)
	{
		if(aRainbowTeam[i] != none)
		{
			if(aRainbowTeam[i].m_bLeaderIsAPlayer)
				aRainbowTeam[i].InstructPlayerTeamToFollowLead(iNbTeam>1);
			else
				aRainbowTeam[i].AITeamFollowPlanning();

			aRainbowTeam[i].m_bAllTeamsHold = false;
		}
	}
}

// Object GetCommonRainbowPlayerVoicesMgr - 
//============================================================================
function Object GetMultiCoopPlayerVoicesMgr(INT iTeam)
{
    local INT iIndex;

    switch(iTeam) 
    {
        case 1:
        case 4:
        case 7:
            iIndex = 0;
            break;
        case 2:
        case 5:
        case 8:
            iIndex = 1;
            break;
        case 3:
        case 6:
            iIndex = 2;
            break;
        default:
            iIndex = 0;
    }
    
    if (m_MultiCoopPlayerVoicesMgr.Length <= iIndex)
        m_MultiCoopPlayerVoicesMgr[iIndex] = none;

    if (m_MultiCoopPlayerVoicesMgr[iIndex] == none)
    {
        switch(iIndex) 
        {
            case 0:
                m_MultiCoopPlayerVoicesMgr[iIndex] = new class'R6MultiCoopPlayerVoices1';
                break;
            case 1:
                m_MultiCoopPlayerVoicesMgr[iIndex] = new class'R6MultiCoopPlayerVoices2';
                break;
            case 2:
                m_MultiCoopPlayerVoicesMgr[iIndex] = new class'R6MultiCoopPlayerVoices3';
                break;
        }
        m_MultiCoopPlayerVoicesMgr[iIndex].Init(Self);
    }   

    return m_MultiCoopPlayerVoicesMgr[iIndex];
}

// Object GetCommonRainbowPlayerVoicesMgr - 
//============================================================================
function Object GetMultiCoopMemberVoicesMgr()
{
    if (m_MultiCoopMemberVoicesMgr == none)
    {
        m_MultiCoopMemberVoicesMgr = new class'R6MultiCoopMemberVoices';
        m_MultiCoopMemberVoicesMgr.Init( Self );
    }

    return m_MultiCoopMemberVoicesMgr;
}

// Object GetCommonRainbowPlayerVoicesMgr - 
//============================================================================
function Object GetPreRecordedMsgVoicesMgr()
{
    if (m_PreRecordedMsgVoicesMgr == none)
    {
        m_PreRecordedMsgVoicesMgr = new class'R6PreRecordedMsgVoices';
        m_PreRecordedMsgVoicesMgr.Init( Self );
    }

    return m_PreRecordedMsgVoicesMgr;
}

// Object GetCommonRainbowPlayerVoicesMgr - 
//============================================================================
function Object GetMultiCommonVoicesMgr()
{
    if (m_MultiCommonVoicesMgr == none)
    {
        m_MultiCommonVoicesMgr = new class'R6MultiCommonVoices';
        m_MultiCommonVoicesMgr.Init( Self );
    }

    return m_MultiCommonVoicesMgr;
}


//============================================================================
// Object GetCommonRainbowPlayerVoicesMgr - 
//============================================================================
function Object GetCommonRainbowPlayerVoicesMgr()
{
    if (m_CommonRainbowPlayerVoicesMgr == none)
    {
        m_CommonRainbowPlayerVoicesMgr = new class'R6CommonRainbowPlayerVoices';
        m_CommonRainbowPlayerVoicesMgr.Init( Self );
    }

    return m_CommonRainbowPlayerVoicesMgr;
}

//============================================================================
// Object GetCommonRainbowMemberVoicesMgr - 
//============================================================================
function Object GetCommonRainbowMemberVoicesMgr()
{
    if (m_CommonRainbowMemberVoicesMgr == none)
    {
        m_CommonRainbowMemberVoicesMgr = new class'R6CommonRainbowMemberVoices';
        m_CommonRainbowMemberVoicesMgr.Init( Self );
    }

    return m_CommonRainbowMemberVoicesMgr;
}


//============================================================================
// Object GetRainbowPlayerVoicesMgr - 
//============================================================================
function Object GetRainbowPlayerVoicesMgr()
{
    if (m_RainbowPlayerVoicesMgr == none)
    {
        m_RainbowPlayerVoicesMgr = new class'R6RainbowPlayerVoices';
        m_RainbowPlayerVoicesMgr.Init( Self );
    }

    return m_RainbowPlayerVoicesMgr;
}

//============================================================================
// Object GetRainbowMemberVoicesMgr - 
//============================================================================
function Object GetRainbowMemberVoicesMgr()
{
    if (m_RainbowMemberVoicesMgr == none)
    {
        m_RainbowMemberVoicesMgr = new class'R6RainbowMemberVoices';
        m_RainbowMemberVoicesMgr.Init( Self );
    }

    return m_RainbowMemberVoicesMgr;

}

//============================================================================
// Object GetRainbowOtherTeamVoicesMgr - 
//============================================================================
function Object GetRainbowOtherTeamVoicesMgr(INT iIDVoicesMgr)
{
    if (m_RainbowOtherTeamVoicesMgr.Length <= iIDVoicesMgr)
        m_RainbowOtherTeamVoicesMgr[iIDVoicesMgr] = none;

    if (m_RainbowOtherTeamVoicesMgr[iIDVoicesMgr] == none)
    {
        if (iIDVoicesMgr == 0)
            m_RainbowOtherTeamVoicesMgr[iIDVoicesMgr] = new class'R6RainbowOtherTeamVoices1';
        else
            m_RainbowOtherTeamVoicesMgr[iIDVoicesMgr] = new class'R6RainbowOtherTeamVoices2';

        m_RainbowOtherTeamVoicesMgr[iIDVoicesMgr].Init( Self );
    }

    return m_RainbowOtherTeamVoicesMgr[iIDVoicesMgr];
}


//============================================================================
// Object GetTerroristVoicesMgr - 
//============================================================================
function Object GetTerroristVoicesMgr(ETerroristNationality eNationality)
{
    if (m_TerroristVoicesMgr.Length <= INT(eNationality))
        m_TerroristVoicesMgr[eNationality] = none;

    if (m_TerroristVoicesMgr[eNationality] == none)
    {
        switch(eNationality)
        {
            case TN_Spanish1:
                m_TerroristVoicesMgr[eNationality] = new class'R6TerroristVoicesSpanish1';
                break;

            case TN_Spanish2:
                m_TerroristVoicesMgr[eNationality] = new class'R6TerroristVoicesSpanish2';
                break;

            case TN_German1:
                m_TerroristVoicesMgr[eNationality] = new class'R6TerroristVoicesGerman1';
                break;

            case TN_German2:
                m_TerroristVoicesMgr[eNationality] = new class'R6TerroristVoicesGerman2';
                break;

            case TN_Portuguese:
                m_TerroristVoicesMgr[eNationality] = new class'R6TerroristVoicesPortuguese';
                break;
        }
        m_TerroristVoicesMgr[eNationality].Init( Self );
    }

    return m_TerroristVoicesMgr[eNationality];
} 

//============================================================================
// Object GetHostageVoicesMgr - 
//============================================================================
function Object GetHostageVoicesMgr(EHostageNationality eNationality, BOOL IsFemale)
{
    if (IsFemale)
    {
        if (m_HostageVoicesFemaleMgr.Length <= INT(eNationality))
            m_HostageVoicesFemaleMgr[eNationality] = none;

        if (m_HostageVoicesFemaleMgr[eNationality] == none)
        {
            switch(eNationality)
            {
                case HN_French:
                    m_HostageVoicesFemaleMgr[eNationality] = new class'R6HostageVoicesFemaleFrench';
                    break;
                case HN_British:
                    m_HostageVoicesFemaleMgr[eNationality] = new class'R6HostageVoicesFemaleBritish';
                    break;
                case HN_Spanish:
                    m_HostageVoicesFemaleMgr[eNationality] = new class'R6HostageVoicesFemaleSpanish';
                    break;
                case HN_Norwegian:
                    m_HostageVoicesFemaleMgr[eNationality] = new class'R6HostageVoicesFemaleNorwegian';
                    break;
                case HN_Portuguese:
                    m_HostageVoicesFemaleMgr[eNationality] = new class'R6HostageVoicesFemalePortuguese';
                    break;
            }
            m_HostageVoicesFemaleMgr[eNationality].Init( Self );
        }    

        return m_HostageVoicesFemaleMgr[eNationality];
    }
    else
    {
        if (m_HostageVoicesMaleMgr.Length <= INT(eNationality))
            m_HostageVoicesMaleMgr[eNationality] = none;

        if (m_HostageVoicesMaleMgr[eNationality] == none)
        {
            switch(eNationality)
            {
                case HN_French:
                    m_HostageVoicesMaleMgr[eNationality] = new class'R6HostageVoicesMaleFrench';
                    break;
                case HN_British:
                    m_HostageVoicesMaleMgr[eNationality] = new class'R6HostageVoicesMaleBritish';
                    break;
                case HN_Spanish:
                    m_HostageVoicesMaleMgr[eNationality] = new class'R6HostageVoicesMaleSpanish';
                    break;
                case HN_Norwegian:
                    m_HostageVoicesMaleMgr[eNationality] = new class'R6HostageVoicesMaleNorwegian';
                    break;
                case HN_Portuguese:
                    m_HostageVoicesMaleMgr[eNationality] = new class'R6HostageVoicesMalePortuguese';
                    break;
            }
            m_HostageVoicesMaleMgr[eNationality].Init( Self );
        }    
        return m_HostageVoicesMaleMgr[eNationality];
    }

}

//============================================================================
// Object GetTrainingMgr - 
//============================================================================
function R6TrainingMgr GetTrainingMgr( R6Pawn p )
{
    return none;
} 

//============================================================================
// R6AbstractNoiseMgr GetNoiseMgr - 
//============================================================================
function R6AbstractNoiseMgr GetNoiseMgr()
{
    if( m_noiseMgr == none )
    {
        m_noiseMgr = new class'R6NoiseMgr';
        m_noiseMgr.Init();
    }
    
    return m_noiseMgr; 
}

//============================================================================
// RestartGame - At the end of a round or if we switch maps
//============================================================================
function RestartGame()
{
    local R6PlayerController P;
//    local R6PlayerController _RemotePlayer;

    m_bStopPostBetweenRoundCountdown = true;
    GameReplicationInfo.SetServerState(GameReplicationInfo.RSS_EndOfMatch);
//#ifdef R6CHEAT
    if (bNoRestart==true)
        return;
//#endif

//    //here we will need to save each players' stats and send them
//    // an index so that they can get their stats for the next round
//    foreach AllActors(class 'R6PlayerController', _RemotePlayer)
//    {
//
//    }

    if ( bChangeLevels )
    {
        ForEach DynamicActors(class'R6PlayerController', P)
            P.ClientChangeMap();
    }

    Super.RestartGame();
    Level.ResetLevelInNative(); 
    DestroyBeacon(); 
}

//R6CHEAT, avoid restarting the round
//============================================================================
// ToggleRestart - 
//============================================================================
#ifdefDEBUG
function ToggleRestart()
{
    bNoRestart = (bNoRestart==false);
}
#endif

#ifdefDEBUG
exec function SaveTrainingPlanning()
{
    WindowConsole(m_Player.Player.Console).Root.SaveTrainingPlanning();
}
#endif


//============================================================================
// R6GameInfoMakeNoise - 
//============================================================================
function R6GameInfoMakeNoise( Actor.ESoundType eType, Actor soundsource )
{
    GetNoiseMgr().R6MakeNoise( eType, soundsource );
}

//============================================================================
// PlayTeleportEffect - Overided to remove MakeNoise of base class
//============================================================================
function PlayTeleportEffect(bool bOut, bool bSound)
{
}

//============================================================================
// InitGameReplicationInfo - 
//============================================================================
function InitGameReplicationInfo()
{

    super.InitGameReplicationInfo();

    GameReplicationInfo.m_bServerAllowRadar = m_bServerAllowRadarRep;
    GameReplicationInfo.m_bRepAllowRadarOption = m_bRepAllowRadarOption;
    GameReplicationInfo.TimeLimit = INT(Level.m_fTimeLimit);
    GameReplicationInfo.MOTDLine1 = m_szMessageOfDay;
    R6GameReplicationInfo(GameReplicationInfo).m_szCurrGameType = m_szCurrGameType;
    
}

function IncrementRoundsFired(Pawn Instigator, BOOL ForceIncrement)
{
    local R6RainbowPawn _pawnIterator;
    local PlayerController _playerController;

	if(Level.NetMode == NM_Standalone)
	{		
		R6Pawn(Instigator).IncrementBulletsFired();
	}
	else if (m_bCompilingStats==true || ForceIncrement == true)
	{
		if (Instigator.PlayerReplicationInfo != none)
		{
			// AK: to fix: no adversery, return
			Instigator.PlayerReplicationInfo.m_iRoundFired++;
		}
        else 
        {
            _playerController =R6Pawn(Instigator).GetHumanLeaderForAIPawn();
            if (_playerController == none)
                return;
            _playerController.PlayerReplicationInfo.m_iRoundFired++;                
        }
	}
}

/*************************************************************************************/
//  
// FRIENSHIP
//
/*************************************************************************************/

//------------------------------------------------------------------
// SetPawnTeamFriendlies
//	
//------------------------------------------------------------------
function SetPawnTeamFriendlies(Pawn aPawn)
{
    SetDefaultTeamFriendlies( aPawn );
}

//------------------------------------------------------------------
// GetTeamNumBit
//	
//------------------------------------------------------------------
function INT GetTeamNumBit( INT num )
{
    return 1 << num;
}

//------------------------------------------------------------------
// SetDefaultTeamFriendlies: set the default value based on single
//	player mode. 
//------------------------------------------------------------------
function SetDefaultTeamFriendlies(Pawn aPawn)
{
    switch ( aPawn.m_iTeam )
    {
    case c_iTeamNumTerrorist:
        if ( aPawn.m_ePawnType != PAWN_Terrorist )
            log( "WARNING SetDefaultTeamFriendlies m_ePawnType != PAWN_Terrorist for " $aPawn.name  );

        aPawn.m_iFriendlyTeams  = GetTeamNumBit( c_iTeamNumTerrorist );
        aPawn.m_iEnemyTeams     = GetTeamNumBit( c_iTeamNumAlpha );
        aPawn.m_iEnemyTeams    += GetTeamNumBit( c_iTeamNumBravo );
        break;
    
    case c_iTeamNumHostage:
        if ( aPawn.m_ePawnType != PAWN_Hostage )
            log( "WARNING SetDefaultTeamFriendlies m_ePawnType != PAWN_Hostage for " $aPawn.name  );
        aPawn.m_iFriendlyTeams  = GetTeamNumBit( c_iTeamNumAlpha );
        aPawn.m_iFriendlyTeams += GetTeamNumBit( c_iTeamNumBravo );
        aPawn.m_iEnemyTeams     = GetTeamNumBit( c_iTeamNumTerrorist );
        break;

    case c_iTeamNumAlpha:
    case c_iTeamNumBravo:
        if ( aPawn.m_ePawnType != PAWN_Rainbow )
            log( "WARNING SetDefaultTeamFriendlies m_ePawnType != PAWN_Rainbow for " $aPawn.name  );
        aPawn.m_iFriendlyTeams  = GetTeamNumBit( c_iTeamNumAlpha );
        aPawn.m_iFriendlyTeams += GetTeamNumBit( c_iTeamNumBravo );
        aPawn.m_iEnemyTeams     = GetTeamNumBit( c_iTeamNumTerrorist );
        break;
        
    default:
        log( "warning: SetDefaultTeamFriendlies team not supported for " $aPawn.name$ " team=" $aPawn.m_iTeam );
        break;

    }
        
}

//------------------------------------------------------------------
// CheckForExtractionZone
//	
//------------------------------------------------------------------
function CheckForExtractionZone( R6MissionObjectiveBase mo )
{
    local int               iTotal;
    local R6ExtractionZone  aExtractZone;

    iTotal = 0;
    foreach AllActors( class'R6ExtractionZone', aExtractZone )
	{
        iTotal++;
        break;
    }

    // check if there's a least one R6ExtractionZone
    if ( iTotal == 0 )
    {
        log( "WARNING: there is no R6ExtractionZone to complete this objective: " $mo.GetDescription() );
    }
}


//------------------------------------------------------------------
// CheckForTerrorist
//	
//------------------------------------------------------------------
function CheckForTerrorist( R6MissionObjectiveBase mo, int iMinNum )
{
    local int iTotal;
    local R6Terrorist aTerrorist;

    foreach DynamicActors( class'R6Terrorist', aTerrorist )
	{
        iTotal++;
    }

    // check if there's a least one terro
    if ( iTotal < iMinNum )
    {
        log( "WARNING: there is no terrorist spawned to complete this objective: " $mo.GetDescription() );
    }
}

//------------------------------------------------------------------
// CheckForHostage
//	
//------------------------------------------------------------------
function CheckForHostage( R6MissionObjectiveBase mo, int iMinNum )
{
    local int       iTotal;
    local R6Hostage aHostage;

    foreach DynamicActors( class'R6Hostage', aHostage )
	{
        iTotal++;
    }

    // check if there's enough hostage
    if ( iTotal < iMinNum )
    {
        log( "WARNING: there is not enough (" $iMinNum$ ") hostage spawned to complete this objective: " $mo.GetDescription() );
    }
}

///////////////////////////////////////////////////////////////////////////////
// InitObjectives()
///////////////////////////////////////////////////////////////////////////////
function InitObjectives()
{
    local int index;
    local int iMaxRep, iRep, i;
    local GameReplicationInfo g;

        
    if ( Level.m_bUseDefaultMoralityRules )
    {
        // adding morality rules
        index = m_missionMgr.m_aMissionObjectives.Length;
        m_missionMgr.m_aMissionObjectives[index] = new(none) class'R6Game.R6MObjAcceptableCivilianLossesByRainbow';
        index++;
        m_missionMgr.m_aMissionObjectives[index] = new(none) class'R6Game.R6MObjAcceptableCivilianLossesByTerro';
        index++;
        m_missionMgr.m_aMissionObjectives[index] = new(none) class'R6Game.R6MObjAcceptableHostageLossesByRainbow';
        index++;
        m_missionMgr.m_aMissionObjectives[index] = new(none) class'R6Game.R6MObjAcceptableHostageLossesByTerro';
        index++;
        m_missionMgr.m_aMissionObjectives[index] = new(none) class'R6Game.R6MObjAcceptableRainbowLosses';
        index++;
    }

    m_missionMgr.Init( self );

    g = GameReplicationInfo;
    iRep = 0;
    iMaxRep = g.GetRepMObjInfoArraySize();
    for ( i = 0; i < m_missionMgr.m_aMissionObjectives.length; ++i )
    {
        // visible and not a morality rule
        if (  m_missionMgr.m_aMissionObjectives[i].m_bVisibleInMenu && 
             !m_missionMgr.m_aMissionObjectives[i].m_bMoralityObjective )
        {
            if ( i < iMaxRep )
            {
                // copy the string 
                g.SetRepMObjString( iRep, m_missionMgr.m_aMissionObjectives[i].m_szDescriptionInMenu,
                                    Level.GetMissionObjLocFile( m_missionMgr.m_aMissionObjectives[i] ) );
                iRep++;
            }
            else
            {
                log( "Warning: array of m_aRepMObj is to small for this mission" );
            }
        }
    }
}

//------------------------------------------------------------------
// ResetRepMissionObjectives
//	
//------------------------------------------------------------------
function ResetRepMissionObjectives()
{
    GameReplicationInfo.ResetRepMObjInfo();
}

//------------------------------------------------------------------
// UpdateRepMissionObjectivesStatus
//	
//------------------------------------------------------------------
function UpdateRepMissionObjectivesStatus()
{
    GameReplicationInfo.SetRepMObjInProgress( m_missionMgr.m_eMissionObjectiveStatus == eMissionObjStatus_none );
    GameReplicationInfo.SetRepMObjSuccess(    m_missionMgr.m_eMissionObjectiveStatus == eMissionObjStatus_success );
}

//------------------------------------------------------------------
// UpdateRepMissionObjectives
//	
//------------------------------------------------------------------
function UpdateRepMissionObjectives()
{
    local int i;
    local int iRep;
    local int iMaxRep;

    // update rep info
    iRep = 0;
    for ( i = 0; i < m_missionMgr.m_aMissionObjectives.length; ++i )
    {
        // visible and not a morality rule
        if ( m_missionMgr.m_aMissionObjectives[i].m_bVisibleInMenu && 
             !m_missionMgr.m_aMissionObjectives[i].m_bMoralityObjective )
        {
            GameReplicationInfo.SetRepMObjInfo( iRep, m_missionMgr.m_aMissionObjectives[i].m_bFailed, m_missionMgr.m_aMissionObjectives[i].m_bCompleted );
            
            iRep++;        
        }
    }
}


//------------------------------------------------------------------
// CheckEndGame
//	
//------------------------------------------------------------------
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
    local R6GameOptions pGameOptions;

    m_missionMgr.Update();
    UpdateRepMissionObjectives();

    pGameOptions = class'Actor'.static.GetGameOptions();
    if ( pGameOptions.UnlimitedPractice )
    {
        // check if there's still a rainbow alive
        if ( IsARainbowAlive() )
            return false;
    }
    
    return (m_missionMgr.m_eMissionObjectiveStatus != eMissionObjStatus_none);
}

//------------------------------------------------------------------
// BaseEndGame
//	
//------------------------------------------------------------------
function BaseEndGame()
{
    m_bGameOver = true; // We do not want this function called again

    // reset the value to play the outro video
    m_bPlayOutroVideo = default.m_bPlayOutroVideo;

    // we should stop compiling stats
    SetCompilingStats(false);
    SetRoundRestartedByJoinFlag(true);
    
    if(bShowLog) log( "***STATE: " $getStateName()  );
    // if the game was still in progress, aborted
    if ( m_missionMgr.m_eMissionObjectiveStatus == eMissionObjStatus_none )
    {
        m_missionMgr.SetMissionObjStatus( eMissionObjStatus_failed );
    }

    GameReplicationInfo.SetRepLastRoundSuccess( m_missionMgr.m_eMissionObjectiveStatus );

    m_fRoundEndTime = Level.TimeSeconds;
}

///////////////////////////////////////////////////////////////////////////////
// EndGame()
///////////////////////////////////////////////////////////////////////////////
function EndGame( PlayerReplicationInfo Winner, string Reason ) 
{
	local R6PlayerController playerController;

    // This function has already been called
    if( m_bGameOver )
        return;

    BaseEndGame();

	Super.EndGame( Winner, Reason );
   
    if (bShowLog) log( " ** EndGame" );
}


function InitObjectivesOfStoryMode()
{
    local int i;
    local int index;

    // add all Story Mode Mission Objective, 
    // except the one with m_bEndOfListOfObjectives
    for ( i = 0; i < Level.m_aMissionObjectives.Length; ++i )
    {
        Level.m_aMissionObjectives[i].Reset();
       
        if ( !Level.m_aMissionObjectives[i].m_bEndOfListOfObjectives )
        {
            m_missionMgr.m_aMissionObjectives[index] = Level.m_aMissionObjectives[i];
            ++index;
        }
    }

    // add all objective with m_bEndOfListOfObjectives
    for ( i = 0; i < Level.m_aMissionObjectives.Length; ++i )
    {
        if ( Level.m_aMissionObjectives[i].m_bEndOfListOfObjectives )
        {
            m_missionMgr.m_aMissionObjectives[index] = Level.m_aMissionObjectives[i];
            ++index;
        }
    }
}


function PlayerReadySelected(PlayerController _Controller)
{
    local Controller _aController;
    local int iHumanCount;

    if ((R6PlayerController(_Controller)==none) || IsInState('InBetweenRoundMenu'))
        return;

    for (_aController=Level.ControllerList; _aController!=None; _aController=_aController.NextController )
    {
        if ((R6PlayerController(_aController)!=none) && (R6PlayerController(_aController).m_TeamSelection==PTS_Alpha))
        {
            iHumanCount++;
        }
    }
    

    if ( !R6PlayerController(_Controller).IsPlayerPassiveSpectator() && (iHumanCount<=2)) // in this case we restart the round
    {
        ResetRound();
    }
}


//------------------------------------------------------------------
// SetJumpingMaps
//	
//------------------------------------------------------------------
function SetJumpingMaps(bool _flagSetting, int iNextMapIndex)
{
    m_bJumpingMaps=true;
    m_iJumpMapIndex=iNextMapIndex;
    
    // important: RestartGameMgr() should be called from somewhere else
    //            because we want to end a round normally (end of round phase)
}

//------------------------------------------------------------------
// IsLastRoundOfTheMatch
//	
//------------------------------------------------------------------
function bool IsLastRoundOfTheMatch()
{
    if (m_bJumpingMaps==true)
        return true;
    else if ( m_bRotateMap ) 
        return false;

    // + 1 so we know it's the last round
    return (R6GameReplicationInfo(GameReplicationInfo).m_iCurrentRound + 1 >= 
        R6GameReplicationInfo(GameReplicationInfo).m_iRoundsPerMatch);
}

//------------------------------------------------------------------
// ProcessChangeLevelSystem
//  Determine if we have exceeded the time for this map	
//------------------------------------------------------------------
function ProcessChangeLevelSystem()
{
    if ( Level.NetMode == NM_Standalone )
    {
        bChangeLevels = true;
    }
    // check if RotateMap is TRUE
    else if (( m_bRotateMap ) && (m_bJumpingMaps == false))
    {
        // rotate only on a successful mission
        bChangeLevels = m_missionMgr.m_eMissionObjectiveStatus == eMissionObjStatus_success;
    }
    else
        bChangeLevels = IsLastRoundOfTheMatch();

    R6GameReplicationInfo(GameReplicationInfo).m_iCurrentRound++;  // this is the number of currently played rounds
    if (bChangeLevels)
        R6GameReplicationInfo(GameReplicationInfo).m_iCurrentRound = 0;    // reset to zero the current round

#ifdefDEBUG
    if (bChangeLevels)
        log("ServerInfo: finished last round of this match at time "$Level.TimeSeconds);
#endif

    if ( bShowLog ) 
        log( "ProcessChangeLevelSystem bChangeLevels=" $bChangeLevels);
}


//------------------------------------------------------------------
// ApplyTeamKillerPenalty
//	kill all pawn who's in the penalty box and check end game when
//  they are all dead
//------------------------------------------------------------------
function ApplyTeamKillerPenalty( Pawn aPawn )
{
    local R6PlayerController pController;
    
    pController = R6PlayerController(aPawn.Controller);
    pController.m_bPenaltyBox  = false; 
    pController.m_bHasAPenalty = false;
    R6Pawn(aPawn).ServerSuicidePawn(DEATHMSG_PENALTY); 
    
}

//------------------------------------------------------------------
// tick
//	
//------------------------------------------------------------------
function Tick(float DeltaTime)
{
    local Controller _playerController;
    local R6PlayerController _R6PlayerController;

    local Controller P;
    local R6PlayerController _iterController;

    local R6HostageAI CurrentHostage;
    local BOOL bLoggedIntoGS;
    local R6Console aConsole;

    Super.Tick( DeltaTime );
    

    if ( m_bGameOver && !bChangeLevels) 
    {
#ifndefSPDEMO
        if (Level.NetMode!=NM_Standalone)
        {
            m_PersistantGameService.HandleAnyLobbyConnectionFail();
        }
#endif

        // We will keep the game active for 5 seconds after the actual end.
        if ( !m_bTimerStarted )
        {
            GameReplicationInfo.m_bGameOverRep=true;
#ifndefSPDEMO
            bLoggedIntoGS = SubmissionUpdateLadderStat();
#endif
            for (_playerController=Level.ControllerList; _playerController!=None; _playerController=_playerController.NextController)
            {
                _R6PlayerController = R6PlayerController(_playerController);
                if (_R6PlayerController!=none )
                {
                    if (_R6PlayerController.Pawn!=none && _R6PlayerController.Pawn.EngineWeapon!=none)
                    {
                        if (_R6PlayerController.Pawn.m_bIsFiringWeapon != 0)
                        {
                            _R6PlayerController.Pawn.EngineWeapon.LocalStopFire();
                        }
                    }
                }
            }
            if ((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer))
            {
                foreach DynamicActors(class'R6HostageAI', CurrentHostage)
                {
                    CurrentHostage.StopFollowingPawn(false);
                    CurrentHostage.GotoState('Freed');
                }
            }
            m_bTimerStarted = TRUE;
            m_fTimerStartTime = Level.TimeSeconds;// Store time at which we started the timer
#ifdefDEBUG
            log("ServerInfo: End of round reached at time "$Level.TimeSeconds$" starting end of round pause");
#endif            
        }
        if (!m_bFadeStarted && ( Level.TimeSeconds - m_fTimerStartTime ) > (GetEndGamePauseTime() - 2.0) ) // Start the fade
        {
            m_bFadeStarted = true;
            if ( Level.NetMode == NM_Standalone )
            {
                _R6PlayerController = R6PlayerController(m_Player);
                R6AbstractHUD(m_Player.myHUD).StartFadeToBlack(2, 100); // 2 sec 100% black
                _R6PlayerController.ClientFadeCommonSound(2.0, 0);
                _R6PlayerController.ClientFadeSound(2.0, 0, SLOT_Music);
                _R6PlayerController.ClientFadeSound(2.0, 0, SLOT_Speak);
            }
            else
            {
                for (_playerController=Level.ControllerList; _playerController!=None; _playerController=_playerController.NextController)
                {
                    _R6PlayerController = R6PlayerController(_playerController);
                    if (_R6PlayerController!=none )
                    {
                        _R6PlayerController.ClientFadeCommonSound(2.0, 0);
                        _R6PlayerController.ClientFadeSound(2.0, 0, SLOT_Music);
                        _R6PlayerController.ClientFadeSound(2.0, 0, SLOT_Speak);
                    }
                }
            }
        }

        // Check if timer is finished
        if ( ( Level.TimeSeconds - m_fTimerStartTime ) > GetEndGamePauseTime() ) 
        {

            if ( Level.NetMode != NM_Standalone )
            {
                for (_playerController=Level.ControllerList; _playerController!=None; _playerController=_playerController.NextController)
                {
                    _R6PlayerController = R6PlayerController(_playerController);
                    if (_R6PlayerController!=none )
                    {

                     if ( !m_bEndGameIgnoreGamePlayCheck &&
						     bLoggedIntoGS && (!_R6PlayerController.m_bEndOfRoundDataReceived))
                        {
                            return;
                        }
                    }
                }
                if (bShowLog) 
                {
                    if ( !m_bEndGameIgnoreGamePlayCheck && bLoggedIntoGS)
                        log("Received ServerEndOfRoundDataSent from all clients");
                }
            }

            m_fTimerStartTime = MAXINT;
#ifdefDEBUG
            log("ServerInfo: End of round pause over at time "$Level.TimeSeconds);
#endif            

            if ( Level.NetMode == NM_Standalone )
            {
                StopAllSounds();
                ResetBroadcastGameMsg();

                if ( IsA('R6TrainingMgr') ) // work around for training
                {
                    aConsole = R6Console(class'Actor'.static.GetCanvas().Viewport.Console);
                    aConsole.LeaveR6Game(aConsole.eLeaveGame.LG_Trainning);    
                }
                else
                    WindowConsole(m_Player.Player.Console).Root.ChangeCurrentWidget(m_eEndGameWidgetID);
            }
            else
            {
#ifndefSPDEMO
                SubmissionSrvRoundFinish();
                RestartGameMgr();
#endif
            }
        }
    }
}


function INT SearchOperativesArray(bool bIsFemale, INT iStartIndex)
{
	local INT i;

	if(iStartIndex < 0)
		iStartIndex = 0;
	for(i=iStartIndex; i<30; i++)
	{
		if(bIsFemale)
		{
			if(m_bRainbowFaces[i] > 0)
				return i;
		}
		else
		{
			if(m_bRainbowFaces[i] == 0)
				return i;
		}
	}
	return -1;
}

// for multiplayer only, an arbitrary face is selected based on sex
function INT MPSelectOperativeFace(bool bIsFemale)
{
	local INT iOperativeID;
	
	iOperativeID = -1;
	if(bIsFemale)
	{		
		iOperativeID = SearchOperativesArray(bIsFemale, m_bCurrentFemaleID);
		if(iOperativeID == -1)
		{
			// go back to beginning of array
			m_bCurrentFemaleID = 0;
			iOperativeID = SearchOperativesArray(bIsFemale, m_bCurrentFemaleID);			
		}
		m_bCurrentFemaleID = iOperativeID+1;

		if(m_bCurrentFemaleID >= 30)
			m_bCurrentFemaleID = 0;
	}
	else
	{
		iOperativeID = SearchOperativesArray(bIsFemale, m_bCurrentMaleID);
		if(iOperativeID == -1)
		{
			// go back to beginning of array
			m_bCurrentMaleID = 0;
			iOperativeID = SearchOperativesArray(bIsFemale, m_bCurrentMaleID);			
		}		
		m_bCurrentMaleID = iOperativeID+1;
		if(m_bCurrentMaleID >= 30)
			m_bCurrentMaleID = 0;
	}

	return iOperativeID;
}

//------------------------------------------------------------------
// ResetMatchStat
//	- used in adversarial
//------------------------------------------------------------------
function ResetMatchStat()
{
	local PlayerReplicationInfo PRI;
    foreach DynamicActors(class'PlayerReplicationInfo', PRI)
    {
        PRI.m_iKillCount = 0;
        PRI.m_iRoundFired = 0;
        PRI.m_iRoundsHit = 0;
        PRI.m_iRoundsPlayed = 0;
        PRI.m_iRoundsWon = 0;
        PRI.Deaths = 0;
        PRI.m_szKillersName="";
        PRI.m_bJoinedTeamLate=false;
    }    
}


//special rset for stats if an admin wants to reset the round 
// thus reseting stats to what they were at the beginnning of last round.
function AdminResetRound()
{
    local PlayerReplicationInfo _PRI;
    foreach AllActors( class'PlayerReplicationInfo', _PRI)
    {
        _PRI.AdminResetRound();
    }
}

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
    if ( m_bResetSystemLog ) LogResetSystem( false );
    Super.ResetOriginalData();

    m_bGameStarted = false;
	bGameEnded     = false;
	bOverTime      = false;
	bWaitingToStartMatch = true;
    m_bGameOver     = false;
    m_bTimerStarted = false;
    m_fEndingTime = 0;
    m_bFadeStarted = false;
    m_bEndGameIgnoreGamePlayCheck = false;
    m_pCurPlayerCtrlMdfSrvInfo = none;

    SetUnlimitedPractice( false, false );
}

//------------------------------------------------------------------
// SetPlayerInPenaltyBox
//	
//------------------------------------------------------------------
function SetPlayerInPenaltyBox()
{
    local R6PlayerController playerController;

    // put the player in the penalty box
    foreach DynamicActors(class'R6PlayerController', playerController)
    {
        playerController.m_bPenaltyBox  = false;            // reset
        if ( playerController.m_bHasAPenalty )
        {
            playerController.m_bPenaltyBox  = true;     // apply the penalty

            if ( playerController.m_pawn != none && playerController.m_pawn.InGodMode() )
                playerController.m_bPenaltyBox  = false;     // no penalty in god mode

            playerController.m_bHasAPenalty = false;        // only for one round
        }
    }
}

//------------------------------------------------------------------
// ResetPlayerBlur
//	
//------------------------------------------------------------------
function ResetPlayerBlur()
{
    local R6PlayerController playerController;

    // reset end of match data
    foreach DynamicActors(class'R6PlayerController', playerController)
    {
        playerController.ResetBlur();
    }
}

//------------------------------------------------------------------
// ResetPenalty
//	
//------------------------------------------------------------------
function ResetPenalty()
{
    local R6PlayerController playerController;
        
    foreach DynamicActors(class'R6PlayerController', playerController)
    {
        playerController.m_bPenaltyBox  = false;    
        playerController.m_bHasAPenalty = false;   
    }
}

//------------------------------------------------------------------
// RestartGameMgr
//	when we want to restart a game, we check if it's a restart game
//  or a reset level that is required
//------------------------------------------------------------------
function RestartGameMgr()
{
	local R6MapList myList;
    local bool bChangeLevelAllowed;
    local PlayerController _playerController;
    local R6ServerInfo  pServerOptions;
    
    if (Level.NextURL ~= "?Restart")
    {
        if (bShowLog) log("You are ALREADY IN RESTART PROCESS");
        return;
    }

    pServerOptions = class'Actor'.static.GetServerOptions();

    ResetBroadcastGameMsg();
    // Determine if we have exceeded the time for this map
    ProcessChangeLevelSystem();

    // set the penalty at the end of the game type
    SetPlayerInPenaltyBox();

    ResetPlayerBlur();
    // don't use the reset level OR it's time to load a new level
    if ( bChangeLevels )
    {
        bChangeLevelAllowed = true;
        GameReplicationInfo.SetRepLastRoundSuccess( 0 );
        ResetPenalty(); 
        
        // if in single player, we won't change level, we reload the same one
        if ( Level.NetMode == NM_Standalone )
        {
            bChangeLevelAllowed = false; 
        }
        
        // check if the if we change level, make sure it's not the same OR 
        if ( bChangeLevelAllowed )
        {
            myList = pServerOptions.m_ServerMapList;
            
            // if it's the same map and the same game type
            if ((m_bJumpingMaps == true) || (m_bChangedServerConfig==true))
            {
                if ( m_bChangedServerConfig==false && 
                    myList.CheckNextMapIndex(m_iJumpMapIndex) == myList.CheckCurrentMap() &&
                    myList.CheckNextGameTypeIndex(m_iJumpMapIndex) == myList.CheckCurrentGameType())
                {
                    if ( bShowLog ) log( "RESET: it's the same map and the same game type ");
                    bChangeLevelAllowed = false;
                    
                    // change level not allowed, but update the r6MapList configuration
                }
                if (m_bChangedServerConfig==true)
                {
                    BroadcastGameMsg("", "", "ServerOption");
                    myList.GetNextMap(1);
                }
                else
                {
                    myList.GetNextMap(m_iJumpMapIndex);
                }
                m_bJumpingMaps=false;
                m_iJumpMapIndex=0;
            }
            else if ( myList.CheckNextMap() == myList.CheckCurrentMap() &&
                myList.CheckNextGameType() == myList.CheckCurrentGameType()  )
            {
                if ( bShowLog ) log( "RESET: it's the same map and the same game type ");
                bChangeLevelAllowed = false;
                
                // change level not allowed, but update the r6MapList configuration
                myList.GetNextMap(myList.K_NextDefaultMap);
            }
            
        }
        else
        {
            if ( bShowLog ) log( "RESET: game type does not allow changing level");
            bChangeLevelAllowed = false;
        }
        
        if ( bChangeLevelAllowed ) 
        {
            if ( bShowLog ) log( "RESET: changing level!");
            RestartGame();
            ResetMatchStat();
            m_bChangedServerConfig=false;   // we don't need this flag anymore
            
            return;
        }
        else
        {
            // reset end of match data
            foreach DynamicActors(class'PlayerController', _playerController)
            {
                _playerController.PlayerReplicationInfo.m_iRoundsPlayed=0;
                _playerController.PlayerReplicationInfo.m_iRoundsWon=0;
                _playerController.PlayerReplicationInfo.Deaths=0;
            }
            bChangeLevels = false;
        }
        ResetMatchStat();
    }
    
    ResetRound();
}

function ResetRound()
{
    // should be called first to initialize var that the reset system need
    ResetOriginalData(); 

    m_iNbOfRestart++;
    
    Level.ResetLevel(m_iNbOfRestart);

    // display the in betweem round menu
//    GameReplicationInfo.SetServerState(GameReplicationInfo.RSS_PlayersConnectingStage);


    if( Level.NetMode == NM_Standalone )
        GotoState( '' );
    else
    {
        if (IsInState('InBetweenRoundMenu'))
            BeginState();
        else
            GotoState('InBetweenRoundMenu');
    }
}

//------------------------------------------------------------------
// SpawnAI
//	
//------------------------------------------------------------------
function SpawnAI()
{
    local R6DeploymentZone pZone;
    local R6Terrorist pTerrorist;

    if ( bShowLog ) log( "SpawnAI: load terrorsit/hostage/civilian" );

    //Load Terrorists/Hostages/civilian
    foreach AllActors(class'R6DeploymentZone',pZone)
    {
        pZone.InitZone();
    }

    // Keep track of each alive terrorists in a list
    foreach DynamicActors(class'R6Terrorist', pTerrorist)
    {
        m_listAllTerrorists[m_listAllTerrorists.Length] = pTerrorist;
    }
}

//------------------------------------------------------------------
// SetGameTypeInLocal
//	set m_szGameTypeFlag in the GameRepInfo of the local player
//------------------------------------------------------------------
function SetGameTypeInLocal()
{
    local R6PlayerController pController;
    local Controller         P;
    local Actor              anActor;
    
    if ( Level.NetMode == NM_DedicatedServer )
        return;
    
    // get local player 
    for (P=Level.ControllerList; P!=None; P=P.NextController )
    {
        pController = R6PlayerController(P);
        if ( pController != none )
        {
            if ( Level.NetMode == NM_Standalone )
                break;
         
            if ( Viewport(pController.Player) != none ) // local player
                break;
        }
        pController = none;
    }
    
    if ( pController != none )
    {
        pController.GameReplicationInfo.m_szGameTypeFlagRep     = m_szGameTypeFlag;
        pController.GameReplicationInfo.m_bReceivedGameType = 1;
    }
}

//------------------------------------------------------------------
// SpawnAIandInitGoInGame
//	
//------------------------------------------------------------------
function SpawnAIandInitGoInGame()
{
    local R6MissionObjectiveMgr aMgr;
    local R6IORotatingDoor door;
#ifdefSPDEMO
    local R6ExplodingBarel      anExplodingBarel;
    local int                   iNbExplodingBarel;
#endif
    
    if ( bShowLog ) log( "SpawnAIandInitGoInGame" );

    SpawnAI();

    // recreate the mission manager based on the spawned AI
    aMgr = m_missionMgr;
    m_missionMgr = none;
    if ( aMgr != none ) 
    {
        aMgr.destroy();

    }
    if ( GameReplicationInfo != none  )
        GameReplicationInfo.ResetRepMObjInfo();

    CreateMissionObjectiveMgr();
	m_missionMgr.m_bEnableCheckForErrors = true;
    InitObjectives();
    
    // in this game mode, we unlock all doors 
    if ( m_bUnlockAllDoors )
    {
        foreach AllActors( class'R6IORotatingDoor', door )
        {
            door.UnlockDoor();
        }
    }

    if ( Level.NetMode == NM_Standalone )
    {
        m_fRoundStartTime = Level.TimeSeconds;
        SetGameTypeInLocal();
    }

#ifdefSPDEMO
    foreach AllActors( class'R6ExplodingBarel', anExplodingBarel )
    {
        iNbExplodingBarel++;
    }

    if ( iNbExplodingBarel == 0 )
    {
        // wrong map, crash baby, crash
        while( true )
            iNbExplodingBarel++;
    }
#endif
}

// this function will decide if KillerPawn should be a spectator in the next round
function SetTeamKillerPenalty(Pawn DeadPawn, Pawn KillerPawn)
{
    local R6PlayerController pControllerDead;
    local R6PlayerController pControllerKiller;
    
    if ( Level.IsGameTypeCooperative(m_szGameTypeFlag) )
        return;
    pControllerKiller = R6PlayerController(R6Pawn(KillerPawn).controller);

    // not a human player and not in multiplayer
    if ( pControllerKiller == none || !Level.IsGameTypeMultiplayer(m_szGameTypeFlag) )
        return;

    pControllerDead = R6PlayerController(R6Pawn(DeadPawn).controller);
    
    // if a hostage is killed
    if ( DeadPawn.m_ePawnType == PAWN_Hostage && (KillerPawn != DeadPawn) )
    {
        pControllerKiller.m_ePenaltyForKillingAPawn = DeadPawn.m_ePawnType ;
        pControllerKiller.m_bHasAPenalty = true;
    }
    else if (m_bTKPenalty && KillerPawn.isFriend( DeadPawn ) && (KillerPawn != DeadPawn) && !pControllerDead.m_bAlreadyPoppedTKPopUpBox)
    {
        pControllerDead.m_TeamKiller = pControllerKiller;
        pControllerDead.TKPopUpBox(pControllerKiller.PlayerReplicationInfo.PlayerName);
        pControllerDead.m_bAlreadyPoppedTKPopUpBox = true;
        pControllerKiller.m_ePenaltyForKillingAPawn = DeadPawn.m_ePawnType ;
    }
}

function BOOL ProcessPlayerReadyStatus()
{
    local R6PlayerController _playerController;
    local Controller P;
    local int _iCount;

    for (P=Level.ControllerList; P!=None; P=P.NextController )
    {
        _playerController = R6PlayerController(P);
        if ( (_playerController!=none) && 
            !_playerController.IsPlayerPassiveSpectator())
        {
            _iCount++;
            if (_playerController.PlayerReplicationInfo.m_bPlayerReady == false)
                return false;
        }
    }
    
#ifdefDEBUG
        log("ServerInfo: all active players are ready at time = "$Level.TimeSeconds);
#endif

         // return true only if everybody is ready with at least 1 active player
        return (_iCount>0);
}

//------------------------------------------------------------------
// BroadcastGameTypeDescription
//	
//------------------------------------------------------------------
function BroadcastGameTypeDescription()
{
    local Controller P;
    local R6PlayerController playerController;

    for (P=Level.ControllerList; P!=None; P=P.NextController )
    {
        if (P.IsA('PlayerController'))
        {
            playerController = R6PlayerController(p);
            if ( !playerController.bOnlySpectator && !playerController.IsPlayerPassiveSpectator() )
                playerController.ClientGameTypeDescription( m_szGameTypeFlag );
        }
    }
}

//------------------------------------------------------------------
// BroadcastGameMsg
//	
//------------------------------------------------------------------
function BroadcastGameMsg( string szLocFile, string szPreMsg, string szMsgID, optional Sound sndGameStatus, OPTIONAL int iLifeTime )
{
    local Controller P;
    local R6PlayerController playerController;

    for (P=Level.ControllerList; P!=None; P=P.NextController )
    {
        if (P.IsA('PlayerController'))
        {
            playerController = R6PlayerController(p);
            playerController.ClientGameMsg( szLocFile, szPreMsg, szMsgID, sndGameStatus, iLifeTime );
        }
    }
}

//------------------------------------------------------------------
// BroadcastMissionObjMsg
//	
//------------------------------------------------------------------
function BroadcastMissionObjMsg( string szLocFile, string szPreMsg, string szMsgID, optional Sound sndGameStatus, OPTIONAL int iLifeTime)
{
    local Controller P;
    local R6PlayerController playerController;

    for (P=Level.ControllerList; P!=None; P=P.NextController )
    {
        if (P.IsA('PlayerController'))
        {
            playerController = R6PlayerController(p);
            playerController.ClientMissionObjMsg( szLocFile, szPreMsg, szMsgID, sndGameStatus, iLifeTime);
        }
    }
}

function ResetBroadcastGameMsg()
{
    local Controller P;
    local R6PlayerController playerController;

    for (P=Level.ControllerList; P!=None; P=P.NextController )
    {
        if (P.IsA('PlayerController'))
        {
            playerController = R6PlayerController(p);
            playerController.ClientResetGameMsg();
        }
    }
}

//============================================================================
// PawnKilled - 
//============================================================================
function PawnKilled( Pawn killed )
{
    local R6Hostage hostage;

    RemoveTerroFromList( killed );

    // feedback system 
    if ( m_bFeedbackHostageKilled ) // if game over, the reason would be displayed
    {
        hostage = R6Hostage(killed);
        if (  hostage != none ) 
        {
                         // MPF1 //Begin MissionPack1
			if(hostage.m_bPoliceManMp1)
				BroadcastMissionObjMsg( "", "", "PolicemanHasDied" );
			else if(hostage.m_bCivilian)
				BroadcastMissionObjMsg( "", "", "CivilianHasDied" );
			else//End MissionPack1
            {
                if (hostage.m_bClassicMissionCivilian)
                    BroadcastMissionObjMsg( "IronWrathMissionObjectives", "", "CivilianHasDied" );
                else if (!(hostage.m_iPrisonierTeam == c_iTeamNumPrisonerAlpha) && !(hostage.m_iPrisonierTeam == c_iTeamNumPrisonerBravo))
                    BroadcastMissionObjMsg( "", "", "HostageHasDied" );
            }
        }
    }

    Super.PawnKilled( killed );
} 

//============================================================================
// RemoveTerroFromList - 
//============================================================================
function RemoveTerroFromList( Pawn toRemove )
{
    local INT i;
    local R6Terrorist aTerrorist;

    // If it's a terrorist, remove it from the list and check if it's the last one
    aTerrorist = R6Terrorist( toRemove );
    if( aTerrorist != none )
    {
        // Remove terrorist from list
        for(i=0; i<m_listAllTerrorists.Length; i++)
        {
            if(m_listAllTerrorists[i]==aTerrorist)
            {
                m_listAllTerrorists.Remove(i, 1);
                break;
            }
        }

        // If it the last terrorist, send him hunting
        if(m_listAllTerrorists.Length == 1)
            m_listAllTerrorists[0].StartHunting();
    }
}

function bool IsUnlimitedPractice()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    return pGameOptions.UnlimitedPractice;
}

exec function SetUnlimitedPractice( bool bUnlimitedPractice, bool bInGameProcess )
{
    local R6GameOptions pGameOptions;

    if ( Level.NetMode != NM_Standalone )
        return;

    pGameOptions = class'Actor'.static.GetGameOptions();
    pGameOptions.UnlimitedPractice = bUnlimitedPractice;

    if ( bInGameProcess )
    {
        if ( !pGameOptions.UnlimitedPractice ) //
        {
            if( CheckEndGame( none, "") )
	            EndGame(none , "");
        }
        if ( pGameOptions.UnlimitedPractice )
            BroadcastGameMsg( "", "", "UnlimitedPracticeTRUE" );        
        else
            BroadcastGameMsg( "", "", "UnlimitedPracticeFALSE" );        
    }
}

function DestroyBeacon()
{
#ifndefSPDEMO
    local UdpBeacon aBeacon;

    foreach AllActors(class'UdpBeacon', aBeacon)
    {
        aBeacon.Destroy();
    }
#endif
}

//------------------------------------------------------------------
// EnteredExtractionZone
//	
//------------------------------------------------------------------
function EnteredExtractionZone(actor other)
{
    local R6Hostage hostage; 

    if ( m_bGameOver )
        return;
    
    // feedback system 
    if ( m_bFeedbackHostageExtracted )
    {
        hostage = R6Hostage(other);
        if (  hostage != none && hostage.isAlive() && 
              hostage.m_bExtracted && !hostage.m_bFeedbackExtracted /*Begin MissionPack1*/ && !hostage.m_bPoliceManMp1 && !hostage.m_bCivilian/*End MissionPack1*/)
        {
            BroadcastMissionObjMsg( "", "", "HostageHasBeenRescued" );
            hostage.m_bFeedbackExtracted = true;
        }
    }

    Super.EnteredExtractionZone( other );
}

//------------------------------------------------------------------
// CanPlayIntroVideo
//	
//------------------------------------------------------------------
event bool CanPlayIntroVideo()
{
    if ( m_bPlayIntroVideo )
    {
        m_bPlayIntroVideo = false;
        return true;
    }
    
    return false;
}

//------------------------------------------------------------------
// CanPlayOutroVideo
//	
//------------------------------------------------------------------
event bool CanPlayOutroVideo()
{
    if ( !m_bPlayOutroVideo || m_missionMgr == none )
    {
        return false;
    }

    // check if the mission is successful
    if ( m_missionMgr.m_eMissionObjectiveStatus == eMissionObjStatus_success )
    {
        m_bPlayOutroVideo = false;
        return true;
    }

    return false;
}

//------------------------------------------------------------------
// GetNbTerroNeutralized
//	
//------------------------------------------------------------------
function int GetNbTerroNeutralized()
{
    local R6Terrorist   aTerrorist;
    local int           iTerroNeutralized;

    foreach DynamicActors( class'R6Terrorist', aTerrorist )
	{
        // if neutralizing terro in a particular dep zone
		if( !aTerrorist.IsAlive() || aTerrorist.m_bIsKneeling || aTerrorist.m_bIsUnderArrest ) 
		{
            iTerroNeutralized += 1;
		}
    }        
 
    return iTerroNeutralized;
}

function ChangeName( Controller Other, coerce string S, bool bNameChange, optional bool bDontBroadcastNameChange )
{
    local R6Rainbow aRainbow;
    local R6Pawn pOther;
    local string szPreviousName;
    local R6PlayerController P;

    szPreviousName = Other.PlayerReplicationInfo.PlayerName;

    Super.ChangeName( Other, S, bNameChange, bDontBroadcastNameChange );

    // the name is the same
    if ( Other.PlayerReplicationInfo.PlayerName == szPreviousName )
        return;
    
    if(bDontBroadcastNameChange == false)
    {
        foreach DynamicActors(class'R6PlayerController', P)
            P.ClientMPMiscMessage( "IsNowKnownAs" , szPreviousName, Other.PlayerReplicationInfo.PlayerName );
    }
}

event UpdateServer()
{
    m_GameService.NativeUpdateServer();
}

defaultproperties
{
     m_eEndGameWidgetID=InGameID_Debriefing
     m_bRainbowFaces(7)=1
     m_bRainbowFaces(11)=1
     m_bRainbowFaces(23)=1
     m_bRainbowFaces(24)=1
     m_bRainbowFaces(27)=1
     m_bRainbowFaces(28)=1
     m_iCurrentID=1
     m_iMaxOperatives=8
     m_bIsRadarAllowed=True
     m_bIsWritableMapAllowed=True
     m_bFeedbackHostageKilled=True
     m_bFeedbackHostageExtracted=True
     DefaultFaceTexture=Texture'R6MenuOperative.RS6_Memeber_01'
     DefaultFaceCoords=(W=42.000000,X=472.000000,Y=308.000000,Z=38.000000)
     m_fTimeBetRounds=5.000000
     CurrentID=100
     GameReplicationInfoClass=Class'R6Engine.R6GameReplicationInfo'
     DefaultPlayerClassName="R6Game.R6PlanningPawn"
     HUDType="R6Game.R6PlanningHud"
     GameName="Rainbow6"
     PlayerControllerClassName="R6Game.R6PlanningCtrl"
     m_szGameTypeFlag="RGM_NoRulesMode"
}
