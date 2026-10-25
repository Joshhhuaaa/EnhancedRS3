//============================================================================//
//  NormalSubP90.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalSubP90 extends SubP90;

defaultproperties
{
     m_iClipCapacity=50
     m_iNbOfClips=4
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=42900.000000
     m_MuzzleScale=0.471813
     m_fFireSoundRadius=2860.000000
     m_fRateOfFire=0.066667
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo57x28mmNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.516275,fShuffleAccuracy=1.928843,fWalkingAccuracy=2.893264,fWalkingFastAccuracy=11.934713,fRunningAccuracy=11.934713,fReticuleTime=0.668750,fAccuracyChange=7.355419,fWeaponJump=6.454216)
     m_fFireAnimRate=1.500000
     m_fFPBlend=0.487843
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Sub_P90_Reloads.Play_P90_Reload'
     m_ReloadEmptySnd=Sound'Sub_P90_Reloads.Play_P90_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Sub_P90.Play_P90_SingleShots'
     m_FullAutoStereoSnd=Sound'Sub_P90.Play_P90_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Sub_P90.Stop_P90_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGP90"
}
