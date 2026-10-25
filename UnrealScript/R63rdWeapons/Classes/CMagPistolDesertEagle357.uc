//============================================================================//
//  CMagPistolDesertEagle357.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class CMagPistolDesertEagle357 extends PistolDesertEagle357;

defaultproperties
{
     m_iClipCapacity=18
     m_iNbOfClips=2
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=26160.000000
     m_MuzzleScale=0.365246
     m_fFireSoundRadius=1744.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo357calMagnumNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.562513,fShuffleAccuracy=1.763728,fWalkingAccuracy=2.204660,fWalkingFastAccuracy=9.094222,fRunningAccuracy=9.094222,fReticuleTime=1.160000,fAccuracyChange=8.986837,fWeaponJump=11.973579)
     m_fFPBlend=0.456359
     m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
     m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
     m_ReloadSnd=Sound'Pistol_Des357_Reloads.Play_Des357_Reload'
     m_ReloadEmptySnd=Sound'Pistol_Des357_Reloads.Play_Des357_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Pistol_Des357.Play_Des357_SingleShots'
     m_EmptyMagSnd=Sound'Pistol_Des357_Reloads.Play_Des357_Chamber'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGPistolHigh"
}
