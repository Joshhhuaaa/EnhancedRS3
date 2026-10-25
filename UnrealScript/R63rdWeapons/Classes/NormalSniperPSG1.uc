//============================================================================//
//  NormalSniperPSG1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalSniperPSG1 extends SniperPSG1;

defaultproperties
{
     m_iClipCapacity=10
     m_iNbOfClips=3
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=50280.000000
     m_MuzzleScale=0.835848
     m_fFireSoundRadius=3352.000000
     m_fRateOfFire=1.027000
     m_szReticuleClass="SNIPER"
     m_pBulletClass=Class'R6Weapons.ammo762mmNATONormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.428670,fShuffleAccuracy=2.822729,fWalkingAccuracy=4.234094,fWalkingFastAccuracy=17.465635,fRunningAccuracy=17.465635,fReticuleTime=3.851250,fAccuracyChange=2.681217,fWeaponJump=17.767620)
     m_fFPBlend=0.467344
     m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
     m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
     m_ReloadSnd=Sound'Sniper_PSG1_Reloads.Play_PSG1_Reload'
     m_ReloadEmptySnd=Sound'Sniper_PSG1_Reloads.Play_PSG1_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Sniper_PSG1.Play_PSG1_SingleShots'
     m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG762mm"
}
