class NormalSniperSL82 extends SniperSL82;

#exec OBJ LOAD FILE=..\Sounds\CommonSniper.uax PACKAGE=CommonSniper
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Sniper_SL8_2_Reloads.uax PACKAGE=MP1_Sniper_SL8_2_Reloads
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Sniper_SL8_2.uax PACKAGE=MP1_Sniper_SL8_2

defaultproperties
{
    m_iClipCapacity=10
    m_iNbOfClips=3
    m_iNbOfExtraClips=2
    m_fMuzzleVelocity=55200.0
    m_MuzzleScale=1.0
    m_fFireSoundRadius=3680.0
    m_fRateOfFire=0.700833
    m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
    m_stAccuracyValues=(fBaseAccuracy=0.7228632,fShuffleAccuracy=2.4402778,fWalkingAccuracy=3.6604168,fWalkingFastAccuracy=15.099219,fRunningAccuracy=15.099219,fReticuleTime=2.628125,fAccuracyChange=3.8197448,fWeaponJump=8.464)
    m_szReticuleClass="SNIPER"
    m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
    m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
    m_ReloadSnd=Sound'MP1_Sniper_SL8_2_Reloads.Play_HKSL8_Reload'
    m_ReloadEmptySnd=Sound'MP1_Sniper_SL8_2_Reloads.Play_HKSL8_EmptyMag'
    m_SingleFireStereoSnd=Sound'MP1_Sniper_SL8_2.Play_HKSL8_SingleShots'
    m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
    m_szMagazineClass="ASWeapons.R63rdMAGSL82"
}
