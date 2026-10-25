//============================================================================//
//  NormalPistolCZ61.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalPistolCZ61 extends PistolCZ61;

defaultproperties
{
     m_iClipCapacity=20
     m_iNbOfClips=3
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=19080.000000
     m_MuzzleScale=0.560042
     m_fFireSoundRadius=318.000000
     m_fRateOfFire=0.071429
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo765mmAutoNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.963358,fShuffleAccuracy=2.612292,fWalkingAccuracy=3.265365,fWalkingFastAccuracy=13.469631,fRunningAccuracy=13.469631,fReticuleTime=1.086875,fAccuracyChange=8.611364,fWeaponJump=3.746794)
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
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGCZ61"
}
