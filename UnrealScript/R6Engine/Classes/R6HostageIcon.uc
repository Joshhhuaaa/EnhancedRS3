//=============================================================================
//  R6HostageIcon.uc : down arrow for planning only.
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Joel Tremblay
//=============================================================================

class R6HostageIcon extends R6ReferenceIcons 
    placeable;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

defaultproperties
{
     bStatic=True
     Texture=Texture'R6Planning.Icons.PlanIcon_KnownHostage'
}
