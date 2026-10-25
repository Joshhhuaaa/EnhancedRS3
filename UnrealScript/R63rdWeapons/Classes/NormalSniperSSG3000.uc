//============================================================================//
//  NormalSniperSSG3000.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalSniperSSG3000 extends SniperSSG3000;

defaultproperties
{
     m_iClipCapacity=5
     m_iNbOfClips=6
     m_iNbOfExtraClips=4
     m_fMuzzleVelocity=45000.000000
     m_MuzzleScale=0.739453
     m_fFireSoundRadius=3000.000000
     m_fRateOfFire=0.861250
     m_szReticuleClass="SNIPER"
     m_pBulletClass=Class'R6Weapons.ammo762mmNATONormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.490302,fShuffleAccuracy=2.742608,fWalkingAccuracy=4.113911,fWalkingFastAccuracy=16.969885,fRunningAccuracy=16.969885,fReticuleTime=3.229687,fAccuracyChange=2.919733,fWeaponJump=9.235731)
     m_fFPBlend=0.723122
     m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
     m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
     m_ReloadSnd=Sound'Sniper_SSG3000_Reloads.Play_SSG3000_Reload'
     m_ReloadEmptySnd=Sound'Sniper_SSG3000_Reloads.Play_SSG3000_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Sniper_SSG3000.Play_SSG3000_SingleShots'
     m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG762mm"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault762"
}
