class SilencedSniperSR25 extends SniperSR25;

#exec OBJ LOAD FILE=..\Sounds\CommonSniper.uax PACKAGE=CommonSniper
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Sniper_SR25_Reloads.uax PACKAGE=Sniper_SR25_Reloads
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Sniper_SR25_Silenced.uax PACKAGE=Sniper_SR25_Silenced

defaultproperties
{
    m_iClipCapacity=10
    m_iNbOfClips=3
    m_iNbOfExtraClips=2
    m_fMuzzleVelocity=30000.0
    m_MuzzleScale=0.351525
    m_fFireSoundRadius=300.0
    m_fRateOfFire=0.874583
    m_pBulletClass=Class'R6Weapons.ammo762mmNATOSubsonicFMJ'
    m_stAccuracyValues=(fBaseAccuracy=0.28904405,fShuffleAccuracy=3.0042427,fWalkingAccuracy=4.506364,fWalkingFastAccuracy=18.588753,fRunningAccuracy=18.588753,fReticuleTime=3.2796874,fAccuracyChange=2.1408646,fWeaponJump=2.88)
    m_szReticuleClass="SNIPER"
    m_bIsSilenced=true
    m_fFPBlend=0.659735
    m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
    m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
    m_ReloadSnd=Sound'Sniper_SR25_Reloads.Play_SR25_Reload'
    m_ReloadEmptySnd=Sound'Sniper_SR25_Reloads.Play_SR25_ReloadEmpty'
    m_SingleFireStereoSnd=Sound'Sniper_SR25_Silenced.Play_SR25Sil_SingleShots'
    m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
    m_szMagazineClass="R63rdWeapons.R63rdMAG762mm"
    m_szSilencerClass="R6WeaponGadgets.R63rdSilencerSnipers"
}
