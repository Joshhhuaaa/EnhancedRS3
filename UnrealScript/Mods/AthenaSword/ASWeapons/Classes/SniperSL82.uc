class SniperSL82 extends R6SniperRifle
    abstract;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6_MP1_TextureMenuEquipment.utx PACKAGE=R6_MP1_TextureMenuEquipment
#exec OBJ LOAD FILE=..\Mods\AthenaSword\StaticMeshes\R63rdItalianWeapons_SM.usx PACKAGE=R63rdItalianWeapons_SM

defaultproperties
{
    m_pBulletClass=Class'R6Weapons.ammo556mmNATO'
    m_pEmptyShells=Class'R6SFX.R6Shell556mmNATO'
    m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash556mm'
    m_stWeaponCaps=(bSingle=1,bSilencer=1,bLight=1,bHeatVision=1)
    m_pFPHandsClass=Class'ASWeapons.R61stHandsSniperSL82'
    m_pFPWeaponClass=Class'ASWeapons.R61stSniperSL82'
    m_HUDTexture=Texture'R6_MP1_TextureMenuEquipment.Mp1_Weapons_Hud'
    m_PawnWaitAnimLow="StandLMGLow_nt"
    m_PawnWaitAnimHigh="StandLMGHigh_nt"
    m_PawnWaitAnimProne="ProneSniper_nt"
    m_PawnFiringAnim="StandFireLmg"
    m_PawnFiringAnimProne="ProneBipodFireSniper"
    m_PawnReloadAnimProne="ProneReloadSniper"
    m_PawnReloadAnimProneTactical="ProneTacReloadSniper"
    m_vPositionOffset=(X=2.0,Y=0.5,Z=-7.5)
    m_HUDTexturePos=(W=32.0,X=100.0,Y=32.0,Z=100.0)
    m_NameID="SniperSL82"
    StaticMesh=StaticMesh'R63rdItalianWeapons_SM.SniperRifles.R63rdSL8_2'
}
