//============================================================================//
//  SlugShotgunSPAS12.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SlugShotgunSPAS12 extends ShotgunSPAS12;

defaultproperties
{
     m_iClipCapacity=8
     m_iNbOfClips=32
     m_iNbOfExtraClips=20
     m_fMuzzleVelocity=28320.000000
     m_MuzzleScale=0.970251
     m_fFireSoundRadius=1888.000000
     m_fRateOfFire=0.684333
     m_szReticuleClass="CIRCLEDOT"
     m_pBulletClass=Class'R6Weapons.ammo12gaugeSlug'
     m_pEmptyShells=Class'R6SFX.R6Shell12GaugeSlug'
     m_stAccuracyValues=(fBaseAccuracy=1.318239,fShuffleAccuracy=2.178994,fWalkingAccuracy=2.723742,fWalkingFastAccuracy=11.235436,fRunningAccuracy=11.235436,fReticuleTime=1.039750,fAccuracyChange=4.575849,fWeaponJump=20.298414)
     m_EquipSnd=Sound'CommonShotguns.Play_Shotgun_Equip'
     m_UnEquipSnd=Sound'CommonShotguns.Play_Shotgun_Unequip'
     m_ReloadEmptySnd=Sound'Shotgun_SPAS12_Reloads.Play_SPAS12_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Shotgun_SPAS12.Play_SPAS12_SingleShots'
     m_TriggerSnd=Sound'CommonShotguns.Play_Shotgun_Trigger'
}
