class NormalAssaultG3KA4 extends AssaultG3KA4;

#exec OBJ LOAD FILE=..\Sounds\CommonAssaultRiffles.uax PACKAGE=CommonAssaultRiffles
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Assault_G3KA4_Reloads.uax PACKAGE=MP1_Assault_G3KA4_Reloads
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Assault_G3KA4.uax PACKAGE=MP1_Assault_G3KA4

defaultproperties
{
    m_iClipCapacity=20
    m_iNbOfClips=6
    m_iNbOfExtraClips=3
    m_fMuzzleVelocity=47400.0
    m_MuzzleScale=0.812218
    m_fFireSoundRadius=3160.0
    m_fRateOfFire=0.109091
    m_pBulletClass=Class'R6Weapons.ammo762mmNATONormalFMJ'
    m_stAccuracyValues=(fBaseAccuracy=1.0326681,fShuffleAccuracy=2.0375314,fWalkingAccuracy=3.0562973,fWalkingFastAccuracy=12.607226,fRunningAccuracy=12.607226,fReticuleTime=0.94375,fAccuracyChange=6.3906374,fWeaponJump=14.245761)
    m_szReticuleClass="RIFLE"
    m_fFireAnimRate=0.916667
    m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
    m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
    m_ReloadSnd=Sound'MP1_Assault_G3KA4_Reloads.Play_G3KA4_Reload'
    m_ReloadEmptySnd=Sound'MP1_Assault_G3KA4_Reloads.Play_G3KA4_EmptyMag'
    m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
    m_SingleFireStereoSnd=Sound'MP1_Assault_G3KA4.Play_G3KA4_SingleShots'
    m_FullAutoStereoSnd=Sound'MP1_Assault_G3KA4.Play_G3KA4_AutoShots'
    m_FullAutoEndStereoSnd=Sound'MP1_Assault_G3KA4.Stop_G3KA4_AutoShots_Go'
    m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
    m_szMagazineClass="R63rdWeapons.R63rdMAG762mm2"
    m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault762"
}
