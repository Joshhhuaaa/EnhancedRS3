//============================================================================//
//  PistolCZ61.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class PistolCZ61 extends R6Pistol
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo765mmAuto'
     m_pEmptyShells=Class'R6SFX.R6Shell765mmAuto'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash9mm'
     m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bLight=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsPistolCZ61'
     m_pFPWeaponClass=Class'R61stWeapons.R61stPistolCZ61'
     m_eGripType=GRIP_P90
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandP90Low_nt"
     m_PawnWaitAnimHigh="StandP90High_nt"
     m_PawnWaitAnimProne="ProneP90_nt"
     m_PawnFiringAnim="StandFireP90"
     m_PawnFiringAnimProne="ProneFireP90"
     m_PawnReloadAnim="StandReloadSubGun"
     m_PawnReloadAnimTactical="StandTacReloadSubGun"
     m_PawnReloadAnimProne="ProneReloadSubGun"
     m_PawnReloadAnimProneTactical="ProneTacReloadSubGun"
     m_vPositionOffset=(X=-3.500000,Y=-4.500000,Z=6.500000)
     m_HUDTexturePos=(W=32.000000,X=400.000000,Y=160.000000,Z=100.000000)
     m_NameID="PistolCZ61"
     StaticMesh=StaticMesh'R63rdWeapons_SM.Pistols.R63rdPistolCZ61'
}
