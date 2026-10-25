//=============================================================================
//  R6MObjCompleteAllAndGoToExtraction.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//
//  Complete all mission objectives (except Morality AND mission objectives 
//  that are flagged with m_bIfCompletedMissionIsSuccessfull).
//  
//  Only valid for a human player
//
//  Special: in the manager, added at the end of the list of mission objectives 
//
//  fail: if one of the objectives fails (excluding exceptions_
//  success: if all MO are compledted 
//=============================================================================

class R6MObjCompleteAllAndGoToExtraction extends R6MissionObjectiveBase;

function Init()
{
    if ( R6MissionObjectiveMgr(m_mgr).m_bEnableCheckForErrors )
        R6GameInfo(m_mgr.Level.Game).CheckForExtractionZone( self );
}

function EnteredExtractionZone( Pawn aPawn )
{
    local R6MissionObjectiveMgr mgr;
    local int i;
    local int iTotal;
    local int iTotalCompleted;

    if ( m_bCompleted || isFailed() || aPawn == none || aPawn.controller == none )
        return;

    if ( !aPawn.IsAlive() )
        return;

    mgr = R6MissionObjectiveMgr( m_mgr );

    for ( i = 0; i < mgr.m_aMissionObjectives.Length; ++i )
    {
        if ( mgr.m_aMissionObjectives[i] == self )
            continue;

        if ( mgr.m_aMissionObjectives[i].m_bMoralityObjective )
            continue;

        if ( mgr.m_aMissionObjectives[i].isMissionCompletedOnSuccess() )
            continue;

        ++iTotal;

        // if a failure, it will be impossible to complete this
        if ( mgr.m_aMissionObjectives[i].isFailed() )
        {
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
            return;
        }

        if ( mgr.m_aMissionObjectives[i].isCompleted() )
        {
            ++iTotalCompleted;
        }
    }

    // if all completed...
    if ( iTotal == iTotalCompleted && iTotal > 0 )
    {
        mgr.SetMissionObjCompleted( self, true, true );
    }

    if ( m_bShowLog ) log( "EnteredExtractionZone: completed=" $m_bCompleted$ " iTotal=" $iTotal$ " iTotalCompleted=" $iTotalCompleted );
}

//------------------------------------------------------------------
// isCompleted
//
//------------------------------------------------------------------
function bool isCompleted()
{
    local R6ExtractionZone  anExtractionZone;
    local R6Rainbow         aRainbow;
    local Controller            aController;
    local R6PlayerController    pR6PlayerController;
    local R6AIController        pAIController;

    if ( isFailed() )
        return false;

    // log( "R6MObjCompleteAllAndGoToExtraction::isCompleted at " $m_mgr.Level.TimeSeconds );
    
    // check if there's a rainbow in a extraction zone after updating something    
    for (aController = m_mgr.Level.ControllerList; aController != None; aController = aController.NextController )
    {
        pR6PlayerController = R6PlayerController(aController);
        if ( pR6PlayerController != none )
        {
            aRainbow = pR6PlayerController.m_pawn;
        }
        else
        {
            pAIController = R6AIController(aController);
            if ( pAIController != none )
                aRainbow = R6Rainbow(pAIController.m_r6pawn);
        }

        if ( aRainbow != none )
        {
		    // if touching the extraction zone
            foreach aRainbow.TouchingActors( class'R6ExtractionZone', anExtractionZone )
		    {
                EnteredExtractionZone( aRainbow );
                break;
		    }

            if ( m_bCompleted || m_bFailed )
                break;
        }
    }

    // log( " R6MObjCompleteAllAndGoToExtraction: m_bCompleted=" $m_bCompleted );
    return m_bCompleted;
}

defaultproperties
{
     m_bIfCompletedMissionIsSuccessfull=True
     m_bIfFailedMissionIsAborted=True
     m_bEndOfListOfObjectives=True
     m_szDescription="Completed all mission objetives"
}
