//============================================================================//
//  NormalLMGRPD.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalLMGRPD extends LMGRPD;

defaultproperties
{
     m_iClipCapacity=100
     m_iNbOfClips=4
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=42000.000000
     m_MuzzleScale=0.734019
     m_fFireSoundRadius=1400.000000
     m_fRateOfFire=0.085714
     m_szReticuleClass="WRETICULE"
     m_pBulletClass=Class'R6Weapons.ammo762mmM43NormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.460400,fShuffleAccuracy=2.001479,fWalkingAccuracy=6.905104,fWalkingFastAccuracy=18.125898,fRunningAccuracy=18.125898,fReticuleTime=2.131406,fAccuracyChange=4.449693,fWeaponJump=8.671593)
     m_fFireAnimRate=1.166667
     m_fFPBlend=0.031432
     m_EquipSnd=Sound'CommonLMGs.Play_LMG_Equip'
     m_UnEquipSnd=Sound'CommonLMGs.Play_LMG_Unequip'
     m_ReloadSnd=Sound'Mach_RPD_Reloads.Play_RPD_Reload'
     m_ReloadEmptySnd=Sound'Mach_RPD_Reloads.Play_RPD_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Mach_RPD.Play_RPD_SingleShots'
     m_FullAutoStereoSnd=Sound'Mach_RPD.Play_RPD_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Mach_RPD.Stop_RPD_AutoShots_Go'
     m_TriggerSnd=Sound'CommonLMGs.Play_LMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGRPD"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleMachineGuns"
}
