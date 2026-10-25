//=============================================================================
//  R6DZonePoint.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/11 * Created by Guillaume Borgia
//=============================================================================

class R6DZonePoint extends R6DeploymentZone
	placeable
    native;

var(R6DZone)    EStance m_eStance;

var(R6DZone)    vector  m_vReactionZoneCenter;
var(R6DZone)    BOOL    m_bUseReactionZone;
var(R6DZone)    FLOAT   m_fReactionZoneX;
var(R6DZone)    FLOAT   m_fReactionZoneY;

defaultproperties
{
     m_fReactionZoneX=300.000000
     m_fReactionZoneY=300.000000
     bDirectional=True
}
