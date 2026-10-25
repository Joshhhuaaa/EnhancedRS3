//============================================================================//
//  NormalAssaultType97.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalAssaultType97 extends AssaultType97;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=54000.000000
     m_MuzzleScale=0.539738
     m_fFireSoundRadius=3600.000000
     m_fRateOfFire=0.092308
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.467345,fShuffleAccuracy=1.472451,fWalkingAccuracy=2.208677,fWalkingFastAccuracy=9.110790,fRunningAccuracy=9.110790,fReticuleTime=0.380688,fAccuracyChange=7.745859,fWeaponJump=14.753572)
     m_fFireAnimRate=1.083333
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_Type97_Reloads.Play_Type97_Reload'
     m_ReloadEmptySnd=Sound'Assault_Type97_Reloads.Play_Type97_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_Type97.Play_Type97_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_Type97.Play_Type97_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_Type97.Stop_Type97_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleType97"
}
