//============================================================================//
//  SilencedSubM12S.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSubM12S extends SubM12S;

defaultproperties
{
     m_iClipCapacity=40
     m_iNbOfClips=5
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=28500.000000
     m_MuzzleScale=0.272596
     m_fFireSoundRadius=285.000000
     m_fRateOfFire=0.109091
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.351279,fShuffleAccuracy=2.013338,fWalkingAccuracy=3.020006,fWalkingFastAccuracy=12.457526,fRunningAccuracy=12.457526,fReticuleTime=0.788875,fAccuracyChange=6.002692,fWeaponJump=2.740608)
     m_bIsSilenced=True
     m_fFireAnimRate=0.916667
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Sub_M12_Reloads.Play_M12_Reload'
     m_ReloadEmptySnd=Sound'Sub_M12_Reloads.Play_M12_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Sub_M12_Silenced.Play_M12Sil_SingleShots'
     m_FullAutoStereoSnd=Sound'Sub_M12_Silenced.Play_M12Sil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Sub_M12_Silenced.Stop_M12Sil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG9mmStraight"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
