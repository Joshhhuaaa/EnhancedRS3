//=============================================================================
//  R6MObjDeathmatch.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//
// success: if there's one pawn alive or one team
//
//=============================================================================

class R6MObjDeathmatch extends R6MissionObjectiveBase;

var     bool             m_bTeamDeathmatch;
var     int              m_iWinningTeam; // -1 no winning team
var     PlayerController m_winnerCtrl;  // in deathmatch
var     int              m_aLivingPlayerInTeam[48]; // must be bigger than 32...


function Reset()
{
    Super.Reset();
    m_iWinningTeam = default.m_iWinningTeam;
    m_winnerCtrl = none;
    ResetLivingPlayerInTeam();
}


//------------------------------------------------------------------
// ResetLivingPlayer
//	
//------------------------------------------------------------------
function ResetLivingPlayerInTeam()
{
    local int i;

    for ( i = 0; i <ArrayCount( m_aLivingPlayerInTeam ); ++i )
    {
        m_aLivingPlayerInTeam[i] = 0;
    }
}

//------------------------------------------------------------------
// GetWinningTeam: look the last team alive
//	return -1 is none
//------------------------------------------------------------------
function int GetWinningTeam()
{
    local int i;
    local int iPotentialWinner;
    local int iNbTeamAlive;

    // When not compiling stats, the round is always a draw.
    if(R6GameInfo(m_mgr.Level.Game).m_bCompilingStats == false)
        return -1;

    for ( i = 0; i < ArrayCount( m_aLivingPlayerInTeam ); ++i )
    {
        if ( m_aLivingPlayerInTeam[i] != 0 )
        {
            iPotentialWinner = i;
            iNbTeamAlive++;
        }
    }

    if ( iNbTeamAlive == 1 )
    {
        return iPotentialWinner;
    }

    return -1;
}

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled( Pawn killedPawn )
{
    local R6Rainbow pPawn; 
    local int       aPlayerAliveInTeam[2];
    local int       iNbAlive;

    ResetLivingPlayerInTeam();
    foreach m_mgr.DynamicActors( class'R6Rainbow', pPawn )
    {
        if ( pPawn.IsAlive() )
        {
            ++iNbAlive;
            
            if ( m_bTeamDeathmatch )
            {
                if ( pPawn.m_iTeam < ArrayCount( m_aLivingPlayerInTeam ) )
                    ++m_aLivingPlayerInTeam[ pPawn.m_iTeam ];
            }

            if (m_bShowLog)
            {
                if ( PlayerController(pPawn.Controller).PlayerReplicationInfo != none )
                    logX( PlayerController(pPawn.Controller).PlayerReplicationInfo.PlayerName$ " is alive in teamID" $pPawn.m_iTeam  );
                else
                    logX( PlayerController(pPawn.Controller)$ " is alive in teamID" $pPawn.m_iTeam  );
            }
            m_winnerCtrl = PlayerController(pPawn.Controller);
        }
        else
        {
            if (m_bShowLog) 
            {
                if ( PlayerController(pPawn.Controller).PlayerReplicationInfo != none )
                    logX( PlayerController(pPawn.Controller).PlayerReplicationInfo.PlayerName$ " is dead" );
                else
                    logX( PlayerController(pPawn.Controller)$ " is dead" );
            }
        }
        

        if ( !m_bTeamDeathmatch ) // not a team deathmatch,
        {
            if ( iNbAlive > 1 )
            {
                if (m_bShowLog) logX( "more than 1 player alive " );

                break;
            }
        }
    }

    // no more player alive
    if ( iNbAlive == 0 )
    {
        if (m_bShowLog) logX( "failed: zero man standing" );
        R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
        return;
    }

    if ( m_bTeamDeathmatch )
    {
        m_iWinningTeam = GetWinningTeam();
        if ( m_iWinningTeam != -1 )
        {
            if (m_bShowLog) logX( "completed, last team standing teamID=" $m_iWinningTeam );
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, true, true );
        }
        else
        {
            if (m_bShowLog) logX( "no winner yet" );
        }
    }
    else
    {
        if ( iNbAlive == 1 )
        {
            if (m_bShowLog) logX( "completed, one man standing" );
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, true, true );
        }
        else
        {
            if (m_bShowLog) logX( "no winner yet" );
            m_winnerCtrl = none;
        }
    }
}

defaultproperties
{
     m_iWinningTeam=-1
     m_bIfCompletedMissionIsSuccessfull=True
     m_bIfFailedMissionIsAborted=True
     m_szDescription="Deathmatch: eleminate enemies"
}
