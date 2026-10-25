//============================================================================//
//  SilencedPistolAPArmy.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SilencedPistolAPArmy extends PistolAPArmy;

defaultproperties
{
     m_iClipCapacity=20
     m_iNbOfClips=3
     m_iNbOfExtraClips=4
     m_fMuzzleVelocity=30000.000000
     m_MuzzleScale=0.240656
     m_fFireSoundRadius=300.000000
     m_fRateOfFire=0.100000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo57x28mmSubsonicFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.412512,fShuffleAccuracy=2.018729,fWalkingAccuracy=2.523411,fWalkingFastAccuracy=10.409071,fRunningAccuracy=10.409071,fReticuleTime=1.003625,fAccuracyChange=7.836853,fWeaponJump=5.220994)
     m_bIsSilenced=True
     m_fFPBlend=0.762949
     m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
     m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
     m_ReloadSnd=Sound'Pistol_Belgian_Reloads.Play_Belgian_Reload'
     m_ReloadEmptySnd=Sound'Pistol_Belgian_Reloads.Play_Belgian_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Pistol_Belgian_Silenced.Play_BelgianSil_SingleShots'
     m_EmptyMagSnd=Sound'Pistol_Belgian_Reloads.Play_Belgian_Chamber'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szSilencerClass="R6WeaponGadgets.R63rdSilencerPistol"
}
