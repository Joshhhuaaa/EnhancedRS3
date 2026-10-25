//============================================================================//
//  SilencedSniperAWCovert.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSniperAWCovert extends SniperAWCovert;

defaultproperties
{
     m_iClipCapacity=10
     m_iNbOfClips=3
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=30000.000000
     m_MuzzleScale=0.351525
     m_fFireSoundRadius=300.000000
     m_fRateOfFire=0.866667
     m_szReticuleClass="SNIPER"
     m_pBulletClass=Class'R6Weapons.ammo762mmNATOSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.427508,fShuffleAccuracy=2.824240,fWalkingAccuracy=4.236360,fWalkingFastAccuracy=17.474983,fRunningAccuracy=17.474983,fReticuleTime=3.250000,fAccuracyChange=2.676720,fWeaponJump=2.733750)
     m_bIsSilenced=True
     m_fFPBlend=0.918045
     m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
     m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
     m_ReloadSnd=Sound'Sniper_AWCovert_Reloads.Play_AWCovert_Reload'
     m_ReloadEmptySnd=Sound'Sniper_AWCovert_Reloads.Play_AWCovert_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Sniper_AWCovert.Play_AWCovert_SingleShots'
     m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG762mm"
}
