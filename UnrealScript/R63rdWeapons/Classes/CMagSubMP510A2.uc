//============================================================================//
//  CMagSubMP510A2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class CMagSubMP510A2 extends SubMP510A2;

defaultproperties
{
     m_iClipCapacity=100
     m_iNbOfClips=2
     m_iNbOfExtraClips=1
     m_fMuzzleVelocity=26520.000000
     m_MuzzleScale=0.435254
     m_fFireSoundRadius=1768.000000
     m_fRateOfFire=0.085714
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo10mmAutoNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.408805,fShuffleAccuracy=1.548553,fWalkingAccuracy=2.322830,fWalkingFastAccuracy=9.581675,fRunningAccuracy=9.581675,fReticuleTime=0.898750,fAccuracyChange=6.925777,fWeaponJump=8.120059)
     m_fFireAnimRate=1.166667
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Sub_MP5_10A2_Reloads.Play_MP5_10A2_Reload'
     m_ReloadEmptySnd=Sound'Sub_MP5_10A2_Reloads.Play_MP5_10A2_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Sub_MP5_10A2.Play_MP5_10A2_SingleShots'
     m_BurstFireStereoSnd=Sound'Sub_MP5_10A2.Play_MP5_10A2_TripleShots'
     m_FullAutoStereoSnd=Sound'Sub_MP5_10A2.Play_MP5_10A2_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Sub_MP5_10A2.Stop_MP5_10A2_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdCMAG9mmMP5"
}
