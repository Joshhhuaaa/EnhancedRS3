//============================================================================//
//  NormalSubUMP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalSubUMP extends SubUMP;

defaultproperties
{
     m_iClipCapacity=25
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=18720.000000
     m_MuzzleScale=0.336402
     m_fFireSoundRadius=312.000000
     m_fRateOfFire=0.103448
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo45calAutoNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.421395,fShuffleAccuracy=1.532187,fWalkingAccuracy=2.298280,fWalkingFastAccuracy=9.480407,fRunningAccuracy=9.480407,fReticuleTime=0.500687,fAccuracyChange=6.984474,fWeaponJump=7.639484)
     m_fFireAnimRate=0.966667
     m_fFPBlend=0.393789
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Sub_UMP45_Reloads.Play_UMP45_Reload'
     m_ReloadEmptySnd=Sound'Sub_UMP45_Reloads.Play_UMP45_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Sub_UMP45.Play_UMP45_SingleShots'
     m_BurstFireStereoSnd=Sound'Sub_UMP45.Play_UMP45_TripleShots'
     m_FullAutoStereoSnd=Sound'Sub_UMP45.Play_UMP45_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Sub_UMP45.Stop_UMP45_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG10mm"
}
