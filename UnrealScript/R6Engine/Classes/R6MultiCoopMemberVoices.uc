class R6MultiCoopMemberVoices extends R6MultiCoopVoices;

var Sound m_sndGasThreat;
var Sound m_sndGrenadeThreat;

function Init(Actor aActor)
{
    Super.Init(aActor);
	aActor.AddSoundBankName("Voices_Multi_Coop_AI");
}


function PlayRainbowTeamVoices(R6Pawn aPawn, Pawn.ERainbowTeamVoices eVoices )
{
    Super.PlayRainbowTeamVoices(aPawn, eVoices);

    // Only the AI can say they see a grenade
    switch(eVoices)
    {
        case RTV_GasThreat: 
            aPawn.PlayVoices(m_sndGasThreat, SLOT_HeadSet, 10);
            break;
        case RTV_GrenadeThreat:
            aPawn.PlayVoices(m_sndGrenadeThreat, SLOT_HeadSet, 10);
            break;
    }
}

defaultproperties
{
     m_sndGasThreat=Sound'Voices_Multi_Coop_AI.Play_AI_GasThreat'
     m_sndGrenadeThreat=Sound'Voices_Multi_Coop_AI.Play_AI_FragThreat'
     m_sndPlacingBug=Sound'Voices_Multi_Coop_AI.Play_AI_PlacingBug'
     m_sndBugActivated=Sound'Voices_Multi_Coop_AI.Play_AI_BugActivated'
     m_sndAccessingComputer=Sound'Voices_Multi_Coop_AI.Play_AI_AccessingComputer'
     m_sndComputerHacked=Sound'Voices_Multi_Coop_AI.Play_AI_FilesDownloaded'
     m_sndEscortingHostage=Sound'Voices_Multi_Coop_AI.Play_AI_Escorting'
     m_sndHostageSecured=Sound'Voices_Multi_Coop_AI.Play_AI_HostageSecured'
     m_sndPlacingExplosives=Sound'Voices_Multi_Coop_AI.Play_AI_PlacingExplosives'
     m_sndExplosivesReady=Sound'Voices_Multi_Coop_AI.Play_AI_ExplosivesReady'
     m_sndSecurityDeactivated=Sound'Voices_Multi_Coop_AI.Play_AI_SecurityDeactivated'
}
