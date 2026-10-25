//=============================================================================
//  R6MObjNeutralizeTerrorist.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//
// fail: if m_bMustSecureTerroInDepZone and the terro is dead
// success: once m_iNeutralizePercentage is reached
//
// example: 
//  - kill or secure all terro in the level
//  - kill or secure a group of terro (specify deployment zone) 
//  - kill or secure a specific terro (specify deployment zone) 
//  - secure a specific terro (specify deployment zone & m_bMustSecureTerroInDepZone) 
//=============================================================================

class R6MObjNeutralizeTerrorist extends R6MissionObjectiveBase;

var() int   m_iNeutralizePercentage;

var() R6DeploymentZone  m_depZone;                   // neutralize terro in this deployment zone
var() bool              m_bMustSecureTerroInDepZone; // must secure the terro, if kill failed

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
        else
        {
            if ( m_bMustSecureTerroInDepZone )
                logMObj( "m_bMustSecureTerroInDepZone was enabled but without a deployment zone" );

            R6GameInfo(m_mgr.Level.Game).CheckForTerrorist( self, 1 );
        }
    }
}

function PawnKilled( Pawn killed )
{
    PawnSecure( killed );
}

function PawnSecure( Pawn secured )
{
    local float         fNeutralized;  
    local int           iTotal;
    local R6Terrorist   aTerrorist;
    local int           i;
    local int           iResult;
 
    if ( secured.m_ePawnType != PAWN_Terrorist )
        return;

    // check terro in this depzone
    if ( m_depZone != none )  
    {
        aTerrorist = R6Terrorist( secured );
        
        if ( m_depZone != aTerrorist.m_DZone )  // not the same dep zone
            return;

        for ( i = 0; i < m_depZone.m_aTerrorist.Length; ++i )
        {
            aTerrorist = m_depZone.m_aTerrorist[i];
            
            if ( m_bMustSecureTerroInDepZone )      // if must be secured
            {
		        if ( !aTerrorist.IsAlive() )        // was killed
                {
                    R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, false, true );
                    if ( m_bShowLog ) logX( "PawnKilled failed=" $m_bFailed$ " should have been secured" );
                    return;
                }

                if( aTerrorist.m_bIsKneeling || aTerrorist.m_bIsUnderArrest )   // is secured
		        {
                    fNeutralized += 1;
		        }
            }
            else                                    // can be killed OR secured
            {
		        if( !aTerrorist.IsAlive() || aTerrorist.m_bIsKneeling || aTerrorist.m_bIsUnderArrest ) 
		        {
                    fNeutralized += 1;
		        }
            }
            ++iTotal;
        }
    }
    else // check all terro in the level
    {   
        fNeutralized = R6GameInfo(m_mgr.Level.Game).GetNbTerroNeutralized();
        foreach m_mgr.DynamicActors( class'R6Terrorist', aTerrorist )
	    {
            ++iTotal;
	    }
    }

    if ( iTotal > 0 )
    {
        iResult = fNeutralized/iTotal*100.0;
        if (iResult >= m_iNeutralizePercentage )
        {
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted( self, true, true );
        }
    }
    
    if ( m_bShowLog ) logX( "PawnSecured/Killed. completed=" $m_bCompleted$ " neutralized=" $secured.name$ " "$iResult$ "/" $m_iNeutralizePercentage$ "%"  );
}

defaultproperties
{
     m_iNeutralizePercentage=100
     m_bIfCompletedMissionIsSuccessfull=True
     m_szDescription="Neutralize all terrorist"
     m_szDescriptionInMenu="NeutralizeAllTerrorist"
}
