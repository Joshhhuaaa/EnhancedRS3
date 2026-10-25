//=============================================================================
//  R6TeamBomb.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/17 * Created by Aristomenis Kolokathis
//=============================================================================

class R6TeamBomb extends R6AdversarialTeamGame;

//------------------------------------------------------------------
// IsBombArmedOrExploded
//	
//------------------------------------------------------------------
function bool IsBombArmedOrExploded()
{
    local R6IOBomb ioBomb;

    foreach DynamicActors( class 'R6IOBomb', ioBomb)
    {
        if ( ioBomb.m_bIsActivated || ioBomb.m_bExploded )
        {
            return true;
        }
    }

    return false;
}

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled( Pawn killedPawn )
{
    local bool bCheckEndGame;
    local R6IOBomb ioBomb;
    local float fTimeLeft;
    local bool bForceFailNow;
    local float fTimeToExplode;

    if ( m_bGameOver )
        return;
    
    // reset every time so we can process the exception:
    // - when Red has been eleminated and a bomb must be defused.
    //   While Green is trying to defuse the bomb, he got kill. So red win
    m_objDeathmatch.Reset();

    Super.PawnKilled( killedPawn );

    if ( m_objDeathmatch.m_bCompleted )
    {
        // no bomb active OR "terro" killed the green team,  mission completed
        if ( !IsBombArmedOrExploded() || 
             m_objDeathmatch.m_iWinningTeam == c_iTeamNumBravo ) 
        {
            m_objDeathmatch.m_bIfCompletedMissionIsSuccessfull = true;
            bCheckEndGame = true;
        }
        else
        {
            // bomb armed. wait for green to defuse...
            // we have to check when the iobomb his defused if the game can end
        }
    }
    else if ( m_objDeathmatch.m_bFailed )
    {
        // death match is over and no bomb has detonated or was armed
        if ( !IsBombArmedOrExploded() )
        {
            m_objDeathmatch.m_bIfFailedMissionIsAborted = true;
            bCheckEndGame = true;
        }
        else
        {
            fTimeLeft = m_fEndingTime - Level.TimeSeconds;

            if ( fTimeLeft < 0 ) // no time left
            {
                bForceFailNow = true;
            }
            else
            {
                bForceFailNow = true;

                // bomb armed or exploded: let the countdown decide who win...
                // force bomb to explode in 3 sec!
                fTimeToExplode = 3;
                foreach DynamicActors( class 'R6IOBomb', ioBomb)
                {
                    // check time left
                    if ( ioBomb.m_bIsActivated &&           
                        ioBomb.m_fTimeLeft <= fTimeLeft )   // must have enough time to explode for this round
                    {
                        if ( ioBomb.m_fTimeLeft > fTimeToExplode ) // if more time than required, 
                            ioBomb.ForceTimeLeft( fTimeToExplode );

                        bForceFailNow = false; // will fail when the bomb will explode
                    }
                }

            }

            // check if a bomb will explode before the end of round
            // if no: it's a draw
            if ( bForceFailNow )
            {
                bCheckEndGame = true;
                m_objDeathmatch.m_bIfFailedMissionIsAborted = true;
            }
        }
    }

    if ( bCheckEndGame )
    {
        if( CheckEndGame( none, "") )
	        EndGame(none , "");
    }
}

//------------------------------------------------------------------
// RestartPlayer
//	set the disarming/arming bomb
//------------------------------------------------------------------
function RestartPlayer( Controller aPlayer ) 
{
    local R6PlayerController pController;

    Super.RestartPlayer( aPlayer );

    pController = R6PlayerController( aPlayer );
    if ( IsPlayerInTeam( pController, c_iAlphaTeam ) )
    {
        pController.m_pawn.m_bCanArmBomb    = false;
        pController.m_pawn.m_bCanDisarmBomb = true;
    }
    else if ( IsPlayerInTeam( pController, c_iBravoTeam ) )
    {
        pController.m_pawn.m_bCanArmBomb    = true;
        pController.m_pawn.m_bCanDisarmBomb = false;
    }
}


//------------------------------------------------------------------
// NotifyMatchStart
//	
//------------------------------------------------------------------
function NotifyMatchStart()
{
    local R6IOBomb ioBomb;

    super.NotifyMatchStart();    
    
    // it overwrite the default rule, because if the B team is wiped
    // and there's a bomb armed, A must defuse it
    m_objDeathmatch.m_bIfCompletedMissionIsSuccessfull = false;
    m_objDeathmatch.m_bIfFailedMissionIsAborted        = false;

    // set IO Bomb time
    foreach DynamicActors( class 'R6IOBomb', ioBomb)
    {
        ioBomb.m_fTimeLeft = m_fBombTime;
        ioBomb.m_fTimeOfExplosion = m_fBombTime;

        if ( ioBomb.m_bIsActivated )
            ioBomb.ArmBomb( none );
    }
}

//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
    local int               iLength;
    local bool              bBombExist;
    local R6IOBomb          ioBomb;
    local R6MObjPreventBombDetonation   objBombDetonation;
    
    iLength = m_missionMgr.m_aMissionObjectives.Length;
    foreach AllActors( class 'R6IOBomb', ioBomb)
    {
        objBombDetonation = new(none) class'R6Game.R6MObjPreventBombDetonation';
        objBombDetonation.m_r6IOObject = ioBomb;
        
        m_missionMgr.m_aMissionObjectives[iLength] = objBombDetonation;
        iLength++;

        objBombDetonation.m_bIfFailedMissionIsAborted                   = true;
        objBombDetonation.m_bIfDetonateObjectiveIsFailed                = true;
        objBombDetonation.m_bIfDeviceIsActivatedObjectiveIsCompleted    = false;
        objBombDetonation.m_bIfDeviceIsActivatedObjectiveIsFailed       = false;
        objBombDetonation.m_bIfDeviceIsDeactivatedObjectiveIsCompleted  = false;
        objBombDetonation.m_bIfDeviceIsDeactivatedObjectiveIsFailed     = false;
        objBombDetonation.m_bIfDestroyedObjectiveIsCompleted            = false;
        objBombDetonation.m_bIfDestroyedObjectiveIsFailed               = false;
        bBombExist = true;
        if ( bShowLog )
        {
            log( "Bomb Added: " $iobomb$ " armedMsg" $ioBomb.m_szMsgArmedID$ " disarmed=" $ioBomb.m_szMsgDisarmedID );
        }
    }

    if ( !bBombExist && m_missionMgr.m_bEnableCheckForErrors )
    {
        log( "WARNING: there is no bomb in the game type: " $self );
    }

    m_missionMgr.m_bOnSuccessAllObjectivesAreCompleted = false;
    Level.m_bUseDefaultMoralityRules = false;
    Super.InitObjectives();
}


//------------------------------------------------------------------
// IObjectInteract
//	
//------------------------------------------------------------------
function IObjectInteract( Pawn aPawn, Actor anInteractiveObject )
{
    local R6IOBomb  ioBomb;
    local R6GameReplicationInfo gameRepInfo;

    if ( m_bGameOver )
        return;
    
    Super.IObjectInteract( aPawn, anInteractiveObject );

    ioBomb = R6IOBomb( anInteractiveObject );
    if ( ioBomb.m_bIsActivated )
    {
        if (bShowLog) log( " R6TeamBomb: " $Localize("Game", ioBomb.m_szMsgArmedID, ioBomb.GetMissionObjLocFile() ) );

        BroadcastMissionObjMsg( ioBomb.GetMissionObjLocFile(), "", ioBomb.m_szMsgArmedID );
    }
    else
    {
        if (bShowLog) log( " R6TeamBomb: " $Localize("Game", ioBomb.m_szMsgDisarmedID, ioBomb.GetMissionObjLocFile() ) );

        BroadcastMissionObjMsg( ioBomb.GetMissionObjLocFile(), "", ioBomb.m_szMsgDisarmedID );
    }
    
    // check if the game can end now: if the red team was killed and there's am armed bomb
    if ( m_objDeathmatch.m_bCompleted )
    {
        if ( !IsBombArmedOrExploded() )
        {
            // Green defused the bomb when there was no red 
            m_objDeathmatch.m_bIfCompletedMissionIsSuccessfull = true;
            
            if( CheckEndGame( none, "") )
	            EndGame(none , "");
        }
    }
    
}

//------------------------------------------------------------------
// EndGame
//	
//------------------------------------------------------------------
function EndGame(PlayerReplicationInfo Winner, string Reason)
{
    local R6GameReplicationInfo gameRepInfo;
    local R6IOBomb  ioBomb;
    local bool      bBombExploded;

    if (m_bGameOver)    // this function has already been called
        return;

    gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);

    // check if bomb exploded
    bBombExploded = false;
    foreach AllActors( class 'R6IOBomb', ioBomb)
    {
        if ( ioBomb.m_bExploded )
        {
            bBombExploded = true;
            break;
        }
    }

    if ( bBombExploded )
    {
        // bravo win
        if ( bShowLog ) log( "** Game : bravo win: bomb exploded" );
        BroadcastGameMsg(       "", "", "RedTeamWonRound", m_sndRedTeamWonRound, GetGameMsgLifeTime());
        BroadcastMissionObjMsg( ioBomb.GetMissionObjLocFile(), "", "BombHasDetonated", none, GetGameMsgLifeTime() );
        AddTeamWonRound( c_iBravoTeam );
    }
    else
    {
        // all player are dead
        if ( m_objDeathmatch.m_bFailed )
        {
            // draw
            if ( bShowLog ) log( "** Game : it's a draw" );
            BroadcastGameMsg( "", "", "RoundIsADraw", m_sndRoundIsADraw, GetGameMsgLifeTime() );
        }
        // a team was neutralized
        else if ( m_objDeathmatch.m_bCompleted )
        {
            if ( m_objDeathmatch.m_iWinningTeam == c_iTeamNumAlpha )
            {
                // alpha win
                if ( bShowLog ) log( "** Game : alpha eleminated bravo" );
                BroadcastGameMsg(       "", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, GetGameMsgLifeTime() );
                BroadcastMissionObjMsg( "", "", "GreenNeutralizedRed", none, GetGameMsgLifeTime() );
                AddTeamWonRound( c_iAlphaTeam );
            }
            else if ( m_objDeathmatch.m_iWinningTeam == c_iTeamNumBravo )
            {
                // bravo win
                if ( bShowLog ) log( "** Game : bravo eleminated alpha" );
                BroadcastGameMsg(       "", "", "RedTeamWonRound", m_sndRedTeamWonRound, GetGameMsgLifeTime() );
                BroadcastMissionObjMsg( "", "", "RedNeutralizedGreen", none, GetGameMsgLifeTime() );
                AddTeamWonRound( c_iBravoTeam );
            }
        }
        else
        {
            // alpha win
            if ( bShowLog ) log( "** Game : alpha prevented bomb detonation" );
            BroadcastGameMsg(       "", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, GetGameMsgLifeTime() );
            BroadcastMissionObjMsg( "", "", "NoBombsDetonated", none, GetGameMsgLifeTime() );
            AddTeamWonRound( c_iAlphaTeam );
        }
    }
    
    Super.EndGame(Winner, Reason);
}

defaultproperties
{
     m_iUbiComGameMode=3
     m_szGameTypeFlag="RGM_BombAdvMode"
}
