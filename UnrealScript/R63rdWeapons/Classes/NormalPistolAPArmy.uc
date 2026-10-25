//============================================================================//
//  NormalPistolAPArmy.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalPistolAPArmy extends PistolAPArmy;

defaultproperties
{
     m_iClipCapacity=20
     m_iNbOfClips=3
     m_iNbOfExtraClips=4
     m_fMuzzleVelocity=39000.000000
     m_MuzzleScale=0.303341
     m_fFireSoundRadius=2600.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo57x28mmNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.605720,fShuffleAccuracy=1.690276,fWalkingAccuracy=2.112845,fWalkingFastAccuracy=8.715486,fRunningAccuracy=8.715486,fReticuleTime=0.831500,fAccuracyChange=9.230096,fWeaponJump=17.206654)
     m_fFPBlend=0.218759
     m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
     m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
     m_ReloadSnd=Sound'Pistol_Belgian_Reloads.Play_Belgian_Reload'
     m_ReloadEmptySnd=Sound'Pistol_Belgian_Reloads.Play_Belgian_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Pistol_Belgian.Play_Belgian_SingleShots'
     m_EmptyMagSnd=Sound'Pistol_Belgian_Reloads.Play_Belgian_Chamber'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szTacticalLightClass="R6WeaponGadgets.R63rdTACPistol"
}
