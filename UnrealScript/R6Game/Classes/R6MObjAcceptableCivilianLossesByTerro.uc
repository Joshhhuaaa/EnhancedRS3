//=============================================================================
//  R6MObjAcceptableCivilianLossesByTerro.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

class R6MObjAcceptableCivilianLossesByTerro extends R6MObjAcceptableLosses;

function PawnKilled( Pawn killed )
{
    local R6Hostage h;

    if ( killed.m_ePawnType != m_ePawnTypeDead )
        return;

    h = R6Hostage( killed );
    
    // a civilian was killed
    if ( h.m_bCivilian ) 
    {
		// MPF1
		if(h.m_bPoliceManMp1)//MissionPack1
			m_szDescriptionFailure="PolicemanWasKilledByTerro";
        Super.PawnKilled( killed );
    }
}

defaultproperties
{
     m_ePawnTypeKiller=PAWN_Terrorist
     m_ePawnTypeDead=PAWN_Hostage
     m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_MissionFailed'
     m_szDescription="Acceptable civilian losses by terro"
     m_szDescriptionFailure="CivilianWasKilledByTerro"
}
