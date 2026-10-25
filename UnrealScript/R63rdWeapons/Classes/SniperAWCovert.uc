//============================================================================//
//  SniperAWCovert.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SniperAWCovert extends R6BoltActionSniperRifle
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo762mmNATO'
     m_pEmptyShells=Class'R6SFX.R6Shell762mmNATO'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash762mm'
     m_stWeaponCaps=(bSingle=1,bLight=1,bHeatVision=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripSniper'
     m_pFPWeaponClass=Class'R61stWeapons.R61stSniperAWCovert'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandLMGLow_nt"
     m_PawnWaitAnimHigh="StandLMGHigh_nt"
     m_PawnWaitAnimProne="ProneSniper_nt"
     m_PawnFiringAnim="StandFireAndBoltRifle"
     m_PawnFiringAnimProne="ProneBipodFireAndBoltRifle"
     m_PawnReloadAnimProne="ProneReloadSniper"
     m_PawnReloadAnimProneTactical="ProneTacReloadSniper"
     m_vPositionOffset=(X=-5.500000,Y=0.500000,Z=-1.000000)
     m_HUDTexturePos=(W=32.000000,X=100.000000,Y=256.000000,Z=100.000000)
     m_NameID="SniperAWCovert"
     StaticMesh=StaticMesh'R63rdWeapons_SM.SniperRifles.R63rdAWCovert'
}
