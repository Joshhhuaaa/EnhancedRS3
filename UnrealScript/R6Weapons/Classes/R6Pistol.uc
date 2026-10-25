//============================================================================//
//  R6Pistol.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6Pistol extends R6Weapons
    Abstract;

//Red weapon if ASE does not exist
#exec OBJ LOAD FILE="..\Textures\Color.utx" PACKAGE=Color 
#exec NEW StaticMesh FILE="models\RedPistol.ASE" NAME="RedPistolStaticMesh" Yaw=32678

defaultproperties
{
     m_fRateOfFire=0.166667
     m_eGripType=GRIP_HandGun
     m_InventoryGroup=2
     m_FPMuzzleFlashTexture=Texture'R6SFX_T.Muzzleflash.1stMuzzle_B'
     m_ShellSingleFireSnd=Sound'CommonPistols.Play_Pistol_SingleShells'
     m_ShellEndFullAutoSnd=Sound'CommonPistols.Play_Pistol_EndShell'
     m_PawnWaitAnimLow="StandHandGunLow_nt"
     m_PawnWaitAnimHigh="StandHandGunHigh_nt"
     m_PawnWaitAnimProne="ProneHandGun_nt"
     m_PawnFiringAnim="StandFireHandGun"
     m_PawnFiringAnimProne="ProneFireHandGun"
     m_PawnReloadAnim="StandReloadHandGun"
     m_PawnReloadAnimTactical="StandReloadHandGun"
     m_PawnReloadAnimProne="ProneReloadHandGun"
     m_PawnReloadAnimProneTactical="ProneReloadHandGun"
     m_AttachPoint="TagRightHand"
     m_HoldAttachPoint="TagHolster"
     m_szMagazineClass="R63rdWeapons.R63rdMAGPistol"
     StaticMesh=StaticMesh'R6Weapons.RedPistolStaticMesh'
}
