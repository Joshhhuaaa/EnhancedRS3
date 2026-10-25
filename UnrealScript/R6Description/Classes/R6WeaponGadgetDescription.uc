//=============================================================================
//  R6WeaponGadgetDescription.uc : This is mainly to accelerate the foreach search 
//                           when populating menu lists
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/24 * Created by Alexandre Dionne
//=============================================================================


class R6WeaponGadgetDescription extends R6Description;

var BOOL m_bPriGadgetWAvailable;
var BOOL m_bSecGadgetWAvailable;

defaultproperties
{
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.PrimaryNone3'
     m_2dMenuRegion=(W=64,H=42)
     m_NameTag="NONE"
}
