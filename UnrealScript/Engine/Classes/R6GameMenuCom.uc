//=============================================================================
//  R6GameMenuCom.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/25 * Created by Aristomenis Kolokathis
//=============================================================================
class R6GameMenuCom extends object
    native;
    

// team selection for team that the player requested in the menus
enum eClientMenuState
{
    CMS_Initial,            // this is before we know what state the server is in
    CMS_SpecMenu,           // check tab, menus has icons
    CMS_BetRoundmenu,       // always display, has icons
    CMS_DisplayStat,        // check for tab, no icons
    CMS_DisplayForceStat,   // forced CMS_DisplayStat at end of round
    CMS_PlayerDead,          // player is dead, same thing than CMS_BetRoundmenu, but the menu is activable or not by tab
    CMS_DisplayForceStatLocked,  //Bring up the stat page and lock it
	CMS_InPreGameState		// close the gear pop-up menu...
};

var eClientMenuState m_eStatMenuState;

struct PlayerPrefInfo
{
    var string m_CharacterName;
    var string m_ArmorName;
    var string m_WeaponName[2];
    var string m_WeaponGadgetName[2];
    var string m_BulletType[2];
    var string m_GadgetName[2];
};

// weapons can change between rounds and we need to keep track of
// the weapon player has used the most.

var PlayerPrefInfo m_PlayerPrefInfo;    // when this is updated, make sure to call SavePlayerSetupInfo() after;

//Weapons Descriptions
var string      m_szPrimaryWeapon;            //R6PrimaryWeaponDescription class name
var string      m_szPrimaryWeaponGadget;      //Token representing type of weapon gadget
var string      m_szPrimaryWeaponBullet;      //Token representing type of bullets
var string      m_szPrimaryGadget;            //R6GadgetDescription class name
var string      m_szSecondaryWeapon;          //R6SecondaryWeaponDescription class name
var string      m_szSecondaryWeaponGadget;    //Token representing type of weapon gadget
var string      m_szSecondaryWeaponBullet;    ///Token representing type of bullets
var string      m_szSecondaryGadget;          //R6GadgetDescription class name
var string      m_szArmor;                    //R6ArmorDescription class name

var PlayerController m_PlayerController;
var GameReplicationInfo m_GameRepInfo;

var INT			m_iLastValidIndex;
var string		m_szServerName;
var string		m_szPreviousGameType;		  // this was the mode played in the last round
var INT			m_iOldMapIndex;				  // used to determine if map has been rotated

var BOOL		m_bImCurrentlyDisconnect;	  // when we are in disconnecting process
var BOOL		bShowLog;

// PostBeginPlays are generally called on actors by native code
// since this is now an object it's PostBeginPlay get's called by
// R6MenuInGameMultiPlayerRootWindow.uc, this is the object that
// created this instance
function PostBeginPlay()
{
    InitialisePlayerSetupInfo();
}

function ClearLevelReferences()
{
    m_PlayerController = none;
    m_GameRepInfo=none;
}

//====================================================================================
// IsInitialisationComplete: true when the initialisation is complete
//====================================================================================
function BOOL IsInitialisationCompleted()
{
    return ((m_PlayerController != None) && (m_GameRepInfo != None));
}

//=======================================================================================
// GetGameType: Get the game mode (game type for the menus) of the game
//=======================================================================================
simulated function string GetGameType();

simulated function InitialisePlayerSetupInfo();
simulated function SavePlayerSetupInfo();
simulated function SelectTeam();
function SetupPlayerPrefs();

function TKPopUpBox(string _KillerName);
function TKPopUpDone(BOOL _bApplyTeamKillerPenalty);
function ActiveVoteMenu( BOOL _bActiveMenu, optional string _szPlayerNameToKick);
function SetClientServerSettings(bool _bCanChangeOptions);
function CountDownPopUpBox();
function CountDownPopUpBoxDone();


function PlayerSelection(ePlayerTeamSelection newTeam)
{
    local int _TeamACount, _TeamBCount;

    if (newTeam==PTS_UnSelected)    // error impossible selection
    {
        log("ERROR: Menu engine returned PTS_UnSelected as player team");
        return;
    }

    RefreshReadyButtonStatus();

    // if we are already on this team
    if( newTeam == m_PlayerController.m_TeamSelection)
    {
		SetStatMenuState( CMS_BetRoundmenu);
        return; // just return
    }

    if (m_GameRepInfo.IsInAGameState())
    {
        if ((newTeam == PTS_Spectator) || !m_GameRepInfo.m_bRestartableByJoin)
        {
            if (m_PlayerController.pawn == none)
            {
			    // game is already in progress, so once player has chosen team go directly into spectator camera
			    m_PlayerController.m_bReadyToEnterSpectatorMode = true;
		        m_PlayerController.Fire(0);
            }
            LoadSoundBankInSpectator();
            SetStatMenuState( CMS_SpecMenu );//m_eStatMenuState = CMS_SpecMenu;
        }
        else
        {
		    SetStatMenuState( CMS_BetRoundmenu);//m_eStatMenuState = CMS_BetRoundmenu;
        }
    }
    else
    {
		SetStatMenuState( CMS_BetRoundmenu);//m_eStatMenuState = CMS_BetRoundmenu;
        if (newTeam == PTS_Spectator)
        {
            LoadSoundBankInSpectator();
        }
    }

    m_PlayerController.ServerTeamRequested(newTeam); // the controller responsible for updating server
    SavePlayerSetupInfo();
    m_szPreviousGameType = GetGameType();
}

function LoadSoundBankInSpectator()
{
   if (!m_PlayerController.m_bLoadSoundGun)
   {
        m_PlayerController.m_bLoadSoundGun=true;
        m_PlayerController.ServerReadyToLoadWeaponSound();
   }
}

function ePlayerTeamSelection IntToPTS(int InInt)
{
    switch (InInt)
    {
    case 0:
        return PTS_UnSelected;
    case 1:
        return PTS_AutoSelect;
    case 2:
        return PTS_Alpha;
    case 3:
        return PTS_Bravo;
    case 4:
        return PTS_Spectator;
    }
}

function INT PTSToInt(ePlayerTeamSelection inEnum)
{
    local byte bCast;
    bCast = inEnum;
    return bCast;
}

function RefreshMPlayerInfo()
{
    if (m_GameRepInfo!=none)
        m_GameRepInfo.RefreshMPlayerInfo();
}

// this returns an INT so that we can know where to display the player on
// the tab menu page
function INT GeTTeamSelection( INT _iIndex);

function NewServerState()
{
    if (m_GameRepInfo == none)
        return;
    RefreshReadyButtonStatus();
    if ( (m_GameRepInfo.m_eCurrectServerState==m_GameRepInfo.RSS_CountDownStage) ||
        (m_GameRepInfo.m_eCurrectServerState==m_GameRepInfo.RSS_PlayersConnectingStage))
    {
        SetPlayerReadyStatus(false);
    }
	else if (m_GameRepInfo.m_eCurrectServerState==m_GameRepInfo.RSS_InPreGameState)
	{
		SetStatMenuState(CMS_InPreGameState);
	}
    else if (m_GameRepInfo.m_eCurrectServerState==m_GameRepInfo.RSS_InGameState)
    {
        if( m_PlayerController.m_TeamSelection==PTS_Alpha || m_PlayerController.m_TeamSelection==PTS_Bravo )
        {
            SetPlayerReadyStatus(true);
            if (!m_PlayerController.bOnlySpectator)
                SetStatMenuState( CMS_DisplayStat);
        }
        else
        {			
            SetStatMenuState( CMS_SpecMenu);
        }
    }
    else if (m_GameRepInfo.m_eCurrectServerState==m_GameRepInfo.RSS_EndOfMatch)
    {
        SetPlayerReadyStatus(false);
        if ((m_PlayerController.pawn != none) && (m_PlayerController.pawn.EngineWeapon != none))
        {
            m_PlayerController.pawn.EngineWeapon.GotoState('');
        }
        if(bShowLog)log("NewServerState() m_GameRepInfo.RSS_EndOfMatch");
        SetStatMenuState( CMS_DisplayForceStat);
    }
}

//=====================================================================
// SetStatMenuState : set the new statmenustate
//=====================================================================
function SetStatMenuState( eClientMenuState _eNewClientMenuState);

//====================================================================================
// SetPlayerReadyStatus: Set the ready button status of the player
//====================================================================================
function SetPlayerReadyStatus( BOOL _bPlayerReady)
{
    if (_bPlayerReady == m_PlayerController.PlayerReplicationInfo.m_bPlayerReady)
        return;
	m_PlayerController.PlayerReplicationInfo.m_bPlayerReady = _bPlayerReady;
    m_PlayerController.ServerSetPlayerReadyStatus(_bPlayerReady);
}

//function SetMenuPlayerReadyStatus(BOOL _bPlayerReady)
//{
//    if (_bPlayerReady == m_bPlayerReady)
//        return;
//    m_bPlayerReady=_bPlayerReady;
//    m_MenuCommunication.m_bPlayerReady = _bPlayerReady;
//}


//====================================================================================
// SetReadyButton: Set the ready button state in the menu (disable when the player play or  -- spectator)
// set this to true when the game is in session, or someone joins as spectator, false otherwise
//====================================================================================
function RefreshReadyButtonStatus();
function SetReadyButton( BOOL _bDisable)
{
//    if (m_PlayerController.m_TeamSelection == PTS_Spectator) ||
//       (m_PlayerController.m_TeamSelection == PTS_UnSelected)
////       (game IN progress))
//	//TODO
}


//====================================================================================
// GetPlayerReadyStatus: Get the ready button status of the player
//====================================================================================
function BOOL GetPlayerReadyStatus()
{
	return m_PlayerController.PlayerReplicationInfo.m_bPlayerReady;
}

//====================================================================================
// GetPlayerDidASelection: 
//====================================================================================
function BOOL GetPlayerDidASelection();

//====================================================================================
// DisconnectClient: Disconnect the client from the server
//====================================================================================
function DisconnectClient( LevelInfo _Level );

simulated function bool IsInGame()
{
    return false;
}

defaultproperties
{
}
