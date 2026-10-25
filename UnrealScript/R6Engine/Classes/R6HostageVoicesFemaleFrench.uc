class R6HostageVoicesFemaleFrench extends R6HostageVoices;

function Init(Actor aActor)
{
    Super.Init(aActor);
    aActor.AddSoundBankName("Voices_F_Host_FR");
}

defaultproperties
{
     m_sndRun=Sound'Voices_F_Host_FR.Play_F_FrAcc_WithRnb_Terro'
     m_sndFrozen=Sound'Voices_F_Host_FR.Play_F_FrAcc_WithRnbNoTerro'
     m_sndFoetal=Sound'Voices_F_Host_FR.Play_F_FrAcc_TerroSeeRnb'
     m_sndHears_Shooting=Sound'Voices_F_Host_FR.Play_F_FrAcc_HearShot'
     m_sndRnbFollow=Sound'Voices_F_Host_FR.Play_F_FrAcc_RnbFollow'
     m_sndRndStayPut=Sound'Voices_F_Host_FR.Play_F_FrAcc_StayPut'
     m_sndRnbHurt=Sound'Voices_F_Host_FR.Play_F_FrAcc_RnbHurt'
     m_sndEntersGas=Sound'Voices_F_Host_FR.Play_F_FrAcc_GasGaggs'
}
