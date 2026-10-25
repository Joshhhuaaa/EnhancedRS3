//============================================================================//
//  SilencedSniperDragunov.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSniperDragunov extends SniperDragunov;

defaultproperties
{
     m_iClipCapacity=10
     m_iNbOfClips=3
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=30000.000000
     m_MuzzleScale=0.377344
     m_fFireSoundRadius=300.000000
     m_fRateOfFire=0.855000
     m_szReticuleClass="SNIPER"
     m_pBulletClass=Class'R6Weapons.ammo762x54mmRSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.136466,fShuffleAccuracy=3.202594,fWalkingAccuracy=4.803890,fWalkingFastAccuracy=19.816048,fRunningAccuracy=19.816048,fReticuleTime=3.206250,fAccuracyChange=1.550389,fWeaponJump=3.685168)
     m_bIsSilenced=True
     m_fFPBlend=0.889522
     m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
     m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
     m_ReloadSnd=Sound'Sniper_Dragunov_Reloads.Play_Dragunov_Reload'
     m_ReloadEmptySnd=Sound'Sniper_Dragunov_Reloads.Play_Dragunov_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Sniper_Dragunov_Silenced.Play_DragunovSil_SingleShots'
     m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGDragunov"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSnipers"
     StaticMesh=StaticMesh'R63rdWeapons_SM.SniperRifles.R63rdDragunovForSilencer'
}
