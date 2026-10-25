//============================================================================//
//  SilencedAssaultTAR21.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedAssaultTAR21 extends AssaultTAR21;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=30000.000000
     m_MuzzleScale=0.230531
     m_fFireSoundRadius=300.000000
     m_fRateOfFire=0.072727
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATOSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.745993,fShuffleAccuracy=2.410209,fWalkingAccuracy=3.615313,fWalkingFastAccuracy=14.913166,fRunningAccuracy=14.913166,fReticuleTime=1.203688,fAccuracyChange=3.909259,fWeaponJump=1.030303)
     m_bIsSilenced=True
     m_fFireAnimRate=1.375000
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_TAR21_Reloads.Play_TAR21_Reload'
     m_ReloadEmptySnd=Sound'Assault_TAR21_Reloads.Play_TAR21_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_TAR21_Silenced.Play_TAR21Sil_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_TAR21_Silenced.Play_TAR21Sil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_TAR21_Silenced.Stop_TAR21Sil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
}
