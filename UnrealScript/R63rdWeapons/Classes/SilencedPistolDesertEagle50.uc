//============================================================================//
//  SilencedPistolDesertEagle50.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedPistolDesertEagle50 extends PistolDesertEagle50;

defaultproperties
{
     m_iClipCapacity=7
     m_iNbOfClips=4
     m_iNbOfExtraClips=6
     m_fMuzzleVelocity=28500.000000
     m_MuzzleScale=0.446557
     m_fFireSoundRadius=285.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo50calPistolSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.397546,fShuffleAccuracy=2.044172,fWalkingAccuracy=2.555215,fWalkingFastAccuracy=10.540263,fRunningAccuracy=10.540263,fReticuleTime=1.595438,fAccuracyChange=8.293940,fWeaponJump=10.048271)
     m_bIsSilenced=True
     m_fFPBlend=0.543774
     m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
     m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
     m_ReloadSnd=Sound'Pistol_Des50_Reloads.Play_Des50_Reload'
     m_ReloadEmptySnd=Sound'Pistol_Des50_Reloads.Play_Des50_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Pistol_Des50_Silenced.Play_Des50Sil_SingleShots'
     m_EmptyMagSnd=Sound'Pistol_Des50_Reloads.Play_Des50_Chamber'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerPistol"
}
