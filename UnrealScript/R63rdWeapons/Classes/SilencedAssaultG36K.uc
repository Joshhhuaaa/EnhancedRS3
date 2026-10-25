//============================================================================//
//  SilencedAssaultG36K.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedAssaultG36K extends AssaultG36K;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=30000.000000
     m_MuzzleScale=0.230531
     m_fFireSoundRadius=300.000000
     m_fRateOfFire=0.080000
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATOSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.696584,fShuffleAccuracy=2.474441,fWalkingAccuracy=3.711662,fWalkingFastAccuracy=15.310603,fRunningAccuracy=15.310603,fReticuleTime=1.003375,fAccuracyChange=3.718044,fWeaponJump=1.067442)
     m_bIsSilenced=True
     m_fFireAnimRate=1.250000
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_G36K_Reloads.Play_G36K_Reload'
     m_ReloadEmptySnd=Sound'Assault_G36K_Reloads.Play_G36K_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_G36K_Silenced.Play_G36KSil_SingleShots'
     m_BurstFireStereoSnd=Sound'Assault_G36K_Silenced.Play_G36KSil_TripleShots'
     m_FullAutoStereoSnd=Sound'Assault_G36K_Silenced.Play_G36KSil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_G36K_Silenced.Stop_G36KSil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
}
