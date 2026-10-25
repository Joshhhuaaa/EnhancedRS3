//=============================================================================
//  R6DZoneRectangle.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/11 * Created by Guillaume Borgia
//=============================================================================

class R6DZoneRectangle extends R6DeploymentZone
	placeable
    native;

var(R6DZone)    FLOAT   m_fX;
var(R6DZone)    FLOAT   m_fY;

defaultproperties
{
     m_fX=500.000000
     m_fY=500.000000
}
