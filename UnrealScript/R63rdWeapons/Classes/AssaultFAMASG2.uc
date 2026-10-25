//============================================================================//
//  AssaultFAMASG2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class AssaultFAMASG2 extends R6AssaultRifle
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo556mmNATO'
     m_pEmptyShells=Class'R6SFX.R6Shell556mmNATO'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash556mm'
     m_stWeaponCaps=(bSingle=1,bThreeRound=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1,bMiniScope=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsAssaultFAMASG2'
     m_pFPWeaponClass=Class'R61stWeapons.R61stAssaultFAMASG2'
     m_eGripType=GRIP_BullPup
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandBullPupLow_nt"
     m_PawnWaitAnimHigh="StandBullPupHigh_nt"
     m_PawnWaitAnimProne="ProneBullPup_nt"
     m_PawnFiringAnim="StandFireBullPup"
     m_PawnFiringAnimProne="ProneFireBullPup"
     m_PawnReloadAnim="StandReloadAug"
     m_PawnReloadAnimTactical="StandTacReloadAug"
     m_PawnReloadAnimProne="ProneReloadAug"
     m_PawnReloadAnimProneTactical="ProneTacReloadAug"
     m_vPositionOffset=(X=-9.000000,Y=-2.000000,Z=-0.500000)
     m_HUDTexturePos=(W=32.000000,X=100.000000,Y=64.000000,Z=100.000000)
     m_NameID="AssaultFAMASG2"
     StaticMesh=StaticMesh'R63rdWeapons_SM.AssaultRifles.R63rdFamasG2'
}
