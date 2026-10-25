//============================================================================//
//  SilencedSubCZ61.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSubCZ61 extends SubCZ61;

defaultproperties
{
     m_iClipCapacity=20
     m_iNbOfClips=10
     m_iNbOfExtraClips=4
     m_fMuzzleVelocity=28500.000000
     m_MuzzleScale=0.241756
     m_fFireSoundRadius=285.000000
     m_fRateOfFire=0.071429
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo765mmAutoSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.492280,fShuffleAccuracy=2.220036,fWalkingAccuracy=3.330054,fWalkingFastAccuracy=13.736471,fRunningAccuracy=13.736471,fReticuleTime=0.393063,fAccuracyChange=6.522383,fWeaponJump=2.557349)
     m_bIsSilenced=True
     m_fFireAnimRate=1.400000
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Mult_CZ61_Reloads.Play_CZ61_Reload'
     m_ReloadEmptySnd=Sound'Mult_CZ61_Reloads.Play_CZ61_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Mult_CZ61_Silenced.Play_CZ61Sil_SingleShots'
     m_FullAutoStereoSnd=Sound'Mult_CZ61_Silenced.Play_CZ61Sil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Mult_CZ61_Silenced.Stop_CZ61Sil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGCZ61"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
