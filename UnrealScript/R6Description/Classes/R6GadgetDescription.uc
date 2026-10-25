//=============================================================================
//  R6GadgetDescription.uc : This is mainly to accelerate the foreach search 
//                           when populating menu lists
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/22 * Created by Alexandre Dionne
//=============================================================================


class R6GadgetDescription extends R6Description;

defaultproperties
{
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.GadgetNone1'
     m_2dMenuRegion=(W=64,H=56)
     m_NameTag="NONE"
}
