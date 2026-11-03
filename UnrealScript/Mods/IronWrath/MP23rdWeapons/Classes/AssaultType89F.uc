class AssaultType89F extends R6AssaultRifle
    abstract;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2HUD.utx PACKAGE=MP2Hud
#exec OBJ LOAD FILE=..\Mods\IronWrath\StaticMeshes\MP23rdWeapons_SM.usx PACKAGE=MP23rdWeapons_SM

defaultproperties
{
    m_pBulletClass=Class'R6Weapons.ammo556mmNATO'
    m_pEmptyShells=Class'R6SFX.R6Shell556mmNATO'
    m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash556mm'
    m_stWeaponCaps=(bSingle=1,bThreeRound=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1)
    m_pFPHandsClass=Class'MP21stWeapons.MP21stHandsAssaultType89f'
    m_pFPWeaponClass=Class'MP21stWeapons.MP21stAssaultType89F'
    m_HUDTexture=Texture'MP2Hud.MP2_Hud_Weapon'
    m_vPositionOffset=(X=-0.5,Y=-1.5,Z=0.0)
    m_HUDTexturePos=(W=32.0,Y=64.0,Z=100.0)
    m_NameID="AssaultType89F"
    StaticMesh=StaticMesh'MP23rdWeapons_SM.AssaultRifles.R63rdType89f'
}
