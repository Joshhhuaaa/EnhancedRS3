//============================================================================//
//  ShotgunSPAS12.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class ShotgunSPAS12 extends R6PumpShotgun
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo12gauge'
     m_pEmptyShells=Class'R6SFX.R6Shell12GaugeBuck'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash12Gauge'
     m_stWeaponCaps=(bSingle=1,bLight=1,bMiniScope=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsShotgunSPAS12'
     m_pFPWeaponClass=Class'R61stWeapons.R61stShotgunSPAS12'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_vPositionOffset=(X=-11.000000,Y=-2.500000,Z=2.000000)
     m_HUDTexturePos=(W=32.000000,X=300.000000,Y=192.000000,Z=100.000000)
     m_NameID="ShotgunSPAS12"
     StaticMesh=StaticMesh'R63rdWeapons_SM.Shotguns.R63rdSPAS12'
}
