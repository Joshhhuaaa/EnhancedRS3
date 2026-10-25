//============================================================================//
//  LMG21E.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class LMG21E extends R6MachineGun
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo762mmNATO'
     m_pEmptyShells=Class'R6SFX.R6Shell762mmNATO'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash762mm'
     m_stWeaponCaps=(bFullAuto=1,bLight=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsLMG21E'
     m_pFPWeaponClass=Class'R61stWeapons.R61stLMG21E'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_vPositionOffset=(X=-3.000000,Y=-0.500000,Z=-1.000000)
     m_HUDTexturePos=(W=32.000000,Y=128.000000,Z=100.000000)
     m_NameID="LMG21E"
     StaticMesh=StaticMesh'R63rdWeapons_SM.MachineGuns.R63rd21E'
}
