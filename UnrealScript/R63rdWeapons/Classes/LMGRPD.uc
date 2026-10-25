//============================================================================//
//  LMGRPD.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class LMGRPD extends R6MachineGun
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo762mmM43'
     m_pEmptyShells=Class'R6SFX.R6Shell762mmm43'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash762mm'
     m_stWeaponCaps=(bFullAuto=1,bLight=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsLMGRPD'
     m_pFPWeaponClass=Class'R61stWeapons.R61stLMGRPD'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_vPositionOffset=(X=-9.500000,Y=-1.500000,Z=2.000000)
     m_HUDTexturePos=(W=32.000000,X=100.000000,Y=96.000000,Z=100.000000)
     m_NameID="LMGRPD"
     StaticMesh=StaticMesh'R63rdWeapons_SM.MachineGuns.R63rdRPD'
}
