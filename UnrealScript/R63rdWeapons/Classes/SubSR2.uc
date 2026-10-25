//============================================================================//
//  SubSR2.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SubSR2 extends R6SubMachineGun
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo9x21mmR'
     m_pEmptyShells=Class'R6SFX.R6Shell9x21mmR'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlashSub'
     m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsSubSR2'
     m_pFPWeaponClass=Class'R61stWeapons.R61stSubSR2'
     m_eGripType=GRIP_Uzi
     m_bUseMicroAnim=True
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandUZILow_nt"
     m_PawnWaitAnimHigh="StandUZIHigh_nt"
     m_PawnWaitAnimProne="ProneUZI_nt"
     m_PawnFiringAnim="StandFireUZI"
     m_PawnFiringAnimProne="ProneFireUZI"
     m_PawnReloadAnim="StandReloadHandGun"
     m_PawnReloadAnimTactical="StandReloadHandGun"
     m_PawnReloadAnimProne="ProneReloadHandGun"
     m_PawnReloadAnimProneTactical="ProneReloadHandGun"
     m_vPositionOffset=(Y=-4.000000,Z=5.500000)
     m_HUDTexturePos=(W=32.000000,Y=288.000000,Z=100.000000)
     m_NameID="SubSR2"
     StaticMesh=StaticMesh'R63rdWeapons_SM.SubGuns.R63rdSubSR2'
}
