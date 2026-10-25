//============================================================================//
//  NormalAssaultFAMASG2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalAssaultFAMASG2 extends AssaultFAMASG2;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=6
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=55500.000000
     m_MuzzleScale=0.565915
     m_fFireSoundRadius=3700.000000
     m_fRateOfFire=0.054545
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.983548,fShuffleAccuracy=2.101387,fWalkingAccuracy=3.152081,fWalkingFastAccuracy=13.002334,fRunningAccuracy=13.002334,fReticuleTime=0.782687,fAccuracyChange=6.562097,fWeaponJump=10.464478)
     m_fFireAnimRate=1.833333
     m_fFPBlend=0.169619
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_FMASG2_Reloads.Play_FMASG2_Reload'
     m_ReloadEmptySnd=Sound'Assault_FMASG2_Reloads.Play_FMASG2_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_FMASG2.Play_FMASG2_SingleShots'
     m_BurstFireStereoSnd=Sound'Assault_FMASG2.Play_FMASG2_TripleShots'
     m_FullAutoStereoSnd=Sound'Assault_FMASG2.Play_FMASG2_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_FMASG2.Stop_FMASG2_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
