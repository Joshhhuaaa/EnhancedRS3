//=============================================================================
// GameReplicationInfo.
//=============================================================================
class GameReplicationInfo extends ReplicationInfo
	native nativereplication;

var string GameName;						// Assigned by GameInfo.
var string GameClass;						// Assigned by GameInfo.
//#ifndef R6CODE
//var bool bStopCountDown;
//var int  ElapsedTime;
//var int  RemainingTime, RemainingMinute;
//var float SecondCount;
//#endif
var int TimeLimit;

var() globalconfig string ServerName;		// Name of the server, i.e.: Bob's Server.
var() globalconfig string ShortName;		// Abbreviated name of server, i.e.: B's Serv (stupid example)
var() globalconfig string AdminName;		// Name of the server admin.
var() globalconfig string AdminEmail;		// Email address of the server admin.
var() globalconfig int	  ServerRegion;		// Region of the game server.

var() globalconfig string MOTDLine1;		// Message
var() globalconfig string MOTDLine2;		// Of
var() globalconfig string MOTDLine3;		// The
var() globalconfig string MOTDLine4;		// Day

var string m_szGameTypeFlagRep;
var byte m_bReceivedGameType; 
var int m_iMapIndex;       // assigned by game info and used by the clients to determine if map changed between rounds
var bool m_bShowPlayerStates;

//enum ER6ServerState
//{
//    RSS_WaitingPlayers,     // we are waiting for players
//    RSS_BetweenRoundTime,   // 
//             // game has already commenced
//};

//0 -> we are waiting for players, 1-> this is the count down to game state, 2->RSS_InGameState, 3->end of round
const RSS_PlayersConnectingStage=0;  // this is the stage when players first join the game before count-down stage
const RSS_CountDownStage=1;          // we are in count down
const RSS_InPreGameState=2;			 // 
const RSS_InGameState=3;
const RSS_EndOfMatch=4;

var byte m_eOldServerState; 
var byte m_eCurrectServerState;

//R6CODE
var BOOL   m_bInPostBetweenRoundTime;       // are we in the PostBetweenRoundTime state

var BYTE   m_iNbWeaponsTerro;
var BOOL   m_bServerAllowRadar;            // if the server allow the radar (a game type CAN restrict this EVEN IF the option is checked by the player) 
var BOOL   m_bRepAllowRadarOption;
var BOOL   m_bGameOverRep;
var BOOL   m_bRestartableByJoin;
// struct did not replicated well...
var string m_aRepMObjDescription[16];
var string m_aRepMObjDescriptionLocFile[16];
var BYTE   m_aRepMObjCompleted[16];
var BYTE   m_aRepMObjFailed[16];
var BYTE   m_bRepMObjInProgress;
var BYTE   m_bRepMObjSuccess;
var BYTE   m_bRepLastRoundSuccess; // 0 = none, 1 = success, 2 = failed

// Variables used for connection to ubi.com
var INT           m_iGameSvrGroupID;    // ubi.com group ID
var INT           m_iGameSvrLobbyID;    // ubi.com lobby ID
//#ifdefR6PUNKBUSTER
var BOOL		  m_bPunkBuster;			  // server is a PunkBuster server
//#endif

//END R6CODE

replication
{
    reliable if (Role == ROLE_Authority)
        m_eCurrectServerState, m_iNbWeaponsTerro, m_bServerAllowRadar,m_bRepAllowRadarOption, m_bGameOverRep, 
        m_aRepMObjDescription, m_aRepMObjDescriptionLocFile, 
        m_aRepMObjCompleted, m_aRepMObjFailed, m_bRepMObjInProgress, m_bRepMObjSuccess, m_bRepLastRoundSuccess,
//#ifdefR6PUNKBUSTER
		m_bPunkBuster,
//#endif
        m_iGameSvrGroupID,m_iGameSvrLobbyID,m_bInPostBetweenRoundTime,m_bRestartableByJoin;



	reliable if ( bNetInitial && (Role==ROLE_Authority) )
		m_iMapIndex,m_szGameTypeFlagRep, GameName, GameClass,
		MOTDLine1, MOTDLine2,
		MOTDLine3, MOTDLine4, ServerName, ShortName, AdminName,
		AdminEmail, ServerRegion, TimeLimit;
//#ifndef R6CODE
//    ElapsedTime,RemainingTime, 
//#endif
}

//#ifdef R6CODE
simulated function ControllerStarted(R6GameMenuCom NewMenuCom);
simulated event NewServerState();
simulated event SaveRemoteServerSettings(string NewServerFile);
//#endif R6CODE

function SetServerState(byte newState)
{
    if (newState!=m_eCurrectServerState)
    {
        m_eCurrectServerState = newState;
        if (Level.NetMode == NM_ListenServer)
        {
            NewServerState();
        }
    }
}

simulated function PostBeginPlay()
{
	if( Level.NetMode == NM_Client )
	{
		// clear variables so we don't display our own values if the server has them left blank 
		ServerName = "";
		AdminName = "";
		AdminEmail = "";
		MOTDLine1 = "";
		MOTDLine2 = "";
		MOTDLine3 = "";
		MOTDLine4 = "";
	}

//#ifndef R6CODE
//	SecondCount = Level.TimeSeconds;
//	SetTimer(1, true);
//#endif
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
}

//#ifdef R6CODE
simulated function ResetOriginalData()
{
    Super.ResetOriginalData();
    m_bInPostBetweenRoundTime=false;
    m_bGameOverRep=false;
}
//#endif R6CODE

//#ifndef R6CODE
//simulated function Timer()
//{
//	if ( Level.NetMode == NM_Client )
//	{
//		if (Level.TimeSeconds - SecondCount >= Level.TimeDilation)
//		{
//			ElapsedTime++;
//			if ( RemainingMinute != 0 )
//			{
//				RemainingTime = RemainingMinute;
//				RemainingMinute = 0;
//			}
//			if ( (RemainingTime > 0) && !bStopCountDown )
//				RemainingTime--;
//			SecondCount += Level.TimeDilation;
//		}
//	}
//}
//#endif

//#ifdef R6CODE
function RefreshMPlayerInfo();

function SetRepMObjInfo( int index, bool bFailed, bool bCompleted )
{
    if ( bFailed )
        m_aRepMObjFailed[index] =  1;
    else
        m_aRepMObjFailed[index] =  0;

    if ( bCompleted )
        m_aRepMObjCompleted[index] =  1;
    else
        m_aRepMObjCompleted[index] =  0;
}

function SetRepMObjString( int index, string szDesc, string szLocFile )
{
    m_aRepMObjDescription[index] = szDesc;
    m_aRepMObjDescriptionLocFile[index] = szLocFile;
}


simulated function string GetRepMObjStringLocFile( int index )
{
    return m_aRepMObjDescriptionLocFile[index];
}

simulated function string GetRepMObjString( int index )
{
    return m_aRepMObjDescription[index];
}

simulated function bool IsRepMObjCompleted( int index )
{
    return m_aRepMObjCompleted[index] == 1;
}

simulated function bool IsRepMObjFailed( int index )
{
    return m_aRepMObjFailed[index] == 1;
}

simulated function ResetRepMObjInfo()
{
    local int i;
    
    for ( i = 0; i < ArrayCount( m_aRepMObjDescription ); ++i )
    {
        m_aRepMObjDescription[i] = "";
        m_aRepMObjDescriptionLocFile[i] = "";
        SetRepMObjInfo( i, false, false );
    }

    m_bRepMObjSuccess    = 0;
    m_bRepMObjInProgress = 1;
}

simulated function int GetRepMObjInfoArraySize()
{
    return ArrayCount( m_aRepMObjDescription );
}

simulated function SetRepMObjInProgress( bool bInProgress )
{
    if ( bInProgress )
        m_bRepMObjInProgress = 1;
    else
        m_bRepMObjInProgress = 0;
}

simulated function SetRepMObjSuccess( bool bSuccess )
{
    if ( bSuccess )
        m_bRepMObjSuccess = 1;
    else
        m_bRepMObjSuccess = 0;
}


simulated function SetRepLastRoundSuccess( BYTE bLastRoundSuccess )
{
    m_bRepLastRoundSuccess = bLastRoundSuccess;
}


simulated function bool IsInAGameState()
{
    return ((m_eCurrectServerState == RSS_InPreGameState) || 
            (m_eCurrectServerState == RSS_InGameState));
}
//#endif

defaultproperties
{
     m_bRestartableByJoin=True
     ServerName="Another Server"
     ShortName="Server"
     m_szGameTypeFlagRep="RGM_AllMode"
     RemoteRole=ROLE_SimulatedProxy
}
