//=============================================================================
//  R6PlanningGrenade.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/16 * Created by Chaouky Garram
//=============================================================================
class R6PlanningGrenade extends R6ReferenceIcons
    notplaceable;

//#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

var Texture         m_pIconTex[4];      // List of the grenade icon texture


function SetGrenadeType(EPlanAction eGrenade)
{
    Texture = m_pIconTex[eGrenade-1];
}

defaultproperties
{
     m_pIconTex(0)=Texture'R6Planning.Icons.PlanIcon_Frag'
     m_pIconTex(1)=Texture'R6Planning.Icons.PlanIcon_Flash'
     m_pIconTex(2)=Texture'R6Planning.Icons.PlanIcon_Gas'
     m_pIconTex(3)=Texture'R6Planning.Icons.PlanIcon_Smoke'
     m_bSkipHitDetection=False
     DrawScale=1.250000
}
