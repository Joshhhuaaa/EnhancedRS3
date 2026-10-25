//============================================================================//
//  CMagPistolP228.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class CMagPistolP228 extends PistolP228;

defaultproperties
{
     m_iClipCapacity=26
     m_iNbOfClips=3
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=21960.000000
     m_MuzzleScale=0.312373
     m_fFireSoundRadius=1464.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.676925,fShuffleAccuracy=1.569227,fWalkingAccuracy=1.961534,fWalkingFastAccuracy=8.091328,fRunningAccuracy=8.091328,fReticuleTime=0.913250,fAccuracyChange=9.401095,fWeaponJump=11.843024)
     m_fFPBlend=0.462286
     m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
     m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
     m_ReloadSnd=Sound'Pistol_P228_Reloads.Play_P228_Reload'
     m_ReloadEmptySnd=Sound'Pistol_P228_Reloads.Play_P228_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Pistol_P228.Play_P228_SingleShots'
     m_EmptyMagSnd=Sound'Pistol_P228_Reloads.Play_P228_Chamber'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGPistolHigh"
}
