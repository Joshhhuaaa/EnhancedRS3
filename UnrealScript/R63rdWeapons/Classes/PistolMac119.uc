//============================================================================//
//  PistolMac119.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class PistolMac119 extends R6Pistol
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellum'
     m_pEmptyShells=Class'R6SFX.R6Shell9mmParabellum'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash9mm'
     m_stWeaponCaps=(bFullAuto=1,bCMag=1,bLight=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsPistolMac119'
     m_pFPWeaponClass=Class'R61stWeapons.R61stPistolMac119'
     m_eGripType=GRIP_Uzi
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandUZILow_nt"
     m_PawnWaitAnimHigh="StandUZIHigh_nt"
     m_PawnWaitAnimProne="ProneUZI_nt"
     m_PawnFiringAnim="StandFireUZI"
     m_PawnFiringAnimProne="ProneFireUZI"
     m_vPositionOffset=(X=-9.000000,Y=-5.000000,Z=6.000000)
     m_HUDTexturePos=(W=32.000000,X=200.000000,Y=160.000000,Z=100.000000)
     m_NameID="PistolMac119"
     StaticMesh=StaticMesh'R63rdWeapons_SM.Pistols.R63rdPistolMac119'
}
