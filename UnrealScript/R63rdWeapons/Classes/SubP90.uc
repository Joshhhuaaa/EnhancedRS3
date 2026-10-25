//============================================================================//
//  SubP90.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SubP90 extends R6SubMachineGun
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo57x28mm'
     m_pEmptyShells=Class'R6SFX.R6Shell57mm'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash556mm'
     m_stWeaponCaps=(bSingle=1,bFullAuto=1,bSilencer=1,bLight=1,bMiniScope=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripP90'
     m_pFPWeaponClass=Class'R61stWeapons.R61stSubP90'
     m_eGripType=GRIP_P90
     m_WithScopeSM=StaticMesh'R63rdWeapons_SM.SubGuns.R63rdP90ForScope'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandP90Low_nt"
     m_PawnWaitAnimHigh="StandP90High_nt"
     m_PawnWaitAnimProne="ProneP90_nt"
     m_PawnFiringAnim="StandFireP90"
     m_PawnFiringAnimProne="ProneFireP90"
     m_PawnReloadAnim="StandReloadP90"
     m_PawnReloadAnimTactical="StandTacReloadP90"
     m_PawnReloadAnimProne="ProneReloadP90"
     m_PawnReloadAnimProneTactical="ProneTacReloadP90"
     m_vPositionOffset=(X=-1.000000,Y=-4.000000,Z=2.500000)
     m_HUDTexturePos=(W=32.000000,X=100.000000,Y=288.000000,Z=100.000000)
     m_NameID="SubP90"
     StaticMesh=StaticMesh'R63rdWeapons_SM.SubGuns.R63rdP90'
}
