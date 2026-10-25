class R6TerroristVoicesGerman1 extends R6TerroristVoices;

function Init(Actor aActor)
{
    Super.Init(aActor);
    aActor.AddSoundBankName("Voices_Terro_German01");
}

defaultproperties
{
     m_sndWounded=Sound'Voices_Terro_German01.02_GmAcc_TerroWounded'
     m_sndTaunt=Sound'Voices_Terro_German01.02_GmAcc_TerroTaunt'
     m_sndSurrender=Sound'Voices_Terro_German01.02_GmAcc_TerroSurrender'
     m_sndSeesTearGas=Sound'Voices_Terro_German01.02_GmAcc_TerroSeesTearGas'
     m_sndRunAway=Sound'Voices_Terro_German01.02_GmAcc_TerroRunAway'
     m_sndGrenade=Sound'Voices_Terro_German01.02_GmAcc_TerroGrenade'
     m_sndCoughsGas=Sound'Voices_Terro_German01.02_GmAcc_TerroCoughsGas'
     m_sndBackup=Sound'Voices_Terro_German01.02_GmAcc_TerroBackup'
     m_sndSeesRainbow_LowAlert=Sound'Voices_Terro_German01.02_GmAcc_SeesRainbow_LowAlert'
     m_sndSeesRainbow_HighAlert=Sound'Voices_Terro_German01.02_GmAcc_SeesRainbow_HighAler'
     m_sndSeesFreeHostage=Sound'Voices_Terro_German01.02_GmAcc_SeesFreeHostage'
     m_sndHearsNoize=Sound'Voices_Terro_German01.02_GmAcc_HearsNoize'
}
