//============================================================================//
//  NormalSubMTAR21.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalSubMTAR21 extends SubMTAR21;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=7
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=21000.000000
     m_MuzzleScale=0.229005
     m_fFireSoundRadius=1400.000000
     m_fRateOfFire=0.072727
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.633823,fShuffleAccuracy=1.776031,fWalkingAccuracy=2.664046,fWalkingFastAccuracy=10.989190,fRunningAccuracy=10.989190,fReticuleTime=0.657500,fAccuracyChange=7.541199,fWeaponJump=4.563125)
     m_fFireAnimRate=1.375000
     m_fFPBlend=0.637905
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Sub_MTAR21_Reloads.Play_MTAR21_Reload'
     m_ReloadEmptySnd=Sound'Sub_MTAR21_Reloads.Play_MTAR21_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Sub_MTAR21.Play_MTAR21_SingleShots'
     m_FullAutoStereoSnd=Sound'Sub_MTAR21.Play_MTAR21_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Sub_MTAR21.Stop_MTAR21_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG556mm"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleSub"
}
