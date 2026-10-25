//=============================================================================
//  R6AbstractGameInfo.uc : This is the abstract class for the R6GameInfo class.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    august 8th, 2001 * Created by Chaouky Garram
//=============================================================================
class R6AbstractGameInfo extends GameInfo
    native
    abstract;

import class R6MissionObjectiveMgr;

var     PlayerController     m_Player;       // AK: local player controller VALID *ONLY* FOR SINGLE PLAYER MODE!!!!!!!
var     R6AbstractNoiseMgr  m_noiseMgr;     // Manager for the loudness of MakeNoise sound
// the following flag can be used for to determine game mode
var     R6MissionObjectiveMgr m_missionMgr;

var				INT			m_iNbOfRainbowAIToSpawn;
var             INT         m_iNbOfTerroristToSpawn; // this is now set in the game info init
var             BOOL        m_bFriendlyFire;
var             BOOL        m_bEndGameIgnoreGamePlayCheck;
var             BOOL        m_bGameOverButAllowDeath;

var INT	   m_iDiffLevel;			// The difficulty level of the terro -- in coop 

var bool m_bTimerStarted;       // Boolean to inticate that we have started the countdown
var INT  m_fTimerStartTime;     // Time at which we began counting down

var FLOAT  m_fEndingTime;       // Time the round will end at in seconds.
var FLOAT  m_fTimeBetRounds;    // Time between round (seconds)
var float  m_fEndVoteTime; // polls close at time m_fEndKickVoteTime
var string m_VoteInstigatorName;       // who is the player that is kicking m_PlayerKick
var PlayerController    m_PlayerKick;       // this is the player who may be kicked

var PlayerController	m_pCurPlayerCtrlMdfSrvInfo; // the player controller who's modifying the server settings

var string m_szDefaultActionPlan; // To have the right part of the name of the action planning. The left part is the name of the map.
var BOOL   m_bInternetSvr;          // The server is a internet server
#ifndefSPDEMO
var UdpBeacon m_UdpBeacon;
#endif

function Object GetRainbowTeam(INT eTeamName);
function Actor GetNewTeam(Actor aCurrentTeam, optional bool bNextTeam);
function ChangeTeams(PlayerController inPlayerController, optional bool bPrevTeam, optional Actor newRainbowTeam);
function ChangeOperatives(PlayerController inPlayerController, INT iTeamId, INT iOperativeId);
function InstructAllTeamsToHoldPosition();
function InstructAllTeamsToFollowPlanning();
function BroadcastGameMsg( string szLocFile, string szPreMsg, string szMsgID, optional Sound sndGameStatus, OPTIONAL int iLifeTime );

function R6AbstractNoiseMgr GetNoiseMgr();

function Object GetMultiCoopPlayerVoicesMgr(INT iTeam);
function Object GetMultiCoopMemberVoicesMgr();
function Object GetPreRecordedMsgVoicesMgr();
function Object GetMultiCommonVoicesMgr();
function Object GetRainbowPlayerVoicesMgr();
function Object GetRainbowMemberVoicesMgr();
function Object GetCommonRainbowPlayerVoicesMgr();
function Object GetCommonRainbowMemberVoicesMgr();
function Object GetRainbowOtherTeamVoicesMgr(INT iIDVoicesMgr);
function Object GetTerroristVoicesMgr(ETerroristNationality eNationality);
function Object GetHostageVoicesMgr(EHostageNationality eNationality, BOOL bIsFemale);
function BOOL ProcessKickVote(PlayerController _KickPlayer, string KickersName);
function BOOL ProcessChangeMapVote(string InstigatorName);
function ResetRound();
function AdminResetRound();
function ResetPenalty(); 
function SetJumpingMaps(bool _flagSetting, int iNextMapIndex);
function UpdateRepResArrays();
function PauseCountDown();
function UnPauseCountDown();
function StartTimer(); // MissionPack1 2 // MPF1
function BOOL IsTeamSelectionLocked();

function BOOL CanSwitchTeamMember()
{
    return true;
}

function actor GetRainbowAIFromTable()
{
	return none;
}

function bool RainbowOperativesStillAlive()
{
	return false;
}

function int GetNbOfRainbowAIToSpawn( PlayerController aController )
{
    return m_iNbOfRainbowAIToSpawn; 
}

function CreateMissionObjectiveMgr()
{
    if ( m_missionMgr == none )
    {
		m_missionMgr = spawn( class'R6Abstract.R6MissionObjectiveMgr' );
    }
}

function BroadcastMissionObjMsg( string szLocMsg, string szPreMsg, string szMsgID, optional Sound sndGameStatus, OPTIONAL int iLifeTime );
function UpdateRepMissionObjectivesStatus();
function UpdateRepMissionObjectives();
function ResetRepMissionObjectives();

function Find2DTexture(string TeamClass, out Material MenuTexture, out Object.Region TextureRegion) {}

function SpawnAIandInitGoInGame();

function InitObjectives();
function RemoveObjectives()
{
    m_missionMgr.RemoveObjectives();
}

function PawnKilled( Pawn killed )
{
    if ( m_bGameOver )
        return;
        
    m_missionMgr.PawnKilled(killed);
    
    if( CheckEndGame( none, "") )
	    EndGame(none , "");
} 

function RemoveTerroFromList( Pawn toRemove );

function PawnSeen( Pawn seen, Pawn witness )
{
    if ( m_bGameOver )
        return;

    m_missionMgr.PawnSeen(seen, witness);
    
    if( CheckEndGame( none, "") )
	    EndGame(none , "");
}

function PawnHeard( Pawn heard, Pawn witness )
{
    if ( m_bGameOver )
        return;

    m_missionMgr.PawnHeard(heard, witness);
    
    if( CheckEndGame( none, "") )
	    EndGame(none , "");
}

function PawnSecure( Pawn secured )
{
    if ( m_bGameOver )
        return;

    m_missionMgr.PawnSecure( secured );

    if( CheckEndGame( none, "") )
	    EndGame(none , "");
}

function bool IsLastRoundOfTheMatch();

//------------------------------------------------------------------
// GetEndGamePauseTime
//	return the time needed when the game is over and we still
//  stay in game to see and heard the end of round result
//------------------------------------------------------------------
function float GetEndGamePauseTime()
{
    if (( Level.NetMode == NM_Standalone ))
        return Level.m_fEndGamePauseTime;
    else if (Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag))
        return 6;
    else
    {
        if (IsLastRoundOfTheMatch())
            return 6;
        else
            return 4;
    }
}

//------------------------------------------------------------------
// GetGameMsgLifeTime
//	return the life time of game msg
//------------------------------------------------------------------
function float GetGameMsgLifeTime()
{
    // if in multi and it's the last round
    if ( IsLastRoundOfTheMatch() && Level.NetMode != NM_Standalone )
    {
        return 10; // longer time so client as the time to read end match msg
    }
    else
    {
        return 5;
    }
}


function BaseEndGame();

//------------------------------------------------------------------
// EndGameAndJumpToMapID
//	set info to jump to a map, end game by aborting the mission without 
//  game stats effect
//------------------------------------------------------------------
function EndGameAndJumpToMapID( int iGotoMapId )
{
    local R6ServerInfo pServerOptions;

    pServerOptions = class'Actor'.static.GetServerOptions();
    if(pServerOptions != none && pServerOptions.m_ServerMapList != none)
        pServerOptions.m_ServerMapList.GetNextMap( iGotoMapId );

    AbortScoreSubmission();
    SetJumpingMaps(true, iGotoMapId);
    if (IsInState('InBetweenRoundMenu') || IsInState('PostBetweenRoundTime'))
    {
        RestartGameMgr();
    }
    else
    {
        // the game can't be completed or failed, we just end the game
        // without stats. This is needed to load a new map specified by the admin
        BaseEndGame();
        m_bEndGameIgnoreGamePlayCheck = true;
    }
}

function AbortMission()
{
    m_missionMgr.AbortMission();  
    
    CheckEndGame( none, ""); // update the missionMgr
    EndGame(none , "");      // force to end game       
    
    // will not wait the delay
    m_bTimerStarted = true;
    m_fTimerStartTime = Level.TimeSeconds - GetEndGamePauseTime() - 1;
    m_fTimerStartTime = Clamp( m_fTimerStartTime, 0, Level.TimeSeconds );
}

function CompleteMission()
{
    m_missionMgr.CompleteMission();  
    CheckEndGame( none, ""); // update the missionMgr
	EndGame(none , "");      // force to end game
}

function EnteredExtractionZone(actor other)
{
    if ( m_bGameOver )
        return;

    m_missionMgr.EnteredExtractionZone( pawn(other) );

    if( CheckEndGame( none, "") )
	    EndGame(none , "");
}

function LeftExtractionZone(actor other)
{
    if ( m_bGameOver )
        return;

    m_missionMgr.ExitExtractionZone( pawn(other) );

    if( CheckEndGame( none, "") )
	    EndGame(none , "");
}

function IObjectInteract( Pawn aPawn, Actor anInteractiveObject )
{
    if ( m_bGameOver )
        return;

    if ( m_missionMgr == none )
        return;
    
    m_missionMgr.IObjectInteract( aPawn, anInteractiveObject );

    if( CheckEndGame( none, "") )
	    EndGame(none , "");
}

function IObjectDestroyed( Pawn aPawn, Actor anInteractiveObject )
{
    if ( m_bGameOver )
        return;

    m_missionMgr.IObjectDestroyed( aPawn, anInteractiveObject );

    if( CheckEndGame( none, "") )
	    EndGame(none , "");
}

function TimerCountdown()
{
    if ( m_bGameOver )
        return;

    if( CheckEndGame( none, "") )
	    EndGame(none , "");
}

function ResetPlayerTeam(Controller aPlayer);

function RemoveController(Controller aPlayer);

function SetPawnTeamFriendlies(Pawn aPawn)
{
    SetDefaultTeamFriendlies( aPawn );
}

//------------------------------------------------------------------
// SetDefaultTeamFriendlies: set the default value based on single
//	player mode. 
//------------------------------------------------------------------
function SetDefaultTeamFriendlies(Pawn aPawn)
{        
}


// this function will decide if KillerPawn should be a spectator in the next round
function SetTeamKillerPenalty(Pawn DeadPawn, Pawn KillerPawn);
function ApplyTeamKillerPenalty( Pawn aPawn );

 // if this function has not been defined then always return false
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
    return false;
}


function PostBeginPlay()
{
    SetTimer(0,false);  //UW has this timer turned on, we don't need it on by default
}

function PlayerReadySelected(PlayerController _Controller);
function IncrementRoundsFired(Pawn Instigator, BOOL ForceIncrement);


//------------------------------------------------------------------
// NotifyMatchStart: fired when the round start
//	
//------------------------------------------------------------------
function NotifyMatchStart();

function BOOL ProcessPlayerReadyStatus();

function bool IsUnlimitedPractice();
exec function SetUnlimitedPractice( bool bUnlimitedPractice, OPTIONAL bool bSendMsg );
function LogVoteInfo();

function string GetIntelVideoName( R6MissionDescription desc )
{
    return "generic_intel";
}

defaultproperties
{
     m_iNbOfTerroristToSpawn=1
}
