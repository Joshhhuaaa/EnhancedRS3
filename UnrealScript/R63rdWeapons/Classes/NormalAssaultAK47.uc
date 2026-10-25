//============================================================================//
//  NormalAssaultAK47.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalAssaultAK47 extends AssaultAK47;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=42900.000000
     m_MuzzleScale=0.756527
     m_fFireSoundRadius=2860.000000
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo762mmM43NormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.096060,fShuffleAccuracy=1.955122,fWalkingAccuracy=2.932684,fWalkingFastAccuracy=12.097320,fRunningAccuracy=12.097320,fReticuleTime=0.876250,fAccuracyChange=6.357965,fWeaponJump=14.088409)
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_AK47_Reloads.Play_AK47_Reload'
     m_ReloadEmptySnd=Sound'Assault_AK47_Reloads.Play_AK47_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_AK47.Play_AK47_SingleShots'
     m_FullAutoStereoSnd=Sound'Assault_AK47.Play_AK47_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_AK47.Stop_AK47_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGAK47"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAK47"
}
