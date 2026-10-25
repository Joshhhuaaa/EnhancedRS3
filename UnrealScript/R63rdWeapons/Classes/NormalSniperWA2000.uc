//============================================================================//
//  NormalSniperWA2000.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class NormalSniperWA2000 extends SniperWA2000;

defaultproperties
{
     m_iClipCapacity=6
     m_iNbOfClips=5
     m_iNbOfExtraClips=3
     m_fMuzzleVelocity=62160.000000
     m_MuzzleScale=1.000000
     m_fFireSoundRadius=4144.000000
     m_fRateOfFire=0.858750
     m_szReticuleClass="SNIPER"
     m_pBulletClass=Class'R6Weapons.ammo30calMagnumNormalFMJ'
     m_stAccuracyValues=(fBaseAccuracy=0.809802,fShuffleAccuracy=2.327257,fWalkingAccuracy=3.490886,fWalkingFastAccuracy=14.399904,fRunningAccuracy=14.399904,fReticuleTime=3.220313,fAccuracyChange=4.156198,fWeaponJump=21.719690)
     m_fFPBlend=0.348864
     m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
     m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
     m_ReloadSnd=Sound'Sniper_WA2000_Reloads.Play_WA2000_Reload'
     m_ReloadEmptySnd=Sound'Sniper_WA2000_Reloads.Play_WA2000_ReloadEmpty'
     m_SingleFireStereoSnd=Sound'Sniper_WA2000.Play_WA2000_SingleShots'
     m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
     m_szMagazineClass="R63rdWeapons.R63rdMAG762mm"
     m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault762"
}
