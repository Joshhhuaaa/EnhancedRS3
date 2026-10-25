//=============================================================================
//  R6EscortPilotGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/17 * Created by Aristomenis Kolokathis
//=============================================================================

class R6EscortPilotGame extends R6AdversarialTeamGame;


var R6MObjGoToExtraction        m_objGoToExtraction;


var R6PlayerController  m_pilotController;
var R6PlayerController  m_previousPilot;

var config BOOL EnablePilotPrimaryWeapon;
var config BOOL EnablePilotSecondaryWeapon;
var config BOOL EnablePilotTertiaryWeapon;

var Sound m_sndPilot;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    LoadConfig( "R6EscortPilotGame.ini" );
    
    if ( bShowLog )
    {
        log( "EnablePilotPrimaryWeapon   =" $EnablePilotPrimaryWeapon );
        log( "EnablePilotSecondaryWeapon =" $EnablePilotSecondaryWeapon );
        log( "EnablePilotTertiaryWeapon  =" $EnablePilotTertiaryWeapon );
    }

}

//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
    local int iLength;

    // mission objective: go to extraction
    m_objGoToExtraction = new(none) class'R6Game.R6MObjGoToExtraction';
    m_objGoToExtraction.m_bIfCompletedMissionIsSuccessfull = true;
    m_objGoToExtraction.m_bIfFailedMissionIsAborted        = true;
    m_objGoToExtraction.SetPawnToExtract( none ); // force to have none if there's no rainbow in green

    iLength = m_missionMgr.m_aMissionObjectives.Length;
    m_missionMgr.m_aMissionObjectives[iLength] = m_objGoToExtraction;
    iLength++;

    m_objGoToExtraction.m_szDescriptionInMenu = "EscortPilotToExtraction";

    // init the manager
    m_missionMgr.m_bOnSuccessAllObjectivesAreCompleted = false;
    Level.m_bUseDefaultMoralityRules = false;
    Super.InitObjectives();
}

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled( Pawn killedPawn )
{
    if ( m_bGameOver )
        return;

    if ( R6Pawn( killedPawn ) == m_objGoToExtraction.m_pawnToExtract )
    {
        BroadcastMissionObjMsg( "", "", "PilotWasKilled" );
    }

    super.PawnKilled( killedPawn );
}

//------------------------------------------------------------------
// UnselectPilot
//	
//------------------------------------------------------------------
function UnselectPilot()
{
        // remove the flag
    if ( m_pilotController != none )
    {
        m_pilotController.PlayerReplicationInfo.m_bIsEscortedPilot = false;
        m_previousPilot = m_pilotController;
        
        // the pilot has disconnected
        if ( m_previousPilot.m_pawn != none &&
             m_previousPilot.m_pawn.m_bSuicideType == DEATHMSG_CONNECTIONLOST )
        {
            m_previousPilot = none;
        }
    }
    
    m_pilotController = none;
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
    if ( m_objGoToExtraction.m_bCompleted )
    {
        if ( bShowLog ) log( "** Game : the pilot was extracted" );
        
        BroadcastGameMsg(       "", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, GetGameMsgLifeTime() );
        BroadcastMissionObjMsg( "", "", "PilotHasEscaped", none, GetGameMsgLifeTime() );
        AddTeamWonRound( c_iAlphaTeam );
    }
    else if ( m_objGoToExtraction.m_bFailed )
    {
        if ( bShowLog ) log( "** Game : the pilot was killed " );
        BroadcastGameMsg( "",  "", "RedTeamWonRound", m_sndRedTeamWonRound, GetGameMsgLifeTime() );
       AddTeamWonRound( c_iBravoTeam );
       UnselectPilot();
    }
    else if ( m_objDeathmatch.m_bFailed )                // all player are dead: draw
    {
        if ( bShowLog ) log( "** Game : it's a draw" );
        BroadcastGameMsg( "", "", "RoundIsADraw", m_sndRoundIsADraw, GetGameMsgLifeTime() );
        UnselectPilot();
    }
    else if ( m_objDeathmatch.m_bCompleted )        // a team was neutralized
    {
        if ( m_objDeathmatch.m_iWinningTeam == c_iTeamNumAlpha )
        {
            if ( bShowLog ) log( "** Game : alpha eleminated bravo" );
            BroadcastGameMsg(       "", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, GetGameMsgLifeTime() );
            BroadcastMissionObjMsg( "", "", "GreenNeutralizedRed", none, GetGameMsgLifeTime() );
            AddTeamWonRound( c_iAlphaTeam );
        }
        else if ( m_objDeathmatch.m_iWinningTeam == c_iTeamNumBravo )
        {
            if ( bShowLog ) log( "** Game : bravo eleminated alpha" );
            BroadcastGameMsg(       "", "", "RedTeamWonRound", m_sndRedTeamWonRound, GetGameMsgLifeTime() );
            BroadcastMissionObjMsg( "", "", "RedNeutralizedGreen", none, GetGameMsgLifeTime() );
            AddTeamWonRound( c_iBravoTeam );
            UnselectPilot();
        }
    }
    else
    {
        if ( bShowLog ) log( "** Game : bravo prevented the escape of the pilot " );
        BroadcastGameMsg(       "", "", "RedTeamWonRound", m_sndRedTeamWonRound, GetGameMsgLifeTime() );
        BroadcastMissionObjMsg( "", "", "PilotHasNotEscaped", none, GetGameMsgLifeTime() );
        AddTeamWonRound( c_iBravoTeam );
        UnselectPilot();
    }

    Super.EndGame(Winner, Reason);
}


//------------------------------------------------------------------
// CanAutoBalancePlayer
//	
//------------------------------------------------------------------
function bool CanAutoBalancePlayer( R6PlayerController pCtrl )
{
    // don't swap the pilot
    if ( pCtrl.PlayerReplicationInfo.m_bIsEscortedPilot )
        return false;

    return true;
}

//------------------------------------------------------------------
// InBetweenRoundMenu
//	
//------------------------------------------------------------------
auto state InBetweenRoundMenu
{
    function EndState()
    {
        local Controller P;
        local int iTeamACount;  // the team arrays not set up yet
        local int iNewGen;
        local int i;
        local int iTotalPilot;


        // valid and update the pilot flag
        for (P=Level.ControllerList; P!=None; P=P.NextController )
        {
            if ( !P.IsA('PlayerController') )
                continue;

            // pilot is in Alpha and was previously a pilot
            if( R6PlayerController(P).m_TeamSelection == PTS_Alpha && 
                P.PlayerReplicationInfo.m_bIsEscortedPilot && iTotalPilot < 1 )
            {
                // check if he still can be a pilot
                if ( R6PlayerController(P).m_bPenaltyBox  )
                    P.PlayerReplicationInfo.m_bIsEscortedPilot = false;
                else
                    iTotalPilot++;
            }
            else
            {
                P.PlayerReplicationInfo.m_bIsEscortedPilot = false;            
            }
        }

        // make sure we have all player in the both team
        ProcessAutoBalanceTeam();

        // we need to determine who his the pilot is before the pawns are spawned
        m_pilotController = none;
        for (P=Level.ControllerList; P!=None; P=P.NextController )
        {
            if ( !P.IsA('PlayerController') )
                continue;

            if( R6PlayerController(P).m_TeamSelection == PTS_Alpha )
            {
                // if pilot is not set yet and doesn't have a penalty
                if ( m_pilotController == none && P.PlayerReplicationInfo.m_bIsEscortedPilot)
                {
                    if ( bShowLog ) log( "InBetweenRoundMenu: still the same pilot" );
                    m_pilotController = R6PlayerController(P);
                }
                else
                {
                    if ( !R6PlayerController(P).m_bPenaltyBox )
                        iTeamACount++;
                }
            }
        }

        if ( m_pilotController == none )    // pick a random pilot among alpha team
        {
            iNewGen = rand(iTeamACount);
            i = 0;
            P=Level.ControllerList; 
            
            while ( P != None )
            {
                if ( P.IsA('PlayerController') && 
                     (R6PlayerController(P).m_TeamSelection == PTS_Alpha &&
                      !R6PlayerController(P).m_bPenaltyBox) )
                {
                    if (i == iNewGen)
                    {
                        // it's the same pilot has before, find a another one
                        if ( m_previousPilot == R6PlayerController(P) )
                        {
                            if ( iTeamACount == 1 ) // only person, we don't have a choice
                            {
                                m_pilotController = R6PlayerController(P);
                            }
                            else
                            {
                                // get a number number and start to loop again
                                while ( iNewGen == i )
                                {
                                    iNewGen = rand(iTeamACount);
                                }

                                i = 0;
                                P = Level.ControllerList;  
                                continue;
                            }
                        }
                        else
                        {
                            m_pilotController = R6PlayerController(P);
                        }

                        if ( m_pilotController != none )
                        {
                            if ( bShowLog )  log( "InBetweenRoundMenu: set new pilot" );
                            
                		    R6SetPilotClassInMultiPlayer(P);
                            m_pilotController.PlayerReplicationInfo.m_bIsEscortedPilot = true;
                            break;
                        }
                    }
                    else
                    {
                        i++;
                    }
                }
                
                if ( P != none )
                    P = P.NextController;
            }
        } // end should we pick a random General

        // we don't need m_previousPilot 
        m_previousPilot = none;

        // now that we have the pilot we can spawn the actor and pawn correclty
        Super.EndState();
    }
}

//------------------------------------------------------------------
// R6SetPilotClassInMultiPlayer
//	
//------------------------------------------------------------------
function R6SetPilotClassInMultiPlayer(Controller playerController)
{
    local R6ModMgr pModManager;

    pModManager = class'Actor'.static.GetModMgr();
    R6PlayerController(playerController).PawnClass = pModManager.GetDefaultPilotPawn();
}

//------------------------------------------------------------------
// R6SetPawnClassInMultiPlayer
//	
//------------------------------------------------------------------
function R6SetPawnClassInMultiPlayer(Controller playerController)
{
    if ( playerController == m_pilotController )
    {
        R6SetPilotClassInMultiPlayer(playerController);
    }
    else
    {
        Super.R6SetPawnClassInMultiPlayer( playerController );
    }
}

//------------------------------------------------------------------
// RestartPlayer
//	
//------------------------------------------------------------------
function RestartPlayer( Controller aPlayer )
{
    Super.RestartPlayer(aPlayer);
    
    if ( aPlayer == m_pilotController)
    {
        m_objGoToExtraction.SetPawnToExtract( R6Pawn(m_pilotController.pawn) );
    }
}


//------------------------------------------------------------------
// IsPrimaryWeaponRestrictedToPawn
//	restriction for the pilot
//------------------------------------------------------------------
function bool IsPrimaryWeaponRestrictedToPawn( Pawn aPawn )
{
    if ( m_objGoToExtraction.m_pawnToExtract == aPawn )
    {
        return !EnablePilotPrimaryWeapon;
    }
    
    return false;
}

//------------------------------------------------------------------
// IsSecondaryWeaponRestrictedToPawn
//	restriction for the pilot
//------------------------------------------------------------------
function bool IsSecondaryWeaponRestrictedToPawn( Pawn aPawn )
{
    if ( m_objGoToExtraction.m_pawnToExtract == aPawn )
    {
        return !EnablePilotSecondaryWeapon;
    }

    return false;
}

//------------------------------------------------------------------
// IsTertiaryWeaponRestrictedToPawn
//	restriction for the pilot
//------------------------------------------------------------------
function bool IsTertiaryWeaponRestrictedToPawn( Pawn aPawn )
{
    if ( m_objGoToExtraction.m_pawnToExtract == aPawn )
    {
        return !EnablePilotTertiaryWeapon;
    }
    
    return false;
}

//------------------------------------------------------------------
// BroadcastGameTypeDescription
//	
//------------------------------------------------------------------
function BroadcastGameTypeDescription()
{
    local Controller P;
    local R6PlayerController playerController;

    Super.BroadcastGameTypeDescription();

    if ( m_pilotController == none )
        return;

    if ( m_pilotController.PlayerReplicationInfo == none )
        return;

    
    m_pilotController.ClientPlaySound(m_sndPilot, SLOT_Speak);
    // send to green team who is the pilot
    for (P=Level.ControllerList; P!=None; P=P.NextController )
    {
        playerController = R6PlayerController(p);
        if ( playerController != none && playerController.m_TeamSelection == PTS_Alpha )
        {
            playerController.ClientMissionObjMsg( "", m_pilotController.PlayerReplicationInfo.PlayerName, 
                                                  "PlayerIsThePilot" );
        }
    }
}

defaultproperties
{
     m_sndPilot=Sound'Voices_Control_Multiplayer.Play_YouAreThePilot'
     m_iUbiComGameMode=5
     m_szGameTypeFlag="RGM_EscortAdvMode"
}
