//=============================================================================
//  R6MObjAcceptableRainbowLosses.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

class R6MObjAcceptableRainbowLosses extends R6MObjAcceptableLosses;

defaultproperties
{
     m_ePawnTypeKiller=PAWN_All
     m_ePawnTypeDead=PAWN_Rainbow
     m_iAcceptableLost=100
     m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_TeamWipedOut'
     m_szDescription="Acceptable rainbow losses"
     m_szDescriptionInMenu="RaibowTeamMustSurvive"
     m_szDescriptionFailure="YourTeamWasWipedOut"
}
