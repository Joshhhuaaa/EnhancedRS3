//============================================================================//
//  ShotgunM1.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class ShotgunM1 extends R6PumpShotgun
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo12gauge'
     m_pEmptyShells=Class'R6SFX.R6Shell12GaugeBuck'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash12Gauge'
     m_stWeaponCaps=(bSingle=1,bLight=1,bMiniScope=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsShotgunM1'
     m_pFPWeaponClass=Class'R61stWeapons.R61stShotgunM1'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_vPositionOffset=(X=-13.800000,Y=-2.500000,Z=6.000000)
     m_HUDTexturePos=(W=32.000000,X=400.000000,Y=192.000000,Z=100.000000)
     m_NameID="ShotgunM1"
     StaticMesh=StaticMesh'R63rdWeapons_SM.Shotguns.R63rdM1'
}
