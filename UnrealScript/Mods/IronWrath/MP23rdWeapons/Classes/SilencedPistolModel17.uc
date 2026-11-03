class SilencedPistolModel17 extends PistolModel17;

#exec OBJ LOAD FILE=..\Sounds\CommonPistols.uax PACKAGE=CommonPistols
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Pistol_Model17_Reloads.uax PACKAGE=Pistol_Model17_Reloads
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Pistol_Model17_Silenced.uax PACKAGE=Pistol_Model17_Silenced

defaultproperties
{
    m_iClipCapacity=17
    m_iNbOfClips=4
    m_iNbOfExtraClips=5
    m_fMuzzleVelocity=28500.0
    m_MuzzleScale=0.296012
    m_fFireSoundRadius=285.0
    m_fRateOfFire=0.1
    m_pBulletClass=Class'R6Weapons.ammo9mmParabellumSubsonicFMJ'
    m_stAccuracyValues=(fBaseAccuracy=1.4705241,fShuffleAccuracy=1.920109,fWalkingAccuracy=2.4001362,fWalkingFastAccuracy=9.900562,fRunningAccuracy=9.900562,fReticuleTime=1.022,fAccuracyChange=8.531264,fWeaponJump=9.25965)
    m_szReticuleClass="CIRCLE"
    m_bIsSilenced=true
    m_fFPBlend=0.579489
    m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
    m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
    m_ReloadSnd=Sound'Pistol_Model17_Reloads.Play_Model17_Reload'
    m_ReloadEmptySnd=Sound'Pistol_Model17_Reloads.Play_Model17_ReloadEmpty'
    m_SingleFireStereoSnd=Sound'Pistol_Model17_Silenced.Play_Model17Sil_SingleShots'
    m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
    m_szSilencerClass="R6WeaponGadgets.R63rdSilencerPistol"
}
