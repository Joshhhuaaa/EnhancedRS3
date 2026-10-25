//============================================================================//
//  NormalSubCZ61.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalSubCZ61 extends SubCZ61;

defaultproperties
{
     m_iClipCapacity=20
     m_iNbOfClips=10
     m_iNbOfExtraClips=4
     m_fMuzzleVelocity=19080.000000
     m_MuzzleScale=0.420032
     m_fFireSoundRadius=318.000000
     m_fRateOfFire=0.071429
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo765mmAutoNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.733978,fShuffleAccuracy=1.905828,fWalkingAccuracy=2.858742,fWalkingFastAccuracy=11.792312,fRunningAccuracy=11.792312,fReticuleTime=0.226375,fAccuracyChange=7.397267,fWeaponJump=3.746794)
     m_fFireAnimRate=1.400000
     m_fFPBlend=0.702683
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Mult_CZ61_Reloads.Play_CZ61_Reload'
     m_ReloadEmptySnd=Sound'Mult_CZ61_Reloads.Play_CZ61_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Mult_CZ61.Play_CZ61_SingleShots'
     m_FullAutoStereoSnd=Sound'Mult_CZ61.Play_CZ61_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Mult_CZ61.Stop_CZ61_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGCZ61"
}
