//============================================================================//
//  SilencedSniperWA2000.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSniperWA2000 extends SniperWA2000;

defaultproperties
{
     m_iClipCapacity=6
     m_iNbOfClips=5
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=30000.000000
     m_MuzzleScale=0.358359
     m_fFireSoundRadius=300.000000
     m_fRateOfFire=0.983750
     m_szReticuleClass="SNIPER"
     m_pBulletClass=Class'R6Weapons.ammo30calMagnumSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.514205,fShuffleAccuracy=2.711534,fWalkingAccuracy=4.067301,fWalkingFastAccuracy=16.777617,fRunningAccuracy=16.777617,fReticuleTime=3.689063,fAccuracyChange=3.012236,fWeaponJump=2.282404)
     m_bIsSilenced=True
     m_fFPBlend=0.931576
     m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
     m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
     m_ReloadSnd=Sound'Sniper_WA2000_Reloads.Play_WA2000_Reload'
     m_ReloadEmptySnd=Sound'Sniper_WA2000_Reloads.Play_WA2000_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Sniper_WA2000_Silenced.Play_WA2000Sil_SingleShots'
     m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG762mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerWA2000"
}
