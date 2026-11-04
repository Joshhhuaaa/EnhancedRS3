class SubSpectreM4 extends R6SubMachineGun
    abstract;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6_MP1_TextureMenuEquipment.utx PACKAGE=R6_MP1_TextureMenuEquipment
#exec OBJ LOAD FILE=..\Mods\AthenaSword\StaticMeshes\R63rdItalianWeapons_SM.usx PACKAGE=R63rdItalianWeapons_SM

defaultproperties
{
    m_pBulletClass=Class'R6Weapons.ammo9mmParabellum'
    m_pEmptyShells=Class'R6SFX.R6Shell9mmParabellum'
    m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlashSub'
    m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1)
    m_pFPHandsClass=Class'ASWeapons.R61stHandsSubSpectreM4'
    m_pFPWeaponClass=Class'ASWeapons.R61stSubSpectreM4'
    m_eGripType=GRIP_Aug
    m_HUDTexture=Texture'R6_MP1_TextureMenuEquipment.Mp1_Weapons_Hud'
    m_PawnWaitAnimLow="StandAugLow_nt"
    m_PawnWaitAnimHigh="StandAugHigh_nt"
    m_PawnWaitAnimProne="ProneAug_nt"
    m_PawnFiringAnim="StandFireAug"
    m_PawnFiringAnimProne="ProneFireAug"
    m_vPositionOffset=(X=0.0,Y=-2.0,Z=3.0)
    m_HUDTexturePos=(W=32.0,Y=96.0,Z=100.0)
    m_NameID="SubSpectreM4"
    StaticMesh=StaticMesh'R63rdItalianWeapons_SM.SubGuns.R63rdSpectreM4'
}
