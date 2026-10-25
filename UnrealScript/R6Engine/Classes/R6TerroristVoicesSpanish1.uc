class R6TerroristVoicesSpanish1 extends R6TerroristVoices;

function Init(Actor aActor)
{
    Super.Init(aActor);
    aActor.AddSoundBankName("Voices_Terro_Spanish01");
}

defaultproperties
{
     m_sndWounded=Sound'Voices_Terro_Spanish01.01_SpAcc_TerroWounded'
     m_sndTaunt=Sound'Voices_Terro_Spanish01.01_SpAcc_TerroTaunt'
     m_sndSurrender=Sound'Voices_Terro_Spanish01.01_SpAcc_TerroSurrender'
     m_sndSeesTearGas=Sound'Voices_Terro_Spanish01.01_SpAcc_TerroSeesTearGas'
     m_sndRunAway=Sound'Voices_Terro_Spanish01.01_SpAcc_TerroRunAway'
     m_sndGrenade=Sound'Voices_Terro_Spanish01.01_SpAcc_TerroGrenade'
     m_sndCoughsGas=Sound'Voices_Terro_Spanish01.01_SpAcc_TerroCoughsGas'
     m_sndBackup=Sound'Voices_Terro_Spanish01.01_SpAcc_TerroBackup'
     m_sndSeesRainbow_LowAlert=Sound'Voices_Terro_Spanish01.01_SpAcc_SeesRainbow_LowAlert'
     m_sndSeesRainbow_HighAlert=Sound'Voices_Terro_Spanish01.01_SpAcc_SeesRainbow_HighAler'
     m_sndSeesFreeHostage=Sound'Voices_Terro_Spanish01.01_SpAcc_SeesFreeHostage'
     m_sndHearsNoize=Sound'Voices_Terro_Spanish01.01_SpAcc_HearsNoize'
}
