//============================================================================//
//  CMagPistolMac119.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class CMagPistolMac119 extends PistolMac119;

defaultproperties
{
     m_eRateOfFire=ROF_FullAuto
     m_iClipCapacity=32
     m_iNbOfClips=2
     m_iNbOfExtraClips=2
     m_fMuzzleVelocity=21960.000000
     m_MuzzleScale=0.624747
     m_fFireSoundRadius=1464.000000
     m_fRateOfFire=0.050000
     m_szReticuleClass="CIRCLE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=2.532495,fShuffleAccuracy=3.344759,fWalkingAccuracy=4.180949,fWalkingFastAccuracy=17.246412,fRunningAccuracy=17.246412,fReticuleTime=1.143687,fAccuracyChange=9.213383,fWeaponJump=6.324285)
     m_fFireAnimRate=2.000000
     m_fFPBlend=0.498153
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Mult_Mac11_Reloads.Play_Mac11_Reload'
     m_ReloadEmptySnd=Sound'Mult_Mac11_Reloads.Play_Mac11_ReloadEmpty'
     m_FullAutoStereoSnd=Sound'Mult_Mac11.Play_Ingram_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Mult_Mac11.Stop_Ingram_AutoShots_Go'
     m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAGPistolHigh"
}
