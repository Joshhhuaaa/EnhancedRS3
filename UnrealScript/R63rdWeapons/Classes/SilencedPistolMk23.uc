//============================================================================//
//  SilencedPistolMk23.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedPistolMk23 extends PistolMk23;

defaultproperties
{
     m_iClipCapacity=12
     m_iNbOfClips=4
     m_iNbOfExtraClips=6
     m_fMuzzleVelocity=27000.000000
     m_MuzzleScale=0.341273
     m_fFireSoundRadius=270.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo45calAutoSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.425768,fShuffleAccuracy=1.996195,fWalkingAccuracy=2.495244,fWalkingFastAccuracy=10.292881,fRunningAccuracy=10.292881,fReticuleTime=1.171813,fAccuracyChange=8.306504,fWeaponJump=8.542969)
     m_bIsSilenced=True
     m_fFPBlend=0.612120
     m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
     m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
     m_ReloadSnd=Sound'Pistol_MK23_Reloads.Play_MK23_Reload'
     m_ReloadEmptySnd=Sound'Pistol_MK23_Reloads.Play_MK23_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Pistol_MK23_Silenced.Play_MK23Sil_SingleShots'
     m_EmptyMagSnd=Sound'Pistol_MK23_Reloads.Play_MK23_Chamber'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerPistol"
}
