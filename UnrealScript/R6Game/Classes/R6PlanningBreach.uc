//=============================================================================
//  R6PlanningBreach.uc : Breach Door icon in the planning phase.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/20 * Created by Joel Tremblay
//=============================================================================
class R6PlanningBreach extends R6ReferenceIcons
    notplaceable;

function SetSpriteAngle(INT iDoorClosedYaw, vector vPointLocation)
{
    local vector vDirection;
    local rotator rPointDoorRotator;
    local INT iYawDifference;

    m_u8SpritePlanningAngle = iDoorClosedYaw / 255;
    rPointDoorRotator = Rotator(vPointLocation - Location);
    if(rPointDoorRotator.Yaw < 0)
    {
        rPointDoorRotator.Yaw += 65536;
    }

    iYawDifference = rPointDoorRotator.Yaw - iDoorClosedYaw;

    if(iYawDifference < 0)
    {
        iYawDifference += 65536;
    }
    //Find the Yaw difference is to determine on which side of the door the character will be standing when he will breach the door.
    // and it sets the icon in the right side of the door.
    if(iYawDifference < 0)
    {
        iYawDifference += 65536;
    }
    if(iYawDifference > 32767)
    {
        vDirection = DrawScale3D;
        vDirection.Y *= -1;
        SetDrawScale3D(vDirection);
    }
}

defaultproperties
{
     m_bSkipHitDetection=False
     Texture=Texture'R6Planning.Icons.PlanIcon_BreachDoor'
}
