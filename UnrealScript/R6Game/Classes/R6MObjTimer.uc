//=============================================================================
//  R6MObjTimer.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

class R6MObjTimer extends R6MissionObjectiveBase;

function TimerCallback( float fTime )
{
    if (m_bShowLog) logX( "failed: timer countdown is zero" );
    R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
}

defaultproperties
{
     m_bIfFailedMissionIsAborted=True
     m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_MissionFailed'
     m_szDescription="Timer countdown"
     m_szFeedbackOnFailure="TimeIsUp"
}
