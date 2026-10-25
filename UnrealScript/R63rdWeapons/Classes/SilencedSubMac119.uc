//============================================================================//
//  SilencedSubMac119.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedSubMac119 extends SubMac119;

defaultproperties
{
     m_iClipCapacity=32
     m_iNbOfClips=7
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=28500.000000
     m_MuzzleScale=0.272596
     m_fFireSoundRadius=285.000000
     m_fRateOfFire=0.050000
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.806080,fShuffleAccuracy=3.177096,fWalkingAccuracy=4.765645,fWalkingFastAccuracy=19.658285,fRunningAccuracy=19.658285,fReticuleTime=0.438812,fAccuracyChange=7.018562,fWeaponJump=3.552600)
     m_bIsSilenced=True
     m_fFireAnimRate=2.000000
     m_fFPBlend=0.718093
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Mult_Mac11_Reloads.Play_Mac11_Reload'
     m_ReloadEmptySnd=Sound'Mult_Mac11_Reloads.Play_Mac11_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Mult_Mac11_Silenced.Play_Ingram_Sil_SingleShots'
     m_FullAutoStereoSnd=Sound'Mult_Mac11_Silenced.Play_Ingram_Sil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Mult_Mac11_Silenced.Stop_Ingram_Sil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG9mmStraight"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
