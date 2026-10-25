//=============================================================================
//  R6MObjPreventBombDetonation.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
// Only for rainbow human controller
//
// fail: if kill, secure, make noise and is seen
//=============================================================================

class R6MObjPreventBombDetonation extends R6MObjObjectInteraction;
    


var() bool              m_bIfDetonateObjectiveIsFailed;
var() bool              m_bIfDetonateObjectiveIsCompleted;

//------------------------------------------------------------------
// IObjectDestroyed
//	
//------------------------------------------------------------------
function IObjectDestroyed( Pawn aPawn, Actor anInteractiveObject )
{
    local R6IOBomb bomb;
    
    if ( m_r6IOObject != anInteractiveObject )
        return;

    bomb = R6IOBomb( m_r6IOObject );
    if ( bomb.m_bExploded ) 
    {
        if ( m_bIfDetonateObjectiveIsFailed )
        {
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
        }
        else if ( m_bIfDetonateObjectiveIsCompleted )
        {
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, true, true );
        }
    }
    else
    {
        if ( m_bIfDestroyedObjectiveIsCompleted )
        {
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, true, true );
        }
        else if ( m_bIfDestroyedObjectiveIsFailed )
        {
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
        }
    }
}

defaultproperties
{
     m_bIfDetonateObjectiveIsFailed=True
     m_bIfDeviceIsDeactivatedObjectiveIsCompleted=True
     m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_BombDetonated'
     m_szDescription="Prevent bomb detonation"
     m_szDescriptionInMenu="PreventBombDetonation"
     m_szDescriptionFailure="BombHasDetonated"
}
