//============================================================================//
//  SilencedSubSR2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSubSR2 extends SubSR2;

defaultproperties
{
     m_iClipCapacity=20
     m_iNbOfClips=10
     m_iNbOfExtraClips=4
     m_fMuzzleVelocity=28500.000000
     m_MuzzleScale=0.264029
     m_fFireSoundRadius=285.000000
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo9x21mmRSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.375933,fShuffleAccuracy=2.371287,fWalkingAccuracy=3.556931,fWalkingFastAccuracy=14.672339,fRunningAccuracy=14.672339,fReticuleTime=0.448938,fAccuracyChange=6.093560,fWeaponJump=3.544556)
     m_bIsSilenced=True
     m_fFPBlend=0.718731
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Mult_SR2MP_Reloads.Play_SR2MP_Reload'
     m_ReloadEmptySnd=Sound'Mult_SR2MP_Reloads.Play_SR2MP_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Mult_SR2MP_Silenced.Play_SR2MPSil_SingleShots'
     m_FullAutoStereoSnd=Sound'Mult_SR2MP_Silenced.Play_SR2MPSil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Mult_SR2MP_Silenced.Stop_SR2MPSil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGPistol"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
