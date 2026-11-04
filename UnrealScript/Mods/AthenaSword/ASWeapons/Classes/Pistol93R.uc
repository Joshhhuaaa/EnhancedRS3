class Pistol93R extends R6Pistol
    abstract;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6_MP1_TextureMenuEquipment.utx PACKAGE=R6_MP1_TextureMenuEquipment
#exec OBJ LOAD FILE=..\Mods\AthenaSword\StaticMeshes\R63rdItalianWeapons_SM.usx PACKAGE=R63rdItalianWeapons_SM

defaultproperties
{
    m_pBulletClass=Class'R6Weapons.ammo9mmParabellum'
    m_pEmptyShells=Class'R6SFX.R6Shell9mmParabellum'
    m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash9mm'
    m_stWeaponCaps=(bSingle=1,bThreeRound=1,bCMag=1,bSilencer=1,bLight=1)
    m_pFPHandsClass=Class'ASWeapons.R61stHandsPistol93R'
    m_pFPWeaponClass=Class'ASWeapons.R61stPistol93R'
    m_HUDTexture=Texture'R6_MP1_TextureMenuEquipment.Mp1_Weapons_Hud'
    m_vPositionOffset=(X=0.0,Y=-5.0,Z=4.5)
    m_HUDTexturePos=(W=32.0,Z=100.0)
    m_NameID="Pistol93R"
    m_szMagazineClass="ASWeapons.R63rdMAG93R"
    StaticMesh=StaticMesh'R63rdItalianWeapons_SM.Pistols.R63rd93R'
}
