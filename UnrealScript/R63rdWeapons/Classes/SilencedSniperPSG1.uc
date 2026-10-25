//============================================================================//
//  SilencedSniperPSG1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSniperPSG1 extends SniperPSG1;

defaultproperties
{
     m_iClipCapacity=10
     m_iNbOfClips=3
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=30000.000000
     m_MuzzleScale=0.351525
     m_fFireSoundRadius=300.000000
     m_fRateOfFire=1.152000
     m_szReticuleClass="SNIPER"
     m_pBulletClass=Class'R6Weapons.ammo762mmNATOSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.133073,fShuffleAccuracy=3.207006,fWalkingAccuracy=4.810509,fWalkingFastAccuracy=19.843348,fRunningAccuracy=19.843348,fReticuleTime=4.320000,fAccuracyChange=1.537255,fWeaponJump=3.847389)
     m_bIsSilenced=True
     m_fFPBlend=0.884659
     m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
     m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
     m_ReloadSnd=Sound'Sniper_PSG1_Reloads.Play_PSG1_Reload'
     m_ReloadEmptySnd=Sound'Sniper_PSG1_Reloads.Play_PSG1_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Sniper_PSG1_Silenced.Play_PSG1Sil_SingleShots'
     m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG762mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSnipers"
}
