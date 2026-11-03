class SniperSR25 extends R6SniperRifle
    abstract;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2HUD.utx PACKAGE=MP2Hud
#exec OBJ LOAD FILE=..\Mods\IronWrath\StaticMeshes\MP23rdWeapons_SM.usx PACKAGE=MP23rdWeapons_SM

defaultproperties
{
    m_pBulletClass=Class'R6Weapons.ammo762mmNATO'
    m_pEmptyShells=Class'R6SFX.R6Shell762mmNATO'
    m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash762mm'
    m_stWeaponCaps=(bSingle=1,bSilencer=1,bLight=1,bHeatVision=1)
    m_pFPHandsClass=Class'R61stWeapons.R61stHandsSniperDragunov'
    m_pFPWeaponClass=Class'MP21stWeapons.MP21stSniperSR25'
    m_HUDTexture=Texture'MP2Hud.MP2_Hud_Weapon'
    m_PawnWaitAnimLow="StandLMGLow_nt"
    m_PawnWaitAnimHigh="StandLMGHigh_nt"
    m_PawnWaitAnimProne="ProneSniper_nt"
    m_PawnFiringAnim="StandFireLmg"
    m_PawnFiringAnimProne="ProneBipodFireSniper"
    m_PawnReloadAnimProne="ProneReloadSniper"
    m_PawnReloadAnimProneTactical="ProneTacReloadSniper"
    m_vPositionOffset=(X=3.0,Y=0.5,Z=-2.5)
    m_HUDTexturePos=(W=32.0,X=100.0,Y=32.0,Z=100.0)
    m_NameID="SniperSR25"
    StaticMesh=StaticMesh'MP23rdWeapons_SM.SniperRifles.R63rdSR25'
}
