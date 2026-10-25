//============================================================================//
//  LMGM249.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class LMGM249 extends R6MachineGun
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo556mmNATO'
     m_pEmptyShells=Class'R6SFX.R6Shell556mmNATO'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash556mm'
     m_stWeaponCaps=(bFullAuto=1,bLight=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripLMG'
     m_pFPWeaponClass=Class'R61stWeapons.R61stLMGM249'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_vPositionOffset=(X=-9.500000,Y=-2.500000,Z=2.000000)
     m_HUDTexturePos=(W=32.000000,X=300.000000,Y=96.000000,Z=100.000000)
     m_NameID="LMGM249"
     StaticMesh=StaticMesh'R63rdWeapons_SM.MachineGuns.R63rdM249'
}
