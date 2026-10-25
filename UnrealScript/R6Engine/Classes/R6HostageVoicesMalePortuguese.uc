class R6HostageVoicesMalePortuguese extends R6HostageVoices;

function Init(Actor aActor)
{
    Super.Init(aActor);
    aActor.AddSoundBankName("Voices_M_Host_PR");
}

defaultproperties
{
     m_sndRun=Sound'Voices_M_Host_PR.Play_M_PrAcc_WithRnb_Terro'
     m_sndFrozen=Sound'Voices_M_Host_PR.Play_M_PrAcc_WithRnbNoTerro'
     m_sndFoetal=Sound'Voices_M_Host_PR.Play_M_PrAcc_TerroSeeRnb'
     m_sndHears_Shooting=Sound'Voices_M_Host_PR.Play_M_PrAcc_HearShot'
     m_sndRnbFollow=Sound'Voices_M_Host_PR.Play_M_PrAcc_RnbFollow'
     m_sndRndStayPut=Sound'Voices_M_Host_PR.Play_M_PrAcc_StayPut'
     m_sndRnbHurt=Sound'Voices_M_Host_PR.Play_M_PrAcc_RnbHurt'
     m_sndEntersGas=Sound'Voices_M_Host_PR.Play_M_PrAcc_GasGaggs'
}
