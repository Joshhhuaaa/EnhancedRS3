//============================================================================//
//  SubMP5KPDW.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SubMP5KPDW extends R6SubMachineGun
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellum'
     m_pEmptyShells=Class'R6SFX.R6Shell9mmParabellum'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlashSub'
     m_stWeaponCaps=(bSingle=1,bThreeRound=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1,bMiniScope=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsSubMp5KPDW'
     m_pFPWeaponClass=Class'R61stWeapons.R61stSubMp5KPDW'
     m_eGripType=GRIP_Aug
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandAugLow_nt"
     m_PawnWaitAnimHigh="StandAugHigh_nt"
     m_PawnWaitAnimProne="ProneAug_nt"
     m_PawnFiringAnim="StandFireAug"
     m_PawnFiringAnimProne="ProneFireAug"
     m_PawnReloadAnim="StandReloadAug"
     m_PawnReloadAnimTactical="StandTacReloadAug"
     m_PawnReloadAnimProne="ProneReloadAug"
     m_PawnReloadAnimProneTactical="ProneTacReloadAug"
     m_vPositionOffset=(X=-5.000000,Y=-4.500000,Z=4.000000)
     m_HUDTexturePos=(W=32.000000,X=400.000000,Y=288.000000,Z=100.000000)
     m_NameID="SubMP5KPDW"
     StaticMesh=StaticMesh'R63rdWeapons_SM.SubGuns.R63rdMp5KPDW'
}
