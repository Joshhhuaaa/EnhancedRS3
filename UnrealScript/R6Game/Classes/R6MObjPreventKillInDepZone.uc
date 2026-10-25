//=============================================================================
//  R6MObjPreventKillInDepZone.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

class R6MObjPreventKillInDepZone extends R6MissionObjectiveBase;

var() R6DeploymentZone  m_depZone;                   // neutralize terro in this deployment zone

function Init()
{
    local int           iTotal;
    local R6Terrorist   aTerrorist;

    if ( R6MissionObjectiveMgr(m_mgr).m_bEnableCheckForErrors )    
    {
        if ( m_depZone != none )
        {
            // must have someone spawned in the depzone
            if ( m_depZone.m_aTerrorist.Length == 0 )
                logMObj( "there is no terrorist in " $m_depZone.name  );
        }
    }
}

function PawnKilled( Pawn killed )
{
    local float         fNeutralized;  
    local int           iTotal;
    local R6Terrorist   aTerrorist;
    local int           i;
    local int           iResult;
 
    if ( killed.m_ePawnType != PAWN_Terrorist )
        return;

    // check terro in this depzone
    if ( m_depZone != none )  
    {
        aTerrorist = R6Terrorist( killed );
        
        if ( m_depZone != aTerrorist.m_DZone )  // not the same dep zone
            return;

		if ( !aTerrorist.IsAlive() )        // was killed
        {
            if ( m_bShowLog ) logX( "PawnKilled failed=" $m_bFailed );
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
        }
    }
}

defaultproperties
{
     m_bVisibleInMenu=False
     m_bIfFailedMissionIsAborted=True
     m_szDescription="Dont kill pawn in this depzone"
}
