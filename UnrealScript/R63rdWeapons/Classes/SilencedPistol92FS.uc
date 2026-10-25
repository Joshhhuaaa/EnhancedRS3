//============================================================================//
//  SilencedPistol92FS.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedPistol92FS extends Pistol92FS;

defaultproperties
{
     m_iClipCapacity=15
     m_iNbOfClips=4
     m_iNbOfExtraClips=6
     m_fMuzzleVelocity=28500.000000
     m_MuzzleScale=0.296012
     m_fFireSoundRadius=285.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.434409,fShuffleAccuracy=1.981504,fWalkingAccuracy=2.476880,fWalkingFastAccuracy=10.217129,fRunningAccuracy=10.217129,fReticuleTime=1.094187,fAccuracyChange=8.254955,fWeaponJump=7.506201)
     m_bIsSilenced=True
     m_fFPBlend=0.659193
     m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
     m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
     m_ReloadSnd=Sound'Pistol_92FS_Reloads.Play_92FS_Reload'
     m_ReloadEmptySnd=Sound'Pistol_92FS_Reloads.Play_92FS_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Pistol_92FS_Silenced.Play_92FSSil_SingleShots'
     m_EmptyMagSnd=Sound'Pistol_92FS_Reloads.Play_92FS_Chamber'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerPistol"
}
