//=============================================================================
//  R6MObjRescueHostage.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//
// success: if enough hostage are rescued in the extraction zone
// fail: if there's too much dead hostage/civilian to complete the mission
//
// example: 
//  - rescue all hostage
//  - rescue a specific hostage (specify the m_depZone)
//  - rescue a specific group hostage (specify the m_depZone)
// 
// ** no difference between a hostage and a civilian
//=============================================================================

class R6MObjRescueHostage extends R6MissionObjectiveBase;

var() bool              m_bRescueAllRemainingHostage;   // rescue all hostage until there's no one alive 
                                                        // ** OR **
var() int               m_iRescuePercentage;            // minimum nb of hostage to rescue. 
var() R6DeploymentZone  m_depZone; // rescure hostage in this deployment zone
var() bool              m_bCheckPawnKilled;

//------------------------------------------------------------------
// Init
//	
//------------------------------------------------------------------
function Init()
{
    local int               iTotal;
    local R6Hostage		    aHostage;
    local R6ExtractionZone  aExtractZone;

    if ( R6MissionObjectiveMgr(m_mgr).m_bEnableCheckForErrors )    
    {
        if ( m_depZone != none )
        {
            // must have someone spawned in the depZone
            if ( m_depZone.m_aHostage.Length == 0 )
                logMObj( "there is no hostage in " $m_depZone.name  );
        }
        else
        {
            R6GameInfo(m_mgr.Level.Game).CheckForHostage( self, 1 );
        }

        R6GameInfo(m_mgr.Level.Game).CheckForExtractionZone( self );
    }
}

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled( Pawn killedPawn )
{
    local R6Hostage h;
    local R6Hostage aHostage;
    local float fTotalDeath;
    local int   iTotal, i;

    if ( !m_bCheckPawnKilled )
        return;

    // not a hostage
    if ( killedPawn.m_ePawnType != PAWN_Hostage )
        return;

    h = R6Hostage( killedPawn );

	// MPF1
	if ( h.m_bCivilian )//MissionPack1
		return; 

    if ( m_depZone != none ) // dep zone type of rescue
    {
        // not the same dep zone
        if ( m_depZone != h.m_DZone )
            return;

        // check in the dep zone if there's too much death
        for ( i = 0; i < m_depZone.m_aHostage.Length; ++i )
        {
		    if( !m_depZone.m_aHostage[i].IsAlive() ) 
		    {
                fTotalDeath += 1;
		    }
            ++iTotal;
        }
    }
    else
    {
        // check in the level if there's too much death
        foreach m_mgr.DynamicActors( class'R6Hostage', aHostage )
	    {
              // MPF1
			if(!aHostage.m_bCivilian )//MissionPack1
			{//MissionPack1
				if( !aHostage.IsAlive() ) 
				{
					fTotalDeath += 1;
				}
				++iTotal;
			}//MissionPack1
	    }
    }

    // if we try to rescue all hostage (even if there's some dead)
    if ( m_bRescueAllRemainingHostage )
    {
        if ( fTotalDeath == iTotal ) // all dead: failed
        {
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
        }
    }
    // too much death
    else if (  fTotalDeath > 0 &&
          (100 - fTotalDeath/iTotal*100.0) <= m_iRescuePercentage )
    {
        R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
    }
        
    if ( m_bShowLog ) logX( "PawnKilled. failed=" $m_bFailed$ " " $(fTotalDeath/iTotal*100.0)$ "/" $m_iRescuePercentage$"%" );
}

function EnteredExtractionZone( Pawn aPawn )
{
    local R6Hostage h;
    local R6Hostage aHostage;
    local float fRescuedNum;
    local int   iTotal, i, iTotalAlive;

    // not a hostage
    if ( aPawn.m_ePawnType != PAWN_Hostage )
        return;

    h = R6Hostage( aPawn );
    
        // MPF1
	if ( h.m_bCivilian )//MissionPack1
		return; 

    // extraction: in a depZone 
    if ( m_depZone != none ) 
    {
        if ( m_depZone != h.m_DZone ) // it is not the good dep zone
            return;

        for ( i = 0; i < m_depZone.m_aHostage.Length; ++i )
        {
            aHostage = m_depZone.m_aHostage[i];
                        // MPF1
			if(!aHostage.m_bCivilian )//MissionPack1
			{//MissionPack1
				if( aHostage.IsAlive() ) 
				{
					iTotalAlive++;
                
					if ( aHostage.m_bExtracted )
						fRescuedNum += 1;
				}
				++iTotal;
			}//MissionPack1
        }
    }
    else // check all dead hostage in the level
    {        
        foreach m_mgr.DynamicActors( class'R6Hostage', aHostage )
	    {
            // if neutralizing terro in a particular dep zone
                        // MPF1
			if(!aHostage.m_bCivilian )//MissionPack1
			{//MissionPack1
				if( aHostage.IsAlive() ) 
				{
					iTotalAlive++;
					if ( aHostage.m_bExtracted )
						fRescuedNum += 1;
				}
				++iTotal;
			}//MissionPack1
	    }
    }

    if ( m_bRescueAllRemainingHostage )
    {
        if ( fRescuedNum == iTotalAlive )
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, true, true );
    }
    else if ( (fRescuedNum/iTotal*100.0) >= m_iRescuePercentage )
    {
        R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, true, true );
    }

    if ( m_bShowLog ) logX( "EnteredExtZone. completed=" $m_bCompleted$ " " $(fRescuedNum/iTotal*100.0)$ "/" $m_iRescuePercentage$"%" );
}

function string GetDescriptionBasedOnNbOfHostages( LevelInfo level )
{
    local R6Hostage aHostage;
    local int       iTotal;

    foreach level.DynamicActors( class'R6Hostage', aHostage )
	{
           // MPF1
	   if ( aHostage.isAlive() /*Begin MissionPack1*/&& (!aHostage.m_bCivilian ))
            ++iTotal;
    }

    switch ( iTotal )
    {
    case 1:
        return "RescueTheHostageToExtractionZone";
        
    case 2:
        return "RescueBothHostagesToExtractionZone";

    case 3:
        return "RescueThreeHostagesToExtractionZone";

    default:
        return "RescueAllHostagesToExtractionZone";
    }
}

defaultproperties
{
     m_iRescuePercentage=100
     m_bCheckPawnKilled=True
     m_bIfFailedMissionIsAborted=True
     m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_HostageKilled'
     m_szDescription="Rescue hostage"
     m_szDescriptionInMenu="RescueAllHostagesToExtractionZone"
}
