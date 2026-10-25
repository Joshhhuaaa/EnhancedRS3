//============================================================================//
//  SilencedAssaultGalilARM.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedAssaultGalilARM extends AssaultGalilARM;

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
     m_pBulletClass=Class'R6Weapons.ammo556mmNATOSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.420207,fShuffleAccuracy=2.833731,fWalkingAccuracy=4.250596,fWalkingFastAccuracy=17.533709,fRunningAccuracy=17.533709,fReticuleTime=1.289688,fAccuracyChange=2.648466,fWeaponJump=0.839122)
     m_bIsSilenced=True
     m_fFireAnimRate=1.083333
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_Galil_Reloads.Play_Galil_Reload'
     m_ReloadEmptySnd=Sound'Assault_Galil_Reloads.Play_Galil_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_Galil_Silenced.Play_GalilSil_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_Galil_Silenced.Play_GalilSil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_Galil_Silenced.Stop_GalilSil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
}
