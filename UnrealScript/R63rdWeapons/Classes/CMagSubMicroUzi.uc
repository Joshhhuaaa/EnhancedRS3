//============================================================================//
//  CMagSubMicroUzi.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class CMagSubMicroUzi extends SubMicroUzi;

defaultproperties
{
     m_iClipCapacity=50
     m_iNbOfClips=4
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=21000.000000
     m_MuzzleScale=0.460559
     m_fFireSoundRadius=1400.000000
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.786834,fShuffleAccuracy=1.837115,fWalkingAccuracy=2.755673,fWalkingFastAccuracy=11.367151,fRunningAccuracy=11.367151,fReticuleTime=0.292000,fAccuracyChange=7.703099,fWeaponJump=7.810928)
     m_fFPBlend=0.380184
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Mult_UziPistol_Reloads.Play_UZIPistol_Reload'
     m_ReloadEmptySnd=Sound'Mult_UziPistol_Reloads.Play_UZIPistol_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Mult_UziPistol.Play_UziPistol_SingleShots'
     m_FullAutoStereoSnd=Sound'Mult_UziPistol.Play_UziPistol_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Mult_UziPistol.Stop_UziPistol_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG9mmHigh"
}
