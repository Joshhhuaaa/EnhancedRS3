//=============================================================================
//  R6MObjAcceptableLosses.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

class R6MObjAcceptableLosses extends R6MissionObjectiveBase
    abstract;

var() int   m_iAcceptableLost;
var() bool  m_bConsiderSuicide;

var   Pawn.EPawnType        m_ePawnTypeKiller;
var   Pawn.EPawnType        m_ePawnTypeDead;
var   int                   m_iKillerTeamID;

function Reset()
{
    Super.Reset();
    m_iKillerTeamID = default.m_iKillerTeamID;
}

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled( Pawn killed )
{
    local int       iLost;
    local R6Pawn    aPawn;
    local float     fTotal;

    if ( killed.m_ePawnType != m_ePawnTypeDead )
        return;

    // if killed by a specific TeamID
    if ( m_iKillerTeamID != -1 )
    {
        aPawn = R6Pawn( killed );
        if ( aPawn.m_KilledBy.m_iTeam != m_iKillerTeamID )
            return;
    }

    foreach m_mgr.DynamicActors( class'R6Pawn', aPawn )
	{
        if ( aPawn.m_ePawnType != m_ePawnTypeDead ) // not the same type
            continue;

        if ( aPawn.m_ePawnType == PAWN_Hostage )    // check hostage exception: hostage or civilian
        {
            // check it's a hostage or a civilian
            if ( R6Hostage(killed).m_bCivilian != R6Hostage(aPawn).m_bCivilian )
                continue;
        }

        fTotal += 1;

        if (  aPawn.isAlive() ) // alive, don't continue
            continue;

        // suicided or killed by the PawnTypeKiller
        if (   (m_bConsiderSuicide && aPawn.m_bSuicided)                     // consider suicided
            || (aPawn.m_bSuicided == false && m_ePawnTypeKiller == PAWN_All) // ignore suicide, killer type == ALL
            || aPawn.m_KilledBy.m_ePawnType == m_ePawnTypeKiller )           // it's the good killer type 
        {
            if ( m_iKillerTeamID == -1 ||                               // not a specific killer ID
                 aPawn.m_KilledBy.m_iTeam == m_iKillerTeamID )  // OR the same killer ID
            {
                iLost += 1;
            }
        }
	}

    iLost = iLost / fTotal * 100.0;
    
    if ( iLost >= 100 || 
         (iLost > 0 && iLost > m_iAcceptableLost) )
    {
        if ( m_bShowLog ) logX( " failed: iLost > m_iAcceptableLost=" $(iLost > m_iAcceptableLost) );
        R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
    }
    
    if ( m_bShowLog  )
    {
        aPawn = R6Pawn( killed );
        logX( "PawnKilled failed="$m_bFailed$ " "  $killed.name$ " was killed by " $aPawn.m_KilledBy.name$ " lost=" $iLost$ " acceptable="$m_iAcceptableLost );
    }
}

defaultproperties
{
     m_iKillerTeamID=-1
     m_bConsiderSuicide=True
     m_bIfFailedMissionIsAborted=True
     m_bMoralityObjective=True
}
