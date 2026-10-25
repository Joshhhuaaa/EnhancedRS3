//============================================================================//
//  CMagAssaultAK74.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class CMagAssaultAK74 extends AssaultAK74;

defaultproperties
{
     m_iClipCapacity=100
     m_iNbOfClips=2
     m_iNbOfExtraClips=1
     m_fMuzzleVelocity=54000.000000
     m_MuzzleScale=0.539738
     m_fFireSoundRadius=3600.000000
     m_fRateOfFire=0.092308
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo545mm7N6NormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.888873,fShuffleAccuracy=2.224465,fWalkingAccuracy=3.336697,fWalkingFastAccuracy=13.763877,fRunningAccuracy=13.763877,fReticuleTime=1.061687,fAccuracyChange=5.214543,fWeaponJump=8.100000)
     m_fFireAnimRate=1.083333
     m_fFPBlend=0.357246
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_AK74_Reloads.Play_AK74_Reload'
     m_ReloadEmptySnd=Sound'Assault_AK74_Reloads.Play_AK74_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_AK74.Play_AK74_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_AK74.Play_AK74_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_AK74.Stop_AK74_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdDrumMAGAK"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAK74"
}
