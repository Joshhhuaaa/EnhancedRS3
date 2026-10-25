//============================================================================//
//  LMGM60E4.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class LMGM60E4 extends R6MachineGun
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo762mmNATO'
     m_pEmptyShells=Class'R6SFX.R6Shell762mmNATO'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash762mm'
     m_stWeaponCaps=(bFullAuto=1,bLight=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsLMGM60E4'
     m_pFPWeaponClass=Class'R61stWeapons.R61stLMGM60E4'
     m_eGripType=GRIP_Aug
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandM60Low_nt"
     m_PawnWaitAnimHigh="StandM60High_nt"
     m_PawnFiringAnim="StandFireM60"
     m_vPositionOffset=(X=-2.500000,Y=-0.500000,Z=-1.500000)
     m_HUDTexturePos=(W=32.000000,X=200.000000,Y=96.000000,Z=100.000000)
     m_NameID="LMGM60E4"
     StaticMesh=StaticMesh'R63rdWeapons_SM.MachineGuns.R63rdM60E4'
}
