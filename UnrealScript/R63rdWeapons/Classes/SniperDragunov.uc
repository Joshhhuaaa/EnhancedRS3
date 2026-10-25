//============================================================================//
//  SniperDragunov.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SniperDragunov extends R6SniperRifle
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo762x54mmR'
     m_pEmptyShells=Class'R6SFX.R6Shell762mmNATO'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash762mm'
     m_stWeaponCaps=(bSingle=1,bSilencer=1,bLight=1,bHeatVision=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsSniperDragunov'
     m_pFPWeaponClass=Class'R61stWeapons.R61stSniperDragunov'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandLMGLow_nt"
     m_PawnWaitAnimHigh="StandLMGHigh_nt"
     m_PawnWaitAnimProne="ProneSniper_nt"
     m_PawnFiringAnim="StandFireLmg"
     m_PawnFiringAnimProne="ProneBipodFireSniper"
     m_PawnReloadAnimProne="ProneReloadSniper"
     m_PawnReloadAnimProneTactical="ProneTacReloadSniper"
     m_vPositionOffset=(Z=-2.000000)
     m_HUDTexturePos=(W=32.000000,Y=256.000000,Z=100.000000)
     m_NameID="SniperDragunov"
     StaticMesh=StaticMesh'R63rdWeapons_SM.SniperRifles.R63rdDragunov'
}
