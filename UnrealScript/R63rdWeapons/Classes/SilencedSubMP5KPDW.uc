//============================================================================//
//  SilencedSubMP5KPDW.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSubMP5KPDW extends SubMP5KPDW;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=7
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=28500.000000
     m_MuzzleScale=0.272596
     m_fFireSoundRadius=285.000000
     m_fRateOfFire=0.075000
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.616003,fShuffleAccuracy=2.579196,fWalkingAccuracy=3.868794,fWalkingFastAccuracy=15.958777,fRunningAccuracy=15.958777,fReticuleTime=0.748750,fAccuracyChange=6.025409,fWeaponJump=3.056985)
     m_bIsSilenced=True
     m_fFireAnimRate=1.333333
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Sub_MP5KPD_Reloads.Play_MP5KPD_Reload'
     m_ReloadEmptySnd=Sound'Sub_MP5KPD_Reloads.Play_MP5KPD_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Sub_MP5KPD_Silenced.Play_Mp5KPDSil_SingleShots'
     m_BurstFireStereoSnd=Sound'Sub_MP5KPD_Silenced.Play_Mp5KPDSil_TripleShots'
     m_FullAutoStereoSnd=Sound'Sub_MP5KPD_Silenced.Play_Mp5KPDSil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Sub_MP5KPD_Silenced.Stop_Mp5KPDSil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG9mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
