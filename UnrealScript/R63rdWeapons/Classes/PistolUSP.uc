//============================================================================//
//  PistolUSP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class PistolUSP extends R6Pistol
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo40calAuto'
     m_pEmptyShells=Class'R6SFX.R6Shell40calAuto'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash9mm'
     m_stWeaponCaps=(bSingle=1,bCMag=1,bSilencer=1,bLight=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripPistol'
     m_pFPWeaponClass=Class'R61stWeapons.R61stPistolUSP'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_vPositionOffset=(Y=-5.000000,Z=4.000000)
     m_HUDTexturePos=(W=32.000000,X=100.000000,Y=128.000000,Z=100.000000)
     m_NameID="PistolUSP"
     StaticMesh=StaticMesh'R63rdWeapons_SM.Pistols.R63rdUSP'
}
