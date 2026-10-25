//=============================================================================
//  R6DZoneRandomPointNode.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/26 * Created by Guillaume Borgia
//=============================================================================
class R6DZoneRandomPointNode extends Actor
	placeable
    native;

var(R6DZone)    BOOL                m_bHighPriority;
var(R6DZone)    BOOL                m_bAllowLeave;
var(R6DZone)    EStance             m_eStance;
var(R6DZone)    INT                 m_iGroupID;
var             R6DZoneRandomPoints m_pZone;

defaultproperties
{
     m_eStance=STAN_Standing
     m_bAllowLeave=True
     bHidden=True
     m_bUseR6Availability=True
     bDirectional=True
     CollisionRadius=40.000000
     CollisionHeight=85.000000
     Texture=Texture'R6Engine_T.Icons.DZoneTer'
}
