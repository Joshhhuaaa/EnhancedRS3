//============================================================================//
//  SilencedSniperM82A1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSniperM82A1 extends SniperM82A1;

defaultproperties
{
     m_iClipCapacity=10
     m_iNbOfClips=3
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=30000.000000
     m_MuzzleScale=0.820313
     m_fFireSoundRadius=300.000000
     m_fRateOfFire=1.712000
     m_szReticuleClass="SNIPER"
     m_pBulletClass=Class'R6Weapons.ammo50calM33SubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.026257,fShuffleAccuracy=3.345866,fWalkingAccuracy=5.018800,fWalkingFastAccuracy=20.702549,fRunningAccuracy=20.702549,fReticuleTime=6.420000,fAccuracyChange=1.123877,fWeaponJump=4.431169)
     m_bIsSilenced=True
     m_fFPBlend=0.867158
     m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
     m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
     m_ReloadSnd=Sound'Sniper_M82A1_Reloads.Play_M82A1_Reload'
     m_ReloadEmptySnd=Sound'Sniper_M82A1_Reloads.Play_M82A1_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Sniper_M82A1_Silenced.Play_M82A1Sil_SingleShots'
     m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGM82A1"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerM82A1"
}
