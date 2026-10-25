//============================================================================//
//  CMagPistolMicroUzi.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class CMagPistolMicroUzi extends PistolMicroUzi;

defaultproperties
{
     m_iClipCapacity=32
     m_iNbOfClips=2
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=20700.000000
     m_MuzzleScale=0.610842
     m_fFireSoundRadius=1380.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=2.011181,fShuffleAccuracy=2.530992,fWalkingAccuracy=3.163740,fWalkingFastAccuracy=13.050429,fRunningAccuracy=13.050429,fReticuleTime=1.128688,fAccuracyChange=8.873637,fWeaponJump=8.041384)
     m_fFPBlend=0.361897
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Mult_UziPistol_Reloads.Play_UZIPistol_Reload'
     m_ReloadEmptySnd=Sound'Mult_UziPistol_Reloads.Play_UZIPistol_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Mult_UziPistol.Play_UziPistol_SingleShots'
     m_FullAutoStereoSnd=Sound'Mult_UziPistol.Play_UziPistol_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Mult_UziPistol.Stop_UziPistol_AutoShots_Go'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGPistolHigh"
}
