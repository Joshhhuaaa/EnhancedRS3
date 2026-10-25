//=============================================================================
//  R6CoOpMode.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/21 * Created by Aristomenis Kolokathis
//=============================================================================

class R6CoOpMode extends R6MultiPlayerGameInfo;


// R6PawnDied is called more than once, in some cases, therefore we need to prevent some functions
// from being called when there is no need to. That is what m_bGameOver checks for

var BOOL bTerroristLeft;
var BOOL bRainbowLeft;

event InitGame( string Options, out string Error )
{
    Super(R6GameInfo).InitGame(Options, Error);
    MaxPlayers = Min(8, MaxPlayers);
}

function INT GetRainbowTeamColourIndex(INT eTeamName)
{
    return 1;  
}


function int GetSpawnPointNum(string options)
{
    return 0;
}

function SetPawnTeamFriendlies(Pawn aPawn)
{
    SetDefaultTeamFriendlies( aPawn );
}

///////////////////////////////////////////////////////////////////////////////
// EndGame()
///////////////////////////////////////////////////////////////////////////////
function EndGame( PlayerReplicationInfo Winner, string Reason ) 
{
    local R6GameReplicationInfo gameRepInfo;
    local R6MissionObjectiveBase obj;
    
    // This function has already been called
    if( m_bGameOver )
        return;

    gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
    if ( m_missionMgr.m_eMissionObjectiveStatus == eMissionObjStatus_success )
    {
        BroadcastMissionObjMsg( "", "", "MissionSuccesfulObjectivesCompleted", Level.m_sndMissionComplete,
                                GetGameMsgLifeTime());
    }
    else
    {
        obj = m_missionMgr.GetMObjFailed();
        BroadcastMissionObjMsg( "", "", "MissionFailed", none, GetGameMsgLifeTime() );
        if ( obj != none ) // if no failure
            BroadcastMissionObjMsg( Level.GetMissionObjLocFile( obj ), "", 
                                    obj.GetDescriptionFailure(), obj.GetSoundFailure(), GetGameMsgLifeTime()); 
    }

    Super.EndGame( Winner, Reason );
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
    

    if ( !R6PlayerController(_Controller).IsPlayerPassiveSpectator() && (iHumanCount<=1)) // in this case we restart the round
    {
        ResetRound();
    }
}

defaultproperties
{
}
