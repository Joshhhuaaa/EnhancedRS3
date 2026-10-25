//============================================================================//
//  SilencedAssaultM14.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedAssaultM14 extends AssaultM14;

defaultproperties
{
     m_iClipCapacity=20
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=28600.000000
     m_MuzzleScale=0.336573
     m_fFireSoundRadius=286.000000
     m_fRateOfFire=0.082759
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo762mmNATOSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.222090,fShuffleAccuracy=3.091283,fWalkingAccuracy=4.636924,fWalkingFastAccuracy=19.127312,fRunningAccuracy=19.127312,fReticuleTime=1.633750,fAccuracyChange=1.881753,fWeaponJump=2.366241)
     m_bIsSilenced=True
     m_fFireAnimRate=1.208333
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_M14_Reloads.Play_M14_Reload'
     m_ReloadEmptySnd=Sound'Assault_M14_Reloads.Play_M14_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_M14_Silenced.Play_M14Sil_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_M14_Silenced.Play_M14Sil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_M14_Silenced.Stop_M14Sil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG762mm2"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
     StaticMesh=StaticMesh'R63rdWeapons_SM.AssaultRifles.R63rdM14ForSilencer'
}
