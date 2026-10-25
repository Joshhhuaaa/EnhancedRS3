class R6MultiCoopPlayerVoices2 extends R6MultiCoopVoices;

function Init(Actor aActor)
{
    Super.Init(aActor);
	aActor.AddSoundBankName("Voices_Multi_Coop_Team2");
}

defaultproperties
{
     m_sndPlacingBug=Sound'Voices_Multi_Coop_Team2.Play_Team2_PlacingBug'
     m_sndBugActivated=Sound'Voices_Multi_Coop_Team2.Play_Team2_BugActivated'
     m_sndAccessingComputer=Sound'Voices_Multi_Coop_Team2.Play_Team2_AccessingComputer'
     m_sndComputerHacked=Sound'Voices_Multi_Coop_Team2.Play_Team2_FilesDownloaded'
     m_sndEscortingHostage=Sound'Voices_Multi_Coop_Team2.Play_Team2_Escorting'
     m_sndHostageSecured=Sound'Voices_Multi_Coop_Team2.Play_Team2_HostageSecured'
     m_sndPlacingExplosives=Sound'Voices_Multi_Coop_Team2.Play_Team2_PlacingExplosives'
     m_sndExplosivesReady=Sound'Voices_Multi_Coop_Team2.Play_Team2_ExplosivesReady'
}
