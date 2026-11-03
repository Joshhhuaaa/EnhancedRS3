class SubMP7PDW extends R6SubMachineGun
    abstract;

#exec OBJ LOAD FILE=..\Mods\IronWrath\StaticMeshes\MP23rdWeapons_SM.usx PACKAGE=MP23rdWeapons_SM
#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2HUD.utx PACKAGE=MP2Hud

defaultproperties
{
    m_pBulletClass=Class'MP2Weapons.ammo46x30mm'
    m_pEmptyShells=Class'MP2SFX.R6Shell46mm'
    m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlashSub'
    m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1,bMiniScope=1)
    m_pFPHandsClass=Class'MP21stWeapons.MP21stHandsSubMp7PDW'
    m_pFPWeaponClass=Class'MP21stWeapons.MP21stSubMP7PDW'
    m_eGripType=GRIP_P90
    m_WithScopeSM=StaticMesh'MP23rdWeapons_SM.SubGuns.R63rdMp7PDWForScope'
    m_HUDTexture=Texture'MP2Hud.MP2_Hud_Weapon'
    m_PawnWaitAnimLow="StandP90Low_nt"
    m_PawnWaitAnimHigh="StandP90High_nt"
    m_PawnWaitAnimProne="ProneP90_nt"
    m_PawnFiringAnim="StandFireP90"
    m_PawnFiringAnimProne="ProneFireP90"
    m_PawnReloadAnim="StandReloadAug"
    m_PawnReloadAnimTactical="StandTacReloadAug"
    m_PawnReloadAnimProne="ProneReloadAug"
    m_PawnReloadAnimProneTactical="ProneTacReloadAug"
    m_vPositionOffset=(X=0.1,Y=-4.3,Z=2.5)
    m_HUDTexturePos=(W=32.0,Y=96.0,Z=100.0)
    m_NameID="SubMP7PDW"
    StaticMesh=StaticMesh'MP23rdWeapons_SM.SubGuns.R63rdMp7PDW'
}
