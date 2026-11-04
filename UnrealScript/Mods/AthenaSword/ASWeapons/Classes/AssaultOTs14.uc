class AssaultOTs14 extends R6AssaultRifle
    abstract;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6_MP1_TextureMenuEquipment.utx PACKAGE=R6_MP1_TextureMenuEquipment
#exec OBJ LOAD FILE=..\Mods\AthenaSword\StaticMeshes\R63rdItalianWeapons_SM.usx PACKAGE=R63rdItalianWeapons_SM

defaultproperties
{
    m_pBulletClass=Class'R6Weapons.ammo9x39mmSP6'
    m_pEmptyShells=Class'R6SFX.R6Shell9mmSP6'
    m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash762mm'
    m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bSilencer=1)
    m_pFPHandsClass=Class'ASWeapons.R61stHandsAssaultOTs14'
    m_pFPWeaponClass=Class'ASWeapons.R61stAssaultOTs14'
    m_eGripType=GRIP_Aug
    m_HUDTexture=Texture'R6_MP1_TextureMenuEquipment.Mp1_Weapons_Hud'
    m_PawnWaitAnimLow="StandAugLow_nt"
    m_PawnWaitAnimHigh="StandAugHigh_nt"
    m_PawnWaitAnimProne="ProneAug_nt"
    m_PawnFiringAnim="StandFireAug"
    m_PawnFiringAnimProne="ProneFireAug"
    m_PawnReloadAnim="StandReloadAug"
    m_PawnReloadAnimTactical="StandTacReloadAug"
    m_PawnReloadAnimProne="ProneReloadAug"
    m_PawnReloadAnimProneTactical="ProneTacReloadAug"
    m_vPositionOffset=(X=-1.0,Y=-4.5,Z=1.0)
    m_HUDTexturePos=(W=32.0,Y=64.0,Z=100.0)
    m_NameID="AssaultOTs14"
    StaticMesh=StaticMesh'R63rdItalianWeapons_SM.AssaultRifles.R63rdOTs14'
}
