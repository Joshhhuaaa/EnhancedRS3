//============================================================================//
//  SilencedAssaultM4.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedAssaultM4 extends AssaultM4;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=30000.000000
     m_MuzzleScale=0.230531
     m_fFireSoundRadius=300.000000
     m_fRateOfFire=0.072727
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATOSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.011782,fShuffleAccuracy=2.064683,fWalkingAccuracy=3.097025,fWalkingFastAccuracy=12.775227,fRunningAccuracy=12.775227,fReticuleTime=0.732063,fAccuracyChange=4.937861,fWeaponJump=0.972458)
     m_bIsSilenced=True
     m_fFireAnimRate=1.375000
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_M4Carb_Reloads.Play_M4Carb_Reload'
     m_ReloadEmptySnd=Sound'Assault_M4Carb_Reloads.Play_M4Carb_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_M4Carb_Silenced.Play_M4CarbSil_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_M4Carb_Silenced.Play_M4CarbSil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_M4Carb_Silenced.Stop_M4CarbSil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
}
