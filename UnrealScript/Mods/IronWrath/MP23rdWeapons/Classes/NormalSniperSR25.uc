class NormalSniperSR25 extends SniperSR25;

#exec OBJ LOAD FILE=..\Sounds\CommonSniper.uax PACKAGE=CommonSniper
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Sniper_SR25_Reloads.uax PACKAGE=Sniper_SR25_Reloads
#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Sniper_SR25.uax PACKAGE=Sniper_SR25

defaultproperties
{
    m_iClipCapacity=10
    m_iNbOfClips=3
    m_iNbOfExtraClips=2
    m_fMuzzleVelocity=50280.0
    m_MuzzleScale=0.835848
    m_fFireSoundRadius=3352.0
    m_fRateOfFire=0.749583
    m_pBulletClass=Class'R6Weapons.ammo762mmNATONormalFMJ'
    m_stAccuracyValues=(fBaseAccuracy=0.5846415,fShuffleAccuracy=2.619966,fWalkingAccuracy=3.929949,fWalkingFastAccuracy=16.21104,fRunningAccuracy=16.21104,fReticuleTime=2.8109374,fAccuracyChange=3.284827,fWeaponJump=13.965079)
    m_szReticuleClass="SNIPER"
    m_EquipSnd=Sound'CommonSniper.Play_Sniper_Equip'
    m_UnEquipSnd=Sound'CommonSniper.Play_Sniper_Unequip'
    m_ReloadSnd=Sound'Sniper_SR25_Reloads.Play_SR25_Reload'
    m_ReloadEmptySnd=Sound'Sniper_SR25_Reloads.Play_SR25_ReloadEmpty'
    m_SingleFireStereoSnd=Sound'Sniper_SR25.Play_SR25_SingleShots'
    m_TriggerSnd=Sound'CommonSniper.Play_Sniper_Trigger'
    m_szMagazineClass="R63rdWeapons.R63rdMAG762mm"
}
