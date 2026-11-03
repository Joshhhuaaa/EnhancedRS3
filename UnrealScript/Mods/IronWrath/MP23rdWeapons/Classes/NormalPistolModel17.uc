class NormalPistolModel17 extends PistolModel17;

#exec OBJ LOAD FILE=..\Sounds\CommonPistols.uax PACKAGE=CommonPistols
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Pistol_Model17_Reloads.uax PACKAGE=Pistol_Model17_Reloads
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Pistol_Model17.uax PACKAGE=Pistol_Model17

defaultproperties
{
    m_iClipCapacity=17
    m_iNbOfClips=4
    m_iNbOfExtraClips=5
    m_fMuzzleVelocity=21600.0
    m_MuzzleScale=0.310345
    m_fFireSoundRadius=1440.0
    m_fRateOfFire=0.1
    m_pBulletClass=Class'R6Weapons.ammo9mmParabellumNormalFMJ'
    m_stAccuracyValues=(fBaseAccuracy=1.6637317,fShuffleAccuracy=1.5916562,fWalkingAccuracy=1.9895703,fWalkingFastAccuracy=8.206977,fRunningAccuracy=8.206977,fReticuleTime=0.849875,fAccuracyChange=9.412058,fWeaponJump=15.95022)
    m_szReticuleClass="CIRCLE"
    m_fFPBlend=0.275648
    m_EquipSnd=Sound'CommonPistols.Play_Pistol_Equip'
    m_UnEquipSnd=Sound'CommonPistols.Play_Pistol_Unequip'
    m_ReloadSnd=Sound'Pistol_Model17_Reloads.Play_Model17_Reload'
    m_ReloadEmptySnd=Sound'Pistol_Model17_Reloads.Play_Model17_ReloadEmpty'
    m_SingleFireStereoSnd=Sound'Pistol_Model17.Play_Model17_SingleShots'
    m_TriggerSnd=Sound'CommonPistols.Play_Pistol_Trigger'
    m_szTacticalLightClass="R6WeaponGadgets.R63rdTACPistol"
}
