class CMagAssaultOTs14 extends AssaultOTs14;

#exec OBJ LOAD FILE=..\Sounds\CommonAssaultRiffles.uax PACKAGE=CommonAssaultRiffles
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Assault_OTs_14_Reloads.uax PACKAGE=MP1_Assault_OTs_14_Reloads
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Assault_OTs_14.uax PACKAGE=MP1_Assault_OTs_14

defaultproperties
{
    m_iClipCapacity=100
    m_iNbOfClips=2
    m_iNbOfExtraClips=1
    m_fMuzzleVelocity=18000.0
    m_MuzzleScale=0.321038
    m_fFireSoundRadius=300.0
    m_fRateOfFire=0.08
    m_pBulletClass=Class'ASWeapons.ammo9x39mmSP6NormalFMJ'
    m_stAccuracyValues=(fBaseAccuracy=1.2648498,fShuffleAccuracy=1.7356954,fWalkingAccuracy=2.603543,fWalkingFastAccuracy=10.7396145,fRunningAccuracy=10.7396145,fReticuleTime=1.4374375,fAccuracyChange=5.9172325,fWeaponJump=2.7920337)
    m_szReticuleClass="RIFLE"
    m_fFireAnimRate=1.25
    m_fFPBlend=0.804009
    m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
    m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
    m_ReloadSnd=Sound'MP1_Assault_OTs_14_Reloads.Play_Groza_Reload'
    m_ReloadEmptySnd=Sound'MP1_Assault_OTs_14_Reloads.Play_Groza_EmptyMag'
    m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
    m_SingleFireStereoSnd=Sound'MP1_Assault_OTs_14.Play_Groza_SingleShots'
    m_FullAutoStereoSnd=Sound'MP1_Assault_OTs_14.Play_Groza_AutoShots'
    m_FullAutoEndStereoSnd=Sound'MP1_Assault_OTs_14.Stop_Groza_AutoShots_Go'
    m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
    m_szMagazineClass="R63rdWeapons.R63rdDrumMAGAK"
}
