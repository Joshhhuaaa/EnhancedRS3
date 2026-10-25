//=============================================================================
// UdpBeacon: Base class of beacon sender and receiver.
//=============================================================================
class UdpBeacon extends UdpLink
	config
	transient;

var() globalconfig bool       DoBeacon;
var() globalconfig int        ServerBeaconPort;		// Listen port
var() globalconfig int        BeaconPort;			// Reply port
var() globalconfig float      BeaconTimeout;
var() globalconfig string     BeaconProduct;

//#ifdef R6CODE // added by John Bennett - April 2002
var                string     KeyWordMarker;
var                string     PreJoinQueryMarker;
var                string     MaxPlayersMarker;
var                string     NumPlayersMarker;
var                string     MapNameMarker;
var                string     GameTypeMarker;
var                string     LockedMarker;
var                string     DecicatedMarker;
var                string     SvrNameMarker;
var                string     MenuGmNameMarker;
var                string     MapListMarker;
var                string     PlayerListMarker;
var                string     OptionsListMarker;
var                string     PlayerTimeMarker;
var                string     PlayerPingMarker;
var                string     PlayerKillMarker;
var                string     GamePortMarker;
//var                string     MapTimeMarker;
var                string     RoundsPerMatchMarker;
var                string     RoundTimeMarker;
var                string     BetTimeMarker;
var                string     BombTimeMarker;
var                string     ShowNamesMarker;
var                string     InternetServerMarker;
var                string     FriendlyFireMarker;
var                string     AutoBalTeamMarker;
var                string     TKPenaltyMarker;
var                string     AllowRadarMarker;
var                string     GameVersionMarker;
var                string     LobbyServerIDMarker;
var                string     GroupIDMarker;
var                string     BeaconPortMarker;
var                string     NumTerroMarker;
var                string     AIBkpMarker;
var                string     RotateMapMarker;
var                string     ForceFPWpnMarker;
var                string     ModNameMarker; // MPF
//#ifdef R6PUNKBUSTER
var                string     PunkBusterMarker;
//#endif
//#endif R6CODE 

var int	UdpServerQueryPort;
var int boundport;
var string LocalIpAddress;



function BeginPlay()
{
	local IpAddr Addr;

    SetServerBeacon(self);
    Level.Game.SetUdpBeacon(self);

	boundport = BindPort(ServerBeaconPort, True, LocalIpAddress);
	if ( boundport == 0 )
	{
		log( "UdpBeacon failed to bind a port." );
		return;
	}

	Addr.Addr = BroadcastAddr;
	Addr.Port = BeaconPort;

//#ifdef R6CODE // added by John Bennett - April 2002
    // Timer used to keep track of how long each player
    // has been playing on this server.
    SetTimer( 10.0, true );
    InitBeaconProduct();
//#endif R6CODE 

//  Do not send out a beacon yet, the server does not have all the player 
//  information, wait for request from clients.
//	BroadcastBeacon(Addr); // Initial notification.
}


function BroadcastBeacon(IpAddr Addr)
{
//#ifdef R6CODE // added by John Bennett - April 2002
    local string         textData;
//#endif R6CODE 

    // This SendText commented out for RAVENSHIELD, no longer used
	//SendText( Addr, BeaconProduct @ Mid(Level.GetAddressURL(),InStr(Level.GetAddressURL(),":")+1) @ Level.Game.GetBeaconText() );
	//Log( "UdpBeacon: sending reply to "$IpAddrToString(Addr) );

//#ifdef R6CODE // added by John Bennett - April 2002

    // Send the data!

    textData = BuildBeaconText();

	SendText( Addr, BeaconProduct @ Mid(Level.GetAddressURL(),InStr(Level.GetAddressURL(),":")+1) @ textData );

//#endif R6CODE 

}

function BroadcastBeaconQuery(IpAddr Addr)
{
	SendText( Addr, BeaconProduct @ UdpServerQueryPort );
	//Log( "UdpBeacon: sending query reply to "$IpAddrToString(Addr) );
}


event ReceivedText( IpAddr Addr, string Text )
{
//#ifdef R6CODE

// Internet servers should be visible in the internet TAB only, do not repond to beacons 
// if this is an internet server.

    local R6ServerInfo   pServerOptions;
    local BOOL           bServerResistered;

    pServerOptions = class'Actor'.static.GetServerOptions();
/*
======================================================================
    BEGIN PATCH Eric Bégin (ASE/GameSpy Support)
======================================================================
    The beacon need to respond to the request even if it's an 
    Internet Server.

    By removing this condition, the Internet on the same LAN was 
    responding to the request, so it was displayed on the LAN Server
    list.
    
    The filter is now done in the 
    R6LanServer::LANSeversManager function
======================================================================
              
    if ( pServerOptions.InternetServer && Text == "REPORT" )
        return;

======================================================================
    END PATCH Eric Bégin (ASE/GameSpy Support)
======================================================================
*/

//#endif R6CODE

	if( Text == "REPORT" )
		BroadcastBeacon(Addr);

	if( Text == "REPORTQUERY" )
		BroadcastBeaconQuery(Addr);

//#ifdef R6CODE
    if ( Text == "PREJOIN" )
    {
        bServerResistered = ( Level.Game.GameReplicationInfo.m_iGameSvrLobbyID != 0  &&
                              Level.Game.GameReplicationInfo.m_iGameSvrGroupID != 0 );

        // If the server is an internet server, and not properly registered,
        // Do not respond to beacons

        if ( !pServerOptions.InternetServer || bServerResistered )
            RespondPreJoinQuery(Addr);
    }

//#endif R6CODE

}

//#ifdef R6CODE

function InitBeaconProduct()
{

    // This variable needs to be different for the multiplayer demo and
    // the regular game.  Initialized here because #ifdefMPDEMO does not
    // work in the default properties.

#ifdefMPDEMO
    BeaconProduct = "rvnshld_demo";
#endif
#ifndefMPDEMO
    BeaconProduct = "rvnshld";
#endif

}
//===============================================================================
// RespondPreJoinQuery: Used to send some data from server to client before
// the client joins a server, intended for a client that is joining using
// the join IP button.
//===============================================================================
function RespondPreJoinQuery( IpAddr Addr )
{
    local string           textData;
    local INT              integerData;
    local R6ServerInfo     pServerOptions;
    local PlayerController aPC;             // Local object for foreach loop
    local INT              iNumPlayers;

	pServerOptions = class'Actor'.static.GetServerOptions();

    textData = PreJoinQueryMarker;

    // Ubi.com lobbyserver ID
    textData = textData$ " "$ LobbyServerIDMarker$ " "$ Level.Game.GameReplicationInfo.m_iGameSvrLobbyID;

    // Ubi.com Group ID
    textData = textData$ " "$ GroupIDMarker$ " "$ Level.Game.GameReplicationInfo.m_iGameSvrGroupID;

    // Boolean to indicate if the server requires a password

    if ( Level.Game.AccessControl.GamePasswordNeeded() )
        integerData = 1;
    else
        integerData = 0;

    textData = textData$ " "$ LockedMarker$ " "$ integerData;

    // Game Version

    textData = textData$ " "$GameVersionMarker$ " "$Level.GetGameVersion(false, !class'Actor'.static.GetModMgr().IsRavenShield());

    // Internet server
    if ( pServerOptions.InternetServer )
        integerData = 1;
    else
        integerData = 0;

    textData = textData$ " "$InternetServerMarker$ " "$ integerData;
    textData = textData$ " "$ModNameMarker$ " "$ class'Actor'.static.GetModMgr().m_pCurrentMod.m_szKeyWord;
    
    // If this is a PunkBuster enabled server
    if (Level.m_bPBSvRunning)
        textData = textData$ " "$PunkBusterMarker$ " 1";
    else
        textData = textData$ " "$PunkBusterMarker$ " 0";

    // Maximun number of players allowed in the game
    textData = textData$ " "$ MaxPlayersMarker$ " "$ Level.Game.MaxPlayers;

    // Number of players
    iNumPlayers = 0;
    ForEach DynamicActors(class'PlayerController', aPC )
        iNumPlayers++;

    textData = textData$ " "$ NumPlayersMarker$ " "$ iNumPlayers;

	SendText( Addr, BeaconProduct @ Mid(Level.GetAddressURL(),InStr(Level.GetAddressURL(),":")+1) @ textData );
}
//#endif R6CODE

function Destroyed()
{
    Level.Game.SetUdpBeacon(none);
	Super.Destroyed();
	//Log("ServerBeacon Destroyed");
}

//#ifdef R6CODE // added by John Bennett - April 2002

//===============================================================================
// BuildBeaconText: Build a string which contains all the game data
// that will be sent to a client.
//===============================================================================
function string BuildBeaconText()
{
    local string         textData;
    local INT            integerData;
    local string         MapListType;       // Maplist this game uses.
	local MapList        myList;            // Map list to cycle through
	local class<MapList> ML;                // Map list class
    local INT            iCounter;          // Counter
    local PlayerController aPC;             // Local object for foreach loop
    local INT            iNumPlayers;
    local string         szIPAddr;
    local FLOAT          fPlayingTime[32];
    local INT            iPingTimeMS[32];   // Ping time in ms
    local INT            iKillCount[32];    // Player Kill count
    local Controller     _Controller;

    local R6ServerInfo  pServerOptions;

	pServerOptions = class'Actor'.static.GetServerOptions();

    //-------------------------------------------------------------------------------
    // In order to pass specific pieces of information from the server to the clients,
    // we will send individual messages using a keyword to identify the type of data
    // sent.  Messages will be of the form...
    //    <BeaconProduct> <port> <KeyWordMarker> <uniqueDataMarker> <data>
    //
    // For example...
    //    unreal 7777 KEYWORD %MAXPLAYERS 16 %NUMPLAYERS 2 %MAPNAME rooms.unr
    //-------------------------------------------------------------------------------

    // The Options list
    
    textData = KeyWordMarker$" ";//$OptionsListMarker$ " ";
//    textData = textData$ Level.Game.m_szGameOptions; 

    // Port number that the game is using


    textData = textData$ " "$ GamePortMarker$ " "$ Mid(Level.GetAddressURL(),InStr(Level.GetAddressURL(),":")+1);

    // The current map name
    if ( InStr(Level.Game.GetURLMap(), ".") == -1 )   // -1 signifies string not found
        textData = textData$ " "$ MapNameMarker$ " "$ Level.Game.GetURLMap();
    else
        textData = textData$ " "$ MapNameMarker$ " "$ left( Level.Game.GetURLMap(), InStr(Level.Game.GetURLMap(), ".") );

    // The server name
    textData = textData$ " "$ SvrNameMarker$ " "$ Level.Game.GameReplicationInfo.ServerName;

    // The current game mode
    textData = textData$ " "$ GameTypeMarker$ " "$ Level.Game.m_szCurrGameType;

    // Maximun number of players allowed in the game
    textData = textData$ " "$ MaxPlayersMarker$ " "$ Level.Game.MaxPlayers;

    // Boolean to indicate if the server requires a password

    if ( Level.Game.AccessControl.GamePasswordNeeded() )
        integerData = 1;
    else
        integerData = 0;

    textData = textData$ " "$ LockedMarker$ " "$ integerData;

    // Boolean to indicate if the server is a dedicated server

    if ( Level.NetMode == NM_DedicatedServer )
        integerData = 1;
    else
        integerData = 0;

    textData = textData$ " "$ DecicatedMarker$ " "$ integerData;

    // The Map list: "MAPS map1/map2/map3/.../mapn"
    
    MapListType = "Engine.R6MapList";
    ML          = class<MapList>(DynamicLoadObject(MapListType, class'Class'));
    myList      = spawn(ML);
    textData    = textData$ " "$ MapListMarker$ " ";
    for ( iCounter = 0; iCounter < arraycount(myList.Maps); iCounter++ )
    {
        if ( myList.Maps[iCounter] != "" )
        {
            if ( InStr(myList.Maps[iCounter], ".") == -1 )   // -1 signifies string not found
                textData = textData$"/"$ myList.Maps[iCounter];
            else
                textData = textData$"/"$ left( myList.Maps[iCounter], InStr(myList.Maps[iCounter], ".") );
        }
    }

    // the corresponding game mode type list 
    textData    = textData$ " "$ MenuGmNameMarker$ " ";
    for ( iCounter = 0; iCounter < arraycount(myList.Maps); iCounter++ )
    {
        textData = textData$"/"$ Level.GetGameTypeFromClassName(R6MapList(myList).GameType[iCounter]) ;
    }

    myList.Destroy();

    // The player list

    textData    = textData$ " "$ PlayerListMarker$ " ";

    // CheckForPlayerTimeouts will check if there are any players that have been
    // off-line for too long and need to be removed from the list.

    CheckForPlayerTimeouts();

    iNumPlayers = 0;

    for (_Controller=Level.ControllerList; _Controller!=None; _Controller=_Controller.NextController)
    {
        aPC = PlayerController(_Controller);
        if (aPC!=none)
        {
            textData = textData$"/"$ aPC.PlayerReplicationInfo.PlayerName;
            // For a player who has started a non-dedicated server, the IP is not 
            // available in the same way as a player who has joined a server.
            // For such a player, get the IP from the console.

		    if ( NetConnection( aPC.Player) == None )
                szIPAddr = WindowConsole(aPC.Player.Console).szStoreIP;
            else
                szIPAddr = aPC.GetPlayerNetworkAddress();

            // The address returned by GetPlayerNetworkAddress() is of the
            // form 1.1.1.1:1234, where 1234 is the port number, we just want
            // the IP, so remove everything after the ":".

            szIPAddr = left( szIPAddr, InStr( szIPAddr, ":" ) );

            iPingTimeMS[iNumPlayers]  = aPC.PlayerReplicationInfo.Ping;
            iKillCount[iNumPlayers]   = aPC.PlayerReplicationInfo.m_iKillCount;
            fPlayingTime[iNumPlayers] = GetPlayingTime( szIPAddr );
            iNumPlayers++;
        }
    }
    // List of player times (time player has been playing on this server)

    textData    = textData$ " "$ PlayerTimeMarker$ " ";

    for (iCounter = 0; iCounter < iNumPlayers; iCounter++ )
    {
        textData = textData$"/"$ DisplayTime( INT( fPlayingTime[iCounter] ) );
    }

    // List of player ping times.

    textData    = textData$ " "$ PlayerPingMarker$ " ";

    for (iCounter = 0; iCounter < iNumPlayers; iCounter++ )
    {
        textData = textData$"/"$  iPingTimeMS[iCounter];
    }

    // List of player kill counts.

    textData    = textData$ " "$ PlayerKillMarker$ " ";

    for (iCounter = 0; iCounter < iNumPlayers; iCounter++ )
    {
        textData = textData$"/"$  iKillCount[iCounter];
    }

    // Number of players currently in the game
    textData = textData$ " "$ NumPlayersMarker$ " "$ iNumPlayers;

    // Map Time
//    textData = textData$ " "$MapTimeMarker$" "$pServerOptions.MapTime;
    textData = textData$ " "$RoundsPerMatchMarker$" "$pServerOptions.RoundsPerMatch;

    // Round time
    textData = textData$ " "$RoundTimeMarker$" "$pServerOptions.RoundTime;

     // Between Round time
    textData = textData$ " "$BetTimeMarker$" "$pServerOptions.BetweenRoundTime;

     // Bomb time
    if (pServerOptions.BombTime > -1)
        textData = textData$ " "$BombTimeMarker$" "$pServerOptions.BombTime;


    // Show Names 
    if ( pServerOptions.ShowNames )
        integerData = 1;
    else
        integerData = 0;
   
    textData = textData$ " "$ShowNamesMarker$ " "$ integerData;

    // Internet server
    if ( pServerOptions.InternetServer )
        integerData = 1;
    else
        integerData = 0;

    textData = textData$ " "$InternetServerMarker$ " "$ integerData;

    // Allow friendly
    if ( pServerOptions.FriendlyFire )
        integerData = 1;
    else
        integerData = 0;

    textData = textData$ " "$FriendlyFireMarker$ " "$ integerData;
 
    // AutoBalance Team
    if ( pServerOptions.Autobalance )
        integerData = 1;
    else
        integerData = 0;

    textData = textData$ " "$AutoBalTeamMarker$ " "$ integerData;

    // Team mate killer penalty
    if ( pServerOptions.TeamKillerPenalty )
        integerData = 1;
    else
        integerData = 0;

    textData = textData$ " "$TKPenaltyMarker$ " "$ integerData;

    // Game Version

    textData = textData$ " "$GameVersionMarker$ " "$Level.GetGameVersion(false, !class'Actor'.static.GetModMgr().IsRavenShield());


    // Allow radar
    if ( pServerOptions.AllowRadar )
        integerData = 1;
    else
        integerData = 0;
    textData = textData$ " "$AllowRadarMarker$ " "$integerData;

    // Ubi.com lobbyserver ID
    textData = textData$ " "$ LobbyServerIDMarker$ " "$ Level.Game.GameReplicationInfo.m_iGameSvrLobbyID;

    // Ubi.com Group ID
    textData = textData$ " "$ GroupIDMarker$ " "$ Level.Game.GameReplicationInfo.m_iGameSvrGroupID;

    // Beacon port number
    textData = textData$ " "$ BeaconPortMarker$ " "$ boundport;

     // Number of terrorists
    textData = textData$ " "$NumTerroMarker$" "$pServerOptions.NbTerro;

     // IA Backup
    if ( pServerOptions.AIBkp )
        integerData = 1;
    else
        integerData = 0;
    textData = textData$ " "$AIBkpMarker$" "$integerData;

     // Rotate Map
    if ( pServerOptions.RotateMap )
        integerData = 1;
    else
        integerData = 0;
    textData = textData$ " "$RotateMapMarker$" "$integerData;

     // Force first person weapons
    if ( pServerOptions.ForceFPersonWeapon )
        integerData = 1;
    else
        integerData = 0;
    textData = textData$ " "$ForceFPWpnMarker$" "$integerData;


    // MPF
    // the mod name 
    textData = textData$ " "$ModNameMarker$ " "$ class'Actor'.static.GetModMgr().m_pCurrentMod.m_szKeyWord;
//#ifdef R6PUNKBUSTER

    // If this is a PunkBuster enabled server
    if (Level.m_bPBSvRunning)
        textData = textData$ " "$PunkBusterMarker$ " 1";
    else
        textData = textData$ " "$PunkBusterMarker$ " 0";
//#endif R6PUNKBUSTER
    return textData;

}

function Timer()
{
    local Controller aPC;             // Local object for foreach loop

    // For servers, update the amount of time each player has been playing
    // on this server

    if( Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer )
    { 
        for ( aPC = Level.ControllerList; aPC != None; aPC = aPC.NextController )
        {
            if ( ( PlayerController(aPC) != none ) && ( PlayerController(aPC).m_szIpAddr != "") )
                SetPlayingTime( PlayerController(aPC).m_szIpAddr, PlayerController(aPC).m_fLoginTime, Level.TimeSeconds );
        }
    }
} 


  
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


//#endif R6CODE

defaultproperties
{
     ServerBeaconPort=8777
     BeaconPort=9777
     DoBeacon=True
     BeaconTimeout=10.000000
     BeaconProduct="unreal"
     KeyWordMarker="KEYWORD"
     PreJoinQueryMarker="PREJOINQUERY"
     MaxPlayersMarker="¶A1"
     NumPlayersMarker="¶B1"
     MapNameMarker="¶E1"
     GameTypeMarker="¶F1"
     LockedMarker="¶G1"
     DecicatedMarker="¶H1"
     SvrNameMarker="¶I1"
     MenuGmNameMarker="¶J1"
     MapListMarker="¶K1"
     PlayerListMarker="¶L1"
     OptionsListMarker="¶C2"
     PlayerTimeMarker="¶M1"
     PlayerPingMarker="¶N1"
     PlayerKillMarker="¶O1"
     GamePortMarker="¶P1"
     RoundsPerMatchMarker="¶Q1"
     RoundTimeMarker="¶R1"
     BetTimeMarker="¶S1"
     BombTimeMarker="¶T1"
     ShowNamesMarker="¶W1"
     InternetServerMarker="¶X1"
     FriendlyFireMarker="¶Y1"
     AutoBalTeamMarker="¶Z1"
     TKPenaltyMarker="¶A2"
     AllowRadarMarker="¶B2"
     GameVersionMarker="¶D2"
     LobbyServerIDMarker="¶E2"
     GroupIDMarker="¶F2"
     BeaconPortMarker="¶G2"
     NumTerroMarker="¶H2"
     AIBkpMarker="¶I2"
     RotateMapMarker="¶J2"
     ForceFPWpnMarker="¶K2"
     ModNameMarker="¶L2"
     PunkBusterMarker="¶L3"
     RemoteRole=ROLE_None
}
