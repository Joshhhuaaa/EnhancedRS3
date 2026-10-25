//============================================================================//
//  SilencedPistolUSP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedPistolUSP extends PistolUSP;

defaultproperties
{
     m_iClipCapacity=13
     m_iNbOfClips=4
     m_iNbOfExtraClips=6
     m_fMuzzleVelocity=28500.000000
     m_MuzzleScale=0.321140
     m_fFireSoundRadius=285.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo40calAutoSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.498539,fShuffleAccuracy=1.872483,fWalkingAccuracy=2.340604,fWalkingFastAccuracy=9.654993,fRunningAccuracy=9.654993,fReticuleTime=1.031375,fAccuracyChange=8.705901,fWeaponJump=10.645995)
     m_bIsSilenced=True
     m_fFPBlend=0.516635
     m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
     m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
     m_ReloadSnd=Sound'Pistol_USP_Reloads.Play_USP_Reload'
     m_ReloadEmptySnd=Sound'Pistol_USP_Reloads.Play_USP_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Pistol_USP_Silenced.Play_USPSil_SingleShots'
     m_EmptyMagSnd=Sound'Pistol_USP_Reloads.Play_USP_Chamber'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerPistol"
}
