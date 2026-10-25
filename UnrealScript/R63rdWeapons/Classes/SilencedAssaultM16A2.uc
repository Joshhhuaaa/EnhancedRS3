//============================================================================//
//  SilencedAssaultM16A2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedAssaultM16A2 extends AssaultM16A2;

defaultproperties
{
     m_eRateOfFire=ROF_ThreeRound
     m_iClipCapacity=30
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=30000.000000
     m_MuzzleScale=0.230531
     m_fFireSoundRadius=300.000000
     m_fRateOfFire=0.072727
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATOSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.340310,fShuffleAccuracy=2.937597,fWalkingAccuracy=4.406395,fWalkingFastAccuracy=18.176378,fRunningAccuracy=18.176378,fReticuleTime=1.136500,fAccuracyChange=2.339265,fWeaponJump=0.993506)
     m_bIsSilenced=True
     m_fFireAnimRate=1.375000
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_M16A2_Reloads.Play_M16A2_Reload'
     m_ReloadEmptySnd=Sound'Assault_M16A2_Reloads.Play_M16A2_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_M16A2_Silenced.Play_M16A2Sil_SingleShots'
     m_BurstFireStereoSnd=Sound'Assault_M16A2_Silenced.Play_M16A2Sil_TripleShots'
     m_FullAutoStereoSnd=Sound'Assault_M16A2_Silenced.Play_M16A2Sil_DoubleShots'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
}
