class NormalSubSpectreM4 extends SubSpectreM4;

#exec OBJ LOAD FILE=..\Sounds\CommonSMG.uax PACKAGE=CommonSMG
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Sub_SpectreM4_Reloads.uax PACKAGE=MP1_Sub_SpectreM4_Reloads
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Sub_SpectreM4.uax PACKAGE=MP1_Sub_SpectreM4

defaultproperties
{
    m_iClipCapacity=50
    m_iNbOfClips=4
    m_iNbOfExtraClips=2
    m_fMuzzleVelocity=21600.0
    m_MuzzleScale=0.237932
    m_fFireSoundRadius=1440.0
    m_fRateOfFire=0.070588
    m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
    m_stAccuracyValues=(fBaseAccuracy=1.5751222,fShuffleAccuracy=1.3323411,fWalkingAccuracy=1.9985116,fWalkingFastAccuracy=8.24386,fRunningAccuracy=8.24386,fReticuleTime=0.6011875,fAccuracyChange=7.080747,fWeaponJump=3.8796678)
    m_szReticuleClass="CIRCLEDOTLINE"
    m_fFireAnimRate=1.416667
    m_fFPBlend=0.69209
    m_EquipSnd=Sound'CommonSMG.Play_SMG_Equip'
    m_UnEquipSnd=Sound'CommonSMG.Play_SMG_Unequip'
    m_ReloadSnd=Sound'MP1_Sub_SpectreM4_Reloads.Play_Spectre_Reload'
    m_ReloadEmptySnd=Sound'MP1_Sub_SpectreM4_Reloads.Play_Spectre_EmptyMag'
    m_ChangeROFSnd=Sound'CommonSMG.Play_SMG_ROF'
    m_SingleFireStereoSnd=Sound'MP1_Sub_SpectreM4.Play_Spectre_SingleShots'
    m_FullAutoStereoSnd=Sound'MP1_Sub_SpectreM4.Play_Spectre_AutoShots'
    m_FullAutoEndStereoSnd=Sound'MP1_Sub_SpectreM4.Stop_Spectre_AutoShots_Go'
    m_TriggerSnd=Sound'CommonSMG.Play_SMG_Trigger'
    m_szMagazineClass="ASWeapons.R63rdMAGSpectreM4"
}
