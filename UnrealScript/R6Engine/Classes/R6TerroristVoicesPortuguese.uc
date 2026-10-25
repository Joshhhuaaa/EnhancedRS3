class R6TerroristVoicesPortuguese extends R6TerroristVoices;

function Init(Actor aActor)
{
    Super.Init(aActor);
    aActor.AddSoundBankName("Voices_Terro_Portuguese01");
}

defaultproperties
{
     m_sndWounded=Sound'Voices_Terro_Portuguese01.08_PrAcc_TerroWounded'
     m_sndTaunt=Sound'Voices_Terro_Portuguese01.08_PrAcc_TerroTaunt'
     m_sndSurrender=Sound'Voices_Terro_Portuguese01.08_PrAcc_TerroSurrender'
     m_sndSeesTearGas=Sound'Voices_Terro_Portuguese01.08_PrAcc_TerroSeesTearGas'
     m_sndRunAway=Sound'Voices_Terro_Portuguese01.08_PrAcc_TerroRunAway'
     m_sndGrenade=Sound'Voices_Terro_Portuguese01.08_PrAcc_TerroGrenade'
     m_sndCoughsGas=Sound'Voices_Terro_Portuguese01.08_PrAcc_TerroCoughsGas'
     m_sndBackup=Sound'Voices_Terro_Portuguese01.08_PrAcc_TerroBackup'
     m_sndSeesRainbow_LowAlert=Sound'Voices_Terro_Portuguese01.08_PrAcc_SeesRainbow_LowAlert'
     m_sndSeesRainbow_HighAlert=Sound'Voices_Terro_Portuguese01.08_PrAcc_SeesRainbow_HighAler'
     m_sndSeesFreeHostage=Sound'Voices_Terro_Portuguese01.08_PrAcc_SeesFreeHostage'
     m_sndHearsNoize=Sound'Voices_Terro_Portuguese01.08_PrAcc_HearsNoize'
}
