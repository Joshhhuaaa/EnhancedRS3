//============================================================================//
//  R6SubMachineGun.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6SubMachineGun extends R6Weapons
    Abstract;

defaultproperties
{
     m_eRateOfFire=ROF_FullAuto
     m_eWeaponType=WT_Sub
     m_ShellSingleFireSnd=Sound'CommonSMG.Play_SMG_SingleShells'
     m_ShellBurstFireSnd=Sound'CommonSMG.Play_SMG_TripleShells'
     m_ShellEndFullAutoSnd=Sound'CommonSMG.Play_SMG_EndShells'
     m_AttachPoint="TagRightHand"
     m_HoldAttachPoint="TagBack"
}
