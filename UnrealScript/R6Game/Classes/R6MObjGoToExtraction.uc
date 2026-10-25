//=============================================================================
//  R6MObjGoToExtraction.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  fail: if pawn killed
//  success: if he is in a extraction zone
//=============================================================================

class R6MObjGoToExtraction extends R6MissionObjectiveBase;

var		R6Pawn	m_pawnToExtract;                // the pawn to extract OR
var()   bool    m_bExtractAtLeastOneRainbow;    // at least one rainbow to extract (anyone)

function Init()
{
    if ( R6MissionObjectiveMgr(m_mgr).m_bEnableCheckForErrors )
        R6GameInfo(m_mgr.Level.Game).CheckForExtractionZone( self );
}

//------------------------------------------------------------------
// SetPawnToExtract 
//	specify which pawn to extract
//------------------------------------------------------------------
function SetPawnToExtract( R6Pawn aPawn )
{
    m_bExtractAtLeastOneRainbow = false;
    m_pawnToExtract             = aPawn;
}

//------------------------------------------------------------------
// Reset
//	
//------------------------------------------------------------------
function Reset()
{
    Super.Reset();

    m_pawnToExtract = none;
}

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled( Pawn killedPawn )
{
    if ( R6Pawn(killedPawn) != m_pawnToExtract )
        return;

    R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
    
    if ( m_bShowLog ) 
        log( "PawnKilled: m_pawnToExtract= " $m_pawnToExtract.name$ " bFailed=" $m_bFailed );
}

//------------------------------------------------------------------
// EnteredExtractionZone
//	
//------------------------------------------------------------------
function EnteredExtractionZone( Pawn aPawn )
{
    if ( m_bExtractAtLeastOneRainbow )
    {
        if ( aPawn.m_ePawnType != PAWN_Rainbow )
            return;
    }
    else if ( R6Pawn( aPawn ) != m_pawnToExtract )
        return;

    R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, true, true );

    if ( m_bShowLog )
    {
        if ( m_pawnToExtract != none)
            log( "EnteredExtractionZone: m_pawnToExtract= " $m_pawnToExtract.name$ " bCompleted=" $m_bCompleted );
        else
            log( "EnteredExtractionZone: m_bExtractAtLeastOneRainbow = " $aPawn.name$ " bCompleted=" $m_bCompleted );
    }
}

defaultproperties
{
     m_bExtractAtLeastOneRainbow=True
     m_bIfCompletedMissionIsSuccessfull=True
     m_bIfFailedMissionIsAborted=True
     m_szDescription="Go to extraction zone"
}
