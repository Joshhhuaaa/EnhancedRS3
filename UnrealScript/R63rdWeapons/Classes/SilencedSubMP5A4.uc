//============================================================================//
//  SilencedSubMP5A4.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSubMP5A4 extends SubMP5A4;

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
     m_stAccuracyValues=(fBaseAccuracy=1.155975,fShuffleAccuracy=1.877233,fWalkingAccuracy=2.815849,fWalkingFastAccuracy=11.615377,fRunningAccuracy=11.615377,fReticuleTime=0.705250,fAccuracyChange=5.495887,fWeaponJump=2.657948)
     m_bIsSilenced=True
     m_fFireAnimRate=1.333333
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Sub_MP5A4_Reloads.Play_Mp5A4_Reload'
     m_ReloadEmptySnd=Sound'Sub_MP5A4_Reloads.Play_Mp5A4_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Sub_MP5_SD5.Play_Mp5Sd5_SingleShots'
     m_BurstFireStereoSnd=Sound'Sub_MP5_SD5.Play_Mp5Sd5_TripleShots'
     m_FullAutoStereoSnd=Sound'Sub_MP5_SD5.Play_Mp5Sd5_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Sub_MP5_SD5.Stop_Mp5Sd5_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG9mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
