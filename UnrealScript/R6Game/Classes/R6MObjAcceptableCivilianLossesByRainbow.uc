//=============================================================================
//  R6MObjAcceptableCivilianLossesByRainbow.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

class R6MObjAcceptableCivilianLossesByRainbow extends R6MObjAcceptableLosses;

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
		if(h.m_bPoliceManMp1)//Begin MissionPack1
		{
			m_szDescriptionFailure="PolicemanWasKilledByRainbow";
			m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_MissionFailed';
		}//End MissionPack1

        Super.PawnKilled( killed );
    }
}

defaultproperties
{
     m_ePawnTypeKiller=PAWN_Rainbow
     m_ePawnTypeDead=PAWN_Hostage
     m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_CivilianKilled'
     m_szDescription="Acceptable civilian losses by rainbow"
     m_szDescriptionInMenu="AvoidCivilianCasualities"
     m_szDescriptionFailure="CivilianWasKilledByRainbow"
}
