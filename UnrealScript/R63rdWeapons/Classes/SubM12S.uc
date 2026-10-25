//============================================================================//
//  SubM12S.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SubM12S extends R6SubMachineGun
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellum'
     m_pEmptyShells=Class'R6SFX.R6Shell9mmParabellum'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlashSub'
     m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1,bMiniScope=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsSubM12S'
     m_pFPWeaponClass=Class'R61stWeapons.R61stSubM12S'
     m_eGripType=GRIP_Aug
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandAugLow_nt"
     m_PawnWaitAnimHigh="StandAugHigh_nt"
     m_PawnWaitAnimProne="ProneAug_nt"
     m_PawnFiringAnim="StandFireAug"
     m_PawnFiringAnimProne="ProneFireAug"
     m_vPositionOffset=(X=3.500000,Y=-4.000000,Z=5.500000)
     m_HUDTexturePos=(W=32.000000,X=300.000000,Y=320.000000,Z=100.000000)
     m_NameID="SubM12S"
     StaticMesh=StaticMesh'R63rdWeapons_SM.SubGuns.R63rdM12S'
}
