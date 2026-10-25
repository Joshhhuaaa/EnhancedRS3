class R6HostageVoicesMaleBritish extends R6HostageVoices;

function Init(Actor aActor)
{
    Super.Init(aActor);
    aActor.AddSoundBankName("Voices_M_Host_BR");
}

defaultproperties
{
     m_sndRun=Sound'Voices_M_Host_BR.Play_M_BrAcc_WithRnb_Terro'
     m_sndFrozen=Sound'Voices_M_Host_BR.Play_M_BrAcc_WithRnbNoTerro'
     m_sndFoetal=Sound'Voices_M_Host_BR.Play_M_BrAcc_TerroSeeRnb'
     m_sndHears_Shooting=Sound'Voices_M_Host_BR.Play_M_BrAcc_HearShot'
     m_sndRnbFollow=Sound'Voices_M_Host_BR.Play_M_BrAcc_RnbFollow'
     m_sndRndStayPut=Sound'Voices_M_Host_BR.Play_M_BrAcc_StayPut'
     m_sndRnbHurt=Sound'Voices_M_Host_BR.Play_M_BrAcc_RnbHurt'
     m_sndEntersGas=Sound'Voices_M_Host_BR.Play_M_BrAcc_GasGaggs'
}
