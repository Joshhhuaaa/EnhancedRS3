//============================================================================//
//  NormalPistolMicroUzi.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalPistolMicroUzi extends PistolMicroUzi;

defaultproperties
{
     m_iClipCapacity=20
     m_iNbOfClips=3
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=20700.000000
     m_MuzzleScale=0.610842
     m_fFireSoundRadius=1380.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=2.011181,fShuffleAccuracy=2.530992,fWalkingAccuracy=3.163740,fWalkingFastAccuracy=13.050429,fRunningAccuracy=13.050429,fReticuleTime=1.091187,fAccuracyChange=8.923948,fWeaponJump=8.832469)
     m_fFPBlend=0.299123
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Mult_UziPistol_Reloads.Play_UZIPistol_Reload'
     m_ReloadEmptySnd=Sound'Mult_UziPistol_Reloads.Play_UZIPistol_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Mult_UziPistol.Play_UziPistol_SingleShots'
     m_FullAutoStereoSnd=Sound'Mult_UziPistol.Play_UziPistol_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Mult_UziPistol.Stop_UziPistol_AutoShots_Go'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szTacticalLightClass="R6WeaponGadgets.R63rdTACPistol"
}
