//============================================================================//
//  SlugShotgunUSAS12.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SlugShotgunUSAS12 extends ShotgunUSAS12;

defaultproperties
{
     m_eRateOfFire=ROF_FullAuto
     m_iClipCapacity=20
     m_iNbOfClips=2
     m_iNbOfExtraClips=1
     m_fMuzzleVelocity=28320.000000
     m_MuzzleScale=0.970251
     m_fFireSoundRadius=1888.000000
     m_fRateOfFire=0.250000
     m_szReticuleClass="CIRCLEDOT"
     m_pBulletClass=Class'R6Weapons.ammo12gaugeSlug'
     m_pEmptyShells=Class'R6SFX.R6Shell12GaugeSlug'
     m_stAccuracyValues=(fBaseAccuracy=1.368001,fShuffleAccuracy=2.094399,fWalkingAccuracy=2.617999,fWalkingFastAccuracy=10.799245,fRunningAccuracy=10.799245,fReticuleTime=1.557500,fAccuracyChange=6.005565,fWeaponJump=13.802921)
     m_fFPBlend=0.251062
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
