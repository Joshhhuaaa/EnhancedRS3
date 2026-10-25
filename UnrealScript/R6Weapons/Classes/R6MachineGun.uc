//============================================================================//
//  R6MachineGun.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6MachineGun extends R6Weapons
    Abstract;

defaultproperties
{
     m_eRateOfFire=ROF_FullAuto
     m_eWeaponType=WT_LMG
     m_eGripType=GRIP_LMG
     m_bBipod=True
     m_ShellFullAutoSnd=Sound'CommonLMGs.Play_LMG_AutoShells'
     m_ShellEndFullAutoSnd=Sound'CommonLMGs.Stop_LMG_AutoShells_Go'
     m_BipodSnd=Sound'Gadget_Bipod.Play_Bipod_Extraction'
     m_PawnWaitAnimLow="StandLMGLow_nt"
     m_PawnWaitAnimHigh="StandLMGHigh_nt"
     m_PawnWaitAnimProne="ProneLMG_nt"
     m_PawnFiringAnim="StandFireLmg"
     m_PawnFiringAnimProne="ProneBipodFireLMG"
     m_PawnReloadAnim="StandReloadLMG"
     m_PawnReloadAnimTactical="StandReloadLMG"
     m_PawnReloadAnimProne="ProneReloadLMG"
     m_PawnReloadAnimProneTactical="ProneReloadLMG"
     m_AttachPoint="TagRightHand"
     m_HoldAttachPoint="TagBack"
}
