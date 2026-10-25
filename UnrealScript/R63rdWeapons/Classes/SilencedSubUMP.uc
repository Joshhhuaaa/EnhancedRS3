//============================================================================//
//  SilencedSubUMP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSubUMP extends SubUMP;

defaultproperties
{
     m_iClipCapacity=25
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=28500.000000
     m_MuzzleScale=0.358834
     m_fFireSoundRadius=285.000000
     m_fRateOfFire=0.103448
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo45calAutoSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.181143,fShuffleAccuracy=1.844514,fWalkingAccuracy=2.766771,fWalkingFastAccuracy=11.412930,fRunningAccuracy=11.412930,fReticuleTime=0.715000,fAccuracyChange=5.524269,fWeaponJump=5.317319)
     m_bIsSilenced=True
     m_fFireAnimRate=0.966667
     m_fFPBlend=0.578058
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Sub_UMP45_Reloads.Play_UMP45_Reload'
     m_ReloadEmptySnd=Sound'Sub_UMP45_Reloads.Play_UMP45_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Sub_UMP45_Silenced.Play_UMP45Sil_SingleShots'
     m_BurstFireStereoSnd=Sound'Sub_UMP45_Silenced.Play_UMP45Sil_TripleShots'
     m_FullAutoStereoSnd=Sound'Sub_UMP45_Silenced.Play_UMP45Sil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Sub_UMP45_Silenced.Stop_UMP45Sil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG10mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
