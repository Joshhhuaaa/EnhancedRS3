//============================================================================//
//  SilencedSubMicroUzi.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSubMicroUzi extends SubMicroUzi;

defaultproperties
{
     m_iClipCapacity=32
     m_iNbOfClips=7
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=28500.000000
     m_MuzzleScale=0.296012
     m_fFireSoundRadius=285.000000
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.545136,fShuffleAccuracy=2.151323,fWalkingAccuracy=3.226984,fWalkingFastAccuracy=13.311310,fRunningAccuracy=13.311310,fReticuleTime=0.396250,fAccuracyChange=6.578284,fWeaponJump=6.584770)
     m_bIsSilenced=True
     m_fFPBlend=0.477483
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Mult_UziPistol_Reloads.Play_UZIPistol_Reload'
     m_ReloadEmptySnd=Sound'Mult_UziPistol_Reloads.Play_UZIPistol_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Mult_UziPistol_Silenced.Play_UziPistol_Sil_SingleShots'
     m_FullAutoStereoSnd=Sound'Mult_UziPistol_Silenced.Play_UziPistol_Sil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Mult_UziPistol_Silenced.Stop_UziPistol_Sil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG9mmStraight"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
