//============================================================================//
//  NormalLMG21E.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalLMG21E extends LMG21E;

defaultproperties
{
     m_iClipCapacity=100
     m_iNbOfClips=3
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=50400.000000
     m_MuzzleScale=0.908490
     m_fFireSoundRadius=1680.000000
     m_fRateOfFire=0.075000
     m_szReticuleClass="WRETICULE"
     m_pBulletClass=Class'R6Weapons.ammo762mmNATONormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.147262,fShuffleAccuracy=2.408559,fWalkingAccuracy=8.309528,fWalkingFastAccuracy=21.812513,fRunningAccuracy=21.812513,fReticuleTime=2.589062,fAccuracyChange=4.217361,fWeaponJump=8.716235)
     m_fFireAnimRate=1.333333
     m_fFPBlend=0.026445
     m_EquipSnd=Sound'CommonLMGs.Play_LMG_Equip'
     m_UnEquipSnd=Sound'CommonLMGs.Play_LMG_Unequip'
     m_ReloadSnd=Sound'Mach_21E3_Reloads.Play_21E3_Reload'
     m_ReloadEmptySnd=Sound'Mach_21E3_Reloads.Play_21E3_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Mach_21E3.Play_21E3_SingleShots'
     m_FullAutoStereoSnd=Sound'Mach_21E3.Play_21E3_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Mach_21E3.Stop_21E3_AutoShots_Go'
     m_TriggerSnd=Sound'CommonLMGs.Play_LMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGBox762mm"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleMachineGuns"
}
