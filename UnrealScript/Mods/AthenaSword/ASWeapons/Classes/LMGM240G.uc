class LMGM240G extends R6MachineGun
    abstract;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6_MP1_TextureMenuEquipment.utx PACKAGE=R6_MP1_TextureMenuEquipment
#exec OBJ LOAD FILE=..\Mods\AthenaSword\StaticMeshes\R63rdItalianWeapons_SM.usx PACKAGE=R63rdItalianWeapons_SM

defaultproperties
{
    m_pBulletClass=Class'R6Weapons.ammo762mmNATO'
    m_pEmptyShells=Class'R6SFX.R6Shell762mmNATO'
    m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash762mm'
    m_stWeaponCaps=(bFullAuto=1,bLight=1)
    m_pFPHandsClass=Class'ASWeapons.R61stHandsLMGM240G'
    m_pFPWeaponClass=Class'ASWeapons.R61stLMGM240G'
    m_HUDTexture=Texture'R6_MP1_TextureMenuEquipment.Mp1_Weapons_Hud'
    m_vPositionOffset=(X=-6.5,Y=0.0,Z=1.0)
    m_HUDTexturePos=(W=32.0,X=100.0,Z=100.0)
    m_NameID="LMGM240G"
    StaticMesh=StaticMesh'R63rdItalianWeapons_SM.MachineGuns.R63rdM240G'
}
