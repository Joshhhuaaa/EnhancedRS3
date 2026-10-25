//============================================================================//
//  SubUzi.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class SubUzi extends R6SubMachineGun
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo9mmParabellum'
     m_pEmptyShells=Class'R6SFX.R6Shell9mmParabellum'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlashSub'
     m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripUZI'
     m_pFPWeaponClass=Class'R61stWeapons.R61stSubUzi'
     m_eGripType=GRIP_BullPup
     m_bUseMicroAnim=True
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_PawnWaitAnimLow="StandBullPupLow_nt"
     m_PawnWaitAnimHigh="StandBullPupHigh_nt"
     m_PawnWaitAnimProne="ProneBullPup_nt"
     m_PawnFiringAnim="StandFireBullPup"
     m_PawnFiringAnimProne="ProneFireBullPup"
     m_PawnReloadAnim="StandReloadHandGun"
     m_PawnReloadAnimTactical="StandReloadHandGun"
     m_PawnReloadAnimProne="ProneReloadHandGun"
     m_PawnReloadAnimProneTactical="ProneReloadHandGun"
     m_vPositionOffset=(X=-0.500000,Y=-2.500000,Z=3.500000)
     m_HUDTexturePos=(W=32.000000,X=200.000000,Y=256.000000,Z=100.000000)
     m_NameID="SubUzi"
     StaticMesh=StaticMesh'R63rdWeapons_SM.SubGuns.R63rdUzi'
}
