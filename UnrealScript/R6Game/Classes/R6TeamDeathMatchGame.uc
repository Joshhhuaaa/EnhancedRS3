//=============================================================================
//  R6TeamDeathMatchGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/05 * Created by Aristomenis Kolokathis
//=============================================================================

class R6TeamDeathMatchGame extends R6AdversarialTeamGame;

//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
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

    if ( m_objDeathmatch.m_bCompleted )        // a team was neutralized
    {
        if ( m_objDeathmatch.m_iWinningTeam == c_iTeamNumAlpha )
        {
            BroadcastGameMsg(       "", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, GetGameMsgLifeTime() );
            BroadcastMissionObjMsg( "", "", "GreenNeutralizedRed", none, GetGameMsgLifeTime() );
            AddTeamWonRound( c_iAlphaTeam );
        }
        else if ( m_objDeathmatch.m_iWinningTeam == c_iTeamNumBravo)
        {
            BroadcastGameMsg(       "", "", "RedTeamWonRound", m_sndRedTeamWonRound, GetGameMsgLifeTime());
            BroadcastMissionObjMsg( "", "", "RedNeutralizedGreen", none, GetGameMsgLifeTime() );
            AddTeamWonRound( c_iBravoTeam );
        }
    }
    else
    {
        if ( bShowLog ) log( "** Game : it's a draw" );
        BroadcastGameMsg( "", "", "RoundIsADraw", m_sndRoundIsADraw, GetGameMsgLifeTime());
    }

    Super.EndGame(Winner, Reason);
}

defaultproperties
{
     m_iUbiComGameMode=2
     m_szGameTypeFlag="RGM_TeamDeathmatchMode"
}
