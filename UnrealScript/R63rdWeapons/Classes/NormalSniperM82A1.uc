//============================================================================//
//  NormalSniperM82A1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalSniperM82A1 extends SniperM82A1;

defaultproperties
{
     m_iClipCapacity=10
     m_iNbOfClips=3
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=51180.000000
     m_MuzzleScale=1.000000
     m_fFireSoundRadius=4000.000000
     m_fRateOfFire=1.581417
     m_szReticuleClass="SNIPER"
     m_pBulletClass=Class'R6Weapons.ammo50calM33NormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.263992,fShuffleAccuracy=3.036810,fWalkingAccuracy=4.555215,fWalkingFastAccuracy=18.790260,fRunningAccuracy=18.790260,fReticuleTime=5.930313,fAccuracyChange=2.043915,fWeaponJump=33.356628)
     m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
     m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
     m_ReloadSnd=Sound'Sniper_M82A1_Reloads.Play_M82A1_Reload'
     m_ReloadEmptySnd=Sound'Sniper_M82A1_Reloads.Play_M82A1_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Sniper_M82A1.Play_M82A1_SingleShots'
     m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGM82A1"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleM82A1"
}
