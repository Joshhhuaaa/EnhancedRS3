class NormalLMGUltimax extends LMGUltimax;

#exec OBJ LOAD FILE=..\Sounds\CommonLMGs.uax PACKAGE=CommonLMGs
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Mach_Ultimax_Reloads.uax PACKAGE=Mach_Ultimax_Reloads
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Mach_Ultimax.uax PACKAGE=Mach_Ultimax

defaultproperties
{
    m_iClipCapacity=100
    m_iNbOfClips=4
    m_iNbOfExtraClips=2
    m_fMuzzleVelocity=54900.0
    m_MuzzleScale=0.755358
    m_fFireSoundRadius=1830.0
    m_fRateOfFire=0.12
    m_pBulletClass=Class'R6Weapons.ammo556mmNATONormalFMJ'
    m_stAccuracyValues=(fBaseAccuracy=1.2592009,fShuffleAccuracy=2.2630389,fWalkingAccuracy=7.8074837,fWalkingFastAccuracy=20.494644,fRunningAccuracy=20.494644,fReticuleTime=1.605,fAccuracyChange=3.412948,fWeaponJump=5.02335)
    m_szReticuleClass="WRETICULE"
    m_fFireAnimRate=0.833333
    m_fFPBlend=0.313992
    m_EquipSnd=Sound'CommonLMGs.Play_LMG_Equip'
    m_UnEquipSnd=Sound'CommonLMGs.Play_LMG_Unequip'
    m_ReloadSnd=Sound'Mach_Ultimax_Reloads.Play_Ultimax_Reload'
    m_ReloadEmptySnd=Sound'Mach_Ultimax_Reloads.Play_Ultimax_ReloadEmpty'
    m_SingleFireStereoSnd=Sound'Mach_Ultimax.Play_Ultimax_SingleShots'
    m_FullAutoStereoSnd=Sound'Mach_Ultimax.Play_Ultimax_AutoShots'
    m_FullAutoEndStereoSnd=Sound'Mach_Ultimax.Stop_Ultimax_AutoShots_Go'
    m_TriggerSnd=Sound'CommonLMGs.Play_LMG_Trigger'
    m_szMagazineClass="MP23rdWeapons.R63rdMAGUltimax100"
    m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleMachineGuns"
}
