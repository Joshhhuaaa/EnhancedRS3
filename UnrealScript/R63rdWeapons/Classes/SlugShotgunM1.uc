//============================================================================//
//  SlugShotgunM1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SlugShotgunM1 extends ShotgunM1;

defaultproperties
{
     m_iClipCapacity=6
     m_iNbOfClips=34
     m_iNbOfExtraClips=20
     m_fMuzzleVelocity=28320.000000
     m_MuzzleScale=0.970251
     m_fFireSoundRadius=1888.000000
     m_fRateOfFire=0.300000
     m_szReticuleClass="CIRCLEDOT"
     m_pBulletClass=Class'R6Weapons.ammo12gaugeSlug'
     m_pEmptyShells=Class'R6SFX.R6Shell12GaugeSlug'
     m_stAccuracyValues=(fBaseAccuracy=1.258351,fShuffleAccuracy=2.280804,fWalkingAccuracy=2.851005,fWalkingFastAccuracy=11.760395,fRunningAccuracy=11.760395,fReticuleTime=0.788500,fAccuracyChange=5.827240,fWeaponJump=23.000000)
     m_EquipSnd=Sound'CommonShotguns.Play_Shotgun_Equip'
     m_UnEquipSnd=Sound'CommonShotguns.Play_Shotgun_Unequip'
     m_ReloadEmptySnd=Sound'Shotgun_M1_Reloads.Play_M1_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Shotgun_M1.Play_M1_SingleShots'
     m_TriggerSnd=Sound'CommonShotguns.Play_Shotgun_Trigger'
}
