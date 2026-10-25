//============================================================================//
//  CMagAssaultGalilARM.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class CMagAssaultGalilARM extends AssaultGalilARM;

defaultproperties
{
     m_iClipCapacity=100
     m_iNbOfClips=2
     m_iNbOfExtraClips=1
     m_fMuzzleVelocity=57000.000000
     m_MuzzleScale=0.592809
     m_fFireSoundRadius=3800.000000
     m_fRateOfFire=0.092308
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.729641,fShuffleAccuracy=2.431466,fWalkingAccuracy=3.647200,fWalkingFastAccuracy=15.044699,fRunningAccuracy=15.044699,fReticuleTime=1.260062,fAccuracyChange=4.853271,fWeaponJump=7.607851)
     m_fFireAnimRate=1.083333
     m_fFPBlend=0.396299
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_Galil_Reloads.Play_Galil_Reload'
     m_ReloadEmptySnd=Sound'Assault_Galil_Reloads.Play_Galil_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_Galil.Play_Galil_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_Galil.Play_Galil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_Galil.Stop_Galil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdCMAG556mm"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
