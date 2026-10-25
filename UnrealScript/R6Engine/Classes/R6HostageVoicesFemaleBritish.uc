class R6HostageVoicesFemaleBritish extends R6HostageVoices;

function Init(Actor aActor)
{
    Super.Init(aActor);
    aActor.AddSoundBankName("Voices_F_Host_BR");
}

defaultproperties
{
     m_sndRun=Sound'Voices_F_Host_BR.Play_F_BrAcc_WithRnb_Terro'
     m_sndFrozen=Sound'Voices_F_Host_BR.Play_F_BrAcc_WithRnbNoTerro'
     m_sndFoetal=Sound'Voices_F_Host_BR.Play_F_BrAcc_TerroSeeRnb'
     m_sndHears_Shooting=Sound'Voices_F_Host_BR.Play_F_BrAcc_HearShot'
     m_sndRnbFollow=Sound'Voices_F_Host_BR.Play_F_BrAcc_RnbFollow'
     m_sndRndStayPut=Sound'Voices_F_Host_BR.Play_F_BrAcc_StayPut'
     m_sndRnbHurt=Sound'Voices_F_Host_BR.Play_F_BrAcc_RnbHurt'
     m_sndEntersGas=Sound'Voices_F_Host_BR.Play_F_BrAcc_GasGaggs'
}
