//============================================================================//
//  SubMicroUzi.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SubMicroUzi extends R6SubMachineGun
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellum'
     m_pEmptyShells=Class'R6SFX.R6Shell9mmParabellum'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlashSub'
     m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsSubMicroUzi'
     m_pFPWeaponClass=Class'R61stWeapons.R61stSubMicroUzi'
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
     m_vPositionOffset=(X=-1.500000,Y=-4.500000,Z=2.500000)
     m_HUDTexturePos=(W=32.000000,X=100.000000,Y=320.000000,Z=100.000000)
     m_NameID="SubMicroUzi"
     StaticMesh=StaticMesh'R63rdWeapons_SM.SubGuns.R63rdSubMicroUzi'
}
