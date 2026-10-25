//=============================================================================
//  R6ArrowUpIcon.uc : Up arrow for planning only.
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Joel Tremblay
//=============================================================================

class R6ArrowIcon extends R6ReferenceIcons 
    notplaceable;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

var vector m_vPointToReach;
var vector m_vStartLocation;

state FollowPath
{
    function tick(float DeltaTime)
    {
        if(Physics == PHYS_Rotating)
        {
            if((Abs(DesiredRotation.Yaw - (Rotation.Yaw & 65535)) < 20) &&
               (Abs(DesiredRotation.Pitch - (Rotation.Pitch & 65535)) < 20))
            {
                R6PlanningPawn(owner).ArrowRotationIsOK();
            }
        }
        else
        {
            if(VSize(m_vPointToReach - m_vStartLocation) < VSize(Location - m_vStartLocation))
            {
                R6PlanningPawn(owner).ArrowReachedNavPoint();
            }
        }
        m_u8SpritePlanningAngle = Rotation.Yaw / 255 + 64;
    }
    function EndState()
    {
        //Hide and stop the arrow
        m_bSpriteShowOver=false;
        Velocity = vect(0,0,0);
    }
    
    function BeginState()
    {
        m_bSpriteShowOver=true;
    }
}

defaultproperties
{
     Physics=PHYS_Projectile
     bHidden=True
     bIgnoreOutOfWorld=True
     bRotateToDesired=True
     m_bSpriteShownIn3DInPlanning=True
     DrawScale=1.250000
     Texture=Texture'R6Planning.Icons.PlanIcon_Arrow'
     RotationRate=(Yaw=5000)
}
