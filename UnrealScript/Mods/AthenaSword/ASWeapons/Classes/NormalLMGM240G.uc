class NormalLMGM240G extends LMGM240G;

#exec OBJ LOAD FILE=..\Sounds\CommonLMGs.uax PACKAGE=CommonLMGs
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Mach_M240G_Reloads.uax PACKAGE=MP1_Mach_M240G_Reloads
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Mach_M240G.uax PACKAGE=MP1_Mach_M240G

defaultproperties
{
    m_iClipCapacity=100
    m_iNbOfClips=3
    m_iNbOfExtraClips=2
    m_fMuzzleVelocity=51180.0
    m_MuzzleScale=0.934488
    m_fFireSoundRadius=3412.0
    m_fRateOfFire=0.08
    m_pBulletClass=Class'R6Weapons.ammo762mmNATONormalFMJ'
    m_stAccuracyValues=(fBaseAccuracy=0.8273362,fShuffleAccuracy=2.824463,fWalkingAccuracy=9.744397,fWalkingFastAccuracy=25.579042,fRunningAccuracy=25.579042,fReticuleTime=3.0853126,fAccuracyChange=3.0602329,fWeaponJump=7.3225827)
    m_szReticuleClass="WRETICULE"
    m_fFireAnimRate=1.25
    m_EquipSnd=Sound'CommonLMGs.Play_LMG_Equip'
    m_UnEquipSnd=Sound'CommonLMGs.Play_LMG_Unequip'
    m_ReloadSnd=Sound'MP1_Mach_M240G_Reloads.Play_M240G_Reload'
    m_ReloadEmptySnd=Sound'MP1_Mach_M240G_Reloads.Play_M240G_ReloadEmpty'
    m_SingleFireStereoSnd=Sound'MP1_Mach_M240G.Play_M240G_SingleShots'
    m_FullAutoStereoSnd=Sound'MP1_Mach_M240G.Play_M240G_AutoShots'
    m_FullAutoEndStereoSnd=Sound'MP1_Mach_M240G.Stop_M240G_AutoShots_Go'
    m_TriggerSnd=Sound'CommonLMGs.Play_LMG_Trigger'
    m_szMagazineClass="R63rdWeapons.R63rdMAGBox762mm"
    m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleMachineGuns"
}
