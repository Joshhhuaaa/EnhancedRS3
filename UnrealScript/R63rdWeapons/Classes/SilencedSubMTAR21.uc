//============================================================================//
//  SilencedSubMTAR21.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSubMTAR21 extends SubMTAR21;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=7
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=28500.000000
     m_MuzzleScale=0.272596
     m_fFireSoundRadius=285.000000
     m_fRateOfFire=0.072727
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.276590,fShuffleAccuracy=1.980433,fWalkingAccuracy=2.970650,fWalkingFastAccuracy=12.253931,fRunningAccuracy=12.253931,fReticuleTime=0.881000,fAccuracyChange=5.962667,fWeaponJump=2.717633)
     m_bIsSilenced=True
     m_fFireAnimRate=1.375000
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Sub_MTAR21_Reloads.Play_MTAR21_Reload'
     m_ReloadEmptySnd=Sound'Sub_MTAR21_Reloads.Play_MTAR21_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Sub_MTAR21_Silenced.Play_MTAR21Sil_SingleShots'
     m_FullAutoStereoSnd=Sound'Sub_MTAR21_Silenced.Play_MTAR21Sil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Sub_MTAR21_Silenced.Stop_MTAR21Sil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
