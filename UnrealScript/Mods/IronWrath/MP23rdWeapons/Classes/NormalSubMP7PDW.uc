class NormalSubMP7PDW extends SubMP7PDW;

#exec OBJ LOAD FILE=..\Sounds\CommonSMG.uax PACKAGE=CommonSMG
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Sub_MP7PDW_Reloads.uax PACKAGE=Sub_MP7PDW_Reloads
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Sub_MP7PDW.uax PACKAGE=Sub_MP7PDW

defaultproperties
{
    m_iClipCapacity=40
    m_iNbOfClips=5
    m_iNbOfExtraClips=3
    m_fMuzzleVelocity=43500.0
    m_MuzzleScale=0.216919
    m_fFireSoundRadius=2900.0
    m_fRateOfFire=0.063158
    m_pBulletClass=Class'MP2Weapons.ammo46x30mmNormalFMJ'
    m_stAccuracyValues=(fBaseAccuracy=1.8749658,fShuffleAccuracy=3.0875444,fWalkingAccuracy=4.6313167,fWalkingFastAccuracy=19.104181,fRunningAccuracy=19.104181,fReticuleTime=0.1680625,fAccuracyChange=7.602234,fWeaponJump=8.191559)
    m_szReticuleClass="CIRCLEDOTLINE"
    m_fFireAnimRate=1.583333
    m_fFPBlend=0.349876
    m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
    m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
    m_ReloadSnd=Sound'Sub_MP7PDW_Reloads.Play_MP7PDW_Reload'
    m_ReloadEmptySnd=Sound'Sub_MP7PDW_Reloads.Play_MP7PDW_ReloadEmpty'
    m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
    m_SingleFireStereoSnd=Sound'Sub_MP7PDW.Play_MP7PDW_SingleShots'
    m_FullAutoStereoSnd=Sound'Sub_MP7PDW.Play_MP7PDW_AutoShots'
    m_FullAutoEndStereoSnd=Sound'Sub_MP7PDW.Stop_MP7PDW_AutoShots_Go'
    m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
    m_szMagazineClass="MP23rdWeapons.R63rdMAGMp7PDW"
    m_szMuzzleClass="R6WeaponGadgets.R63rdMuzzleSub"
}
