//============================================================================//
//  SilencedPistolP228.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedPistolP228 extends PistolP228;

defaultproperties
{
     m_iClipCapacity=13
     m_iNbOfClips=4
     m_iNbOfExtraClips=6
     m_fMuzzleVelocity=28500.000000
     m_MuzzleScale=0.296012
     m_fFireSoundRadius=285.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.483718,fShuffleAccuracy=1.897680,fWalkingAccuracy=2.372100,fWalkingFastAccuracy=9.784912,fRunningAccuracy=9.784912,fReticuleTime=1.044688,fAccuracyChange=8.525638,fWeaponJump=8.333018)
     m_bIsSilenced=True
     m_fFPBlend=0.621652
     m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
     m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
     m_ReloadSnd=Sound'Pistol_P228_Reloads.Play_P228_Reload'
     m_ReloadEmptySnd=Sound'Pistol_P228_Reloads.Play_P228_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Pistol_P228_Silenced.Play_P228Sil_SingleShots'
     m_EmptyMagSnd=Sound'Pistol_P228_Reloads.Play_P228_Chamber'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerPistol"
}
