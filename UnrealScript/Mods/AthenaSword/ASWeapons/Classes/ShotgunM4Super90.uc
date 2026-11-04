class ShotgunM4Super90 extends R6PumpShotgun
    abstract;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6_MP1_TextureMenuEquipment.utx PACKAGE=R6_MP1_TextureMenuEquipment
#exec OBJ LOAD FILE=..\Mods\AthenaSword\StaticMeshes\R63rdItalianWeapons_SM.usx PACKAGE=R63rdItalianWeapons_SM

defaultproperties
{
    m_pBulletClass=Class'R6Weapons.ammo12gauge'
    m_pEmptyShells=Class'R6SFX.R6Shell12GaugeBuck'
    m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash12Gauge'
    m_stWeaponCaps=(bSingle=1,bLight=1,bMiniScope=1)
    m_pFPHandsClass=Class'R61stWeapons.R61stHandsShotgunM1'
    m_pFPWeaponClass=Class'ASWeapons.R61stShotgunM4Super90'
    m_HUDTexture=Texture'R6_MP1_TextureMenuEquipment.Mp1_Weapons_Hud'
    m_vPositionOffset=(X=-13.8,Y=-2.5,Z=6.5)
    m_HUDTexturePos=(W=32.0,Y=32.0,Z=100.0)
    m_NameID="ShotgunM4Super90"
    StaticMesh=StaticMesh'R63rdItalianWeapons_SM.Shotguns.R63rdM4_Super90'
}
