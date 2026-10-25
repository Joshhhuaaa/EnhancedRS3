//=============================================================================
//  R6GameServices.uc : This class contains all inofrmation and functions 
//  for connecting to a gameservice or master server
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/20 * Created by John Bennett
//============================================================================//

class R6GSServers extends R6ServerList
	native;

//var array<string>           m_favoriteServersList;

//------------------
// Member variables
//------------------

// CDKey validation server
var config BYTE   m_ucActivationID[16];// CDKey validation server activation ID
var config INT    m_iRSCDKeyPort;
var config INT    m_iModCDKeyPort;
var config INT    m_iRegSvrPort;       // Port use for the register server communication
var config BOOL   m_bValidActivationID;// CDKey validation server activation ID valid flag
// Temporary label to disable CDKEY code
var config BOOL m_bUseCDKey;
var config string m_szUbiRemFileURL;   // ubi.com remote file URL
var config string m_szGSVersion;       // The version of the gs-game 
var config string m_szGlobalID;                      // ubi globalID (string)
var config string m_szSavedPwd;        // Saved user password for GameService

var BOOL              m_bStartedByGSClient;
var BOOL m_bUbiComClientDied;       // The ubi.com client is not reponding
var BOOL m_bUbiComRoomDestroyed;    // The ubi.com room has been destroyed

// Usrename and password for ubi.com account entered
var BOOL   m_bUbiAccntInfoEntered;
var BOOL m_bInitGame;               // initgame has been called
var BOOL   m_bLoggedInUbiDotCom;     // Logged in to ubi.com

var BOOL m_bAutoLoginInProgress;    // Auto log in of the player is in progress
var BOOL m_bAutoLoginFailed;        // Auto log in failed, reset in menu system
var BOOL m_bRefreshFinished;         // The list is finished being
var FLOAT             m_fMaxTimeForResponse;

var R6ModGSInfo   m_ModGSInfo;

var string          m_szUbiHomePage;     // ubi.com home page
var string m_szPassword;        // User password for GameService

// File used to save ubi.com URL
var string  m_szGSInitFileName;

var string m_szGSClientIP;          // IP address recieved from ubi.com client
var string m_szGSServerName;        // Server name recieved from ubi.com client
var INT    m_iGSNumPlayers;         // Max number of players recieved from ubi.com client
var string m_szGSPassword;          // Game password recieved from ubi.com client

native(3530) final function FLOAT NativeGetSeconds();

native(3560) final function       NativeUpdateServer();

native(3561) final function       NativeLogOutServer(GameReplicationInfo _GRI);

native(3531) final function BOOL  NativeGetMSClientInitialized();

native(3570) final function       NativeMSClientReqAltInfo( INT iLobbyID, INT iGroupID );

native(3571) final function       NativeMSCLientJoinServer( INT iLobbyID, INT iGroupID, string szPassword );

native(3540) final function         NativeSetMatchResult(string szUbiUserID, INT iField, INT iValue);

native(3562) final function BOOL    NativeProcessIcmpPing(string _ServerIpAddress, out INT piPingTime);

native(3563) final function BOOL HandleAnyLobbyConnectionFail();

native(3564) final function       EnterCDKey(string _szCDKey);

native(3541) final function         SetLastServerQueried(string szIPAddress);

native(3550) final function BOOL  NativeIsRouterDisconnect();

native(3551) final function BOOL  NativeIsWaitingForGSInit();

native(3552) final function BOOL  NativeIsGSReadyToChangeMod();

function BOOL CallNativeProcessIcmpPing(string _ServerIpAddress, out INT piPingTime)
{
    return NativeProcessIcmpPing(_ServerIpAddress, piPingTime);
}

function CallNativeSetMatchResult(string szUbiUserID, INT iField, INT iValue)
{
    NativeSetMatchResult(szUbiUserID, iField, iValue);
}
function INT getServerListSize()
{
    return m_GameServerList.length;
}

event ProcessServerMsg(PlayerController _aPlayerController, string _szErrorMsgKey)
{
    if (_szErrorMsgKey == "BannedIP")
        R6PlayerController(_aPlayerController).ServerIndicatesInvalidCDKey(_szErrorMsgKey);
    else if (_szErrorMsgKey != "")
        R6PlayerController(_aPlayerController).ServerIndicatesInvalidCDKey("ServerAuthNotResponding");

    if (R6PlayerController(_aPlayerController).m_GameService == none)
        R6PlayerController(_aPlayerController).m_GameService = self;

    _aPlayerController.SpecialDestroy();
}

event BOOL IsGlobalIDBanned(R6AbstractGameInfo _GameInfo, string _szGlobalID)
{
    return _GameInfo.AccessControl.IsGlobalIDBanned(_szGlobalID);
}

event string TempGetPBConnectStatus(PlayerController _aPlayerController)
{
    return _aPlayerController.GetPBConnectStatus();
}

//===========================================================================
// RefreshOneServer - Start process to refresh an indivisual server.
//===========================================================================
native(3521) final function       RefreshOneServer( INT iIdx );

native(3522) final function BOOL  IsRefreshServersInProgress();

native(3523) final function       StopRefreshServers();

event string GetLocallyBoundIpAddr()
{
    local UdpBeacon _UdpBeacon;
    if ( m_ClientBeacon != none )
        return m_ClientBeacon.LocalIpAddress;
    else 
    {
        _UdpBeacon = UdpBeacon(class'Actor'.static.GetServerBeacon());
        if (_UdpBeacon!=none)
            return _UdpBeacon.LocalIpAddress;
    }
    return "";
}

event string GetConsoleStoreIP(PlayerController _aPlayerController)
{
    return WindowConsole(_aPlayerController.Player.Console).szStoreIP;
}

//=============================================================================
// Initialize the game service software, call native function to download 
// data from ubi.com.
//=============================================================================
native(3500) final function BOOL  Initialize();

//=============================================================================
// Establish initial connection to the server
//=============================================================================
native(3502) final function BOOL  InitializeMSClient();

//=============================================================================
// Uninitialize the MSClient SDK (logout)
//=============================================================================
native(3510) final function BOOL  UnInitializeMSClient();


//=============================================================================
// Set the user ID and password for the ubi.com account
//=============================================================================
function SetUbiAccount( string szUserID, string szPassword )
{
    m_szUserID   = szUserID;
    m_szPassword = szPassword;
}

//=============================================================================
// FillCreateGameInfo Fill the m_CrGameSrvInfo structure with all the
// required data from the gameinfo, levelinfo, and beacon
//=============================================================================
event FillCreateGameInfo( GameInfo pGameInfo, LevelInfo pLevel )
{
    local R6ServerInfo     pServerOptions;
    local PlayerController aPC;             // Local object for foreach loop
    local Controller _PC;
    local INT              iNumPlayers;
    local INT              iNumMaps;
    local R6MapList        mapList;         // Map list to cycle through
    local INT              iCounter;        // Counter
    local stRemotePlayers  sPlayer;
    local stGameTypeAndMap sMapAndGame;
    
    pServerOptions = class'Actor'.static.GetServerOptions();

    iNumPlayers = 0;
    
    m_CrGameSrvInfo.sGameData.playerList.Remove( 0, m_CrGameSrvInfo.sGameData.iNbrPlayer);
    
    for (_PC=pGameInfo.Level.ControllerList; _PC!=None; _PC=_PC.NextController )
    {
        aPC = PlayerController(_PC);
        if (aPC!=none)
        {
            sPlayer.szAlias = aPC.PlayerReplicationInfo.PlayerName;
            
            sPlayer.iPing   = aPC.PlayerReplicationInfo.Ping;
            sPlayer.iSkills  = aPC.PlayerReplicationInfo.m_iKillCount;
            sPlayer.szTime  = DisplayTime( pLevel.TimeSeconds - aPC.PlayerReplicationInfo.StartTime );
            m_CrGameSrvInfo.sGameData.playerList[iNumPlayers] = sPlayer;
            
            iNumPlayers++;
        }
    }
    
    m_CrGameSrvInfo.sGameData.gameMapList.Remove( 0, m_CrGameSrvInfo.sGameData.gameMapList.length );
    mapList = pGameInfo.spawn(class'R6MapList');
    for ( iCounter = 0; iCounter < arraycount(mapList.Maps); iCounter++ )
    {
        if ( mapList.Maps[iCounter] != "" )
        {
            if ( InStr(mapList.Maps[iCounter], ".") == -1 )   // -1 signifies string not found
                sMapAndGame.szMap = mapList.Maps[iCounter];
            else
                sMapAndGame.szMap = left( mapList.Maps[iCounter], InStr(mapList.Maps[iCounter], ".") );
            
            sMapAndGame.szGameType = pLevel.GetGameTypeFromClassName( mapList.GameType[iCounter] );
            //            sMapAndGame.szGameLoc = pLevel.GetGameNameLocalization( pLevel.GetGameTypeFromClassName(mapList.GameType[iCounter]) );
            m_CrGameSrvInfo.sGameData.gameMapList[iNumMaps] = sMapAndGame;
            iNumMaps++;
        }
    }
    
    m_CrGameSrvInfo.sGameData.szCurrentMap      = mapList.CheckCurrentMap();//pLevel.Game.GetURLMap();
    
    mapList.Destroy();
    
    if ( m_ClientBeacon != none )
        m_CrGameSrvInfo.iBeaconPort             = m_ClientBeacon.boundport;
    else if (R6AbstractGameInfo(pGameInfo).m_UdpBeacon!=none)
        m_CrGameSrvInfo.iBeaconPort             = R6AbstractGameInfo(pGameInfo).m_UdpBeacon.boundport;
    else
        m_CrGameSrvInfo.iBeaconPort             = class'UdpBeacon'.Default.ServerBeaconPort;
    
    m_CrGameSrvInfo.sGameData.szName            = pGameInfo.GameReplicationInfo.ServerName;
    m_CrGameSrvInfo.sGameData.szModName         = class'Actor'.static.GetModMgr().m_pCurrentMod.m_szKeyWord; // MPF
    m_CrGameSrvInfo.sGameData.szPassword        = pServerOptions.GamePassword;
    m_CrGameSrvInfo.sGameData.bUsePassword      = pServerOptions.UsePassword;
    m_CrGameSrvInfo.sGameData.iMaxPlayer        = pServerOptions.MaxPlayers;
    m_CrGameSrvInfo.sGameData.bDedicatedServer  = (pLevel.NetMode == NM_DedicatedServer);
    m_CrGameSrvInfo.sGameData.iPort             = int(Mid(pLevel.GetAddressURL(),InStr(pLevel.GetAddressURL(),":")+1));
    m_CrGameSrvInfo.sGameData.bAutoBalTeam      = pServerOptions.Autobalance;
    m_CrGameSrvInfo.sGameData.bFriendlyFire     = pServerOptions.FriendlyFire;
    m_CrGameSrvInfo.sGameData.bInternetServer   = pServerOptions.InternetServer;
    m_CrGameSrvInfo.sGameData.bShowNames        = pServerOptions.ShowNames;
    m_CrGameSrvInfo.sGameData.bTKPenalty        = pServerOptions.TeamKillerPenalty;
    m_CrGameSrvInfo.sGameData.bRadar            = pServerOptions.AllowRadar;
    m_CrGameSrvInfo.sGameData.iRoundsPerMatch   = pServerOptions.RoundsPerMatch;
    m_CrGameSrvInfo.sGameData.szGameDataGameType= pGameInfo.m_szCurrGameType;
    m_CrGameSrvInfo.sGameData.iBetTime          = pServerOptions.BetweenRoundTime;
    m_CrGameSrvInfo.sGameData.iBombTime         = pServerOptions.BombTime;
    m_CrGameSrvInfo.sGameData.iNbrPlayer        = iNumPlayers;
    m_CrGameSrvInfo.sGameData.iNumMaps          = iNumMaps;
    m_CrGameSrvInfo.sGameData.iRoundTime        = pServerOptions.RoundTime;
    m_CrGameSrvInfo.sGameData.szMessageOfDay    = pServerOptions.MOTD;
    m_CrGameSrvInfo.sGameData.szGameType        = pLevel.GetGameNameLocalization( m_CrGameSrvInfo.sGameData.szGameDataGameType );
    m_CrGameSrvInfo.sGameData.bAdversarial      = pLevel.IsGameTypeAdversarial( m_CrGameSrvInfo.sGameData.szGameDataGameType );
    m_CrGameSrvInfo.sGameData.iNumTerro         = pServerOptions.NbTerro;
    m_CrGameSrvInfo.sGameData.bAIBkp            = pServerOptions.AIBkp;
    m_CrGameSrvInfo.sGameData.bRotateMap        = pServerOptions.RotateMap;
    m_CrGameSrvInfo.sGameData.bForceFPWeapon    = pServerOptions.ForceFPersonWeapon;
    //#ifdef R6PUNKBUSTER
    m_CrGameSrvInfo.sGameData.bPunkBuster       = class'Actor'.static.IsPBServerEnabled();
    //#endif
}

//=============================================================================
// Refresh the list of servers
//=============================================================================

native(3520) final function       RefreshServers();

//=============================================================================
// The user can right click on a server and get additional information
// on that server (players, maps, etc.).  This function is called to select
// that server from the server list.
//=============================================================================

//function SetSelectedServer( INT iServerListIndex)
//{
//
//    if ( iServerListIndex > m_GameServerList.length )  // Check index is valid
//        return;
//
//    m_iSelSrvIndex = iServerListIndex;
//
//}

//=============================================================================
// Initialize the Game service CDKey SDK
//=============================================================================

native(3501) final function BOOL  InitGSCDKey();

//=============================================================================
// Request a cd key user validation
//=============================================================================

//function requestUserValidation( string szAuthID )
//{
//    if ( m_bCDKInit )
//    {
//        NativeCDKeyValidateUser( szAuthID );
//        m_eUserValidationRequest  = EGSREQ_FIRST_PASS;
//        m_eMenuUserValidation  = EMENU_REQ_PENDING;
//    }
//    else
//    {
//        if (bShowLog) log("Could not get user validation from ubi.com");
//        m_eMenuUserValidation  = EMENU_REQ_FAILURE;
//    }
//}


//===============================================================================
// DisplayTime: display the time in min (have to be in sec)
//===============================================================================
function string DisplayTime( INT _iTimeToConvert) //, BOOL _bInSec)
{
    local FLOAT fTemp;
    local INT iMin, iSec, iTemp;
    local string szTemp, szTime;
    
    iMin = 0;
    iSec = _iTimeToConvert;
    
    if (_iTimeToConvert >= 60) // 60sec
    {
        fTemp = FLOAT(_iTimeToConvert ) / 60;
        iMin = INT(fTemp);
        iSec = _iTimeToConvert - (iMin * 60);
    }
    
    if (iSec < 10)
    {
        szTime = iMin $ ":0" $ iSec;
    }
    else
    {
        szTemp = string(iSec);
        szTemp = Left( szTemp, 2);
        szTime = iMin $ ":" $ szTemp;
    }
    
    return szTime;
}
//===============================================================================
// GetSelectedServerIP:  Return the IP address of the selected server, include
// a check to make sure the server is responding, else try the alternate IP.
// Also remove the port number.
//===============================================================================
function string GetSelectedServerIP() 
{
    local string szIPAddress;       // Primary IP address
    local string szAltIPAddress;    // Alternate IP address
    
    // Remove the Port number from the IP string: 10.10.10.10:1234 -> 10.10.10.10
    szIPAddress = left( m_GameServerList[m_iSelSrvIndex].szIPAddress, InStr(m_GameServerList[m_iSelSrvIndex].szIPAddress, ":") );
    szAltIPAddress = left( m_GameServerList[m_iSelSrvIndex].szAltIPAddress, InStr(m_GameServerList[m_iSelSrvIndex].szAltIPAddress, ":") );
    
    // If the ping time is not valid, ping now to determine which IP to use
    if ( m_GameServerList[m_iSelSrvIndex].iPing >= NativeGetPingTimeOut() )
    {
        if ( NativeGetPingTime( szIPAddress ) >= NativeGetPingTimeOut() )
        {
            // If there is no response from the first IP, try the alternate IP
            if ( NativeGetPingTime( szAltIPAddress ) < NativeGetPingTimeOut())
                m_GameServerList[m_iSelSrvIndex].bUseAltIP = TRUE;
        }
    }
    
    if ( m_GameServerList[m_iSelSrvIndex].bUseAltIP )
        return m_GameServerList[m_iSelSrvIndex].szAltIPAddress;
    else
        return m_GameServerList[m_iSelSrvIndex].szIPAddress;
    
}

//===============================================================================
// Start the auto log in procedure
//===============================================================================

function StartAutoLogin()
{
    if ( m_szUserID != "" && m_szPassword != "" && m_bAutoLISave )
    {
        InitializeMSClient();
        m_bAutoLoginInProgress = TRUE;
    }
}
//===============================================================================
// This function has to inform the server that the end of round (a Ubi match) data
// has been sent to Ubi.com
//===============================================================================
event EndOfRoundDataSent()
{
    R6PlayerController(m_LocalPlayerController).ServerEndOfRoundDataSent();
}

//===============================================================================
// This function returns the maximum allowed size of the server name, this is 
// limited by ubi.com
//===============================================================================
native(3532) final function INT   GetMaxUbiServerNameSize();

event HandleNewLobbyConnection(LevelInfo _Level)
{
    local Controller P;
    
    for (P=_Level.ControllerList; P!=None; P=P.NextController )
    {
        if ((R6PlayerController(P)!=none) && (Viewport(R6PlayerController(P).Player) == None))
        {
            // these 2 vars may not have been replicated to the client yet
            R6PlayerController(P).ClientNewLobbyConnection(_Level.Game.GameReplicationInfo.m_iGameSvrLobbyID, _Level.Game.GameReplicationInfo.m_iGameSvrGroupID);
        }
    }
}

function string MyID()
{
    return m_szGlobalID;
}

event INT GetMaxAvailPorts()
{
    return class'UdpLink'.static.GetMaxAvailPorts();
}

function SaveInfo()
{
    local BYTE ATemp[16];
    local string szFilename;
    
    szFilename = "..\\" $ class'Actor'.static.GetModMgr().GetIniFilesDir() $ "\\" $ class'Actor'.static.GetModMgr().GetModKeyword();
    m_ModGSInfo.SaveConfig(szFilename);
    SaveConfig();
}

event InitializeMod()
{
    Created();
    if (m_ModGSInfo == none)
        m_ModGSInfo = new(none) class'R6ModGSInfo';
    m_ModGSInfo.InitGSMod();
}

defaultproperties
{
     m_iRSCDKeyPort=5777
     m_iModCDKeyPort=10777
     m_iRegSvrPort=6777
     m_fMaxTimeForResponse=10.000000
     m_szUbiRemFileURL="http://gsconnect.ubisoft.com/gsinit.php?user=%s&dp=%s"
     m_szGSVersion="1.0"
     m_szUbiHomePage="http://www.ubi.com/login/newuser?l=%s"
     m_szGSInitFileName="./GSRouters.dat"
     m_iSelSrvIndex=-1
}
