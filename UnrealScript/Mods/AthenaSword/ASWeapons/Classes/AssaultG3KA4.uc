class AssaultG3KA4 extends R6AssaultRifle
    abstract;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6_MP1_TextureMenuEquipment.utx PACKAGE=R6_MP1_TextureMenuEquipment
#exec OBJ LOAD FILE=..\Mods\AthenaSword\StaticMeshes\R63rdItalianWeapons_SM.usx PACKAGE=R63rdItalianWeapons_SM

defaultproperties
{
    m_pBulletClass=Class'R6Weapons.ammo762mmNATO'
    m_pEmptyShells=Class'R6SFX.R6Shell762mmNATO'
    m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash762mm'
    m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1,bMiniScope=1)
    m_pFPHandsClass=Class'ASWeapons.R61stHandsAssaultG3KA4'
    m_pFPWeaponClass=Class'ASWeapons.R61stAssaultG3KA4'
    m_HUDTexture=Texture'R6_MP1_TextureMenuEquipment.Mp1_Weapons_Hud'
    m_HUDTexturePos=(W=32.0,X=100.0,Y=64.0,Z=100.0)
    m_NameID="AssaultG3KA4"
    StaticMesh=StaticMesh'R63rdItalianWeapons_SM.AssaultRifles.R63rdG3KA4'
}
