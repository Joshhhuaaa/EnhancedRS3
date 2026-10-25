//============================================================================//
//  NormalPistolUSP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalPistolUSP extends PistolUSP;

defaultproperties
{
     m_iClipCapacity=13
     m_iNbOfClips=4
     m_iNbOfExtraClips=6
     m_fMuzzleVelocity=20400.000000
     m_MuzzleScale=0.322973
     m_fFireSoundRadius=1360.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo40calAutoNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.691747,fShuffleAccuracy=1.544031,fWalkingAccuracy=1.930038,fWalkingFastAccuracy=7.961408,fRunningAccuracy=7.961408,fReticuleTime=0.859250,fAccuracyChange=9.521252,fWeaponJump=17.566099)
     m_fFPBlend=0.202439
     m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
     m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
     m_ReloadSnd=Sound'Pistol_USP_Reloads.Play_USP_Reload'
     m_ReloadEmptySnd=Sound'Pistol_USP_Reloads.Play_USP_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Pistol_USP.Play_USP_SingleShots'
     m_EmptyMagSnd=Sound'Pistol_USP_Reloads.Play_USP_Chamber'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szTacticalLightClass="R6WeaponGadgets.R63rdTACPistol"
}
