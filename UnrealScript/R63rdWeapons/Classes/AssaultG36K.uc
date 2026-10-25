//============================================================================//
//  AssaultG36K.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class AssaultG36K extends R6AssaultRifle
    Abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

defaultproperties
{
     m_szWithWeaponReticuleClass="WITHWEAPONDOT"
     m_pBulletClass=Class'R6Weapons.ammo556mmNATO'
     m_pEmptyShells=Class'R6SFX.R6Shell556mmNATO'
     m_pMuzzleFlash=Class'R6SFX.R6MuzzleFlash556mm'
     m_stWeaponCaps=(bSingle=1,bThreeRound=1,bFullAuto=1,bCMag=1,bSilencer=1,bLight=1)
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsAssaultG36K'
     m_pFPWeaponClass=Class'R61stWeapons.R61stAssaultG36K'
     m_fMaxZoom=2.500000
     m_ScopeTexture=Texture'Inventory_t.Scope.ScopeBlurTex_TAR'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_vPositionOffset=(X=9.500000,Y=-0.500000,Z=-3.500000)
     m_HUDTexturePos=(W=32.000000,X=400.000000,Y=32.000000,Z=100.000000)
     m_NameID="AssaultG36K"
     StaticMesh=StaticMesh'R63rdWeapons_SM.AssaultRifles.R63rdG36K'
}
