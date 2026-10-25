//============================================================================//
//  SilencedSubUzi.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSubUzi extends SubUzi;

defaultproperties
{
     m_iClipCapacity=32
     m_iNbOfClips=7
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=28500.000000
     m_MuzzleScale=0.272596
     m_fFireSoundRadius=285.000000
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.110021,fShuffleAccuracy=2.456973,fWalkingAccuracy=3.685459,fWalkingFastAccuracy=15.202518,fRunningAccuracy=15.202518,fReticuleTime=0.932875,fAccuracyChange=5.113484,fWeaponJump=2.759866)
     m_bIsSilenced=True
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Mult_Uzi_Reloads.Play_UZI_Reload'
     m_ReloadEmptySnd=Sound'Mult_Uzi_Reloads.Play_UZI_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Mult_Uzi_Silenced.Play_UZI_Sil_SingleShots'
     m_FullAutoStereoSnd=Sound'Mult_Uzi_Silenced.Play_UZI_Sil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Mult_Uzi_Silenced.Stop_UZI_Sil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG9mmStraight"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
