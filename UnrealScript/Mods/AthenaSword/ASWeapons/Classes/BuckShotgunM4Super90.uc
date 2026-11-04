class BuckShotgunM4Super90 extends ShotgunM4Super90;

#exec OBJ LOAD FILE=..\Sounds\CommonShotguns.uax PACKAGE=CommonShotguns
#exec OBJ LOAD FILE=..\Sounds\Shotgun_M1_Reloads.uax PACKAGE=Shotgun_M1_Reloads
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Shotgun_M4super90.uax PACKAGE=MP1_Shotgun_M4super90

defaultproperties
{
    m_iClipCapacity=6
    m_iNbOfClips=34
    m_iNbOfExtraClips=20
    m_fMuzzleVelocity=24780.0
    m_MuzzleScale=0.646452
    m_fFireSoundRadius=1652.0
    m_fRateOfFire=0.3
    m_pBulletClass=Class'R6Weapons.ammo12gaugeBuck'
    m_stAccuracyValues=(fBaseAccuracy=3.2398784,fShuffleAccuracy=3.7963161,fWalkingAccuracy=4.745395,fWalkingFastAccuracy=12.456663,fRunningAccuracy=12.456663,fReticuleTime=0.9068125,fAccuracyChange=7.2914286,fWeaponJump=20.0)
    m_szReticuleClass="CIRCLEDOT"
    m_EquipSnd=Sound'CommonShotguns.Play_Shotgun_Equip'
    m_UnEquipSnd=Sound'CommonShotguns.Play_Shotgun_Unequip'
    m_ReloadEmptySnd=Sound'Shotgun_M1_Reloads.Play_M1_ReloadEmpty'
    m_SingleFireStereoSnd=Sound'MP1_Shotgun_M4super90.Play_M4_SingleShots'
    m_TriggerSnd=Sound'CommonShotguns.Play_Shotgun_Trigger'
}
