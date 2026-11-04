class SilencedSubSpectreM4 extends SubSpectreM4;

#exec OBJ LOAD FILE=..\Sounds\CommonSMG.uax PACKAGE=CommonSMG
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Sub_SpectreM4_Reloads.uax PACKAGE=MP1_Sub_SpectreM4_Reloads
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Sub_SpectreM4_Silenced.uax PACKAGE=MP1_Sub_SpectreM4_Silenced

defaultproperties
{
    m_iClipCapacity=50
    m_iNbOfClips=4
    m_iNbOfExtraClips=2
    m_fMuzzleVelocity=28500.0
    m_MuzzleScale=0.272596
    m_fFireSoundRadius=285.0
    m_fRateOfFire=0.070588
    m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
    m_stAccuracyValues=(fBaseAccuracy=1.3348707,fShuffleAccuracy=1.6446681,fWalkingAccuracy=2.4670022,fWalkingFastAccuracy=10.176384,fRunningAccuracy=10.176384,fReticuleTime=0.8155,fAccuracyChange=6.188214,fWeaponJump=2.109434)
    m_szReticuleClass="CIRCLEDOTLINE"
    m_bIsSilenced=true
    m_fFireAnimRate=1.416667
    m_fFPBlend=0.75
    m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
    m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
    m_ReloadSnd=Sound'MP1_Sub_SpectreM4_Reloads.Play_Spectre_Reload'
    m_ReloadEmptySnd=Sound'MP1_Sub_SpectreM4_Reloads.Play_Spectre_EmptyMag'
    m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
    m_SingleFireStereoSnd=Sound'MP1_Sub_SpectreM4_Silenced.Play_SpectreSil_SingleShots'
    m_FullAutoStereoSnd=Sound'MP1_Sub_SpectreM4_Silenced.Play_SpectreSil_AutoShots'
    m_FullAutoEndStereoSnd=Sound'MP1_Sub_SpectreM4_Silenced.Stop_SpectreSil_AutoShots_Go'
    m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
    m_szMagazineClass="ASWeapons.R63rdMAGSpectreM4"
    m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
