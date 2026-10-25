//============================================================================//
//  NormalPistolSR2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalPistolSR2 extends PistolSR2;

defaultproperties
{
     m_iClipCapacity=20
     m_iNbOfClips=3
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=25200.000000
     m_MuzzleScale=0.647735
     m_fFireSoundRadius=1680.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo9x21mmRNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.837456,fShuffleAccuracy=2.826324,fWalkingAccuracy=3.532905,fWalkingFastAccuracy=14.573235,fRunningAccuracy=14.573235,fReticuleTime=1.149500,fAccuracyChange=8.515594,fWeaponJump=9.031177)
     m_fFPBlend=0.283355
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Mult_SR2MP_Reloads.Play_SR2MP_Reload'
     m_ReloadEmptySnd=Sound'Mult_SR2MP_Reloads.Play_SR2MP_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Mult_SR2MP.Play_SR2MP_SingleShots'
     m_FullAutoStereoSnd=Sound'Mult_SR2MP.Play_SR2MP_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Mult_SR2MP.Stop_SR2MP_AutoShots_Go'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
}
