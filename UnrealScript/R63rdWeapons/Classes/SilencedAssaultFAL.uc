//============================================================================//
//  SilencedAssaultFAL.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedAssaultFAL extends AssaultFAL;

defaultproperties
{
     m_iClipCapacity=20
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=28600.000000
     m_MuzzleScale=0.336573
     m_fFireSoundRadius=286.000000
     m_fRateOfFire=0.092308
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo762mmNATOSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.270704,fShuffleAccuracy=3.028084,fWalkingAccuracy=4.542127,fWalkingFastAccuracy=18.736271,fRunningAccuracy=18.736271,fReticuleTime=1.482813,fAccuracyChange=2.069890,fWeaponJump=2.654615)
     m_bIsSilenced=True
     m_fFireAnimRate=1.083333
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_FAL_Reloads.Play_FAL_Reload'
     m_ReloadEmptySnd=Sound'Assault_FAL_Reloads.Play_FAL_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_FAL_Silenced.Play_FALSil_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_FAL_Silenced.Play_FALSil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_FAL_Silenced.Stop_FALSil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG762mm2"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
}
