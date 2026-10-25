//=============================================================================
//  R6SquadTeamDeathmatch.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

class R6SquadTeamDeathmatch extends R6AdversarialTeamGame;

var INT m_iNextPlayerTeamID;

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
// GetNbOfRainbowAIToSpawnBaseOnTeamNb
//	
//------------------------------------------------------------------
function int GetNbOfRainbowAIToSpawnBaseOnTeamNb( int iTeamNb)
{
    switch ( iTeamNb  )
    {
        case  0: return 0; 
        case  1: return 3; 
        case  2: return 3;
        case  3: return 3; 
        case  4: return 2;

        default: return 1;
    } 
}

//------------------------------------------------------------------
// GetNbOfTeamMemberToSpawn
//	spawn the nb of ai in team. if the nb of player in each team
//  is not equal, adjust the nb of ai for the other team
//------------------------------------------------------------------
function int GetNbOfRainbowAIToSpawn( PlayerController aController )
{
    local int iAlphaNb;
    local int iBravoNb;
    local int iHumanNb;
    local int iAdjustedMax;
    local int iNbAssigned;
    local int iNbPawnAssignedForThisController;
    local int iAiMax;
    local R6GameMenuCom.ePlayerTeamSelection eTeamToAdjust;
    local Controller P;

    if ( R6PlayerController(aController).m_TeamSelection != PTS_Alpha &&
         R6PlayerController(aController).m_TeamSelection != PTS_Bravo    )
        return 0;

    GetNbHumanPlayerInTeam( iAlphaNb, iBravoNb );

    if ( R6PlayerController(aController).m_TeamSelection == PTS_Alpha )
        iAiMax = GetNbOfRainbowAIToSpawnBaseOnTeamNb( iAlphaNb );
    else
        iAiMax = GetNbOfRainbowAIToSpawnBaseOnTeamNb( iBravoNb );

    // if both are equal, return this, otherwise cap.
    if ( iAlphaNb == iBravoNb || 
         iAlphaNb == 0 || iBravoNb == 0) // or doesn't have any human player
        return iAiMax;

    // if i'm in team with the least nb of human player, return iAiMax
    if ( R6PlayerController(aController).m_TeamSelection == PTS_Alpha )
    {
        if ( iAlphaNb < iBravoNb )
            return iAiMax;
    }
    else 
    {
        if ( iAlphaNb > iBravoNb )
            return iAiMax;
    }

    // from now, we have to cap the number of ai in his team 
    if ( iAlphaNb > iBravoNb )  // more player in alpha, cap the ai for the alpha team
    {
        iAdjustedMax  = GetNbOfRainbowAIToSpawnBaseOnTeamNb( iBravoNb ) * iBravoNb;
        eTeamToAdjust = PTS_Alpha;
        iHumanNb      = iAlphaNb;
    }
    else                        // more player in bravo, cap the ai for the bravo team
    {
        iAdjustedMax  = GetNbOfRainbowAIToSpawnBaseOnTeamNb( iAlphaNb ) * iAlphaNb;
        eTeamToAdjust = PTS_Bravo;
        iHumanNb      = iBravoNb;
    }
    
    // minus the human player
    iAdjustedMax -= iHumanNb;

    // loop until we have assigned all the ai to each member of the eTeamToAdjust
    while ( iAdjustedMax > 0 )
    {
        // try to assign an ai per controller
        for (P=Level.ControllerList; P!=None; P=P.NextController )
        {
            if ( R6PlayerController( P ) != None &&
                 R6PlayerController(P).m_TeamSelection == eTeamToAdjust )
            {
                if ( aController == P ) // this is the player interested to spawn a team
                {
                    ++iNbPawnAssignedForThisController;
                }
                iAdjustedMax--; // minus 
            }

            if ( iAdjustedMax == 0)
                break;
        }
    }

    iNbPawnAssignedForThisController++; // plus the human player
    
    return iNbPawnAssignedForThisController;
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
            BroadcastGameMsg(       "", "", "RedTeamWonRound", m_sndRedTeamWonRound, GetGameMsgLifeTime() );
            BroadcastMissionObjMsg( "", "", "RedNeutralizedGreen", none, GetGameMsgLifeTime() );
            AddTeamWonRound( c_iBravoTeam );
        }
    }
    else
    {
        if ( bShowLog ) log( "** Game : it's a draw" );
        BroadcastGameMsg( "", "", "RoundIsADraw", m_sndRoundIsADraw, GetGameMsgLifeTime() );
    }

    Super.EndGame(Winner, Reason);
}

defaultproperties
{
     m_szGameTypeFlag="RGM_SquadTeamDeathmatch"
}
