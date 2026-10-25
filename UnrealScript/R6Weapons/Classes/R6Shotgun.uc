//============================================================================//
//  R6Shotgun.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6Shotgun extends R6Weapons
    Abstract;

function INT NbBulletToShot()
{
    if((m_pBulletClass != none) && (m_pBulletClass.Default.m_szBulletType == "BUCK"))
    {
        // 9  bullets are shot with buckshoot ammo
        return 9;
    }
    return 1;
}

defaultproperties
{
     m_eWeaponType=WT_ShotGun
     m_eGripType=GRIP_ShotGun
     m_ShellSingleFireSnd=Sound'CommonShotguns.Play_Shotgun_SingleShell'
     m_ShellEndFullAutoSnd=Sound'CommonShotguns.Play_Shotgun_EndShell'
     m_PawnWaitAnimLow="StandShotGunLow_nt"
     m_PawnWaitAnimHigh="StandShotGunHigh_nt"
     m_PawnWaitAnimProne="ProneShotGun_nt"
     m_PawnFiringAnim="StandFireShotGun"
     m_AttachPoint="TagRightHand"
     m_HoldAttachPoint="TagBack"
}
