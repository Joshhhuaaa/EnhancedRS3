//============================================================================//
//  CMagAssaultG36K.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class CMagAssaultG36K extends AssaultG36K;

defaultproperties
{
     m_iClipCapacity=100
     m_iNbOfClips=2
     m_iNbOfExtraClips=1
     m_fMuzzleVelocity=55200.000000
     m_MuzzleScale=0.560622
     m_fFireSoundRadius=3680.000000
     m_fRateOfFire=0.080000
     m_szReticuleClass="RIFLE"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.006018,fShuffleAccuracy=2.072177,fWalkingAccuracy=3.108265,fWalkingFastAccuracy=12.821594,fRunningAccuracy=12.821594,fReticuleTime=0.973750,fAccuracyChange=6.140980,fWeaponJump=8.845573)
     m_fFireAnimRate=1.250000
     m_fFPBlend=0.298083
     m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
     m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
     m_ReloadSnd=Sound'Assault_G36K_Reloads.Play_G36K_Reload'
     m_ReloadEmptySnd=Sound'Assault_G36K_Reloads.Play_G36K_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
     m_SingleFireStereoSnd=Sound'Assault_G36K.Play_G36K_SingleShots'
     m_BurstFireStereoSnd=Sound'Assault_G36K.Play_G36K_TripleShots'
     m_FullAutoStereoSnd=Sound'Assault_G36K.Play_G36K_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Assault_G36K.Stop_G36K_AutoShots_Go'
     m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdCMAG556mm"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
