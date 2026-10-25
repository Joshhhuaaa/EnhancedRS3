//=============================================================================
//  R6MissionObjectiveMgr.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

// to put in game info
class R6MissionObjectiveMgr extends Actor;

enum EMissionObjectiveStatus
{
    eMissionObjStatus_none,
    eMissionObjStatus_success,
    eMissionObjStatus_failed
};

var Array<R6MissionObjectiveBase>   m_aMissionObjectives;
var EMissionObjectiveStatus         m_eMissionObjectiveStatus;
var bool                            m_bShowLog;
var bool                            m_bDontUpdateMgr;
var bool                            m_bOnSuccessAllObjectivesAreCompleted;
var bool                            m_bEnableCheckForErrors;
var R6AbstractGameInfo              m_gameInfo;

//------------------------------------------------------------------
//                          *** IMPORTANT ***
//	if you add a new function, add it in the R6MObjGroupMission and
//  follow the same logic: dispatch the function to all sub mission.
//                          *** IMPORTANT ***
//------------------------------------------------------------------


function SetMissionObjStatus( EMissionObjectiveStatus eStatus )
{
    m_eMissionObjectiveStatus = eStatus;
    m_gameInfo.UpdateRepMissionObjectivesStatus();
}

function Init( R6AbstractGameInfo gameInfo )
{
    local int   i;
    local int   index;
    local int   iTimer;
    
    if( m_bShowLog ) log( "*** Mission Objectives ***" );

    m_gameInfo = gameInfo;

    SetMissionObjStatus( eMissionObjStatus_none );

    // IMPORTANT: any special init code should also go in R6MObjGroupMission::Init()
    for ( i = 0; i < m_aMissionObjectives.Length; ++i )
    {
        m_aMissionObjectives[i].m_mgr = self;
        if( m_bShowLog ) log( "  " $i$ ": " $m_aMissionObjectives[i].GetDescription() );
        m_aMissionObjectives[i].Init();
    }
    // IMPORTANT: any special init code should also go in R6MObjGroupMission::Init()

    
}

//------------------------------------------------------------------
// RemoveObjectives
//	
//------------------------------------------------------------------
function RemoveObjectives()
{
    if( m_bShowLog ) log( "Mission objective: removed" );

    if ( m_aMissionObjectives.Length > 0 )
        m_aMissionObjectives.Remove( 0, m_aMissionObjectives.Length );

    m_gameInfo.ResetRepMissionObjectives();
}


//------------------------------------------------------------------
// Timer
//	
//------------------------------------------------------------------
/*
function Timer()
{
    // find the timer that have this value
    // start next timer by taking in account the time already spend
    local int i;

    for ( i = 0; i < m_aMissionObjectives.Length; ++i )
    {
        m_aMissionObjectives[i].TimerCallback(0);
    }
}*/

//------------------------------------------------------------------
// TimerCallback
//	
//------------------------------------------------------------------
function TimerCallback( float fTime );


//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled( Pawn killedPawn )
{
    local int i;

    if ( m_eMissionObjectiveStatus != eMissionObjStatus_none || killedPawn == none )
        return;

    if( m_bShowLog )
    {
        if ( PlayerController(killedPawn.Controller) != none && 
             PlayerController(killedPawn.Controller).PlayerReplicationInfo != none)
        {
            log( "MissionObjective: PawnKilled " $PlayerController(killedPawn.Controller).PlayerReplicationInfo.PlayerName );
        }
        else
        {
            log( "MissionObjective: PawnKilled " $killedPawn.name );
        }
    }

    for ( i = 0; i < m_aMissionObjectives.Length; ++i )
    {
        if ( m_aMissionObjectives[i].m_bFailed || m_aMissionObjectives[i].m_bCompleted )
            continue;

        m_aMissionObjectives[i].PawnKilled( killedPawn );
    }
}

//------------------------------------------------------------------
// IObjectInteract
//	
//------------------------------------------------------------------
function IObjectInteract( Pawn aPawn, Actor anInteractiveObject )
{
    local int i;

    if ( m_eMissionObjectiveStatus != eMissionObjStatus_none )
        return;

    for ( i = 0; i < m_aMissionObjectives.Length; ++i )
    {
        if ( m_aMissionObjectives[i].m_bFailed || m_aMissionObjectives[i].m_bCompleted )
            continue;

        m_aMissionObjectives[i].IObjectInteract( aPawn, anInteractiveObject );
    }
}

//------------------------------------------------------------------
// IObjectDestroyed
//	
//------------------------------------------------------------------
function IObjectDestroyed( Pawn aPawn, Actor anInteractiveObject )
{
    local int i;

    if ( m_eMissionObjectiveStatus != eMissionObjStatus_none )
        return;

    for ( i = 0; i < m_aMissionObjectives.Length; ++i )
    {
        if ( m_aMissionObjectives[i].m_bFailed || m_aMissionObjectives[i].m_bCompleted )
            continue;

        m_aMissionObjectives[i].IObjectDestroyed( aPawn, anInteractiveObject );
    }
}

//------------------------------------------------------------------
// PawnSeen
//	
//------------------------------------------------------------------
function PawnSeen( Pawn seen, Pawn witness )
{
    local int i;

    if ( m_eMissionObjectiveStatus != eMissionObjStatus_none )
        return;

    for ( i = 0; i < m_aMissionObjectives.Length; ++i )
    {
        if ( m_aMissionObjectives[i].m_bFailed || m_aMissionObjectives[i].m_bCompleted )
            continue;

        m_aMissionObjectives[i].PawnSeen( seen, witness );
    }
}

//------------------------------------------------------------------
// PawnHeard
//	
//------------------------------------------------------------------
function PawnHeard( Pawn heard, Pawn witness )
{
    local int i;

    if ( m_eMissionObjectiveStatus != eMissionObjStatus_none )
        return;

    for ( i = 0; i < m_aMissionObjectives.Length; ++i )
    {
        if ( m_aMissionObjectives[i].m_bFailed || m_aMissionObjectives[i].m_bCompleted )
            continue;

        m_aMissionObjectives[i].PawnHeard( heard, witness );
    }
}


//------------------------------------------------------------------
// PawnSecure
//	
//------------------------------------------------------------------
function PawnSecure( Pawn securedPawn )
{
    local int i;

    if ( m_eMissionObjectiveStatus != eMissionObjStatus_none )
        return;

    for ( i = 0; i < m_aMissionObjectives.Length; ++i )
    {
        if ( m_aMissionObjectives[i].m_bFailed || m_aMissionObjectives[i].m_bCompleted )
            continue;

        m_aMissionObjectives[i].PawnSecure( securedPawn );
    }
}

//------------------------------------------------------------------
// EnteredExtractionZone
//	
//------------------------------------------------------------------
function EnteredExtractionZone( Pawn aPawn )
{
    local int i;
    
    if ( aPawn == none )
        return;

    if ( m_eMissionObjectiveStatus != eMissionObjStatus_none )
        return;

    for ( i = 0; i < m_aMissionObjectives.Length; ++i )
    {
        if ( m_aMissionObjectives[i].m_bFailed || m_aMissionObjectives[i].m_bCompleted )
            continue;

        m_aMissionObjectives[i].EnteredExtractionZone( aPawn );
    }
}

//------------------------------------------------------------------
// ExitExtractionZone
//	
//------------------------------------------------------------------
function ExitExtractionZone( Pawn aPawn )
{
    local int i;
    
    if ( aPawn == none )
        return;

    if ( m_eMissionObjectiveStatus != eMissionObjStatus_none )
        return;

    for ( i = 0; i < m_aMissionObjectives.Length; ++i )
    {
        if ( m_aMissionObjectives[i].m_bFailed || m_aMissionObjectives[i].m_bCompleted )
            continue;

        m_aMissionObjectives[i].ExitExtractionZone( aPawn );
    }
}


//------------------------------------------------------------------
// Update: update the mission objective manager. check if mission
//	have failed or has been completed
//------------------------------------------------------------------
function EMissionObjectiveStatus Update()
{
    local int i;
    local int iTotalMissionToComplete;
    local int iCompleted;
    local int iTotalMissionFailed;

    if ( m_bDontUpdateMgr || (InPlanningMode() && !Level.m_bInGamePlanningActive ) )
        return eMissionObjStatus_none;

    // it's over?
    if ( m_eMissionObjectiveStatus != eMissionObjStatus_none )
        return m_eMissionObjectiveStatus;

    // look for morality OR failed objective
    for ( i = 0; i < m_aMissionObjectives.Length; ++i )
    {
        if ( m_aMissionObjectives[i].isFailed() )
        {
            if ( !m_aMissionObjectives[i].m_bMoralityObjective )         
                ++iTotalMissionFailed;

            // a mission has failed and force the failure of the whole mission
            if ( m_aMissionObjectives[i].IsMissionAbortedOnFailure() )
            {
                SetMissionObjStatus( eMissionObjStatus_failed );
            }
        }
    }

    // check if the mission was aborted
    if ( m_eMissionObjectiveStatus == eMissionObjStatus_failed )
        return m_eMissionObjectiveStatus;

    // look if mission objective are completed
    for ( i = 0; i < m_aMissionObjectives.Length; ++i )
    {
        // skip morality rules
        if ( m_aMissionObjectives[i].m_bMoralityObjective )
            continue;
        
        ++iTotalMissionToComplete;
            
        // if not failed AND completed
        if ( !m_aMissionObjectives[i].isFailed() &&
             m_aMissionObjectives[i].isCompleted() )
        {
            ++iCompleted;
            
            // a mission was completed and force the success of the whole mission
            if ( m_aMissionObjectives[i].isMissionCompletedOnSuccess() )
            {
                SetMissionObjStatus( eMissionObjStatus_success );
            }
        }
    }    
    
    // check if the mission was completed with success
    if ( m_eMissionObjectiveStatus == eMissionObjStatus_success )
    {
        // set all in progress objective to completed
        CompleteMission();
        
        return m_eMissionObjectiveStatus;
    }

    if ( iTotalMissionToComplete > 0 )
    {
        // all mission to complete have failed
        if ( iTotalMissionFailed == iTotalMissionToComplete )
        {
            SetMissionObjStatus( eMissionObjStatus_failed );
            return m_eMissionObjectiveStatus;
        }
        // all mission to complete have been completed
        else if ( iCompleted == iTotalMissionToComplete )
        {
            CompleteMission();

            return m_eMissionObjectiveStatus;
        }
    }
    
    return eMissionObjStatus_none;
}


//------------------------------------------------------------------
// AbortMission: Force to abord the mission
//  set all mission objective to false except morality
//------------------------------------------------------------------
function AbortMission()
{
    local int i;

    for ( i = 0; i < m_aMissionObjectives.Length; ++i )
    {
        // skip morality rules
        if ( m_aMissionObjectives[i].m_bMoralityObjective )
            continue;

        SetMissionObjCompleted( m_aMissionObjectives[i], false, false );
    }

    SetMissionObjStatus( eMissionObjStatus_failed );
    m_gameInfo.UpdateRepMissionObjectives();
}

//------------------------------------------------------------------
// CompleteMission
//	set all not failed mission to completed
//------------------------------------------------------------------
function CompleteMission()
{
    local int i;
    
    if ( m_bOnSuccessAllObjectivesAreCompleted )
    {
        for ( i = 0; i < m_aMissionObjectives.Length; ++i )
        {
            if ( !m_aMissionObjectives[i].m_bFailed  )
                SetMissionObjCompleted( m_aMissionObjectives[i], true, false );
        }
    }
    
    SetMissionObjStatus( eMissionObjStatus_success );
    m_gameInfo.UpdateRepMissionObjectives();
}

//------------------------------------------------------------------
// ToggleLog
//	
//------------------------------------------------------------------
function ToggleLog( bool bToggle )
{
    local int i;
    m_bShowLog = bToggle;

    for ( i = 0; i < m_aMissionObjectives.Length; ++i )
    {
        m_aMissionObjectives[i].ToggleLog( bToggle );
    }
}

//------------------------------------------------------------------
// GetMObjFailed
//  We only check for one reason for the failure. This is why
//  the moralities are checked last.
//------------------------------------------------------------------
function R6MissionObjectiveBase GetMObjFailed()
{
    local int i;
    local string szFailure;

    for ( i = 0; i < m_aMissionObjectives.Length; ++i )
    {
        if ( !m_aMissionObjectives[i].isFailed() )
            continue;

        if ( m_aMissionObjectives[i].m_bMoralityObjective )
            continue;

        if ( m_aMissionObjectives[i].GetDescriptionFailure() != "" )
        {
            return m_aMissionObjectives[i];
        }
    }

    // check moralities rules
    for ( i = 0; i < m_aMissionObjectives.Length; ++i )
    {
        if ( !m_aMissionObjectives[i].isFailed() )
            continue;

        if ( !m_aMissionObjectives[i].m_bMoralityObjective )
            continue;

        if ( m_aMissionObjectives[i].GetDescriptionFailure() != "" )
        {
            return m_aMissionObjectives[i];
        }
    }
}


simulated event Destroyed()
{
    local int i;

    Super.Destroyed();
    for ( i = 0; i < m_aMissionObjectives.Length; ++i )
    {
        m_aMissionObjectives[i].SetMObjMgr( none );
    }

    m_gameInfo = none;
}

//------------------------------------------------------------------
// SetMissionObjCompleted
//	set completed or failed and check he need to send a feedback
//------------------------------------------------------------------
function SetMissionObjCompleted( R6MissionObjectiveBase mobj, bool bCompleted, bool bFeedback )
{
    if ( (InPlanningMode() && !Level.m_bInGamePlanningActive) )
        return;

    if ( bCompleted )
        mobj.m_bCompleted = true;
    else
        mobj.m_bFailed = true;

    // if no feedback or already sent, return
    if ( !bFeedback || mobj.m_bFeedbackOnCompletionSend || mobj.m_bFeedbackOnFailureSend )
        return;

    // check if needs to send a game event feedback
    if (  mobj.m_bCompleted  )
    {
        if (  mobj.m_szFeedbackOnCompletion != "" )
        {
            m_gameInfo.BroadcastMissionObjMsg( Level.GetMissionObjLocFile(mobj), "", mobj.m_szFeedbackOnCompletion );
            mobj.m_bFeedbackOnCompletionSend = true;
        }
    }
    else
    {
        if (  mobj.m_szFeedbackOnFailure != "" )
        {
            m_gameInfo.BroadcastMissionObjMsg( Level.GetMissionObjLocFile(mobj), "", mobj.m_szFeedbackOnFailure );
            mobj.m_bFeedbackOnFailureSend = true;
        }
    }
}

defaultproperties
{
     m_bOnSuccessAllObjectivesAreCompleted=True
     bHidden=True
}
