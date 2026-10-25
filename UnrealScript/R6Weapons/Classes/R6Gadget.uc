//=============================================================================
//  R6Gadget.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/05 * Created by Rima Brek
//=============================================================================
class R6Gadget extends R6Weapons
	native
	abstract;

simulated function TurnOffEmitters(BOOL bTurnOff){}

simulated function DisableWeaponOrGadget()
{
	if(bShowLog) log(self$" DisableWeaponOrGadget() was called...");
}

function SetHoldAttachPoint()
{
    if (m_InventoryGroup == 4)
    {
        m_HoldAttachPoint = m_HoldAttachPoint2;
    }
}

function GiveMoreAmmo()
{
    m_iNbBulletsInWeapon += m_iClipCapacity;
}

defaultproperties
{
     m_stAccuracyValues=(fBaseAccuracy=0.100000,fShuffleAccuracy=0.100000,fWalkingAccuracy=0.100000,fWalkingFastAccuracy=0.100000,fRunningAccuracy=0.100000,fAccuracyChange=1.000000,fWeaponJump=1.000000)
     m_eWeaponType=WT_Gadget
     m_eGripType=GRIP_None
     m_InventoryGroup=3
     m_HoldAttachPoint="TagItemBack1"
     m_HoldAttachPoint2="TagItemBack2"
}
