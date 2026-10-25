//============================================================================//
//  SilencedAssaultType97.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedAssaultType97 extends AssaultType97;

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
     m_stAccuracyValues=(fBaseAccuracy=1.157911,fShuffleAccuracy=1.874715,fWalkingAccuracy=2.812073,fWalkingFastAccuracy=11.599800,fRunningAccuracy=11.599800,fReticuleTime=0.672813,fAccuracyChange=5.503381,fWeaponJump=1.267956)
     m_bIsSilenced=True
     m_fFireAnimRate=1.083333
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_Type97_Reloads.Play_Type97_Reload'
     m_ReloadEmptySnd=Sound'Assault_Type97_Reloads.Play_Type97_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_Type97_Silenced.Play_Type97Sil_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_Type97_Silenced.Play_Type97Sil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_Type97_Silenced.Stop_Type97Sil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSnipers"
}
