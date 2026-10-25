class R6MultiCoopPlayerVoices1 extends R6MultiCoopVoices;

function Init(Actor aActor)
{
    Super.Init(aActor);
	aActor.AddSoundBankName("Voices_Multi_Coop_Team1");
}

defaultproperties
{
     m_sndPlacingBug=Sound'Voices_Multi_Coop_Team1.Play_Team1_PlacingBug'
     m_sndBugActivated=Sound'Voices_Multi_Coop_Team1.Play_Team1_BugActivated'
     m_sndAccessingComputer=Sound'Voices_Multi_Coop_Team1.Play_Team1_AccessingComputer'
     m_sndComputerHacked=Sound'Voices_Multi_Coop_Team1.Play_Team1_FilesDownloaded'
     m_sndEscortingHostage=Sound'Voices_Multi_Coop_Team1.Play_Team1_Escorting'
     m_sndHostageSecured=Sound'Voices_Multi_Coop_Team1.Play_Team1_HostageSecured'
     m_sndPlacingExplosives=Sound'Voices_Multi_Coop_Team1.Play_Team1_PlacingExplosives'
     m_sndExplosivesReady=Sound'Voices_Multi_Coop_Team1.Play_Team1_ExplosivesReady'
     m_sndSecurityDeactivated=Sound'Voices_Multi_Coop_Team1.Play_Team1_SecurityDeactivated'
}
