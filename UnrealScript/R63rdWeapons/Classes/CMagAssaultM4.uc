//============================================================================//
//  CMagAssaultM4.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class CMagAssaultM4 extends AssaultM4;

defaultproperties
{
     m_iClipCapacity=100
     m_iNbOfClips=2
     m_iNbOfExtraClips=1
     m_fMuzzleVelocity=55260.000000
     m_MuzzleScale=0.561678
     m_fFireSoundRadius=3684.000000
     m_fRateOfFire=0.072727
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.259581,fShuffleAccuracy=1.742545,fWalkingAccuracy=2.613817,fWalkingFastAccuracy=10.781995,fRunningAccuracy=10.781995,fReticuleTime=0.752500,fAccuracyChange=7.091378,fWeaponJump=7.652174)
     m_fFireAnimRate=1.375000
     m_fFPBlend=0.392782
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_M4Carb_Reloads.Play_M4Carb_Reload'
     m_ReloadEmptySnd=Sound'Assault_M4Carb_Reloads.Play_M4Carb_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_M4Carb.Play_M4Carb_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_M4Carb.Play_M4Carb_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_M4Carb.Stop_M4Carb_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdCMAG556mm"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
