//============================================================================//
//  SilencedAssaultFAMASG2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedAssaultFAMASG2 extends AssaultFAMASG2;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=30000.000000
     m_MuzzleScale=0.230531
     m_fFireSoundRadius=300.000000
     m_fRateOfFire=0.054545
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATOSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.674114,fShuffleAccuracy=2.503651,fWalkingAccuracy=3.755477,fWalkingFastAccuracy=15.491343,fRunningAccuracy=15.491343,fReticuleTime=1.074813,fAccuracyChange=3.631086,fWeaponJump=0.919840)
     m_bIsSilenced=True
     m_fFireAnimRate=1.833333
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_FMASG2_Reloads.Play_FMASG2_Reload'
     m_ReloadEmptySnd=Sound'Assault_FMASG2_Reloads.Play_FMASG2_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_FMASG2_Silenced.Play_FMASG2Sil_SingleShots'
     m_BurstFireStereoSnd=Sound'Assault_FMASG2_Silenced.Play_FMASG2Sil_TripleShots'
     m_FullAutoStereoSnd=Sound'Assault_FMASG2_Silenced.Play_FMASG2Sil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_FMASG2_Silenced.Stop_FMASG2Sil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
}
