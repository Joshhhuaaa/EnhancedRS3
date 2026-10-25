//============================================================================//
//  CMagSubSR2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class CMagSubSR2 extends SubSR2;

defaultproperties
{
     m_iClipCapacity=50
     m_iNbOfClips=4
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=25200.000000
     m_MuzzleScale=0.485801
     m_fFireSoundRadius=1680.000000
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo9x21mmRNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.617631,fShuffleAccuracy=2.057080,fWalkingAccuracy=3.085619,fWalkingFastAccuracy=12.728181,fRunningAccuracy=12.728181,fReticuleTime=0.376000,fAccuracyChange=7.361363,fWeaponJump=7.197808)
     m_fFPBlend=0.428837
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Mult_SR2MP_Reloads.Play_SR2MP_Reload'
     m_ReloadEmptySnd=Sound'Mult_SR2MP_Reloads.Play_SR2MP_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Mult_SR2MP.Play_SR2MP_SingleShots'
     m_FullAutoStereoSnd=Sound'Mult_SR2MP.Play_SR2MP_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Mult_SR2MP.Stop_SR2MP_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG9mmHigh"
}
