//=============================================================================
//  R6MObjAcceptableHostageLossesByTerro.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

class R6MObjAcceptableHostageLossesByTerro extends R6MObjAcceptableLosses;

function PawnKilled( Pawn killed )
{
    local R6Hostage h;

    if ( killed.m_ePawnType != m_ePawnTypeDead )
        return;

    h = R6Hostage( killed );
    
    // a hostage was killed
    if ( !h.m_bCivilian ) 
    {
        Super.PawnKilled( killed );
    }
}

defaultproperties
{
     m_ePawnTypeKiller=PAWN_Terrorist
     m_ePawnTypeDead=PAWN_Hostage
     m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_HostageKilled'
     m_szDescription="Acceptable hostage losses by terro"
     m_szDescriptionInMenu="AvoidHostageCasualities"
     m_szDescriptionFailure="HostageWasKilledByTerro"
}
