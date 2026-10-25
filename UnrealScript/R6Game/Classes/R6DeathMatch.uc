//=============================================================================
//  R6DeathMatch.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/27 * Created by Aristomenis Kolokathis  Adversarial Mode
//=============================================================================

class R6DeathMatch extends R6AdversarialTeamGame;

var INT m_iNextPlayerTeamID;

function INT GetRainbowTeamColourIndex(INT eTeamName)
{
    return 1;  
}

function BroadcastTeam( Actor Sender, coerce string Msg, optional name Type )
{
    // do nothing, no team in deatmatch
}

//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
    m_iNextPlayerTeamID = c_iTeamNumUnknow + 1;
    m_missionMgr.m_bOnSuccessAllObjectivesAreCompleted = false;
    Level.m_bUseDefaultMoralityRules = false;
    
    Super.InitObjectives();
}

//------------------------------------------------------------------
// EndGame
//	
//------------------------------------------------------------------
function EndGame(PlayerReplicationInfo Winner, string Reason)
{
    local R6GameReplicationInfo gameRepInfo;
        
    if (m_bGameOver)    // this function has already been called
        return;
    
    gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
    
    if (( m_objDeathmatch.m_bCompleted ) && (m_bCompilingStats==true))
    {
        if ( bShowLog ) log( "** Game : someone won the deathmatch " );
        
        m_objDeathmatch.m_winnerCtrl.PlayerReplicationInfo.m_iRoundsWon++;
        BroadcastGameMsg( "", m_objDeathmatch.m_winnerCtrl.PlayerReplicationInfo.PlayerName, "HasWonTheRound", 
                          none, GetGameMsgLifeTime() );
    }
    else
    {
        BroadcastGameMsg( "", "", "RoundIsADraw", none, GetGameMsgLifeTime() );
        if ( bShowLog ) log( "** Game : it's a draw" );
    }

    Super.EndGame(Winner, Reason);
    
    
}


//------------------------------------------------------------------
// GetSpawnPointNum
//	
//------------------------------------------------------------------
function int GetSpawnPointNum(string options)
{
    return 0;
}

//------------------------------------------------------------------
// ResetPlayerTeam
//	
//------------------------------------------------------------------
function ResetPlayerTeam( Controller aPlayer )	// set pawn's m_iTeam
{
    Super.ResetPlayerTeam( aPlayer );
    aPlayer.pawn.PlayerReplicationInfo.TeamID = m_iNextPlayerTeamID;
    R6Pawn(aPlayer.pawn).m_iTeam = m_iNextPlayerTeamID;
    m_iNextPlayerTeamID++;
}


//------------------------------------------------------------------
// SetPawnTeamFriendlies
//	
//------------------------------------------------------------------
function SetPawnTeamFriendlies(Pawn aPawn)
{
    // this is pure deathmatch, everybody is everyone else's enemy
    // only friendly to yourself
    aPawn.m_iFriendlyTeams  = GetTeamNumBit( aPawn.m_iTeam );   
    
    // and an enemy to everyone else
    aPawn.m_iEnemyTeams     = ~aPawn.m_iFriendlyTeams;      
}

defaultproperties
{
     m_iUbiComGameMode=1
     m_bIsRadarAllowed=False
     m_bIsWritableMapAllowed=False
     m_szGameTypeFlag="RGM_DeathmatchMode"
}
