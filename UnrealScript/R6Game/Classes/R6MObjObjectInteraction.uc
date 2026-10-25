//=============================================================================
//  R6MObjObjectInteraction.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
// Only for rainbow human controller
//
//=============================================================================

class R6MObjObjectInteraction extends R6MissionObjectiveBase;

var() R6IOObject        m_r6IOObject;

var() bool              m_bIfDeviceIsActivatedObjectiveIsCompleted;
var() bool              m_bIfDeviceIsActivatedObjectiveIsFailed;
var() bool              m_bIfDeviceIsDeactivatedObjectiveIsCompleted;
var() bool              m_bIfDeviceIsDeactivatedObjectiveIsFailed;
var() bool              m_bIfDestroyedObjectiveIsCompleted;
var() bool              m_bIfDestroyedObjectiveIsFailed;

//------------------------------------------------------------------
// Init
//	
//------------------------------------------------------------------
function Init()
{
    if ( R6MissionObjectiveMgr(m_mgr).m_bEnableCheckForErrors )   
    {
        if ( m_r6IOObject == none )
        {
            logMObj( "m_r6IOObject not specified" );
        }

        if ( m_bIfDestroyedObjectiveIsCompleted && m_bIfDestroyedObjectiveIsFailed )
        {
            logMObj( "both are set to true m_bIfDestroyedObjectiveIsCompleted, m_bIfDestroyedObjectiveIsFailed"  );
        }
    }
}

//------------------------------------------------------------------
// IObjectInteract
//	
//------------------------------------------------------------------
function IObjectInteract( Pawn aPawn, Actor anInteractiveObject )
{
    if ( m_r6IOObject != anInteractiveObject )
        return;

    // is activated / armed
    if ( m_r6IOObject.m_bIsActivated )
    {
        if ( m_bIfDeviceIsActivatedObjectiveIsCompleted )
        {
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, true, true );
        }
        else if ( m_bIfDeviceIsActivatedObjectiveIsFailed )
        {
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
        }
    }
    else // disabled / disarmed 
    {
        if ( m_bIfDeviceIsDeactivatedObjectiveIsCompleted )
        {
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, true, true );
        }
        else if ( m_bIfDeviceIsDeactivatedObjectiveIsFailed )
        {
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
        }

    }
}

//------------------------------------------------------------------
// IObjectDestroyed
//	
//------------------------------------------------------------------
function IObjectDestroyed( Pawn aPawn, Actor anInteractiveObject )
{
    if ( m_r6IOObject != anInteractiveObject )
        return;

    if ( m_bIfDestroyedObjectiveIsCompleted )
    {
        R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, true, true );
    }
    else if ( m_bIfDestroyedObjectiveIsFailed )
    {
        R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
    }
}

defaultproperties
{
     m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_MissionFailed'
     m_szDescription="Interact with object"
}
