//============================================================================//
//  AssaultAUG.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class AssaultAUG extends R6AssaultRifle
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_pBulletClass=Class'R6Weapons.ammo556mmNATO'
     m_pEmptyShells=Class'R6SFX.R6Shell556mmNATO'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash556mm'
     m_stWeaponCaps=(bSingle=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripAUG'
     m_pFPWeaponClass=Class'R61stWeapons.R61stAssaultAUG'
     m_eGripType=GRIP_Aug
     m_fMaxZoom=2.500000
     m_ScopeTexture=Texture'Inventory_t.Scope.ScopeBlurTex_Aug'
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
     m_vPositionOffset=(X=-2.500000,Y=-3.500000,Z=4.500000)
     m_HUDTexturePos=(W=32.000000,X=300.000000,Y=64.000000,Z=100.000000)
     m_NameID="AssaultAUG"
     StaticMesh=StaticMesh'R63rdWeapons_SM.AssaultRifles.R63rdAUG'
}
