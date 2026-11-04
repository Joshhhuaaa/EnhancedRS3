class SilencedAssaultG3KA4 extends AssaultG3KA4;

#exec OBJ LOAD FILE=..\Sounds\CommonAssaultRiffles.uax PACKAGE=CommonAssaultRiffles
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Assault_G3KA4_Reloads.uax PACKAGE=MP1_Assault_G3KA4_Reloads
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Assault_G3KA4_Silenced.uax PACKAGE=MP1_Assault_G3KA4_Silenced

defaultproperties
{
    m_iClipCapacity=20
    m_iNbOfClips=6
    m_iNbOfExtraClips=3
    m_fMuzzleVelocity=28600.0
    m_MuzzleScale=0.336573
    m_fFireSoundRadius=286.0
    m_fRateOfFire=0.109091
    m_pBulletClass=Class'R6Weapons.ammo762mmNATOSubsonicFMJ'
    m_stAccuracyValues=(fBaseAccuracy=0.6553096,fShuffleAccuracy=2.5280976,fWalkingAccuracy=3.7921462,fWalkingFastAccuracy=15.642604,fRunningAccuracy=15.642604,fReticuleTime=1.26625,fAccuracyChange=3.5583122,fWeaponJump=2.9337902)
    m_szReticuleClass="RIFLE"
    m_bIsSilenced=true
    m_fFireAnimRate=0.916667
    m_fFPBlend=0.75
    m_EquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Equip'
    m_UnEquipSnd=Sound'CommonAssaultRiffles.Play_Assault_Unequip'
    m_ReloadSnd=Sound'MP1_Assault_G3KA4_Reloads.Play_G3KA4_Reload'
    m_ReloadEmptySnd=Sound'MP1_Assault_G3KA4_Reloads.Play_G3KA4_EmptyMag'
    m_ChangeROFSnd=Sound'CommonAssaultRiffles.Play_Assault_ROF'
    m_SingleFireStereoSnd=Sound'MP1_Assault_G3KA4_Silenced.Play_G3KA4Sil_SingleShots'
    m_FullAutoStereoSnd=Sound'MP1_Assault_G3KA4_Silenced.Play_G3KA4Sil_AutoShots'
    m_FullAutoEndStereoSnd=Sound'MP1_Assault_G3KA4_Silenced.Stop_G3KA4Sil_AutoShots_Go'
    m_TriggerSnd=Sound'CommonAssaultRiffles.Play_Assault_Trigger'
    m_szMagazineClass="R63rdWeapons.R63rdMAG762mm2"
    m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns2"
}
