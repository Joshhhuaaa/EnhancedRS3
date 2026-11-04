class SlugShotgunM4Super90 extends ShotgunM4Super90;

#exec OBJ LOAD FILE=..\Sounds\CommonShotguns.uax PACKAGE=CommonShotguns
#exec OBJ LOAD FILE=..\Sounds\Shotgun_M1_Reloads.uax PACKAGE=Shotgun_M1_Reloads
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Shotgun_M4super90.uax PACKAGE=MP1_Shotgun_M4super90

defaultproperties
{
    m_iClipCapacity=6
    m_iNbOfClips=34
    m_iNbOfExtraClips=20
    m_fMuzzleVelocity=28320.0
    m_MuzzleScale=0.970251
    m_fFireSoundRadius=1888.0
    m_fRateOfFire=0.3
    m_pBulletClass=Class'R6Weapons.ammo12gaugeSlug'
    m_pEmptyShells=Class'R6SFX.R6Shell12GaugeSlug'
    m_stAccuracyValues=(fBaseAccuracy=1.2149544,fShuffleAccuracy=2.3545775,fWalkingAccuracy=2.943222,fWalkingFastAccuracy=12.140791,fRunningAccuracy=12.140791,fReticuleTime=0.9068125,fAccuracyChange=5.3089066,fWeaponJump=23.0)
    m_szReticuleClass="CIRCLEDOT"
    m_EquipSnd=Sound'CommonShotguns.Play_Shotgun_Equip'
    m_UnEquipSnd=Sound'CommonShotguns.Play_Shotgun_Unequip'
    m_ReloadEmptySnd=Sound'Shotgun_M1_Reloads.Play_M1_ReloadEmpty'
    m_SingleFireStereoSnd=Sound'MP1_Shotgun_M4super90.Play_M4_SingleShots'
    m_TriggerSnd=Sound'CommonShotguns.Play_Shotgun_Trigger'
}
