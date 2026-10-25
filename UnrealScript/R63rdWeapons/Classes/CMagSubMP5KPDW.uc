//============================================================================//
//  CMagSubMP5KPDW.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class CMagSubMP5KPDW extends SubMP5KPDW;

defaultproperties
{
     m_iClipCapacity=100
     m_iNbOfClips=2
     m_iNbOfExtraClips=1
     m_fMuzzleVelocity=22500.000000
     m_MuzzleScale=0.251792
     m_fFireSoundRadius=1500.000000
     m_fRateOfFire=0.075000
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.916317,fShuffleAccuracy=2.188787,fWalkingAccuracy=3.283181,fWalkingFastAccuracy=13.543123,fRunningAccuracy=13.543123,fReticuleTime=0.759438,fAccuracyChange=6.754191,fWeaponJump=4.549955)
     m_fFireAnimRate=1.333333
     m_fFPBlend=0.750000
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Sub_MP5KPD_Reloads.Play_MP5KPD_Reload'
     m_ReloadEmptySnd=Sound'Sub_MP5KPD_Reloads.Play_MP5KPD_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Sub_MP5KPD.Play_Mp5KPD_SingleShots'
     m_BurstFireStereoSnd=Sound'Sub_MP5KPD.Play_Mp5KPD_TripleShots'
     m_FullAutoStereoSnd=Sound'Sub_MP5KPD.Play_Mp5KPD_AutoShots'
     m_FullAutoEndStereoSnd=Sound'Sub_MP5KPD.Stop_Mp5KPD_AutoShots_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdCMAG9mmMP5"
}
