//============================================================================//
//  SilencedAssaultAUG.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedAssaultAUG extends AssaultAUG;

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
     m_stAccuracyValues=(fBaseAccuracy=0.675957,fShuffleAccuracy=2.501256,fWalkingAccuracy=3.751884,fWalkingFastAccuracy=15.476523,fRunningAccuracy=15.476523,fReticuleTime=1.125250,fAccuracyChange=3.400403,fWeaponJump=0.889535)
     m_bIsSilenced=True
     m_fFireAnimRate=1.083333
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_AUG_Reloads.Play_Aug_Reload'
     m_ReloadEmptySnd=Sound'Assault_AUG_Reloads.Play_Aug_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_AUG_Silenced.Play_AugSil_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_AUG_Silenced.Play_AugSil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_AUG_Silenced.Stop_AugSil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSnipers"
}
