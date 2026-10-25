//============================================================================//
//  NormalPistolSPP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalPistolSPP extends PistolSPP;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=2
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=21000.000000
     m_MuzzleScale=0.307039
     m_fFireSoundRadius=1400.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.949965,fShuffleAccuracy=2.635059,fWalkingAccuracy=3.293824,fWalkingFastAccuracy=13.587025,fRunningAccuracy=13.587025,fReticuleTime=1.024250,fAccuracyChange=8.861562,fWeaponJump=8.831855)
     m_fFPBlend=0.599004
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Pistol_SPP_Reloads.Play_SPP_Reload'
     m_ReloadEmptySnd=Sound'Pistol_SPP_Reloads.Play_SPP_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Sub_TMP.Play_TMP_SingleShots'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
}
