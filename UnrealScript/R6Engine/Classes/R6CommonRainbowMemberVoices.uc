class R6CommonRainbowMemberVoices extends R6CommonRainbowVoices;

function Init(Actor aActor)
{
    Super.Init(aActor);
	aActor.AddSoundBankName("Voices_Common_3rd");
}

defaultproperties
{
     m_sndTerroristDown=Sound'Voices_Common_3rd.Play_3rd_TerroDown'
     m_sndTakeWound=Sound'Voices_Common_3rd.Play_3rd_Wounded'
     m_sndGoesDown=Sound'Voices_Common_3rd.Play_3rd_GoDown'
     m_sndEntersGas=Sound'Voices_Common_3rd.Play_3rd_Gagging'
}
