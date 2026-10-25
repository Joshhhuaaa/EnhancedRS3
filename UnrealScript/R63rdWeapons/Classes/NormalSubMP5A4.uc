//============================================================================//
//  NormalSubMP5A4.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalSubMP5A4 extends SubMP5A4;

defaultproperties
{
     m_iClipCapacity=30
     m_iNbOfClips=7
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=24000.000000
     m_MuzzleScale=0.276150
     m_fFireSoundRadius=1600.000000
     m_fRateOfFire=0.075000
     m_szReticuleClass="CIRCLEDOTLINE"
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=1.396226,fShuffleAccuracy=1.564906,fWalkingAccuracy=2.347358,fWalkingFastAccuracy=9.682854,fRunningAccuracy=9.682854,fReticuleTime=0.529375,fAccuracyChange=6.966247,fWeaponJump=5.862295)
     m_fFireAnimRate=1.333333
     m_fFPBlend=0.627850
     m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
     m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
     m_ReloadSnd=Sound'Sub_MP5A4_Reloads.Play_Mp5A4_Reload'
     m_ReloadEmptySnd=Sound'Sub_MP5A4_Reloads.Play_Mp5A4_ReloadEmpty'
     m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
     m_SingleFireStereoSnd=Sound'Sub_MP5A4.Play_MP5A4_SingleShots'
     m_BurstFireStereoSnd=Sound'Sub_MP5A4.Play_MP5A4_TripleShots'
     m_FullAutoStereoSnd=Sound'Sub_MP5A4.Play_MP5A4_FullAuto'
     m_FullAutoEndStereoSnd=Sound'Sub_MP5A4.Stop_MP5A4_FullAuto_Go'
     m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG9mm"
}
