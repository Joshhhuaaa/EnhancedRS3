//============================================================================//
//  SilencedAssaultG3A3.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedAssaultG3A3 extends AssaultG3A3;

defaultproperties
{
     m_iClipCapacity=20
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=28600.000000
     m_MuzzleScale=0.336573
     m_fFireSoundRadius=286.000000
     m_fRateOfFire=0.109091
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo762mmNATOSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.454915,fShuffleAccuracy=2.788610,fWalkingAccuracy=4.182916,fWalkingFastAccuracy=17.254526,fRunningAccuracy=17.254526,fReticuleTime=1.449062,fAccuracyChange=2.622738,fWeaponJump=2.641386)
     m_bIsSilenced=True
     m_fFireAnimRate=0.916667
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_G3A3_Reloads.Play_G3A3_Reload'
     m_ReloadEmptySnd=Sound'Assault_G3A3_Reloads.Play_G3A3_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_G3A3_Silenced.Play_G3A3Sil_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_G3A3_Silenced.Play_G3A3Sil_AutoShot'
     m_FullAutoEndStereoSnd=Sound'Assault_G3A3_Silenced.Stop_G3A3Sil_AutoShot_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG762mm2"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
}
