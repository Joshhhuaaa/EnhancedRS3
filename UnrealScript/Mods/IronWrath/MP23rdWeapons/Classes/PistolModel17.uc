class PistolModel17 extends R6Pistol
    abstract;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2HUD.utx PACKAGE=MP2Hud
#exec OBJ LOAD FILE=..\Mods\IronWrath\StaticMeshes\MP23rdWeapons_SM.usx PACKAGE=MP23rdWeapons_SM

defaultproperties
{
    m_pBulletClass=Class'R6Weapons.ammo9mmParabellum'
    m_pEmptyShells=Class'R6SFX.R6Shell9mmParabellum'
    m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash9mm'
    m_stWeaponCaps=(bSingle=1,bCMag=1,bSilencer=1,bLight=1)
    m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripPistol'
    m_pFPWeaponClass=Class'MP21stWeapons.MP21stPistolModel17'
    m_HUDTexture=Texture'MP2Hud.MP2_Hud_Weapon'
    m_vPositionOffset=(X=0.0,Y=-5.0,Z=4.0)
    m_HUDTexturePos=(W=32.0,Z=100.0)
    m_NameID="PistolModel17"
    StaticMesh=StaticMesh'MP23rdWeapons_SM.Pistols.R63rdModel17'
}
