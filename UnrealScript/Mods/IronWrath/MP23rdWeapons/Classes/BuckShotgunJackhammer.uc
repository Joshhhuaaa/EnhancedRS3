class BuckShotgunJackhammer extends ShotgunJackhammer;

#exec OBJ LOAD FILE=..\Sounds\CommonShotguns.uax PACKAGE=CommonShotguns
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Shotgun_Jackhammer_Reloads.uax PACKAGE=Shotgun_Jackhammer_Reloads
#exec OBJ LOAD FILE=..\Sounds\CommonWeapons.uax PACKAGE=CommonWeapons
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Shotgun_Jackhammer.uax PACKAGE=Shotgun_Jackhammer

defaultproperties
{
    m_eRateOfFire=ROF_FullAuto
    m_iClipCapacity=10
    m_iNbOfClips=4
    m_iNbOfExtraClips=2
    m_fMuzzleVelocity=24780.0
    m_MuzzleScale=0.646452
    m_fFireSoundRadius=1652.0
    m_fRateOfFire=0.25
    m_pBulletClass=Class'R6Weapons.ammo12gaugeBuck'
    m_stAccuracyValues=(fBaseAccuracy=3.619642,fShuffleAccuracy=2.8089309,fWalkingAccuracy=3.5111635,fWalkingFastAccuracy=9.2168045,fRunningAccuracy=9.2168045,fReticuleTime=0.9664375,fAccuracyChange=8.026272,fWeaponJump=15.927639)
    m_szReticuleClass="CIRCLEDOT"
    m_fFPBlend=0.135777
    m_EquipSnd=Sound'CommonShotguns.Play_Shotgun_Equip'
    m_UnEquipSnd=Sound'CommonShotguns.Play_Shotgun_Unequip'
    m_ReloadSnd=Sound'Shotgun_Jackhammer_Reloads.Play_Jackhammer_Reload'
    m_ReloadEmptySnd=Sound'Shotgun_Jackhammer_Reloads.Play_Jackhammer_ReloadEmpty'
    m_ChangeROFSnd=Sound'CommonWeapons.Play_ChangeROF'
    m_SingleFireStereoSnd=Sound'Shotgun_Jackhammer.Play_Jackhammer_SingleShots'
    m_FullAutoStereoSnd=Sound'Shotgun_Jackhammer.Play_Jackhammer_AutoShots'
    m_FullAutoEndStereoSnd=Sound'Shotgun_Jackhammer.Stop_Jackhammer_AutoShots_Go'
    m_TriggerSnd=Sound'CommonShotguns.Play_Shotgun_Trigger'
}
