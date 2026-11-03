class ShotgunJackhammer extends R6Shotgun
    abstract;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2HUD.utx PACKAGE=MP2Hud
#exec OBJ LOAD FILE=..\Mods\IronWrath\StaticMeshes\MP23rdWeapons_SM.usx PACKAGE=MP23rdWeapons_SM

defaultproperties
{
    m_pBulletClass=Class'R6Weapons.ammo12gauge'
    m_pEmptyShells=Class'R6SFX.R6Shell12GaugeBuck'
    m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash12Gauge'
    m_stWeaponCaps=(bSingle=1,bFullAuto=1,bLight=1,bMiniScope=1)
    m_pFPHandsClass=Class'MP21stWeapons.MP21stHandsShotgunJackhammer'
    m_pFPWeaponClass=Class'MP21stWeapons.MP21stShotgunJackhammer'
    m_HUDTexture=Texture'MP2Hud.MP2_Hud_Weapon'
    m_PawnWaitAnimLow="StandBullPupLow_nt"
    m_PawnWaitAnimHigh="StandBullPupHigh_nt"
    m_PawnWaitAnimProne="ProneBullPup_nt"
    m_PawnFiringAnim="StandFireBullPup"
    m_PawnFiringAnimProne="ProneFireBullPup"
    m_PawnReloadAnim="StandReloadAug"
    m_PawnReloadAnimProne="ProneReloadAug"
    m_vPositionOffset=(X=-0.5,Y=-3.0,Z=2.5)
    m_HUDTexturePos=(W=32.0,Y=32.0,Z=100.0)
    m_NameID="ShotgunJackhammer"
    m_szMagazineClass="MP23rdWeapons.R63rdMAGJackhammer"
    StaticMesh=StaticMesh'MP23rdWeapons_SM.Shotguns.R63rdJackhammer'
}
