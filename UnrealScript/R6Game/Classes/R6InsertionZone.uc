//=============================================================================
//  R6InsertionZone.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/12 * Created by Chaouky Garram
//=============================================================================
class R6InsertionZone extends R6AbstractInsertionZone
    placeable;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

defaultproperties
{
     bHidden=False
     m_bUseR6Availability=True
     bUnlit=True
     Texture=Texture'R6Planning.Icons.PlanIcon_ZoneDefault'
     m_PlanningColor=(B=181,G=134,R=24)
}
