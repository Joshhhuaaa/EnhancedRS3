//=============================================================================
//  R6CameraDirection.uc : Sniper icon in the planning phase.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/15 * Created by Joel Tremblay
//=============================================================================
class R6CameraDirection extends R6ReferenceIcons
    notplaceable;

function SetPlanningRotation(Rotator PointRotation)
{
    m_u8SpritePlanningAngle = PointRotation.Yaw / 255;
}

defaultproperties
{
     bHidden=True
     DrawScale=6.000000
     Texture=Texture'R6Planning.Icons.PlanIcon_CamDirection'
}
