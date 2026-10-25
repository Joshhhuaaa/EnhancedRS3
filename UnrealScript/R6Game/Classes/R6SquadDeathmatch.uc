//=============================================================================
//  R6SquadDeathmatch.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

class R6SquadDeathmatch extends R6AdversarialTeamGame;

var INT m_iNextPlayerTeamID;

//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
    m_iNextPlayerTeamID = c_iTeamNumAlpha;

    Level.m_bUseDefaultMoralityRules = false;
    Super.InitObjectives();
}


//------------------------------------------------------------------
// GetNbOfRainbowAIToSpawn
//	
//------------------------------------------------------------------
function int GetNbOfRainbowAIToSpawn( PlayerController aController )
{
    if ( R6PlayerController(aController).m_TeamSelection == PTS_Alpha )
        return m_iNbOfRainbowAIToSpawn;
    else
        return 0;
}

//------------------------------------------------------------------
// 
//	set the number of ai to spawn based on the 
//------------------------------------------------------------------
auto state InBetweenRoundMenu
{
    function EndState()
    {
        local int         iNbOfPlayer;
        local Controller  P;

        for (P=Level.ControllerList; P!=None; P=P.NextController )
        {
            if (    P.IsA('PlayerController') && P.PlayerReplicationInfo != None 
                 && R6PlayerController(P).m_TeamSelection == PTS_Alpha )
            {
                ++iNbOfPlayer;
            }
        }

        switch ( iNbOfPlayer  )
        {
            case  0: m_iNbOfRainbowAIToSpawn = 0; break;
            case  1: m_iNbOfRainbowAIToSpawn = 4; break;
            case  2: m_iNbOfRainbowAIToSpawn = 3; break;
            case  3: m_iNbOfRainbowAIToSpawn = 3; break;
            case  4: m_iNbOfRainbowAIToSpawn = 3; break;
            case  5: m_iNbOfRainbowAIToSpawn = 2; break;
            case  6: m_iNbOfRainbowAIToSpawn = 2; break;
            case  7: m_iNbOfRainbowAIToSpawn = 1; break;
            case  8: m_iNbOfRainbowAIToSpawn = 1; break;
            case  9: m_iNbOfRainbowAIToSpawn = 1; break;
            case 10: m_iNbOfRainbowAIToSpawn = 1; break;
        
            default: m_iNbOfRainbowAIToSpawn = 0;
        }

        if ( bShowLog ) 
            log( "NotifyMatchStart nb of player: " $iNbOfPlayer$ " AI in a team: " $m_iNbOfRainbowAIToSpawn );

        Super.EndState();
    }
}


//------------------------------------------------------------------
// ResetPlayerTeam
//	set pawn's m_iTeam 
//------------------------------------------------------------------
function ResetPlayerTeam( Controller aPlayer )	
{
    local R6Pawn aPawn;
    
    Super.ResetPlayerTeam( aPlayer );
    
    aPawn = R6Pawn(aPlayer.pawn);
    // now that we know how many player are playing, set the teamID
    aPawn.PlayerReplicationInfo.TeamID = m_iNextPlayerTeamID;
    aPawn.m_iTeam = m_iNextPlayerTeamID;
    m_iNextPlayerTeamID++;

    R6PlayerController( aPlayer ).m_TeamManager.SetMemberTeamID( aPawn.m_iTeam );
}

//------------------------------------------------------------------
// SetPawnTeamFriendlies
//	
//------------------------------------------------------------------
function SetPawnTeamFriendlies(Pawn aPawn)
{
    // this is pure deathmatch, everybody is everyone else's enemy
    // only friendly to yourself and team mate
    aPawn.m_iFriendlyTeams  = GetTeamNumBit( aPawn.m_iTeam );   
    // and an enemy to everyone else
    aPawn.m_iEnemyTeams     = ~aPawn.m_iFriendlyTeams;      
}

//------------------------------------------------------------------
// EndGame
//	
//------------------------------------------------------------------
function EndGame(PlayerReplicationInfo Winner, string Reason)
{
    local R6GameReplicationInfo gameRepInfo;

    if (m_bGameOver)    
        return;
    
    gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
    BroadcastGameMsg( "", "", "GameOver", none, GetGameMsgLifeTime() );
        
    if ( m_objDeathmatch.m_bCompleted )
    {
        if ( bShowLog ) log( "** Game : the pilot was extracted" );
        
        BroadcastGameMsg( "", m_objDeathmatch.m_winnerCtrl.PlayerReplicationInfo.PlayerName, "HasWonTheRound", 
                          none, GetGameMsgLifeTime() );
    }
    else
    {
        if ( bShowLog ) log( "** Game : it's a draw" );

        BroadcastGameMsg( "", "", "RoundIsADraw", none, GetGameMsgLifeTime() );
    }

    Super.EndGame(Winner, Reason);
}

defaultproperties
{
     m_szGameTypeFlag="RGM_SquadDeathmatch"
}
