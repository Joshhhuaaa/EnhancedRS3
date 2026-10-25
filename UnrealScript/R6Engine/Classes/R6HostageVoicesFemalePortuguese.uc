class R6HostageVoicesFemalePortuguese extends R6HostageVoices;

function Init(Actor aActor)
{
    Super.Init(aActor);
    aActor.AddSoundBankName("Voices_F_Host_PR");
}

defaultproperties
{
     m_sndRun=Sound'Voices_F_Host_PR.Play_F_PrAcc_WithRnb_Terro'
     m_sndFrozen=Sound'Voices_F_Host_PR.Play_F_PrAcc_WithRnbNoTerro'
     m_sndFoetal=Sound'Voices_F_Host_PR.Play_F_PrAcc_TerroSeeRnb'
     m_sndHears_Shooting=Sound'Voices_F_Host_PR.Play_F_PrAcc_HearShot'
     m_sndRnbFollow=Sound'Voices_F_Host_PR.Play_F_PrAcc_RnbFollow'
     m_sndRndStayPut=Sound'Voices_F_Host_PR.Play_F_PrAcc_StayPut'
     m_sndRnbHurt=Sound'Voices_F_Host_PR.Play_F_PrAcc_RnbHurt'
     m_sndEntersGas=Sound'Voices_F_Host_PR.Play_F_PrAcc_GasGaggs'
}
