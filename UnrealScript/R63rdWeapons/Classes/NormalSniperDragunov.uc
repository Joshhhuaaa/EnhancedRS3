//============================================================================//
//  NormalSniperDragunov.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalSniperDragunov extends SniperDragunov;

defaultproperties
{
     m_iClipCapacity=10
     m_iNbOfClips=3
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=48600.000000
     m_MuzzleScale=1.000000
     m_fFireSoundRadius=3240.000000
     m_fRateOfFire=0.730000
     m_szReticuleClass="SNIPER"
     m_pBulletClass=Class'R6Weapons.ammo762x54mmRNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.432064,fShuffleAccuracy=2.818317,fWalkingAccuracy=4.227475,fWalkingFastAccuracy=17.438335,fRunningAccuracy=17.438335,fReticuleTime=2.737500,fAccuracyChange=2.694351,fWeaponJump=25.085356)
     m_fFPBlend=0.247965
     m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
     m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
     m_ReloadSnd=Sound'Sniper_Dragunov_Reloads.Play_Dragunov_Reload'
     m_ReloadEmptySnd=Sound'Sniper_Dragunov_Reloads.Play_Dragunov_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Sniper_Dragunov.Play_Dragunov_SingleShots'
     m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGDragunov"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault762"
}
