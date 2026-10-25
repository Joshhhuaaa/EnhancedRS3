//=============================================================================
//  R6BulletDescription.uc : This is mainly to accelerate the foreach search 
//                           when populating menu lists
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/22 * Created by Alexandre Dionne
//=============================================================================


class R6BulletDescription extends R6Description;


var string m_SubsonicClassName; //Class of item to spawn if the gun is silenced
                                //if not use m_ClassName of R6Description

defaultproperties
{
     m_2DMenuTexture=Texture'R6TextureMenuEquipment.PrimaryNone2'
     m_2dMenuRegion=(W=64,H=34)
     m_NameTag="NONE"
}
