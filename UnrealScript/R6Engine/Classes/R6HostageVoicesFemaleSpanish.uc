class R6HostageVoicesFemaleSpanish extends R6HostageVoices;

function Init(Actor aActor)
{
    Super.Init(aActor);
    aActor.AddSoundBankName("Voices_F_Host_SP");
}

defaultproperties
{
     m_sndRun=Sound'Voices_F_Host_SP.Play_F_SpAcc_WithRnb_Terro'
     m_sndFrozen=Sound'Voices_F_Host_SP.Play_F_SpAcc_WithRnbNoTerro'
     m_sndFoetal=Sound'Voices_F_Host_SP.Play_F_SpAcc_TerroSeeRnb'
     m_sndHears_Shooting=Sound'Voices_F_Host_SP.Play_F_SpAcc_HearShot'
     m_sndRnbFollow=Sound'Voices_F_Host_SP.Play_F_SpAcc_RnbFollow'
     m_sndRndStayPut=Sound'Voices_F_Host_SP.Play_F_SpAcc_StayPut'
     m_sndRnbHurt=Sound'Voices_F_Host_SP.Play_F_SpAcc_RnbHurt'
     m_sndEntersGas=Sound'Voices_F_Host_SP.Play_F_SpAcc_GasGaggs'
}
