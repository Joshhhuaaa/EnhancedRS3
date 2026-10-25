//============================================================================//
//  NormalPistolDesertEagle50.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalPistolDesertEagle50 extends PistolDesertEagle50;

defaultproperties
{
     m_iClipCapacity=7
     m_iNbOfClips=4
     m_iNbOfExtraClips=6
     m_fMuzzleVelocity=23700.000000
     m_MuzzleScale=0.471165
     m_fFireSoundRadius=1580.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo50calPistolNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.581697,fShuffleAccuracy=1.731116,fWalkingAccuracy=2.163895,fWalkingFastAccuracy=8.926065,fRunningAccuracy=8.926065,fReticuleTime=1.428750,fAccuracyChange=9.196082,fWeaponJump=22.024775)
     m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
     m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
     m_ReloadSnd=Sound'Pistol_Des50_Reloads.Play_Des50_Reload'
     m_ReloadEmptySnd=Sound'Pistol_Des50_Reloads.Play_Des50_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Pistol_Des50.Play_Des50_SingleShots'
     m_EmptyMagSnd=Sound'Pistol_Des50_Reloads.Play_Des50_Chamber'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szTacticalLightClass="R6WeaponGadgets.R63rdTACPistol"
}
