//============================================================================//
//  NormalLMGM60E4.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalLMGM60E4 extends LMGM60E4;

defaultproperties
{
     m_iClipCapacity=100
     m_iNbOfClips=3
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=51180.000000
     m_MuzzleScale=0.934488
     m_fFireSoundRadius=3412.000000
     m_fRateOfFire=0.104348
     m_szReticuleClass="WRETICULE"
     m_pBulletClass=Class'R6Weapons.ammo762mmNATONormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.305753,fShuffleAccuracy=2.202521,fWalkingAccuracy=7.598699,fWalkingFastAccuracy=19.946585,fRunningAccuracy=19.946585,fReticuleTime=2.567344,fAccuracyChange=3.760192,fWeaponJump=8.953001)
     m_fFireAnimRate=0.958333
     m_EquipSnd=Sound'CommonLMGs.Play_LMG_Equip'
     m_UnEquipSnd=Sound'CommonLMGs.Play_LMG_Unequip'
     m_ReloadSnd=Sound'Mach_M60_Reloads.Play_M60_Reload'
     m_ReloadEmptySnd=Sound'Mach_M60_Reloads.Play_M60_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Mach_M60.Play_M60_SingleShots'
     m_FullAutoStereoSnd=Sound'Mach_M60.Play_M60_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Mach_M60.Stop_M60_AutoShots_Go'
     m_TriggerSnd=Sound'CommonLMGs.Play_LMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGBox762mm"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleMachineGuns"
}
