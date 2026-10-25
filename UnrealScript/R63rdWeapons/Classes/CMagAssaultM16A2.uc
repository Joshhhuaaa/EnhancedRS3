//============================================================================//
//  CMagAssaultM16A2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class CMagAssaultM16A2 extends AssaultM16A2;

defaultproperties
{
     m_eRateOfFire=ROF_ThreeRound
     m_iClipCapacity=100
     m_iNbOfClips=2
     m_iNbOfExtraClips=1
     m_fMuzzleVelocity=59700.000000
     m_MuzzleScale=0.643027
     m_fFireSoundRadius=3980.000000
     m_fRateOfFire=0.072727
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.649744,fShuffleAccuracy=2.535332,fWalkingAccuracy=3.802999,fWalkingFastAccuracy=15.687368,fRunningAccuracy=15.687368,fReticuleTime=1.106875,fAccuracyChange=5.325887,fWeaponJump=9.709861)
     m_fFireAnimRate=1.375000
     m_fFPBlend=0.229500
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_M16A2_Reloads.Play_M16A2_Reload'
     m_ReloadEmptySnd=Sound'Assault_M16A2_Reloads.Play_M16A2_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_M16A2.Play_M16A2_SingleShots'
     m_BurstFireStereoSnd=Sound'Assault_M16A2.Play_M16A2_TripleShots'
     m_FullAutoStereoSnd=Sound'Assault_M16A2.Play_M16A2_DoubleShots'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdCMAG556mm"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
