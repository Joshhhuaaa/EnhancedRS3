//=============================================================================
//  R6ArmorDescription.uc : This is mainly to accelerate the foreach search 
//                           when populating menu lists
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/22 * Created by Alexandre Dionne
//=============================================================================


class R6ArmorDescription extends R6Description;

var name m_LimitedToClass; // If the armor can only be used by specific operative.
var bool m_bHideFromMenu;

defaultproperties
{
     m_LimitedToClass="R6Operative"
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.ArmorNone'
     m_2dMenuRegion=(W=133,H=251)
     m_NameTag="NONE"
}
