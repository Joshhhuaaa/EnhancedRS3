//============================================================================//
//  R6AssaultRifle.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6AssaultRifle extends R6Weapons
    Abstract;

defaultproperties
{
     m_eRateOfFire=ROF_FullAuto
     m_eWeaponType=WT_Assault
     m_ShellSingleFireSnd=Sound'CommonAssaultRiffles.Play_Assault_SingleShell'
     m_ShellBurstFireSnd=Sound'CommonAssaultRiffles.Play_Assault_TripleShells'
     m_ShellEndFullAutoSnd=Sound'CommonAssaultRiffles.Play_Assault_EndShells'
     m_AttachPoint="TagRightHand"
     m_HoldAttachPoint="TagBack"
}
