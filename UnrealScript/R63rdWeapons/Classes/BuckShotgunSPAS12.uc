//============================================================================//
//  BuckShotgunSPAS12.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class BuckShotgunSPAS12 extends ShotgunSPAS12;

defaultproperties
{
     m_iClipCapacity=8
     m_iNbOfClips=32
     m_iNbOfExtraClips=20
     m_fMuzzleVelocity=24780.000000
     m_MuzzleScale=0.646452
     m_fFireSoundRadius=1652.000000
     m_fRateOfFire=0.684333
     m_szReticuleClass="CIRCLEDOT"
     m_pBulletClass=Class'R6Weapons.ammo12gaugeBuck'
     m_stAccuracyValues=(fBaseAccuracy=3.295598,fShuffleAccuracy=3.651447,fWalkingAccuracy=4.564308,fWalkingFastAccuracy=11.981309,fRunningAccuracy=11.981309,fReticuleTime=1.039750,fAccuracyChange=7.399245,fWeaponJump=17.176865)
     m_fFPBlend=0.067994
     m_EquipSnd=Sound'CommonShotguns.Play_Shotgun_Equip'
     m_UnEquipSnd=Sound'CommonShotguns.Play_Shotgun_Unequip'
     m_ReloadEmptySnd=Sound'Shotgun_SPAS12_Reloads.Play_SPAS12_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Shotgun_SPAS12.Play_SPAS12_SingleShots'
     m_TriggerSnd=Sound'CommonShotguns.Play_Shotgun_Trigger'
}
