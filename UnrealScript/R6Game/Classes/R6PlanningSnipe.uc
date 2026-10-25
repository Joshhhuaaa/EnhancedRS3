//=============================================================================
//  R6PlanningSnipe.uc : Sniper icon in the planning phase.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/15 * Created by Joel Tremblay
//=============================================================================
class R6PlanningSnipe extends R6ReferenceIcons
    notplaceable;

function rotator SetDirectionRotator(vector vTowards)
{
    local rotator rActionRotator;
    local vector  vResultVector;

    //Angle is calculated only on plane Z=0;
    vResultVector = Normal(vTowards - Location);
    rActionRotator = Rotator(vResultVector);

    m_u8SpritePlanningAngle = rActionRotator.Yaw / 255;
    
    return rActionRotator;
}

defaultproperties
{
     DrawScale=2.500000
     Texture=Texture'R6Planning.Icons.PlanIcon_Snipe'
}
