//============================================================================//
//  SilencedSubP90.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSubP90 extends SubP90;

defaultproperties
{
     m_iClipCapacity=50
     m_iNbOfClips=4
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=30000.000000
     m_MuzzleScale=0.240656
     m_fFireSoundRadius=300.000000
     m_fRateOfFire=0.066667
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo57x28mmSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.279797,fShuffleAccuracy=2.236264,fWalkingAccuracy=3.354396,fWalkingFastAccuracy=13.836884,fRunningAccuracy=13.836884,fReticuleTime=0.881375,fAccuracyChange=5.975079,fWeaponJump=1.985294)
     m_bIsSilenced=True
     m_fFireAnimRate=1.500000
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Sub_P90_Reloads.Play_P90_Reload'
     m_ReloadEmptySnd=Sound'Sub_P90_Reloads.Play_P90_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Sub_P90_Silenced.Play_P90Sil_SingleShots'
     m_FullAutoStereoSnd=Sound'Sub_P90_Silenced.Play_P90Sil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Sub_P90_Silenced.Stop_P90Sil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGP90"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
