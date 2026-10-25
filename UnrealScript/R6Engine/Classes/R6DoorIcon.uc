//=============================================================================
//  R6DoorIcon.uc : DoorIcon for planning Only
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/05 * Created by Joel Tremblay
//=============================================================================

class R6DoorIcon extends R6ReferenceIcons
    notplaceable;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

defaultproperties
{
     Texture=Texture'R6Planning.Icons.PlanIcon_Door'
}
