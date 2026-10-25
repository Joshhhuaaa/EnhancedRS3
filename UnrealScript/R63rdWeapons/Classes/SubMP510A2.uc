//============================================================================//
//  SubMP510A2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SubMP510A2 extends R6SubMachineGun
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo10mmAuto'
     m_pEmptyShells=Class'R6SFX.R6Shell10mmAuto'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlashSub'
     m_stWeaponCaps=(bSingle=1,bThreeRound=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1,bMiniScope=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripMP5'
     m_pFPWeaponClass=Class'R61stWeapons.R61stSubMp510A2'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandBullPupLow_nt"
     m_PawnWaitAnimHigh="StandBullPupHigh_nt"
     m_PawnWaitAnimProne="ProneBullPup_nt"
     m_PawnFiringAnim="StandFireBullPup"
     m_PawnFiringAnimProne="ProneFireBullPup"
     m_vPositionOffset=(X=-2.000000,Y=-1.000000,Z=0.500000)
     m_HUDTexturePos=(W=32.000000,X=143.000000,Y=417.000000,Z=100.000000)
     m_NameID="SubMP510A2"
     StaticMesh=StaticMesh'R63rdWeapons_SM.SubGuns.R63rdMp5A4'
}
