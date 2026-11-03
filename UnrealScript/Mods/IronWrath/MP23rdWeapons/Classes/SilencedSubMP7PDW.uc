class SilencedSubMP7PDW extends SubMP7PDW;

#exec OBJ LOAD FILE=..\Sounds\CommonSMG.uax PACKAGE=CommonSMG
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Sub_MP7PDW_Reloads.uax PACKAGE=Sub_MP7PDW_Reloads
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Sub_MP7PDW_Silenced.uax PACKAGE=Sub_MP7PDW_Silenced

defaultproperties
{
    m_iClipCapacity=40
    m_iNbOfClips=5
    m_iNbOfExtraClips=3
    m_fMuzzleVelocity=28500.0
    m_MuzzleScale=0.205776
    m_fFireSoundRadius=285.0
    m_fRateOfFire=0.063158
    m_pBulletClass=Class'MP2Weapons.ammo46x30mmSubsonicFMJ'
    m_stAccuracyValues=(fBaseAccuracy=1.5746514,fShuffleAccuracy=3.4779532,fWalkingAccuracy=5.21693,fWalkingFastAccuracy=21.519836,fRunningAccuracy=21.519836,fReticuleTime=0.3068125,fAccuracyChange=5.8973846,fWeaponJump=1.1420035)
    m_szReticuleClass="CIRCLEDOTLINE"
    m_bIsSilenced=true
    m_fFireAnimRate=1.583333
    m_fFPBlend=0.909365
    m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
    m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
    m_ReloadSnd=Sound'Sub_MP7PDW_Reloads.Play_MP7PDW_Reload'
    m_ReloadEmptySnd=Sound'Sub_MP7PDW_Reloads.Play_MP7PDW_ReloadEmpty'
    m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
    m_SingleFireStereoSnd=Sound'Sub_MP7PDW_Silenced.Play_MP7PDWSil_SingleShots'
    m_FullAutoStereoSnd=Sound'Sub_MP7PDW_Silenced.Play_MP7PDWSil_AutoShots'
    m_FullAutoEndStereoSnd=Sound'Sub_MP7PDW_Silenced.Stop_MP7PDWSil_AutoShots_Go'
    m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
    m_szMagazineClass="MP23rdWeapons.R63rdMAGMp7PDW"
    m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
