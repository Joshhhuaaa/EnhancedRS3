//=============================================================================
//  R6MObjRecon.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
// Only for rainbow 
//
// fail: if kill, secure, make noise and is seen
//=============================================================================

class R6MObjRecon extends R6MissionObjectiveBase;

var() bool  m_bCanKill;
var() bool  m_bCanSecure;
var() bool  m_bCanMakeNoise;
var() bool  m_bCanSeeMe;

//------------------------------------------------------------------
// Init
//	
//------------------------------------------------------------------
function Init()
{
    // must always be setted to true, so it can be used with R6MObjCompleteAllAndGoToExtraction
    m_bIfCompletedMissionIsSuccessfull = true; 
}
//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled( Pawn killed )
{
    local R6Pawn p;

    if ( m_bCanKill )
        return;

    p = R6Pawn(killed);

    // no killer
    if ( p.m_KilledBy == none )
        return;

    // the killer is not a rainbow
    if ( p.m_KilledBy.m_ePawnType != PAWN_Rainbow )
        return;

    R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
    if ( m_bShowLog ) logX( "PawnKilled. mission failed" );
}

//------------------------------------------------------------------
// PawnSecure
//	
//------------------------------------------------------------------
function PawnSecure( Pawn securedPawn )
{
    if ( m_bCanSecure )
        return;

    R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
    if ( m_bShowLog ) logX( "PawnSecure. mission failed" );
}

//------------------------------------------------------------------
// PawnSeen
//	
//------------------------------------------------------------------
function PawnSeen( Pawn seen, Pawn witness )
{
    if ( m_bCanSeeMe )
        return;

    // if not a raibow
    if ( seen.m_ePawnType != PAWN_Rainbow )
        return;

    R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
    if ( m_bShowLog ) logX( "PawnSeen. mission failed" );
}

//------------------------------------------------------------------
// PawnHeard
//	
//------------------------------------------------------------------
function PawnHeard( Pawn seen, Pawn witness )
{
    // log( "R6MObjRecon PawnHeard seen=" $seen$ " m_bCanMakeNoise=" $m_bCanMakeNoise );

    if ( m_bCanMakeNoise )
        return;

    // if not a raibow
    if ( seen.m_ePawnType != PAWN_Rainbow )
        return;

    R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
    if ( m_bShowLog ) logX( "PawnHeard. mission failed" );
}

defaultproperties
{
     m_bCanMakeNoise=True
     m_bIfCompletedMissionIsSuccessfull=True
     m_bIfFailedMissionIsAborted=True
     m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_TeamSpotted'
     m_szDescription="Recon: don't kill anyone and don't get caugh"
     m_szDescriptionInMenu="AvoidDetection"
     m_szDescriptionFailure="YouWereDetected"
}
