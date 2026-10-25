//============================================================================//
//  SilencedSniperSSG3000.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSniperSSG3000 extends SniperSSG3000;

defaultproperties
{
     m_iClipCapacity=5
     m_iNbOfClips=6
     m_iNbOfExtraClips=4
     m_fMuzzleVelocity=30000.000000
     m_MuzzleScale=0.351525
     m_fFireSoundRadius=300.000000
     m_fRateOfFire=1.032917
     m_szReticuleClass="SNIPER"
     m_pBulletClass=Class'R6Weapons.ammo762mmNATOSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.194704,fShuffleAccuracy=3.126884,fWalkingAccuracy=4.690326,fWalkingFastAccuracy=19.347597,fRunningAccuracy=19.347597,fReticuleTime=3.873437,fAccuracyChange=1.775770,fWeaponJump=2.257548)
     m_bIsSilenced=True
     m_fFPBlend=0.932321
     m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
     m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
     m_ReloadSnd=Sound'Sniper_SSG3000_Reloads.Play_SSG3000_Reload'
     m_ReloadEmptySnd=Sound'Sniper_SSG3000_Reloads.Play_SSG3000_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Sniper_SSG3000_Silenced.Play_SSG3000Sil_SingleShots'
     m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG762mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSnipers"
}
