//=============================================================================
//  R6ActionSpot.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/13 * Created by Guillaume Borgia
//=============================================================================
class R6ActionSpot extends Actor
	placeable
    native;


#exec Texture Import File=Textures\ASInvest.pcx Name=ASInvest Mips=Off MASKED=1
#exec Texture Import File=Textures\ASCover.pcx Name=ASCover Mips=Off MASKED=1
#exec Texture Import File=Textures\ASFire.pcx Name=ASFire Mips=Off MASKED=1
#exec Texture Import File=Textures\ASBase.pcx Name=ASBase Mips=Off MASKED=1

var     BOOL        m_bValidTarget;
var()   BOOL        m_bInvestigate;
var()   EStance     m_eCover;
var()   EStance     m_eFire;

var     INT             m_iLastInvestigateID;
var     NavigationPoint m_Anchor;
var     Pawn            m_pCurrentUser;
var     R6ActionSpot    m_NextSpot;

simulated function FirstPassReset()
{
    m_pCurrentUser = none;
}

defaultproperties
{
     m_bInvestigate=True
     bStatic=True
     bHidden=True
     bCollideWhenPlacing=True
     bDirectional=True
     CollisionRadius=80.000000
     CollisionHeight=135.000000
     Texture=Texture'Engine.ASBase'
}
