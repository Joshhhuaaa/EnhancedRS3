//============================================================================//
//  SilencedSubTMP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSubTMP extends SubTMP;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=7
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=28500.000000
     m_MuzzleScale=0.272596
     m_fFireSoundRadius=285.000000
     m_fRateOfFire=0.066667
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.339539,fShuffleAccuracy=2.418600,fWalkingAccuracy=3.627899,fWalkingFastAccuracy=14.965085,fRunningAccuracy=14.965085,fReticuleTime=0.530125,fAccuracyChange=5.902411,fWeaponJump=3.438217)
     m_bIsSilenced=True
     m_fFireAnimRate=1.500000
     m_fFPBlend=0.727169
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Sub_TMP_Reloads.Play_TMP_Reload'
     m_ReloadEmptySnd=Sound'Sub_TMP_Reloads.Play_TMP_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Sub_TMP_Silenced.Play_TMPSil_SingleShots'
     m_FullAutoStereoSnd=Sound'Sub_TMP_Silenced.Play_TMPSil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Sub_TMP_Silenced.Stop_TMPSil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG9mmStraight"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
