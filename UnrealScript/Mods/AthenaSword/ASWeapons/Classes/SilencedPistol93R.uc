class SilencedPistol93R extends Pistol93R;

#exec OBJ LOAD FILE=..\Sounds\CommonPistols.uax PACKAGE=CommonPistols
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Pistol_93R_Reloads.uax PACKAGE=MP1_Pistol_93R_Reloads
#exec OBJ LOAD FILE=..\Sounds\CommonWeapons.uax PACKAGE=CommonWeapons
#exec OBJ LOAD FILE=..\Mods\AthenaSword\Sounds\MP1_Pistol_93R_Silenced.uax PACKAGE=MP1_Pistol_93R_Silenced

defaultproperties
{
    m_iClipCapacity=20
    m_iNbOfClips=3
    m_iNbOfExtraClips=4
    m_fMuzzleVelocity=28500.0
    m_MuzzleScale=0.296012
    m_fFireSoundRadius=285.0
    m_fRateOfFire=0.054545
    m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
    m_stAccuracyValues=(fBaseAccuracy=1.3974004,fShuffleAccuracy=2.0444193,fWalkingAccuracy=2.555524,fWalkingFastAccuracy=10.541537,fRunningAccuracy=10.541537,fReticuleTime=1.1015,fAccuracyChange=8.45626,fWeaponJump=7.6551337)
    m_szReticuleClass="CIRCLE"
    m_bIsSilenced=true
    m_fFPBlend=0.652355
    m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
    m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
    m_ReloadSnd=Sound'MP1_Pistol_93R_Reloads.Play_93R_Reload'
    m_ReloadEmptySnd=Sound'MP1_Pistol_93R_Reloads.Play_93R_EmptyMag'
    m_ChangeROFSnd=Sound'CommonWeapons.Play_ChangeROF'
    m_SingleFireStereoSnd=Sound'MP1_Pistol_93R_Silenced.Play_93RSil_SingleShots'
    m_BurstFireStereoSnd=Sound'MP1_Pistol_93R_Silenced.Play_93RSil_AutoShots'
    m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
    m_szMagazineClass="R63rdWeapons.R63rdMAGPistol"
    m_szSilencerClass="R6WeaponGadgets.R63rdSilencerPistol"
}
