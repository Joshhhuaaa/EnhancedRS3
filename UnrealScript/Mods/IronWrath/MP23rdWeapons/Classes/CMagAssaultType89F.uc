class CMagAssaultType89F extends AssaultType89F;

#exec OBJ LOAD FILE=..\Sounds\CommonAssaultRiffles.uax PACKAGE=CommonAssaultRiffles
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Assault_Type89F_Reloads.uax PACKAGE=Assault_Type89F_Reloads
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Assault_Type89F.uax PACKAGE=Assault_Type89F

defaultproperties
{
    m_iClipCapacity=100
    m_iNbOfClips=2
    m_iNbOfExtraClips=1
    m_fMuzzleVelocity=55200.0
    m_MuzzleScale=0.560622
    m_fFireSoundRadius=3680.0
    m_fRateOfFire=0.08
    m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
    m_stAccuracyValues=(fBaseAccuracy=0.84508395,fShuffleAccuracy=2.281391,fWalkingAccuracy=3.4220862,fWalkingFastAccuracy=14.116106,fRunningAccuracy=14.116106,fReticuleTime=1.1215,fAccuracyChange=5.501097,fWeaponJump=7.8484364)
    m_szReticuleClass="RIFLE"
    m_fFireAnimRate=1.25
    m_fFPBlend=0.449069
    m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
    m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
    m_ReloadSnd=Sound'Assault_Type89F_Reloads.Play_Type89F_Reload'
    m_ReloadEmptySnd=Sound'Assault_Type89F_Reloads.Play_Type89F_ReloadEmpty'
    m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
    m_SingleFireStereoSnd=Sound'Assault_Type89F.Play_Type89F_SingleShots'
    m_BurstFireStereoSnd=Sound'Assault_Type89F.Play_Type89F_TripleShots'
    m_FullAutoStereoSnd=Sound'Assault_Type89F.Play_Type89F_AutoShots'
    m_FullAutoEndStereoSnd=Sound'Assault_Type89F.Stop_Type89F_AutoShots_Go'
    m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
    m_szMagazineClass="R63rdWeapons.R63rdCMAG556mm"
    m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleAssault556"
}
