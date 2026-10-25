//============================================================================//
//  SilencedSubMP5SD5.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSubMP5SD5 extends SubMP5SD5;

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
     m_stAccuracyValues=(fBaseAccuracy=1.314605,fShuffleAccuracy=1.671013,fWalkingAccuracy=2.506520,fWalkingFastAccuracy=10.339395,fRunningAccuracy=10.339395,fReticuleTime=0.662500,fAccuracyChange=6.109786,fWeaponJump=2.623380)
     m_bIsSilenced=True
     m_fFireAnimRate=1.333333
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Sub_MP5_SD5_Reloads.Play_Mp5_SD5_Reload'
     m_ReloadEmptySnd=Sound'Sub_MP5_SD5_Reloads.Play_Mp5_SD5_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Sub_MP5_SD5.Play_Mp5Sd5_SingleShots'
     m_BurstFireStereoSnd=Sound'Sub_MP5_SD5.Play_Mp5Sd5_TripleShots'
     m_FullAutoStereoSnd=Sound'Sub_MP5_SD5.Play_Mp5Sd5_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Sub_MP5_SD5.Stop_Mp5Sd5_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG9mm"
}
