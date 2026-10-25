//============================================================================//
//  SilencedAssaultM82.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedAssaultM82 extends AssaultM82;

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
     m_stAccuracyValues=(fBaseAccuracy=0.794769,fShuffleAccuracy=2.346800,fWalkingAccuracy=3.520200,fWalkingFastAccuracy=14.520823,fRunningAccuracy=14.520823,fReticuleTime=0.997750,fAccuracyChange=4.098022,fWeaponJump=0.972458)
     m_bIsSilenced=True
     m_fFireAnimRate=1.250000
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_M82_Reloads.Play_M82_Reload'
     m_ReloadEmptySnd=Sound'Assault_M82_Reloads.Play_M82_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_M82_Silenced.Play_M82Sil_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_M82_Silenced.Play_M82Sil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_M82_Silenced.Stop_M82Sil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
