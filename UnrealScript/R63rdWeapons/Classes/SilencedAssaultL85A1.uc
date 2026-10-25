//============================================================================//
//  SilencedAssaultL85A1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedAssaultL85A1 extends AssaultL85A1;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=30000.000000
     m_MuzzleScale=0.230531
     m_fFireSoundRadius=300.000000
     m_fRateOfFire=0.086957
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATOSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.611746,fShuffleAccuracy=2.584730,fWalkingAccuracy=3.877095,fWalkingFastAccuracy=15.993017,fRunningAccuracy=15.993017,fReticuleTime=1.133687,fAccuracyChange=3.389721,fWeaponJump=0.879310)
     m_bIsSilenced=True
     m_fFireAnimRate=1.150000
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_L85A1_Reloads.Play_L85A1_Reload'
     m_ReloadEmptySnd=Sound'Assault_L85A1_Reloads.Play_L85A1_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_L85A1_Silenced.Play_L85A1Sil_SingleShots'
     m_BurstFireStereoSnd=Sound'Assault_L85A1_Silenced.Play_L85A1Sil_TripleShots'
     m_FullAutoStereoSnd=Sound'Assault_L85A1_Silenced.Play_L85A1Sil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_L85A1_Silenced.Stop_L85A1Sil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
