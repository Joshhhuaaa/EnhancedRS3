//============================================================================//
//  NormalLMGM249.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalLMGM249 extends LMGM249;

defaultproperties
{
     m_iClipCapacity=200
     m_iNbOfClips=2
     m_iNbOfExtraClips=1
     m_fMuzzleVelocity=54900.000000
     m_MuzzleScale=0.555358
     m_fFireSoundRadius=1830.000000
     m_fRateOfFire=0.080000
     m_szReticuleClass="WRETICULE"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.191801,fShuffleAccuracy=2.350658,fWalkingAccuracy=8.109772,fWalkingFastAccuracy=21.288149,fRunningAccuracy=21.288149,fReticuleTime=2.096875,fAccuracyChange=3.373141,fWeaponJump=6.469466)
     m_fFireAnimRate=1.250000
     m_fFPBlend=0.277397
     m_EquipSnd=Sound'CommonLMGs.Play_LMG_Equip'
     m_UnEquipSnd=Sound'CommonLMGs.Play_LMG_Unequip'
     m_ReloadSnd=Sound'Mach_M249_Reloads.Play_M249_Reload'
     m_ReloadEmptySnd=Sound'Mach_M249_Reloads.Play_M249_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Mach_M249.Play_M249_SingleShots'
     m_FullAutoStereoSnd=Sound'Mach_M249.Play_M249_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Mach_M249.Stop_M249_AutoShots_Go'
     m_TriggerSnd=Sound'CommonLMGs.Play_LMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGBox556mm"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleMachineGuns"
}
