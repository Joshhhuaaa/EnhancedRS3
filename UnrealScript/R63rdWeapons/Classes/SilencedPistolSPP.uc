//============================================================================//
//  SilencedPistolSPP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedPistolSPP extends PistolSPP;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=2
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=28500.000000
     m_MuzzleScale=0.296012
     m_fFireSoundRadius=285.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.708456,fShuffleAccuracy=3.045625,fWalkingAccuracy=3.807032,fWalkingFastAccuracy=15.704006,fRunningAccuracy=15.704006,fReticuleTime=1.196375,fAccuracyChange=7.785405,fWeaponJump=6.117633)
     m_bIsSilenced=True
     m_fFPBlend=0.722239
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Pistol_SPP_Reloads.Play_SPP_Reload'
     m_ReloadEmptySnd=Sound'Pistol_SPP_Reloads.Play_SPP_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Sub_TMP_Silenced.Play_TMPSil_SingleShots'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
