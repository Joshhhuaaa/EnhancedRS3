//============================================================================//
//  CMagSubTMP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class CMagSubTMP extends SubTMP;

defaultproperties
{
     m_iClipCapacity=50
     m_iNbOfClips=4
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=21000.000000
     m_MuzzleScale=0.460559
     m_fFireSoundRadius=1400.000000
     m_fRateOfFire=0.066667
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.714633,fShuffleAccuracy=1.930977,fWalkingAccuracy=2.896465,fWalkingFastAccuracy=11.947920,fRunningAccuracy=11.947920,fReticuleTime=0.369063,fAccuracyChange=7.750079,fWeaponJump=5.199155)
     m_fFireAnimRate=1.500000
     m_fFPBlend=0.587435
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Sub_TMP_Reloads.Play_TMP_Reload'
     m_ReloadEmptySnd=Sound'Sub_TMP_Reloads.Play_TMP_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Sub_TMP.Play_TMP_SingleShots'
     m_FullAutoStereoSnd=Sound'Sub_TMP.Play_TMP_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Sub_TMP.Stop_TMP_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG9mmHigh"
}
