//============================================================================//
//  BuckShotgunM1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class BuckShotgunM1 extends ShotgunM1;

defaultproperties
{
     m_iClipCapacity=6
     m_iNbOfClips=34
     m_iNbOfExtraClips=20
     m_fMuzzleVelocity=24780.000000
     m_MuzzleScale=0.646452
     m_fFireSoundRadius=1652.000000
     m_fRateOfFire=0.300000
     m_szReticuleClass="CIRCLEDOT"
     m_pBulletClass=Class'R6Weapons.ammo12gaugeBuck'
     m_stAccuracyValues=(fBaseAccuracy=3.355602,fShuffleAccuracy=3.495436,fWalkingAccuracy=4.369295,fWalkingFastAccuracy=11.469398,fRunningAccuracy=11.469398,fReticuleTime=0.788500,fAccuracyChange=7.515353,fWeaponJump=20.000000)
     m_EquipSnd=Sound'CommonShotguns.Play_Shotgun_Equip'
     m_UnEquipSnd=Sound'CommonShotguns.Play_Shotgun_Unequip'
     m_ReloadEmptySnd=Sound'Shotgun_M1_Reloads.Play_M1_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Shotgun_M1.Play_M1_SingleShots'
     m_TriggerSnd=Sound'CommonShotguns.Play_Shotgun_Trigger'
}
