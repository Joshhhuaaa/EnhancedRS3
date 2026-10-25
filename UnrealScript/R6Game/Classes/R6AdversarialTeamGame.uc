//=============================================================================
//  R6AdversarialTeamGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/05 * Created by Aristomenis Kolokathis
//    2002/04/22 * AK: added team selection support for menu system
//=============================================================================

class R6AdversarialTeamGame extends R6MultiPlayerGameInfo;

struct MultiPlayerTeamInfo 
{
    var Array<R6PlayerController>   m_aPlayerController; 
    var INT                         m_iLivingPlayers;
};


var const int c_iAlphaTeam;
var const int c_iBravoTeam;
var const int c_iMaxTeam;
var MultiPlayerTeamInfo     m_aTeam[2]; // must be equal to == c_iMaxTeam

var bool                m_bAddObjDeathmatch;
var R6MObjDeathmatch    m_objDeathmatch;

var Sound m_sndGreenTeamWonRound;
var Sound m_sndRedTeamWonRound;
var Sound m_sndRoundIsADraw;

var Sound m_sndGreenTeamWonMatch;
var Sound m_sndRedTeamWonMatch;
var Sound m_sndMatchIsADraw;


event PostBeginPlay()
{
    Super(R6GameInfo).PostBeginPlay();
    AddSoundBankName("Voices_Control_Multiplayer");
}
//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
    local int iLength;

    if ( m_bAddObjDeathmatch )
    {
        // add deathmatch rules
        m_objDeathmatch = new(none) class'R6Game.R6MObjDeathmatch';
        m_objDeathmatch.m_bTeamDeathmatch = true;
        iLength = m_missionMgr.m_aMissionObjectives.Length;
        m_missionMgr.m_aMissionObjectives[iLength] = m_objDeathmatch;
        iLength++;
    }

    Super.InitObjectives();
}

//------------------------------------------------------------------
// GetTeamIDFromTeamSelection
//	convert a EPlayerTeamSelection to a R6Adversarial team ID
//------------------------------------------------------------------
function int GetTeamIDFromTeamSelection( R6GameMenuCom.EPlayerTeamSelection eTeam )
{
    if ( eTeam == PTS_Alpha )
    {
        return c_iAlphaTeam;
    }
    else 
    {
        return c_iBravoTeam;
    }
}

//------------------------------------------------------------------
// SetControllerTeamID
//	convert a EPlayerTeamSelection to a  R6AbstractGameInfo team ID
//------------------------------------------------------------------
function SetControllerTeamID( R6PlayerController pController, R6GameMenuCom.EPlayerTeamSelection eTeam )
{
    if (      eTeam == PTS_Alpha )
    {
        pController.m_pawn.m_iTeam = c_iTeamNumAlpha;
    }
    else if ( eTeam == PTS_Bravo) 
    {
        pController.m_pawn.m_iTeam = c_iTeamNumBravo;
    }

#ifdefDebug    
        log("SetControllerTeamID called on "$pController.PlayerReplicationInfo.PlayerName$
            " new TeamID=" $pController.m_pawn.m_iTeam$
            " current is "$pController.PlayerReplicationInfo.TeamID );
#endif
}

//------------------------------------------------------------------
// IsPlayerInTeam
//	
//------------------------------------------------------------------
function bool IsPlayerInTeam( R6PlayerController pController, int iTeamID )
{
    local int i;

    if ( iTeamID >= c_iMaxTeam )
        return false;

    for ( i = 0; i < m_aTeam[ iTeamID ].m_aPlayerController.Length; ++i )
    {
        if (  m_aTeam[ iTeamID ].m_aPlayerController[i] == pController )
        {
            return true; 
        }
    }

    return false;
}

//------------------------------------------------------------------
// AddPlayerToTeam
//	
//------------------------------------------------------------------
function AddPlayerToTeam( R6PlayerController pController, R6GameMenuCom.EPlayerTeamSelection eTeam )
{   
    local int iLength;
    local int iTeamID;

    // get the teamID
    iTeamID = GetTeamIDFromTeamSelection( eTeam );
    
    // add the player to his team and set his controllerTeamID
    iLength = m_aTeam[ iTeamID ].m_aPlayerController.Length;
    m_aTeam[ iTeamID ].m_aPlayerController[ iLength ] = pController;

    if ( bShowLog ) log( "AddPlayerToTeam pController=" $pController$ " (alpha=0, bravo=1) index=" $iTeamID );
}

//------------------------------------------------------------------
// RemovePlayerFromTeam: remove player from all teams
//	
//------------------------------------------------------------------
function bool RemovePlayerFromTeams( R6PlayerController pController )
{
    local int   iTeam;
    local int   i;
    local bool  bRemoved;

    for ( iTeam = 0; iTeam < ArrayCount( m_aTeam ); ++iTeam )
    {
        for ( i = 0; i < m_aTeam[iTeam].m_aPlayerController.Length; ++i )
        {
            if (  m_aTeam[iTeam].m_aPlayerController[i] == pController )
            {
                m_aTeam[iTeam].m_aPlayerController.Remove( i, 1 );
                --i;
                bRemoved = true;
                if ( bShowLog ) log( "RemovePlayerFromTeam pController=" $pController$ " in team=" $iTeam );
            }
        }
    }
    
    return bRemoved;
}

//------------------------------------------------------------------
// UpdateTeamInfo
//	- update the iLivingPlayers
//------------------------------------------------------------------
function UpdateTeamInfo()
{
    local int   iTeam;
    local int   i;

    for ( iTeam = 0; iTeam < ArrayCount( m_aTeam ); ++iTeam )
    {
        m_aTeam[iTeam].m_iLivingPlayers = 0;

        for ( i = 0; i < m_aTeam[iTeam].m_aPlayerController.Length; ++i )
        {
            if (  m_aTeam[iTeam].m_aPlayerController[i].m_pawn.IsAlive() )
            {
                m_aTeam[iTeam].m_iLivingPlayers++;
            }
        }
    }    
}

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
    local int   iTeam;
    
    if ( m_bResetSystemLog ) LogResetSystem( false );
    Super.ResetOriginalData();

    for ( iTeam = 0; iTeam < ArrayCount( m_aTeam ); ++iTeam )
    {
        m_aTeam[iTeam].m_aPlayerController.Remove( 0, m_aTeam[iTeam].m_aPlayerController.length );
        m_aTeam[iTeam].m_iLivingPlayers = 0;
    }
}

//------------------------------------------------------------------
// GetLastManStanding
//	
//------------------------------------------------------------------
function R6PlayerController GetLastManStanding()
{
    local int    iTeam;
    local int    i;
    local R6PlayerController aController;
    local R6PlayerController aPotentialWinnerController;
    local int                iPotentialWinner;

    for ( iTeam = 0; iTeam < ArrayCount( m_aTeam ); ++iTeam )
    {
        m_aTeam[iTeam].m_iLivingPlayers = 0;

        for ( i = 0; i < m_aTeam[iTeam].m_aPlayerController.Length; ++i )
        {
            if ( m_aTeam[iTeam].m_aPlayerController[i].m_pawn != none &&
                 m_aTeam[iTeam].m_aPlayerController[i].m_pawn.IsAlive() )
            {
                if ( aController != none )
                    return none; // there is more than one player alive

                aController = m_aTeam[iTeam].m_aPlayerController[i];
                m_aTeam[iTeam].m_iLivingPlayers++;
            }
            
            aPotentialWinnerController = m_aTeam[iTeam].m_aPlayerController[i];
            iPotentialWinner++;
        }
    }    

    // if there's only one player...
    if ( iPotentialWinner == 1 )
    {
        return aPotentialWinnerController;
    }
    
    return aController;
}

function INT GetRainbowTeamColourIndex(INT eTeamName)
{
    return eTeamName-1;  
}

function int GetSpawnPointNum(string options)
{
    return GetIntOption( Options, "SpawnNum", 255);
}

function RemoveController(Controller aPlayer)
{
    RemovePlayerFromTeams( R6PlayerController(aPlayer) );
}

//------------------------------------------------------------------
// ResetPlayerTeam
//	
//------------------------------------------------------------------
function ResetPlayerTeam( Controller aPlayer )	
{
    // if wrong team OR not in a team
    if ( !IsPlayerInTeam( R6PlayerController(aPlayer), 
                          GetTeamIDFromTeamSelection( R6PlayerController(aPlayer).m_TeamSelection )) )
    {
        // remove player from teams
        RemovePlayerFromTeams( R6PlayerController(aPlayer) );
    
        if ( R6PlayerController(aPlayer).m_TeamSelection == PTS_Alpha ||
             R6PlayerController(aPlayer).m_TeamSelection == PTS_Bravo )
        {
            // nothing
        }
        else if ( R6PlayerController(aPlayer).m_TeamSelection == PTS_AutoSelect )
        {
            // auto select 
            if ( m_aTeam[c_iAlphaTeam].m_aPlayerController.Length <= m_aTeam[c_iBravoTeam].m_aPlayerController.Length )
            {
                R6PlayerController(aPlayer).m_TeamSelection = PTS_Alpha;
            }
            else
            {
                R6PlayerController(aPlayer).m_TeamSelection = PTS_Bravo;
            }
        }
        else // problem?
        {
            if (bShowLog) log("R6AdversarialTeamGame: not added player " $aPlayer.pawn$ "to Team yet");
            
            R6Pawn(aPlayer.pawn).m_iTeam = c_iTeamNumUnknow;
#ifdefDebug    
            log("ResetPlayerTeam called on "$R6PlayerController(aPlayer).PlayerReplicationInfo.PlayerName$
                " new TeamID=" $c_iTeamNumUnknow$
                " current is "$R6PlayerController(aPlayer).PlayerReplicationInfo.TeamID);
#endif
            return;
        }

        AddPlayerToTeam( R6PlayerController(aPlayer), R6PlayerController(aPlayer).m_TeamSelection );
    }
    
    Super.ResetPlayerTeam(aPlayer);
    
    if ( R6PlayerController(aPlayer).m_pawn != none )
    {
        SetControllerTeamID( R6PlayerController(aPlayer), R6PlayerController(aPlayer).m_TeamSelection );
    }
}

//------------------------------------------------------------------
// SetPawnTeamFriendlies
//	
//------------------------------------------------------------------
function SetPawnTeamFriendlies(Pawn aPawn)
{
    switch( aPawn.m_iTeam )
    {
    case c_iTeamNumHostage:     // hostage will be friend with alpha, and bravo for AI reason
        aPawn.m_iFriendlyTeams  = GetTeamNumBit( c_iTeamNumAlpha );
        aPawn.m_iFriendlyTeams += GetTeamNumBit( c_iTeamNumBravo );
        aPawn.m_iEnemyTeams     = GetTeamNumBit( c_iTeamNumTerrorist );
        break;

    case c_iTeamNumTerrorist: // terros DO NOT exist in these modes
        aPawn.m_iFriendlyTeams  = GetTeamNumBit( c_iTeamNumTerrorist );
        aPawn.m_iEnemyTeams     = GetTeamNumBit( c_iTeamNumAlpha );
        aPawn.m_iEnemyTeams    += GetTeamNumBit( c_iTeamNumBravo );
        break;

    case c_iTeamNumAlpha: // alpha team
        aPawn.m_iFriendlyTeams  = GetTeamNumBit( c_iTeamNumAlpha );
        aPawn.m_iEnemyTeams     = GetTeamNumBit( c_iTeamNumBravo );
        aPawn.m_iEnemyTeams    += GetTeamNumBit( c_iTeamNumTerrorist );
        break;

    case c_iTeamNumBravo: // bravo team
        aPawn.m_iFriendlyTeams  = GetTeamNumBit( c_iTeamNumBravo );
        aPawn.m_iEnemyTeams     = GetTeamNumBit( c_iTeamNumAlpha );
        aPawn.m_iEnemyTeams    += GetTeamNumBit( c_iTeamNumTerrorist );
        break;

    default:
        log( "warning: SetPawnTeamFriendlies team not supported for " $aPawn.name$ " team=" $aPawn.m_iTeam );
        break;
    }
}

// this is a signal from the server that a controller has selected his team/Or that he is ready to start
// we may need to do a round (but not a match) restart
function PlayerReadySelected(PlayerController _Controller)
{
    local Controller _aController;
    local int iHumanCountA, iHumanCountB;
    local R6GameMenuCom.ePlayerTeamSelection _TeamSelection;

    if ( (R6PlayerController(_Controller)==none) || 
         IsInState('InBetweenRoundMenu'))
        return;

    // we are in game...
    
    GetNbHumanPlayerInTeam( iHumanCountA, iHumanCountB );
        
    _TeamSelection = R6PlayerController(_Controller).m_TeamSelection;

    // if not in a team, return
    if ( !(_TeamSelection == PTS_Alpha || _TeamSelection == PTS_Bravo) )
        return;

    // look if there's enough player connected to restart a game
    if ( Level.IsGameTypeTeamAdversarial( m_szGameTypeFlag ) ) // alpha vs bravo
    {
        // okay, there's now at 
        if ( (_TeamSelection == PTS_Alpha && iHumanCountA == 1 && iHumanCountB > 0 ) ||
             (_TeamSelection == PTS_Bravo && iHumanCountB == 1 && iHumanCountA > 0 ) ||
             (iHumanCountA+iHumanCountB==1) )
        {
            ResetPenalty();
            ResetRound();
        }
    }
    else if ( iHumanCountA <= 2 ) // there's now 2 players connected, restart
    {
        ResetPenalty();
        ResetRound();
    }
}

//------------------------------------------------------------------
// GetTotalTeamFrag
//	
//------------------------------------------------------------------
function int GetTotalTeamFrag( int iTeamID )
{
    local int i;
    local int iFragCount;
    local R6PlayerController pController;

    for ( i = 0; i < m_aTeam[ iTeamID ].m_aPlayerController.Length; ++i )
    {
        pController = m_aTeam[ iTeamID ].m_aPlayerController[i];
        
        if ( pController.m_pawn != none &&
             !pController.m_pawn.m_bSuicided )
        {
            iFragCount += pController.PlayerReplicationInfo.m_iRoundKillCount;
        }
    }

    return iFragCount;
}

//------------------------------------------------------------------
// AddTeamWonRound
//	
//------------------------------------------------------------------
function AddTeamWonRound( int iTeamID )
{
    if (m_bCompilingStats==false)   // we should not add round won if we never had an adversary
        return;

    if ( iTeamID < ArrayCount( R6GameReplicationInfo(GameReplicationInfo).m_aTeamScore ) )
    {
        R6GameReplicationInfo(GameReplicationInfo).m_aTeamScore[iTeamID]++;
        // log( "AddTeamWonRound iTeamID=" $iTeamID$ " score=" $R6GameReplicationInfo(GameReplicationInfo).m_aTeamScore[iTeamID] );
    }
    else
        log( "Warning: AddTeamWonRound teamID=" $iTeamID$ " and m_aTeamScore size is= " $ArrayCount( R6GameReplicationInfo(GameReplicationInfo).m_aTeamScore ) );
}

//------------------------------------------------------------------
// GetNbRoundWinner
//	return the teamID of the winner.
//  return -1 if no winner
//------------------------------------------------------------------
function int GetNbRoundWinner()
{
    local int   iTeam;
    local int   iCurWinner;
    local int   iCurWinnerScore;
    local bool  bDraw;
    local R6GameReplicationInfo repGameInfo;

    repGameInfo     = R6GameReplicationInfo(GameReplicationInfo);
    iCurWinner      = -1;
    iCurWinnerScore = -1;

    for ( iTeam = 0; iTeam < ArrayCount( repGameInfo.m_aTeamScore ); ++iTeam )
    {
        // same score, draw
        if ( repGameInfo.m_aTeamScore[ iTeam ] == iCurWinnerScore )
        {
            bDraw = true;
        }
        else if ( repGameInfo.m_aTeamScore[ iTeam ] > iCurWinnerScore )
        {
            iCurWinner      = iTeam;
            iCurWinnerScore = repGameInfo.m_aTeamScore[ iTeam ];
            bDraw = false;
        }
    }

    // check if not a draw
    if ( bDraw )
        return -1;
    else
        return iCurWinner;
}

//------------------------------------------------------------------
// ResetMatchStat
//	
//------------------------------------------------------------------
function ResetMatchStat()
{
    local int   iTeam;
    local R6GameReplicationInfo repGameInfo;
    
    repGameInfo = R6GameReplicationInfo(GameReplicationInfo);
    for ( iTeam = 0; iTeam < ArrayCount( repGameInfo.m_aTeamScore ); ++iTeam )
    {
        repGameInfo.m_aTeamScore[ iTeam ] = 0;
    }
    Super.ResetMatchStat();
}

//------------------------------------------------------------------
// GetDeathMatchWinner
//	return the winner for a deathmatch game.
//  if a draw, return none
//------------------------------------------------------------------
function string GetDeathMatchWinner()
{
    local PlayerMenuInfo playerMenuInfo1;
    local PlayerMenuInfo playerMenuInfo2;
    R6GameReplicationInfo(GameReplicationInfo).RefreshMPInfoPlayerStats();
    GetFPlayerMenuInfo( 0, playerMenuInfo1 );
    GetFPlayerMenuInfo( 1, playerMenuInfo2 );

    if ( playerMenuInfo1.iRoundsWon > playerMenuInfo2.iRoundsWon )
    {
        return playerMenuInfo1.szPlayerName;
    }

    return "";
    
}

//------------------------------------------------------------------
// EndGame
//	send the end of match string
//------------------------------------------------------------------
function EndGame( PlayerReplicationInfo Winner, string Reason )
{
    local R6GameReplicationInfo gameRepInfo;
    local int iWinnerID;
    local PlayerController playerCtrl;
    local string szWinner;

    // This function has already been called
    if( m_bGameOver )
        return;

    if ( IsLastRoundOfTheMatch() )
    {
        gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
        // red vs green
        if ( Level.IsGameTypeTeamAdversarial(m_szGameTypeFlag) )
        {
            iWinnerID = GetNbRoundWinner();
            // is there a winner? or it's a draw
            if ( iWinnerID == -1 )
            {
                BroadcastGameMsg( "", "", "MatchIsADraw", m_sndMatchIsADraw, GetGameMsgLifeTime() );
            }
            else if ( iWinnerID == c_iAlphaTeam )
            {
                BroadcastGameMsg( "", "", "GreenTeamWonMatch", m_sndGreenTeamWonMatch, GetGameMsgLifeTime() );
            }
            else if ( iWinnerID == c_iBravoTeam )
            {
                BroadcastGameMsg( "", "", "RedTeamWonMatch", m_sndRedTeamWonMatch, GetGameMsgLifeTime() );
            }
            else
            {
                log( "Warning: GetNbRoundWinner unknow id= " $iWinnerID$ " in " $class.name );
            }

        }
        // deathmatch
        else if ( Level.IsGameTypeAdversarial(m_szGameTypeFlag) )
        {
            szWinner = GetDeathMatchWinner();

            // is there a winner? or it's a draw
            if ( szWinner == "" )
            {
                BroadcastGameMsg( "", "", "MatchIsADraw", none, GetGameMsgLifeTime() );
            }
            else
            {
                BroadcastGameMsg( "", szWinner, "HasWonTheMatch", none, GetGameMsgLifeTime() );
            }
        }
    }

    Super.EndGame( Winner, Reason);
}

defaultproperties
{
     c_iBravoTeam=1
     c_iMaxTeam=2
     m_bAddObjDeathmatch=True
     m_sndGreenTeamWonRound=Sound'Voices_Control_Multiplayer.Play_Green_Team'
     m_sndRedTeamWonRound=Sound'Voices_Control_Multiplayer.Play_Red_Team'
     m_sndRoundIsADraw=Sound'Voices_Control_Multiplayer.Play_Round_Draw'
     m_sndGreenTeamWonMatch=Sound'Voices_Control_Multiplayer.Play_Green_Team_Match'
     m_sndRedTeamWonMatch=Sound'Voices_Control_Multiplayer.Play_Red_Team_Match'
     m_sndMatchIsADraw=Sound'Voices_Control_Multiplayer.Play_Match_Draw'
     m_bUnlockAllDoors=True
}
