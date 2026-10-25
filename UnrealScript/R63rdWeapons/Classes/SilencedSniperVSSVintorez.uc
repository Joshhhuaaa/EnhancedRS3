//============================================================================//
//  SilencedSniperVSSVintorez.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSniperVSSVintorez extends SniperVSSVintorez;

defaultproperties
{
     m_eRateOfFire=ROF_FullAuto
     m_iClipCapacity=10
     m_iNbOfClips=3
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=29500.000000
     m_MuzzleScale=0.385754
     m_fFireSoundRadius=295.000000
     m_fRateOfFire=0.070588
     m_szReticuleClass="SNIPER"
     m_pBulletClass=Class'R6Weapons.ammo9x39mmSP6SubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.141020,fShuffleAccuracy=1.896674,fWalkingAccuracy=2.845011,fWalkingFastAccuracy=11.735668,fRunningAccuracy=11.735668,fReticuleTime=2.141250,fAccuracyChange=6.142879,fWeaponJump=5.609304)
     m_bIsSilenced=True
     m_fFPBlend=0.831838
     m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
     m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
     m_ReloadSnd=Sound'Sniper_Vintorez_Reloads.Play_Vintorez_Reload'
     m_ReloadEmptySnd=Sound'Sniper_Vintorez_Reloads.Play_Vintorez_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonWeapons.Play_ChangeROF'
     m_SingleFireStereoSnd=Sound'Sniper_Vintorez.Play_Vintorez_SingleShots'
     m_FullAutoStereoSnd=Sound'Sniper_Vintorez.Play_Vintorez_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Sniper_Vintorez.Stop_Vintorez_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGVintorez"
}
