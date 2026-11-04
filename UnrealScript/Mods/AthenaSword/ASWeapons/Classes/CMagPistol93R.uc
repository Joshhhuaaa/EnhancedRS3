class CMagPistol93R extends Pistol93R;

#exec OBJ LOAD FILE=..\Sounds\CommonPistols.uax PACKAGE=CommonPistols
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Pistol_93R_Reloads.uax PACKAGE=MP1_Pistol_93R_Reloads
#exec OBJ LOAD FILE=..\Sounds\CommonWeapons.uax PACKAGE=CommonWeapons
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Pistol_93R.uax PACKAGE=MP1_Pistol_93R

defaultproperties
{
    m_iClipCapacity=30
    m_iNbOfClips=2
    m_iNbOfExtraClips=2
    m_fMuzzleVelocity=22500.0
    m_MuzzleScale=0.315479
    m_fFireSoundRadius=1500.0
    m_fRateOfFire=0.054545
    m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
    m_stAccuracyValues=(fBaseAccuracy=1.590608,fShuffleAccuracy=1.7159665,fWalkingAccuracy=2.144958,fWalkingFastAccuracy=8.847952,fRunningAccuracy=8.847952,fReticuleTime=0.9606875,fAccuracyChange=9.2210865,fWeaponJump=11.75381)
    m_szReticuleClass="CIRCLE"
    m_fFPBlend=0.466221
    m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
    m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
    m_ReloadSnd=Sound'MP1_Pistol_93R_Reloads.Play_93R_Reload'
    m_ReloadEmptySnd=Sound'MP1_Pistol_93R_Reloads.Play_93R_EmptyMag'
    m_ChangeROFSnd=Sound'CommonWeapons.Play_ChangeROF'
    m_SingleFireStereoSnd=Sound'MP1_Pistol_93R.Play_93R_SingleShots'
    m_BurstFireStereoSnd=Sound'MP1_Pistol_93R.Play_93R_AutoShots'
    m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
    m_szMagazineClass="R63rdWeapons.R63rdMAGPistolHigh"
}
