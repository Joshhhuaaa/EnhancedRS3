//============================================================================//
//  SilencedAssaultAK74.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedAssaultAK74 extends AssaultAK74;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=30000.000000
     m_MuzzleScale=0.230531
     m_fFireSoundRadius=300.000000
     m_fRateOfFire=0.092308
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo545mm7N6SubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.548496,fShuffleAccuracy=2.666955,fWalkingAccuracy=4.000433,fWalkingFastAccuracy=16.501787,fRunningAccuracy=16.501787,fReticuleTime=1.091313,fAccuracyChange=2.951972,fWeaponJump=1.015487)
     m_bIsSilenced=True
     m_fFireAnimRate=1.083333
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_AK74_Reloads.Play_AK74_Reload'
     m_ReloadEmptySnd=Sound'Assault_AK74_Reloads.Play_AK74_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_AK74_Silenced.Play_AK74Sil_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_AK74_Silenced.Play_AK74Sil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_AK74_Silenced.Stop_AK74Sil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGAK74"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
