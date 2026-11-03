class LMGUltimax extends R6MachineGun
    abstract;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2HUD.utx PACKAGE=MP2Hud
#exec OBJ LOAD FILE=..\Mods\IronWrath\StaticMeshes\MP23rdWeapons_SM.usx PACKAGE=MP23rdWeapons_SM

defaultproperties
{
    m_pBulletClass=Class'R6Weapons.ammo556mmNATO'
    m_pEmptyShells=Class'R6SFX.R6Shell556mmNATO'
    m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash556mm'
    m_stWeaponCaps=(bFullAuto=1,bLight=1)
    m_pFPHandsClass=Class'MP21stWeapons.MP21stHandsLMGUltimax100'
    m_pFPWeaponClass=Class'MP21stWeapons.MP21stLMGUltimax'
    m_eGripType=GRIP_Aug
    m_HUDTexture=Texture'MP2Hud.MP2_Hud_Weapon'
    m_PawnWaitAnimLow="StandAugLow_nt"
    m_PawnWaitAnimHigh="StandAugHigh_nt"
    m_PawnFiringAnim="StandFireAug"
    m_vPositionOffset=(X=-17.0,Y=0.5,Z=-0.5)
    m_HUDTexturePos=(W=32.0,X=100.0,Z=100.0)
    m_NameID="LMGUltimax"
    StaticMesh=StaticMesh'MP23rdWeapons_SM.MachineGuns.R63rdUltimax100'
}
