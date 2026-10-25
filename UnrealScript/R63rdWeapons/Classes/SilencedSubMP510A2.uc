//============================================================================//
//  SilencedSubMP510A2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSubMP510A2 extends SubMP510A2;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=28500.000000
     m_MuzzleScale=0.309718
     m_fFireSoundRadius=285.000000
     m_fRateOfFire=0.085714
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo10mmAutoSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.168553,fShuffleAccuracy=1.860880,fWalkingAccuracy=2.791321,fWalkingFastAccuracy=11.514198,fRunningAccuracy=11.514198,fReticuleTime=0.766187,fAccuracyChange=5.544566,fWeaponJump=4.531443)
     m_bIsSilenced=True
     m_fFireAnimRate=1.166667
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Sub_MP5_10A2_Reloads.Play_MP5_10A2_Reload'
     m_ReloadEmptySnd=Sound'Sub_MP5_10A2_Reloads.Play_MP5_10A2_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Sub_MP5_10A2_Silenced.Play_MP5_10A2Sil_SingleShots'
     m_BurstFireStereoSnd=Sound'Sub_MP5_10A2_Silenced.Play_MP5_10A2Sil_TripleShots'
     m_FullAutoStereoSnd=Sound'Sub_MP5_10A2_Silenced.Play_MP5_10A2Sil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Sub_MP5_10A2_Silenced.Stop_MP5_10A2Sil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG10mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
