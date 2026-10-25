//============================================================================//
//  NormalLMG23E.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalLMG23E extends LMG23E;

defaultproperties
{
     m_iClipCapacity=200
     m_iNbOfClips=2
     m_iNbOfExtraClips=1
     m_fMuzzleVelocity=57000.000000
     m_MuzzleScale=0.592809
     m_fFireSoundRadius=1900.000000
     m_fRateOfFire=0.080000
     m_szReticuleClass="WRETICULE"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.349079,fShuffleAccuracy=2.146197,fWalkingAccuracy=7.404380,fWalkingFastAccuracy=19.436497,fRunningAccuracy=19.436497,fReticuleTime=2.389062,fAccuracyChange=3.370407,fWeaponJump=5.850954)
     m_fFireAnimRate=1.250000
     m_fFPBlend=0.346481
     m_EquipSnd=Sound'CommonLMGs.Play_LMG_Equip'
     m_UnEquipSnd=Sound'CommonLMGs.Play_LMG_Unequip'
     m_ReloadSnd=Sound'Mach_23E_Reloads.Play_23E_Reload'
     m_ReloadEmptySnd=Sound'Mach_23E_Reloads.Play_23E_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Mach_23E.Play_23E_SingleShots'
     m_FullAutoStereoSnd=Sound'Mach_23E.Play_23E_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Mach_23E.Stop_23E_AutoShots_Go'
     m_TriggerSnd=Sound'CommonLMGs.Play_LMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGBox556mm"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleMachineGuns"
}
