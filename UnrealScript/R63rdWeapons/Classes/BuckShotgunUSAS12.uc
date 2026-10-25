//============================================================================//
//  BuckShotgunUSAS12.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class BuckShotgunUSAS12 extends ShotgunUSAS12;

defaultproperties
{
     m_eRateOfFire=ROF_FullAuto
     m_iClipCapacity=20
     m_iNbOfClips=2
     m_iNbOfExtraClips=1
     m_fMuzzleVelocity=24780.000000
     m_MuzzleScale=0.646452
     m_fFireSoundRadius=1652.000000
     m_fRateOfFire=0.250000
     m_szReticuleClass="CIRCLEDOT"
     m_pBulletClass=Class'R6Weapons.ammo12gaugeBuck'
     m_stAccuracyValues=(fBaseAccuracy=3.420001,fShuffleAccuracy=3.327996,fWalkingAccuracy=4.159996,fWalkingFastAccuracy=10.919989,fRunningAccuracy=10.919989,fReticuleTime=1.658750,fAccuracyChange=7.639967,fWeaponJump=11.680268)
     m_fFPBlend=0.366236
     m_EquipSnd=Sound'CommonShotguns.Play_Shotgun_Equip'
     m_UnEquipSnd=Sound'CommonShotguns.Play_Shotgun_Unequip'
     m_ReloadSnd=Sound'Shotgun_USAS12_Reloads.Play_USAS12_Reload'
     m_ReloadEmptySnd=Sound'Shotgun_USAS12_Reloads.Play_USAS12_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonWeapons.Play_ChangeROF'
     m_SingleFireStereoSnd=Sound'Shotgun_USAS12.Play_USAS12_SingleShots'
     m_FullAutoStereoSnd=Sound'Shotgun_USAS12.Play_USAS12_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Shotgun_USAS12.Stop_USAS12_AutoShots_Go'
     m_TriggerSnd=Sound'CommonShotguns.Play_Shotgun_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGUSAS12"
}
