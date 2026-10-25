//=============================================================================
//  R6MObjAcceptableHostageLossesByRainbow.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

class R6MObjAcceptableHostageLossesByRainbow extends R6MObjAcceptableLosses;

function PawnKilled( Pawn killed )
{
    local R6Hostage h;

    if ( killed.m_ePawnType != m_ePawnTypeDead )
        return;

    h = R6Hostage( killed );
    
    // not a civilian
    if ( !h.m_bCivilian ) 
    {
        Super.PawnKilled( killed );
    }
}

defaultproperties
{
     m_ePawnTypeKiller=PAWN_Rainbow
     m_ePawnTypeDead=PAWN_Hostage
     m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_HostageKilled'
     m_szDescription="Acceptable hostage losses by rainbow"
     m_szDescriptionInMenu="AvoidHostageCasualities"
     m_szDescriptionFailure="HostageWasKilledByRainbow"
}
