//============================================================================//
//  SilencedAssaultFNC.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedAssaultFNC extends AssaultFNC;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=30000.000000
     m_MuzzleScale=0.230531
     m_fFireSoundRadius=300.000000
     m_fRateOfFire=0.092308
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATOSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.388652,fShuffleAccuracy=2.874752,fWalkingAccuracy=4.312129,fWalkingFastAccuracy=17.787529,fRunningAccuracy=17.787529,fReticuleTime=1.375750,fAccuracyChange=2.526348,fWeaponJump=0.787307)
     m_bIsSilenced=True
     m_fFireAnimRate=1.083333
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_FNC_Reloads.Play_FNC_Reload'
     m_ReloadEmptySnd=Sound'Assault_FNC_Reloads.Play_FNC_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_FNC_Silenced.Play_FNCSil_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_FNC_Silenced.Play_FNCSil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_FNC_Silenced.Stop_FNCSil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
}
