//============================================================================//
//  SniperVSSVintorez.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SniperVSSVintorez extends R6SniperRifle
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo9x39mmSP6'
     m_pEmptyShells=Class'R6SFX.R6Shell9mmSP6'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash762mm'
     m_stWeaponCaps=(bSingle=1,bFullAuto=1,bLight=1,bHeatVision=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsSniperVSSVintorez'
     m_pFPWeaponClass=Class'R61stWeapons.R61stSniperVSSVintorez'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandLMGLow_nt"
     m_PawnWaitAnimHigh="StandLMGHigh_nt"
     m_PawnWaitAnimProne="ProneSniper_nt"
     m_PawnFiringAnim="StandFireLmg"
     m_PawnFiringAnimProne="ProneBipodFireSniper"
     m_PawnReloadAnimProne="ProneReloadSniper"
     m_PawnReloadAnimProneTactical="ProneTacReloadSniper"
     m_vPositionOffset=(X=-4.000000,Y=1.000000,Z=-1.500000)
     m_HUDTexturePos=(W=32.000000,X=100.000000,Y=224.000000,Z=100.000000)
     m_NameID="SniperVSSVintorez"
     StaticMesh=StaticMesh'R63rdWeapons_SM.SniperRifles.R63rdVSSVintorez'
}
