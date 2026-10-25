//=============================================================================
//  R6GameReplicationInfo.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/10 * Created by Aristomenis Kolokathis
//=============================================================================

class R6GameReplicationInfo extends GameReplicationInfo
	native;

var             R6RainbowTeam       m_RainbowTeam[3];
//var             R6RainbowTeam       m_RainbowPlayerTeam;   // assigned to the above team that the player is leading.
// if mission ended successfully, this var is set in GameInfo classes, such as R6TerroristHuntGame and is used
// by such places as the player's hud for special processing.


var INT           m_iDeathCameraMode;         // Camer mode used for dead players
var BOOL          bShowLog;
var R6GameMenuCom m_MenuCommunication;
var string        m_szCurrGameType;
var INT           m_MaxPlayers;
//var FLOAT         m_fTimeMap;
var INT           m_iCurrentRound;     // this is the current round in this match
var INT           m_iRoundsPerMatch;
var INT			  m_iDiffLevel;				 // The difficulty level of the terro -- in coop 
var INT			  m_iNbOfTerro;				 // The number of terro -- in coop
var FLOAT         m_fTimeBetRounds;
var BOOL          m_bPasswordReq;
var BOOL          m_bAdminPasswordReq;
const m_MapLength = 32;                      // The size of the map and game mode array.
var string        m_mapArray[m_MapLength];
var string        m_gameModeArray[m_MapLength];
var string        m_szSubMachineGunsRes[32]; // Primary weapon: List of restricted sub maching guns
var string        m_szShotGunRes[32];        // Primary weapon: Shotguns restricted
var string        m_szAssRifleRes[32];       // Primary weapon: Assault rifles restricted
var string        m_szMachGunRes[32];        // Primary weapon: Machine Guns restricted
var string        m_szSnipRifleRes[32];      // Primary weapon: Sniper rifles restricted
var string        m_szPistolRes[32];         // Secondary weapon: Pistols restricted
var string        m_szMachPistolRes[32];     // Secondary weapon: Machine pistols restricted
var string        m_szGadgPrimaryRes[32];    // Gadget: primary weapon restricted
var string        m_szGadgSecondayRes[32];   // Gadget: secondary restricted
var string        m_szGadgMiscRes[32];       // Gadget: misceleaneous restricted
var BOOL          m_bFriendlyFire;
var BOOL          m_bAutoBalance;
var BOOL          m_bTKPenalty;               // this is the Team killer penalty setting as seen by the game mode
var BOOL          m_bMenuTKPenaltySetting;    // This is the Team killer penalty setting as set in the menus
var BOOL		  m_bShowNames;
var FLOAT         m_fBombTime;
var BOOL          m_bInternetSvr;             // The server is a internet server
var BOOL          m_bFFPWeapon;               // Force first person weapons
var BOOL          m_bDedicatedSvr;            // The server is a dedicated server
var BOOL		  m_bAIBkp;					  // AI backup
var BOOL		  m_bRotateMap;				  // in coop, rotate map automatically if it's true
var INT           m_iMenuCountDownTime;
var FLOAT         m_fRepMenuCountDownTime;
var FLOAT         m_fRepMenuCountDownTimeLastUpdate;
var BOOL          m_bRepMenuCountDownTimePaused;
var BOOL          m_bRepMenuCountDownTimeUnlimited;


var int           m_aTeamScore[2]; 

var bool m_bIsWritableMapAllowed; // in some game type, the writablemap can't be used (ie: deathmatch)


var const INT c_iTeamNumBravo;

simulated function FirstPassReset()
{
    m_RainbowTeam[0] = none;
    m_RainbowTeam[1] = none;
    m_RainbowTeam[2] = none;
}

replication
{
    unreliable if (Role==ROLE_Authority )
        m_fRepMenuCountDownTime,m_aTeamScore,m_iCurrentRound,m_bRepMenuCountDownTimePaused,m_bRepMenuCountDownTimeUnlimited;

    unreliable if (bNetInitial && Role==ROLE_Authority )
        m_mapArray, m_gameModeArray, m_iRoundsPerMatch,m_fTimeBetRounds,
        m_bPasswordReq,m_bAdminPasswordReq,m_iDeathCameraMode,m_szCurrGameType,
        m_bFriendlyFire, m_bAutoBalance, m_bTKPenalty, m_bMenuTKPenaltySetting, m_bShowNames, m_MaxPlayers,
        m_bIsWritableMapAllowed, m_fBombTime, m_bInternetSvr,
        m_bFFPWeapon, m_bDedicatedSvr, 
		m_bAIBkp, m_bRotateMap, m_iDiffLevel, m_iNbOfTerro;

    unreliable if (Role==ROLE_Authority)
        m_szSubMachineGunsRes, m_szShotGunRes, m_szAssRifleRes, 
        m_szMachGunRes, m_szSnipRifleRes, m_szPistolRes, m_szMachPistolRes,
        m_szGadgPrimaryRes,  m_szGadgSecondayRes, m_szGadgMiscRes;
}

simulated event Tick(FLOAT fDeltaTime)
{
    Super.Tick(fDeltaTime);

    if ((Level.NetMode == NM_Client) && !m_bRepMenuCountDownTimePaused && !m_bRepMenuCountDownTimeUnlimited)
    {
        m_fRepMenuCountDownTime -= fDeltaTime;
        if(m_fRepMenuCountDownTime < 0.0f)
            m_fRepMenuCountDownTime = 0.0f;
    }
}

simulated event FLOAT GetRoundTime()
{
    if(Level.NetMode == NM_ListenServer)
		return m_iMenuCountDownTime;

    return m_fRepMenuCountDownTime;
}

simulated function ControllerStarted(R6GameMenuCom NewMenuCom)
{
    m_MenuCommunication = NewMenuCom;
}

simulated event Destroyed()
{
    Super.Destroyed();
    if (m_MenuCommunication!=none)
    {
        m_MenuCommunication.ClearLevelReferences();
    }
}

function PlaySoundStatus();

simulated function RefreshMPlayerInfo()
{
    m_MenuCommunication.m_iLastValidIndex=0;
    m_MenuCommunication.m_szServerName=ServerName;
    RefreshMPInfoPlayerStats();
}    

simulated function RefreshMPInfoPlayerStats()
{
	local PlayerReplicationInfo PRI;
    local PlayerMenuInfo _PlayerMenuInfo;
    local INT _iLastValidIndex;

    foreach DynamicActors(class'PlayerReplicationInfo', PRI)
    {
        if (bShowLog) log("RefreshMPlayerInfo Index:"@_iLastValidIndex@
            "PRI is"@PRI@"Name is"@PRI.PlayerName);
        
        if (PRI.m_iRoundsHit>0)
        {
            if (PRI.m_iRoundsHit < PRI.m_iRoundFired)
                _PlayerMenuInfo.iEfficiency = (PRI.m_iRoundsHit * 100)/PRI.m_iRoundFired;
            else
                _PlayerMenuInfo.iEfficiency = 100;
        }
        else
        {
            _PlayerMenuInfo.iEfficiency = 0;
        }
        
        _PlayerMenuInfo.szPlayerName = PRI.PlayerName;
        _PlayerMenuInfo.iKills = PRI.m_iKillCount;
        _PlayerMenuInfo.iRoundsFired = PRI.m_iRoundFired;
        _PlayerMenuInfo.iRoundsHit = PRI.m_iRoundsHit;
        _PlayerMenuInfo.szKilledBy = PRI.m_szKillersName;
        _PlayerMenuInfo.iPingTime = PRI.Ping;
        _PlayerMenuInfo.iHealth = PRI.m_iHealth;
        _PlayerMenuInfo.bJoinedTeamLate = PRI.m_bJoinedTeamLate;
        _PlayerMenuInfo.iTeamSelection = PRI.TeamID;
        _PlayerMenuInfo.iRoundsPlayed = PRI.m_iRoundsPlayed;
        _PlayerMenuInfo.iRoundsWon = PRI.m_iRoundsWon;
        _PlayerMenuInfo.iDeathCount = PRI.Deaths;
        _PlayerMenuInfo.bPlayerReady = PRI.m_bPlayerReady;
        _PlayerMenuInfo.bSpectator = (PRI.TeamID == INT(ePlayerTeamSelection.PTS_UnSelected)) ||
            (PRI.TeamID == INT(ePlayerTeamSelection.PTS_Spectator) );

        if(m_bShowPlayerStates)
            log("DBG: "$PRI.PlayerName$" bSpectator="$_PlayerMenuInfo.bSpectator$" TeamID="$PRI.TeamID);
        
        if ( PRI.owner == None )
            _PlayerMenuInfo.bOwnPlayer = false;
        else _PlayerMenuInfo.bOwnPlayer = ( Viewport(PlayerController(PRI.owner).Player) != None );
        
        SetFPlayerMenuInfo(_iLastValidIndex, _PlayerMenuInfo);
        _iLastValidIndex++;
    }

    SortFPlayerMenuInfo(_iLastValidIndex, m_szCurrGameType);
    if (m_MenuCommunication!=none)
    {
        m_MenuCommunication.m_iLastValidIndex = _iLastValidIndex;
    }
}

simulated event NewServerState()
{
    if ((m_MenuCommunication!=none) && (!m_MenuCommunication.m_bImCurrentlyDisconnect))
	{
        m_MenuCommunication.NewServerState();
	}
}

simulated event SaveRemoteServerSettings(string NewServerFile)
{
    local R6ServerInfo  pServerOptions;
    local int _iCount;
    local WindowConsole _console;

   
    pServerOptions = new class'R6ServerInfo';
    pServerOptions.m_ServerMapList=spawn(class'Engine.R6MapList');

    // we need to set the server options from what we know about the server
    pServerOptions.ServerName         = ServerName;
    pServerOptions.CamFirstPerson     = ((m_iDeathCameraMode & 0x01) > 0);
    pServerOptions.CamThirdPerson     = ((m_iDeathCameraMode & 0x02) > 0);
    pServerOptions.CamFreeThirdP      = ((m_iDeathCameraMode & 0x04) > 0);
    pServerOptions.CamGhost           = ((m_iDeathCameraMode & 0x08) > 0);
    pServerOptions.CamFadeToBlack     = ((m_iDeathCameraMode & 0x10) > 0);
    pServerOptions.CamTeamOnly        = ((m_iDeathCameraMode & 0x20) > 0);
    pServerOptions.MaxPlayers         = m_MaxPlayers;
    pServerOptions.NbTerro            = m_iNbOfTerro;
    pServerOptions.UsePassword        = false;
    pServerOptions.GamePassword       = "";
    pServerOptions.MOTD               = MOTDLine1;
    pServerOptions.RoundTime          = TimeLimit;
    pServerOptions.RoundsPerMatch     = m_iRoundsPerMatch;
    pServerOptions.BetweenRoundTime   = m_fTimeBetRounds;
    pServerOptions.UseAdminPassword   = false;
    pServerOptions.AdminPassword      = "";
    pServerOptions.BombTime           = m_fBombTime;
    pServerOptions.DiffLevel          = m_iDiffLevel;
    pServerOptions.ShowNames          = m_bShowNames;
    pServerOptions.InternetServer     = m_bInternetSvr;
    pServerOptions.DedicatedServer    = m_bDedicatedSvr;
    pServerOptions.FriendlyFire       = m_bFriendlyFire;
    pServerOptions.Autobalance        = m_bAutoBalance;
    pServerOptions.TeamKillerPenalty  = m_bMenuTKPenaltySetting;
    pServerOptions.AllowRadar         = m_bRepAllowRadarOption;
    pServerOptions.ForceFPersonWeapon = m_bFFPWeapon;
    pServerOptions.AIBkp              = m_bAIBkp;
    pServerOptions.RotateMap          = m_bRotateMap;

    // restriction kit

    pServerOptions.ClearSettings(); // clears the kit restriction

    _console = WindowConsole(m_MenuCommunication.m_PlayerController.Player.Console);

    //Insert All Primary Descriptions except None
    _console.GetRestKitDescName(self, pServerOptions);

    // and the various gadgets
    for (_iCount=0; (_iCount < ArrayCount(m_szGadgPrimaryRes)) && (m_szGadgPrimaryRes[_iCount]!=""); _iCount++)
        pServerOptions.RestrictedPrimary[_iCount] = m_szGadgPrimaryRes[_iCount];

    for (_iCount=0; (_iCount < ArrayCount(m_szGadgSecondayRes)) && (m_szGadgSecondayRes[_iCount]!=""); _iCount++)
        pServerOptions.RestrictedSecondary[_iCount] = m_szGadgSecondayRes[_iCount];

    for (_iCount=0; (_iCount < ArrayCount(m_szGadgMiscRes)) && (m_szGadgMiscRes[_iCount]!=""); _iCount++)
        pServerOptions.RestrictedMiscGadgets[_iCount] = m_szGadgMiscRes[_iCount];

    for ( _iCount = 0; _iCount< m_MapLength; _iCount++ )
    {
        pServerOptions.m_ServerMapList.GameType[_iCount] = m_gameModeArray[_iCount];
        pServerOptions.m_ServerMapList.Maps[_iCount] = m_mapArray[_iCount];
    }

// now we need to save these settings
    pServerOptions.SaveConfig(NewServerFile);
    pServerOptions.m_ServerMapList.SaveConfig(NewServerFile);
}

defaultproperties
{
     c_iTeamNumBravo=3
}
