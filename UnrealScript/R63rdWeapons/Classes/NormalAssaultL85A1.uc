//============================================================================//
//  NormalAssaultL85A1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalAssaultL85A1 extends AssaultL85A1;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=56400.000000
     m_MuzzleScale=0.581966
     m_fFireSoundRadius=3760.000000
     m_fRateOfFire=0.086957
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.921180,fShuffleAccuracy=2.182466,fWalkingAccuracy=3.273699,fWalkingFastAccuracy=13.504008,fRunningAccuracy=13.504008,fReticuleTime=0.841563,fAccuracyChange=5.962138,fWeaponJump=10.241727)
     m_fFireAnimRate=1.150000
     m_fFPBlend=0.187295
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_L85A1_Reloads.Play_L85A1_Reload'
     m_ReloadEmptySnd=Sound'Assault_L85A1_Reloads.Play_L85A1_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_L85A1.Play_L85A1_SingleShots'
     m_BurstFireStereoSnd=Sound'Assault_L85A1.Play_L85A1_TripleShots'
     m_FullAutoStereoSnd=Sound'Assault_L85A1.Play_L85A1_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_L85A1.Stop_L85A1_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
