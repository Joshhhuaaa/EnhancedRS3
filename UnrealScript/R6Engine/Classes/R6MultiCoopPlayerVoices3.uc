class R6MultiCoopPlayerVoices3 extends R6MultiCoopVoices;

function Init(Actor aActor)
{
    Super.Init(aActor);
	aActor.AddSoundBankName("Voices_Multi_Coop_Team3");
}

defaultproperties
{
     m_sndPlacingBug=Sound'Voices_Multi_Coop_Team3.Play_Team3_PlacingBug'
     m_sndBugActivated=Sound'Voices_Multi_Coop_Team3.Play_Team3_BugActivated'
     m_sndAccessingComputer=Sound'Voices_Multi_Coop_Team3.Play_Team3_AccessingComputer'
     m_sndComputerHacked=Sound'Voices_Multi_Coop_Team3.Play_Team3_FilesDownloaded'
     m_sndEscortingHostage=Sound'Voices_Multi_Coop_Team3.Play_Team3_Escorting'
     m_sndHostageSecured=Sound'Voices_Multi_Coop_Team3.Play_Team3_HostageSecured'
     m_sndPlacingExplosives=Sound'Voices_Multi_Coop_Team3.Play_Team3_PlacingExplosives'
     m_sndExplosivesReady=Sound'Voices_Multi_Coop_Team3.Play_Team3_ExplosivesReady'
}
