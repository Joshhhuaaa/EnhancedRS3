//=============================================================================
//  R6MObjGroupMission.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
// 
//
// example 1:
//      secure a terro
//      rescue one hostage
//      - the 2 must be completed
//      - if 1 fail, the group objective fails
//=============================================================================

class R6MObjGroupMission extends R6MissionObjectiveBase;

var() editinline Array<R6MissionObjectiveBase> m_aSubMissionObjectives;
var() int        m_iMinSuccessRequired; // minimum number of mission successful required for having a "mission completed"
var() int        m_iMaxFailedAccepted;  // maximum number of mission failed accepted before having "mission failed"

//------------------------------------------------------------------
// Init
//	
//------------------------------------------------------------------
function Init()
{
    local R6MissionObjectiveMgr mgr;
    local int i, index;
    local Array<R6MissionObjectiveBase> aTempMObj;

    if ( R6MissionObjectiveMgr(m_mgr).m_bEnableCheckForErrors )    
    {
        if ( m_aSubMissionObjectives.Length == 0 )
            logMObj( "m_aSubMissionObjectives.Length == 0" );

        if ( m_iMinSuccessRequired <= 0 )
            logMObj( "m_iMinSuccessRequired <= 0" );

        if ( m_iMinSuccessRequired >  m_aSubMissionObjectives.Length  )
            logMObj( "m_iMinSuccessRequired >  m_aSubMissionObjectives.Length " );

        if ( m_iMaxFailedAccepted > m_aSubMissionObjectives.Length  )
            logMObj( "m_iMaxFailedAccepted > m_aSubMissionObjectives.Length" );
    }

    // fix any error
    m_iMaxFailedAccepted  = Clamp( m_iMaxFailedAccepted,  0, m_aSubMissionObjectives.Length );
    m_iMinSuccessRequired = Clamp( m_iMinSuccessRequired, 1, m_aSubMissionObjectives.Length );

    // add all objective, except the one with m_bEndOfListOfObjectives
    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        if ( !m_aSubMissionObjectives[i].m_bEndOfListOfObjectives )
        {
            aTempMObj[index] = m_aSubMissionObjectives[i];
            ++index;
        }
    }

    // add all objective with m_bEndOfListOfObjectives
    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        if ( m_aSubMissionObjectives[i].m_bEndOfListOfObjectives )
        {
            aTempMObj[index] = m_aSubMissionObjectives[i];
            ++index;
        }
    }

    mgr = R6MissionObjectiveMgr( m_mgr );

    // copy back the ordered list and init the objective
    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        m_aSubMissionObjectives[i] = aTempMObj[i];
        m_aSubMissionObjectives[i].m_mgr = m_mgr;
        m_aSubMissionObjectives[i].Init();
        
        if( mgr.m_bShowLog ) log( "    " $i$ ": " $m_aSubMissionObjectives[i].GetDescription() );
    }
}

function ToggleLog( bool bToggle )
{
    local int i;
    Super.ToggleLog( bToggle );
    
    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        m_aSubMissionObjectives[i].ToggleLog( bToggle );
    }
}

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled( Pawn killedPawn )
{
    local int i;
    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        if ( m_aSubMissionObjectives[i].m_bFailed || m_aSubMissionObjectives[i].m_bCompleted )
            continue;

        m_aSubMissionObjectives[i].PawnKilled( killedPawn );
    }
}

//------------------------------------------------------------------
// IObjectInteract
//	
//------------------------------------------------------------------
function IObjectInteract( Pawn aPawn, Actor anInteractiveObject )
{
    local int i;
    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        if ( m_aSubMissionObjectives[i].m_bFailed || m_aSubMissionObjectives[i].m_bCompleted )
            continue;

        m_aSubMissionObjectives[i].IObjectInteract( aPawn, anInteractiveObject );
    }
}

//------------------------------------------------------------------
// IObjectDestroyed
//	
//------------------------------------------------------------------
function IObjectDestroyed( Pawn aPawn, Actor anInteractiveObject )
{
    local int i;
    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        if ( m_aSubMissionObjectives[i].m_bFailed || m_aSubMissionObjectives[i].m_bCompleted )
            continue;

        m_aSubMissionObjectives[i].IObjectDestroyed( aPawn, anInteractiveObject );
    }
}
//------------------------------------------------------------------
// PawnSeen
//	
//------------------------------------------------------------------
function PawnSeen( Pawn seen, Pawn  witness )
{
    local int i;
    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        if ( m_aSubMissionObjectives[i].m_bFailed || m_aSubMissionObjectives[i].m_bCompleted )
            continue;

        m_aSubMissionObjectives[i].PawnSeen( seen, witness );
    }
}

//------------------------------------------------------------------
// PawnHeard
//	
//------------------------------------------------------------------
function PawnHeard( Pawn seen, Pawn  witness )
{
    local int i;
    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        if ( m_aSubMissionObjectives[i].m_bFailed || m_aSubMissionObjectives[i].m_bCompleted )
            continue;

        m_aSubMissionObjectives[i].PawnHeard( seen, witness );
    }
}

//------------------------------------------------------------------
// PawnSecure
//	
//------------------------------------------------------------------
function PawnSecure( Pawn securedPawn )
{
    local int i;
    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        if ( m_aSubMissionObjectives[i].m_bFailed || m_aSubMissionObjectives[i].m_bCompleted )
            continue;

        m_aSubMissionObjectives[i].PawnSecure( securedPawn );
    }
}

//------------------------------------------------------------------
// EnteredExtractionZone
//	
//------------------------------------------------------------------
function EnteredExtractionZone( Pawn pawn )
{
    local int i;
    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        if ( m_aSubMissionObjectives[i].m_bFailed || m_aSubMissionObjectives[i].m_bCompleted )
            continue;

        m_aSubMissionObjectives[i].EnteredExtractionZone( pawn );
    }
}

//------------------------------------------------------------------
// ExitExtractionZone
//	
//------------------------------------------------------------------
function ExitExtractionZone( Pawn pawn )
{
    local int i;
    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        if ( m_aSubMissionObjectives[i].m_bFailed || m_aSubMissionObjectives[i].m_bCompleted )
            continue;

        m_aSubMissionObjectives[i].ExitExtractionZone( pawn );
    }
}

//------------------------------------------------------------------
// isCompleted
//
//------------------------------------------------------------------
function bool isCompleted()
{
    local int i;
    local int iNum;
    
    if ( m_bCompleted || m_bFailed )
        return m_bCompleted;

    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        if ( m_aSubMissionObjectives[i].isCompleted() )
        {
            if ( m_aSubMissionObjectives[i].isMissionCompletedOnSuccess() )
            {
                if ( m_bShowLog ) logX( " mission is completed on success because of " $m_aSubMissionObjectives[i].GetDescription() );
                R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, true, true );
            }

            iNum++;
        }
    }

    if ( m_bCompleted )
        return m_bCompleted;

    if (iNum >= m_iMinSuccessRequired)
    {
        R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, true, true );
    }

    if ( m_bCompleted && m_bShowLog )
    {
        logX( "is completed. num completed=" $iNum$ " minSuccessRequired=" $m_iMinSuccessRequired );
    }

    return m_bCompleted;
}

//------------------------------------------------------------------
// isFailed
//
//------------------------------------------------------------------
function bool isFailed()
{
    local int i;
    local int iNum;

    if ( m_bFailed || m_bCompleted )
        return m_bFailed;

    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        if ( m_aSubMissionObjectives[i].isFailed() )
        {
            if ( m_aSubMissionObjectives[i].m_bIfFailedMissionIsAborted )
            {
                R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
                if ( m_bShowLog ) logX( "is failed. Mission is aborted because of " $m_aSubMissionObjectives[i].GetDescription() );
            }

            iNum++;
        }
    }

    if ( m_bFailed )
        return m_bFailed;
       
    if ( iNum == 0 )
        return false;

    if ( iNum >= m_iMaxFailedAccepted )
        R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );

    if ( m_bShowLog && m_bFailed )
    {
        logX( "is failed. num failed=" $iNum$ " maxFailedAccepted=" $m_iMaxFailedAccepted );
    }
    
    return m_bFailed;
}

function string GetDescriptionFailure()
{
    local int i;
    local int iNum;

    if ( !m_bFailed )
        return "";

    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        if ( m_aSubMissionObjectives[i].isFailed() &&
             m_aSubMissionObjectives[i].GetDescriptionFailure() != "" )
        {
            return m_aSubMissionObjectives[i].GetDescriptionFailure();
        }
    }
}

function Sound GetSoundFailure()
{
    local int i;

    if ( !m_bFailed )
        return none;

    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        if ( m_aSubMissionObjectives[i].isFailed())
        {
            return m_aSubMissionObjectives[i].GetSoundFailure();
        }
    }
    return m_sndSoundFailure;
}

function int GetNumSubMission()
{
    return m_aSubMissionObjectives.Length;
}

function R6MissionObjectiveBase GetSubMissionObjective( int index )
{
    return m_aSubMissionObjectives[index];    
}

function SetMObjMgr( Actor aMObjMgr )
{
    local int i;
    
    Super.SetMObjMgr( aMObjMgr );
    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        m_aSubMissionObjectives[i].SetMObjMgr( aMObjMgr );
    }
}

function Reset()
{
    local int i;
    
    Super.Reset();
    for ( i = 0; i < m_aSubMissionObjectives.Length; ++i )
    {
        m_aSubMissionObjectives[i].Reset();
    }
}

defaultproperties
{
     m_iMinSuccessRequired=1
     m_szDescription="This a group mission"
}
