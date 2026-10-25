//============================================================================//
//  NormalPistol92FS.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalPistol92FS extends Pistol92FS;

defaultproperties
{
     m_iClipCapacity=15
     m_iNbOfClips=4
     m_iNbOfExtraClips=6
     m_fMuzzleVelocity=23400.000000
     m_MuzzleScale=0.320822
     m_fFireSoundRadius=1560.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.627617,fShuffleAccuracy=1.653051,fWalkingAccuracy=2.066314,fWalkingFastAccuracy=8.523544,fRunningAccuracy=8.523544,fReticuleTime=0.922063,fAccuracyChange=9.264375,fWeaponJump=14.164312)
     m_fFPBlend=0.356892
     m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
     m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
     m_ReloadSnd=Sound'Pistol_92FS_Reloads.Play_92FS_Reload'
     m_ReloadEmptySnd=Sound'Pistol_92FS_Reloads.Play_92FS_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Pistol_92FS.Play_92FS_SingleShots'
     m_EmptyMagSnd=Sound'Pistol_92FS_Reloads.Play_92FS_Chamber'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szTacticalLightClass="R6WeaponGadgets.R63rdTACPistol"
}
