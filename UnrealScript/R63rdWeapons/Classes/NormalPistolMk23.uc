//============================================================================//
//  NormalPistolMk23.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalPistolMk23 extends PistolMk23;

defaultproperties
{
     m_iClipCapacity=12
     m_iNbOfClips=4
     m_iNbOfExtraClips=6
     m_fMuzzleVelocity=16200.000000
     m_MuzzleScale=0.318344
     m_fFireSoundRadius=270.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo45calAutoNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.602875,fShuffleAccuracy=1.695113,fWalkingAccuracy=2.118892,fWalkingFastAccuracy=8.740428,fRunningAccuracy=8.740428,fReticuleTime=1.008687,fAccuracyChange=9.090479,fWeaponJump=10.394486)
     m_fFPBlend=0.528055
     m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
     m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
     m_ReloadSnd=Sound'Pistol_MK23_Reloads.Play_MK23_Reload'
     m_ReloadEmptySnd=Sound'Pistol_MK23_Reloads.Play_MK23_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Pistol_MK23.Play_Mk23_SingleShots'
     m_EmptyMagSnd=Sound'Pistol_MK23_Reloads.Play_MK23_Chamber'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szTacticalLightClass="R6WeaponGadgets.R63rdTACPistol"
}
