//============================================================================//
//  SilencedAssaultAK47.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedAssaultAK47 extends AssaultAK47;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=29600.000000
     m_MuzzleScale=0.332888
     m_fFireSoundRadius=296.000000
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo762mmM43SubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.680965,fShuffleAccuracy=2.494745,fWalkingAccuracy=3.742118,fWalkingFastAccuracy=15.436235,fRunningAccuracy=15.436235,fReticuleTime=1.198750,fAccuracyChange=3.418024,fWeaponJump=3.028913)
     m_bIsSilenced=True
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_AK47_Reloads.Play_AK47_Reload'
     m_ReloadEmptySnd=Sound'Assault_AK47_Reloads.Play_AK47_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_AK47_Silenced.Play_AK47Sil_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_AK47_Silenced.Play_AK47Sil_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_AK47_Silenced.Stop_AK47Sil_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGAK47"
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
