class SilencedSniperSL82 extends SniperSL82;

#exec OBJ LOAD FILE=..\Sounds\CommonSniper.uax PACKAGE=CommonSniper
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Sniper_SL8_2_Reloads.uax PACKAGE=MP1_Sniper_SL8_2_Reloads
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Sniper_SL8_2_Silenced.uax PACKAGE=MP1_Sniper_SL8_2_Silenced

defaultproperties
{
    m_iClipCapacity=10
    m_iNbOfClips=3
    m_iNbOfExtraClips=2
    m_fMuzzleVelocity=30000.0
    m_MuzzleScale=0.230531
    m_fFireSoundRadius=300.0
    m_fRateOfFire=0.814167
    m_pBulletClass=Class'R6Weapons.ammo556mmNATOSubsonicFMJ'
    m_stAccuracyValues=(fBaseAccuracy=0.49644813,fShuffleAccuracy=2.7346175,fWalkingAccuracy=4.1019263,fWalkingFastAccuracy=16.920444,fRunningAccuracy=16.920444,fReticuleTime=3.053125,fAccuracyChange=2.9435184,fWeaponJump=0.7753378)
    m_szReticuleClass="SNIPER"
    m_bIsSilenced=true
    m_fFPBlend=0.908396
    m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
    m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
    m_ReloadSnd=Sound'MP1_Sniper_SL8_2_Reloads.Play_HKSL8_Reload'
    m_ReloadEmptySnd=Sound'MP1_Sniper_SL8_2_Reloads.Play_HKSL8_EmptyMag'
    m_SingleFireStereoSnd=Sound'MP1_Sniper_SL8_2_Silenced.Play_HKSL8Sil_SingleShots'
    m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
    m_szMagazineClass="ASWeapons.R63rdMAGSL82"
    m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSubGuns"
}
