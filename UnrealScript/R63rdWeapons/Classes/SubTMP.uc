//============================================================================//
//  SubTMP.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SubTMP extends R6SubMachineGun
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellum'
     m_pEmptyShells=Class'R6SFX.R6Shell9mmParabellum'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlashSub'
     m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsSubTMP'
     m_pFPWeaponClass=Class'R61stWeapons.R61stSubTMP'
     m_eGripType=GRIP_Aug
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandP90Low_nt"
     m_PawnWaitAnimHigh="StandP90High_nt"
     m_PawnWaitAnimProne="ProneP90_nt"
     m_PawnFiringAnim="StandFireP90"
     m_PawnFiringAnimProne="ProneFireP90"
     m_PawnReloadAnim="StandReloadHandGun"
     m_PawnReloadAnimTactical="StandReloadHandGun"
     m_PawnReloadAnimProne="ProneReloadHandGun"
     m_PawnReloadAnimProneTactical="ProneReloadHandGun"
     m_vPositionOffset=(X=6.000000,Y=-4.000000,Z=8.000000)
     m_HUDTexturePos=(W=32.000000,X=400.000000,Y=256.000000,Z=100.000000)
     m_NameID="SubTMP"
     StaticMesh=StaticMesh'R63rdWeapons_SM.SubGuns.R63rdTMP'
}
