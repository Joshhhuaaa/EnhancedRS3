class SlugShotgunJackhammer extends ShotgunJackhammer;

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
    m_fMuzzleVelocity=28320.0
    m_MuzzleScale=0.970251
    m_fFireSoundRadius=1888.0
    m_fRateOfFire=0.25
    m_pBulletClass=Class'R6Weapons.ammo12gaugeSlug'
    m_pEmptyShells=Class'R6SFX.R6Shell12GaugeSlug'
    m_stAccuracyValues=(fBaseAccuracy=1.4478568,fShuffleAccuracy=1.9586434,fWalkingAccuracy=2.4483044,fWalkingFastAccuracy=10.099256,fRunningAccuracy=10.099256,fReticuleTime=0.9664375,fAccuracyChange=6.4046326,fWeaponJump=18.822166)
    m_szReticuleClass="CIRCLEDOT"
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
