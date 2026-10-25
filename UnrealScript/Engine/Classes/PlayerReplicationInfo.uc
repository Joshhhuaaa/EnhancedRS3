//=============================================================================
// PlayerReplicationInfo.
//=============================================================================
class PlayerReplicationInfo extends ReplicationInfo
	native nativereplication;

// also replicate here player class and skins and any other seldom changed stuff


var float				Score;			// Player's current score.
var int					Ping;
var Volume				PlayerLocation;
var int					NumLives;

var string				PlayerName;		// Player name, or blank if none.
var string				OldName, PreviousName;		// Temporary value.
var int					PlayerID;		// Unique id number.
var string              m_szUbiUserID;
var int					TeamID;			// Player position in team.
var class<VoicePack>	VoiceType;
//#ifdef R6CODE
var int					iOperativeID;	// used to select which operative's face will be used
//#endif
var bool				bIsFemale;
var bool				bFeigningDeath;
var bool				bIsSpectator;
var bool				bWaitingPlayer;
var bool				bReadyToPlay;
var bool				bOutOfLives;
var bool				bBot;
var Texture				TalkTexture;

// Time elapsed.
var int					StartTime;
var int					TimeAcc;
//#ifdef R6Code
// -- statistics -- //
var BOOL		        m_bPlayerReady; // the player ready status

// values that are kept between rounds
var         INT         m_iKillCount;
var         INT         m_iKillCountForEvent;   // used to signal when kill count has changed
var         INT	        m_iRoundFired;
var         INT	        m_iRoundsHit;
var         INT         m_iRoundsPlayed;
var         BOOL        m_bJoinedTeamLate;
var         INT         m_iRoundsWon;
var float				Deaths;			// Number of player's deaths.
var         INT         m_iDeathCountForEvent;   // used to signal when kill count has changed

// backup of stats in case of Admin Restart Round
var         INT         m_iBackUpKillCount;
var         INT	        m_iBackUpRoundFired;
var         INT	        m_iBackUpRoundsHit;
var         INT         m_iBackUpRoundsPlayed;
var         INT         m_iBackUpRoundsWon;
var float				m_iBackUpDeaths;			// Number of player's deaths.

// values that are reset
var         INT         m_iHealth;
var         INT         m_iRoundKillCount;      // frag count
var         string      m_szKillersName;        // name of the player that killed me

// we need the number of times I have died or suiceded
// m_szFavWeapon is to be removed and replaced by the killer name
//var         string      m_szFavWeapon;          // the server replicates the Fav Weapon to all clients

// For General Escort Mode only
// this is a temporary hack to tell the server that I should be the General
// If m_bIsGeneral is false for all players then the server should pick
// a general randomly
var travel BOOL                 m_bIsEscortedPilot;

// MPF1 // For Kamikaze Mode only (for MissionPack2)
var travel BOOL                 m_bIsBombMan;

// Variables used for ubi.com game service
var travel BOOL         m_bAlreadyLoggedIn;
var travel INT          m_iUniqueID;
var BOOL                m_bClientWillSubmitResult; // server side info on player
var BOOL                m_bIsTheIntruder;
var BOOL                m_bHasTheFloppy;


// this is the mapping of the stats for GS ladder stats submission
const m_cKillStat = 0;
const m_cDeathStat=1;
const m_cRatioStat=2;
const m_cMission=3;
const m_cPlayTime=4;

//#endif R6CODE

replication
{
    // Things the server should send to the client.
    reliable if ( bNetDirty && (Role == Role_Authority) )
        PlayerName, TeamID, PlayerID,VoiceType, iOperativeID, bIsFemale, bFeigningDeath, //#ifdef R6CODE iOperativeID
        bIsSpectator, bWaitingPlayer, bReadyToPlay, TalkTexture,  bOutOfLives, 
        m_bIsEscortedPilot,m_szKillersName,m_bPlayerReady,m_szUbiUserID
		,m_bIsBombMan; // MPF1  //MissionPack1 (for MissionPack2)

    unreliable if ( bNetDirty && (Role == Role_Authority) )
        Score, Ping, PlayerLocation,m_bJoinedTeamLate;

    reliable if ( bNetInitial && (Role == Role_Authority) )
        StartTime,bBot;

    reliable if (Role == Role_Authority)
        m_bClientWillSubmitResult, m_bIsTheIntruder;

    unreliable if (Role == Role_Authority)
        m_iBackUpKillCount,m_iBackUpRoundFired,m_iBackUpRoundsHit,m_iBackUpRoundsPlayed,m_iBackUpRoundsWon,
        m_iBackUpDeaths,Deaths, m_iRoundKillCount,m_iKillCount,m_iHealth,m_iRoundFired, m_iRoundsHit, m_iRoundsPlayed,
        m_iRoundsWon;
}

function PostBeginPlay()
{
    StartTime = Level.TimeSeconds;
    Timer();
    SetTimer(2.0, true);
}

//#ifdef R6CODE
function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	
	// on server side only
	if(Role == Role_Authority)
	{
        // since this is Authority we have access to the GameInfo
        PlayerID = Level.Game.CurrentID++;
	}
}
//#endif

simulated function SaveOriginalData()
{
    if ( m_bResetSystemLog ) LogResetSystem( true );
    Super.SaveOriginalData();	
}

//special rset for stats if an admin wants to reset the round 
// thus reseting stats to what they were at the beginnning of last round.
function AdminResetRound()
{
    m_iKillCount    = m_iBackUpKillCount;
    m_iRoundFired   = m_iBackUpRoundFired;
    m_iRoundsHit    = m_iBackUpRoundsHit;
    m_iRoundsPlayed = m_iBackUpRoundsPlayed;
    m_iRoundsWon    = m_iBackUpRoundsWon;
    Deaths          = m_iBackUpDeaths;
}

simulated function ResetOriginalData()
{
    if ( m_bResetSystemLog ) LogResetSystem( false );
    Super.ResetOriginalData();

    m_iHealth = 0;
    m_iRoundKillCount = 0;      // frag count
// designers want to reset.......
//  m_szKillersName = "";        // name of the player that killed me

    m_iBackUpKillCount      = m_iKillCount;
    m_iBackUpRoundFired     = m_iRoundFired;
    m_iBackUpRoundsHit      = m_iRoundsHit;
    m_iBackUpRoundsPlayed   = m_iRoundsPlayed;
    m_iBackUpRoundsWon      = m_iRoundsWon;
    m_iBackUpDeaths         = Deaths;
    m_bPlayerReady          = false;
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	Score = 0;
//	Deaths = 0;
	bReadyToPlay = false;
	NumLives = 0;
	bOutOfLives = false;
    m_bPlayerReady = false;
}

simulated function string GetLocationName()
{
	if ( PlayerLocation != None )
		return PlayerLocation.LocationName;
	else
		return"";
}

simulated function string GetHumanReadableName()
{
	return PlayerName;
}

function UpdatePlayerLocation()
{
	local Volume V;

	PlayerLocation = None;
	ForEach TouchingActors(class'Volume',V)
		if ( (V.LocationName != "") 
			&& ((PlayerLocation == None) || (V.LocationPriority > PlayerLocation.LocationPriority))
			&& V.Encompasses(self) )
		{
			PlayerLocation = V;
		}
}

/* DisplayDebug()
list important controller attributes on canvas
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Canvas.DrawText("     PlayerName "$PlayerName);
}
 					
function Timer()
{
	UpdatePlayerLocation();

	if ( FRand() < 0.65 )
		return;

// #ifdef R6CODE  // if it's R6CODE we don't want to do this type of ping
//	if (PlayerController(Owner) != None)
//    {
//        Ping = int(Controller(Owner).ConsoleCommand("GETPING"));
//    }
// #endif R6CODE

}

function SetPlayerName(string S)
{
	OldName = PlayerName;
    
    // R6CODE
    ReplaceText(S, " ", "_");
    ReplaceText(S, "~", "_");
    ReplaceText(S, "?", "_");
    ReplaceText(S, ",", "_");
    ReplaceText(S, "#", "_");
    ReplaceText(S, "/", "_");
    PlayerName = RemoveInvalidChars(S);
}

function SetWaitingPlayer(bool B)
{
	bIsSpectator = B;	
	bWaitingPlayer = B;
}

//function ServerNewFavWeapon(string szNewFavWeapon)
//{
//    m_szFavWeapon = szNewFavWeapon;
//}

defaultproperties
{
     iOperativeID=-1
     bIsSpectator=True
     RemoteRole=ROLE_SimulatedProxy
     bTravel=True
     NetUpdateFrequency=2.000000
}
