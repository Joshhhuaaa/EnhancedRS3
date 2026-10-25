//============================================================================//
//  SubUMP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SubUMP extends R6SubMachineGun
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo45calAuto'
     m_pEmptyShells=Class'R6SFX.R6Shell45calAuto'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlashSub'
     m_stWeaponCaps=(bSingle=1,bThreeRound=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1,bMiniScope=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsSubUMP'
     m_pFPWeaponClass=Class'R61stWeapons.R61stSubUMP'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandBullPupLow_nt"
     m_PawnWaitAnimHigh="StandBullPupHigh_nt"
     m_PawnWaitAnimProne="ProneBullPup_nt"
     m_PawnFiringAnim="StandFireBullPup"
     m_PawnFiringAnimProne="ProneFireBullPup"
     m_vPositionOffset=(X=6.000000,Y=-1.000000,Z=-1.000000)
     m_HUDTexturePos=(W=32.000000,X=300.000000,Y=256.000000,Z=100.000000)
     m_NameID="SubUMP"
     StaticMesh=StaticMesh'R63rdWeapons_SM.SubGuns.R63rdUMP'
}
