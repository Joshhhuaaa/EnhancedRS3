class NormalAssaultOTs14 extends AssaultOTs14;

#exec OBJ LOAD FILE=..\Sounds\CommonAssaultRiffles.uax PACKAGE=CommonAssaultRiffles
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Assault_OTs_14_Reloads.uax PACKAGE=MP1_Assault_OTs_14_Reloads
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Assault_OTs_14.uax PACKAGE=MP1_Assault_OTs_14

defaultproperties
{
    m_iClipCapacity=20
    m_iNbOfClips=6
    m_iNbOfExtraClips=3
    m_fMuzzleVelocity=18000.0
    m_MuzzleScale=0.321038
    m_fFireSoundRadius=300.0
    m_fRateOfFire=0.08
    m_pBulletClass=Class'ASWeapons.ammo9x39mmSP6NormalFMJ'
    m_stAccuracyValues=(fBaseAccuracy=1.2648498,fShuffleAccuracy=1.7356954,fWalkingAccuracy=2.603543,fWalkingFastAccuracy=10.7396145,fRunningAccuracy=10.7396145,fReticuleTime=0.5888125,fAccuracyChange=6.601028,fWeaponJump=6.6132445)
    m_szReticuleClass="RIFLE"
    m_fFireAnimRate=1.25
    m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
    m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
    m_ReloadSnd=Sound'MP1_Assault_OTs_14_Reloads.Play_Groza_Reload'
    m_ReloadEmptySnd=Sound'MP1_Assault_OTs_14_Reloads.Play_Groza_EmptyMag'
    m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
    m_SingleFireStereoSnd=Sound'MP1_Assault_OTs_14.Play_Groza_SingleShots'
    m_FullAutoStereoSnd=Sound'MP1_Assault_OTs_14.Play_Groza_AutoShots'
    m_FullAutoEndStereoSnd=Sound'MP1_Assault_OTs_14.Stop_Groza_AutoShots_Go'
    m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
    m_szMagazineClass="ASWeapons.R63rdMAGOTs14"
}
