//============================================================================//
//  CMagAssaultTAR21.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class CMagAssaultTAR21 extends AssaultTAR21;

defaultproperties
{
     m_iClipCapacity=100
     m_iNbOfClips=2
     m_iNbOfExtraClips=1
     m_fMuzzleVelocity=53400.000000
     m_MuzzleScale=0.529467
     m_fFireSoundRadius=3560.000000
     m_fRateOfFire=0.072727
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.055427,fShuffleAccuracy=2.007944,fWalkingAccuracy=3.011917,fWalkingFastAccuracy=12.424156,fRunningAccuracy=12.424156,fReticuleTime=1.174062,fAccuracyChange=6.285569,fWeaponJump=8.023257)
     m_fFireAnimRate=1.375000
     m_fFPBlend=0.363336
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_TAR21_Reloads.Play_TAR21_Reload'
     m_ReloadEmptySnd=Sound'Assault_TAR21_Reloads.Play_TAR21_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_TAR21.Play_TAR21_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_TAR21.Play_TAR21_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_TAR21.Stop_TAR21_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdCMAG556mm"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
