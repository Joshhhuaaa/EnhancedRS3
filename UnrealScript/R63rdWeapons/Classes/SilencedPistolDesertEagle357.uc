//============================================================================//
//  SilencedPistolDesertEagle357.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedPistolDesertEagle357 extends PistolDesertEagle357;

defaultproperties
{
     m_iClipCapacity=9
     m_iNbOfClips=4
     m_iNbOfExtraClips=6
     m_fMuzzleVelocity=28500.000000
     m_MuzzleScale=0.298296
     m_fFireSoundRadius=285.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo357calMagnumSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.378362,fShuffleAccuracy=2.076785,fWalkingAccuracy=2.595981,fWalkingFastAccuracy=10.708421,fRunningAccuracy=10.708421,fReticuleTime=1.251688,fAccuracyChange=7.677244,fWeaponJump=5.252550)
     m_bIsSilenced=True
     m_fFPBlend=0.761516
     m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
     m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
     m_ReloadSnd=Sound'Pistol_Des357_Reloads.Play_Des357_Reload'
     m_ReloadEmptySnd=Sound'Pistol_Des357_Reloads.Play_Des357_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Pistol_Des357_Silenced.Play_Des357Sil_SingleShots'
     m_EmptyMagSnd=Sound'Pistol_Des357_Reloads.Play_Des357_Chamber'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerPistol"
}
